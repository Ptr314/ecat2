unit wd1793;
{
English:

		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.

		Author: Panther <http://www.emuverse.ru/wiki/User:Panther>

Russian:
		Этот файл является свободным программным обеспечением, вы можете
		распространять и изменять его на условиях лицензии GNU General Public
		License, опубликованной Free Software Foundation, версии 3, или
		более поздней, на ваше усмотрение.

		Программа распространяется с надеждой, что она окажется полезной,
		но БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, в том числе подразумеваемых гарантий
		КОММЕРЧЕСКОЙ ЦЕННОСТИ или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ.
		Подробнее смотрите текст лицензии GNU General Public License.

		Копия текста лицензии должна поставляться вместе с этим файлом,
		в противном случае вы можете получить ее по адресу
		<http://www.gnu.org/licenses/>

		Автор: Panther <http://www.emuverse.ru/wiki/User:Panther>
}

interface

uses
		SysUtils,
		Config,
		Utils, Core, fdc, fdd;

type
	TWD1793 = class (TFDC)
	private
		FIAddress: TInterface;
		FIData: TInterface;
		FIINTRQ: TInterface;
		FIDRQ: TInterface;
		FDrives: array [0..3] of TCommonFDD;
		FDrivesCount: Integer;
		FSelectedDrive: Integer;
		FCommand: Integer;
		FDelay: Integer;
		FRegisterDelay: Integer;
		FRegisterToWrite: Cardinal;
		FValueToWrite: Cardinal;
		FSectorSize, FBytes: Integer;
		FStepDir: Integer;
		procedure SetDRQ;
		function GetDRQ:Boolean;
		procedure ClearDRQ;
		procedure SetFlag(Flag: Cardinal);
		procedure ClearFlag(Flag: Cardinal);
		procedure SetINTRQ;
		procedure ClearINTRQ;
		procedure FindSelectedDrive;
		procedure WriteRegister(Address:Cardinal; Value:Cardinal);
	protected
		function GetBusy:Boolean; override;
		function GetSelectedDrive:Cardinal; override;
		function GetValue(Address:Cardinal):Cardinal; override;
		procedure SetValue(Address:Cardinal; Value:Cardinal); override;
	public
		FRegs:array[0..4] of Byte;
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
		procedure Clock(Counter:Cardinal); override;
	end;

const
	wd1793_REG_STATUS  = $00;
	wd1793_REG_COMMAND = $00;
	wd1793_REG_TRACK   = $01;
	wd1793_REG_SECTOR  = $02;
	wd1793_REG_DATA    = $03;

	wd1793_FLAG_BUSY       = $01;
	wd1793_FLAG_DRQ        = $02;
	wd1793_FLAG_INDEX      = $02;
	wd1793_FLAG_TR00       = $04;
	wd1793_FLAG_LOST_DATA  = $04;
	wd1793_FLAG_BAD_CRC    = $08;
	wd1793_FLAG_ERR_SEEK   = $10;
	wd1793_FLAG_HLD        = $20;
	wd1793_FLAG_DATA_TYPE  = $20;
	wd1793_FLAG_ERR_WRITE  = $20;
	wd1793_FLAG_PROTECTED  = $40;
	wd1793_FLAG_NOT_READY  = $80;

	wd1793_PARAM_T = $10;
	wd1793_PARAM_m = $10;
	wd1793_PARAM_h = $08;
	wd1793_PARAM_V = $04;

	//задержка записи значения в регистр
	//Если 0 - эмулятор не проходит некоторые тесты
	//Если слишком большое - не работают программы
	//Все значения задержек - в тактах контроллера
	wd1793_DELAY_REGISTER = 10;

	wd1793_DELAY_RESTORE = 100;
	wd1793_COMMAND_RESTORE = 1;

	wd1793_DELAY_SECTOR = 100;
	wd1793_COMMAND_READ_SECTOR = 2;
	wd1793_COMMAND_WRITE_SECTOR = 3;

	wd1793_DELAY_NEXT_BYTE = 10;
	wd1793_COMMAND_READ_BYTE = 4;
	wd1793_COMMAND_WRITE_BYTE = 5;

	wd1793_DELAY_STEP = 100;
	wd1793_COMMAND_SEEK = 6;
	wd1793_COMMAND_STEP = 7;

implementation

function CreateWD1793(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TWD1793.Create(IM, ConfigDevice);
end;

constructor TWD1793.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIAddress := CreateInterface(2, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_R);
	FIINTRQ := CreateInterface(1, 'intrq', MODE_W);
	FIDRQ := CreateInterface(1, 'drq', MODE_W);

	FDrivesCount := 0;

	FCommand := 0;
	FDelay := 0;
	FRegisterDelay := 0;

	FStepDir := 1;
  
	FillChar(FRegs, SizeOf(FRegs), 0);
end;

procedure TWD1793.LoadConfig;
var S:String;
		Parts: array[0..3] of String;
		i: Integer;
begin
	inherited LoadConfig(SD);
	try
		S := FConfigData.Parameters['drives'].Value;
	except
		raise Exception.Create('В параметрах контроллера '''+Name+''' не задан список дисководов!');
	end;

	FDrivesCount := Explode(Parts, '|', S);
	for i:=0 to FDrivesCount-1 do
		FDrives[i] := IM.DM.GetDeviceByName(Parts[i]) as TCommonFDD;
end;


procedure TWD1793.SetDRQ;
begin
	SetFlag(wd1793_FLAG_DRQ);
	FIDRQ.Change(1);
end;

procedure TWD1793.ClearDRQ;
begin
	ClearFlag(wd1793_FLAG_DRQ);
	FIDRQ.Change(0);
end;

function TWD1793.GetDRQ;
begin
	Result := (FRegs[wd1793_REG_STATUS] and wd1793_FLAG_DRQ) <> 0;
end;

procedure TWD1793.SetFlag(Flag: Cardinal);
begin
	FRegs[wd1793_REG_STATUS] := FRegs[wd1793_REG_STATUS] or Flag;
end;

procedure TWD1793.ClearFlag(Flag: Cardinal);
begin
	FRegs[wd1793_REG_STATUS] := FRegs[wd1793_REG_STATUS] and not Flag;
end;

procedure TWD1793.SetINTRQ;
begin
	FIINTRQ.Change(1);
end;

procedure TWD1793.ClearINTRQ;
begin
	FIINTRQ.Change(0);
end;

function TWD1793.GetValue(Address:Cardinal):Cardinal;
var A: Cardinal;
begin
	A := Address and 3;
	Result := FRegs[A];
	if A=wd1793_REG_DATA then ClearDRQ;
	if A=wd1793_REG_STATUS then ClearINTRQ;
end;

procedure TWD1793.FindSelectedDrive;
var i:Integer;
begin
	for i:=0 to FDrivesCount-1 do
		if FDrives[i].IsSelected then begin
			FSelectedDrive := i;
			exit;
		end;
	//Не найдено
  FSelectedDrive := -1;
	//FIM.DM.Error(Self, 'Контроллер не нашел активный дисковод!');
end;


procedure TWD1793.SetValue(Address:Cardinal; Value:Cardinal);
begin
	if wd1793_DELAY_REGISTER > 0 then begin
		FRegisterDelay := wd1793_DELAY_REGISTER;
		FRegisterToWrite := Address;
		FValueToWrite := Value;
	end else
		WriteRegister(Address, Value);
end;

procedure TWD1793.WriteRegister(Address:Cardinal; Value:Cardinal);
var A: Cardinal;
		Command: Cardinal;
begin
	A := Address and 3;
	if A=wd1793_REG_COMMAND then begin
		//Регистр команд
		FRegs[4] := Value;
		ClearINTRQ;
		FindSelectedDrive;
		Command := (Value and $F0) shr 4;
		//Запуск исполнения команд
		case Command of
			$0: begin
						//Restore
						FDelay := wd1793_DELAY_RESTORE;
						FCommand := wd1793_COMMAND_RESTORE;
						SetFlag(wd1793_FLAG_BUSY);
					end;
			$1: begin
						//Seek
						FDelay := wd1793_DELAY_STEP*Abs(Fregs[wd1793_REG_TRACK] - Fregs[wd1793_REG_DATA]);
						FCommand := wd1793_COMMAND_SEEK;
						SetFlag(wd1793_FLAG_BUSY);
					end;
			$2,$3: begin
						//Step
						FDelay := wd1793_DELAY_STEP;
						FCommand := wd1793_COMMAND_STEP;
						SetFlag(wd1793_FLAG_BUSY);
					end;
			$4,$5: begin
						//Step-In
						FStepDir := 1;
						FDelay := wd1793_DELAY_STEP;
						FCommand := wd1793_COMMAND_STEP;
						SetFlag(wd1793_FLAG_BUSY);
					end;
			$6,$7: begin
						//Step-Out
						FStepDir := -1;
						FDelay := wd1793_DELAY_STEP;
						FCommand := wd1793_COMMAND_STEP;
						SetFlag(wd1793_FLAG_BUSY);
					end;
			$8,$9: begin
						//Read sector
						if Value and wd1793_PARAM_m > 0 then
							FIM.DM.Error(Self, 'Чтение нескольких секторов не поддерживается!');
						FDelay := wd1793_DELAY_SECTOR;
						FCommand := wd1793_COMMAND_READ_SECTOR;
						SetFlag(wd1793_FLAG_BUSY);
					end;
			$A,$B: begin
						//Write sector
						if Value and wd1793_PARAM_m > 0 then
							FIM.DM.Error(Self, 'Запись нескольких секторов не поддерживается!');
						FDelay := wd1793_DELAY_SECTOR;
						FCommand := wd1793_COMMAND_WRITE_SECTOR;
						SetFlag(wd1793_FLAG_BUSY);
					end;
			$C: begin
						//Read address
						SetFlag(wd1793_FLAG_NOT_READY);
						SetINTRQ;
					end;
			$E: begin
						//Read track
						SetFlag(wd1793_FLAG_NOT_READY);
						SetINTRQ;
					end;
			$F: begin
						//Write track
						SetFlag(wd1793_FLAG_NOT_READY);
						SetINTRQ;
					end;
			$D: begin
						//Force Interrupt
						ClearFlag(wd1793_FLAG_BUSY);
						FCommand := 0;
						FDelay := 0;
						ClearDRQ;
						if Value and $0F <> 0 then
							FIM.DM.Error(Self, 'Параметры команды Force Interrupt не поддерживаются!');
					end;
		end;
	end else
		FRegs[A] := Value;
	if A=wd1793_REG_DATA then ClearDRQ;
end;

procedure TWD1793.Clock(Counter:Cardinal);

	procedure Set_I_Flags(T, S: Byte);
	var SeekRes: Integer;
	begin
		ClearFlag(wd1793_FLAG_BUSY);

		if FRegs[4] and wd1793_PARAM_h > 0 then
			SetFlag(wd1793_FLAG_HLD)
		else
			ClearFlag(wd1793_FLAG_HLD);

		if Fregs[wd1793_REG_TRACK]=0 then
			SetFlag(wd1793_FLAG_TR00)
		else
			ClearFlag(wd1793_FLAG_TR00);

		if FSelectedDrive >= 0 then begin
			SeekRes := FDrives[FSelectedDrive].SeekSector(T, S);
			if SeekRes < 0 then
				SetFlag(wd1793_FLAG_NOT_READY)
			else
				ClearFlag(wd1793_FLAG_NOT_READY);

			if FDrives[FSelectedDrive].IsProtected then
				SetFlag(wd1793_FLAG_PROTECTED)
			else
				ClearFlag(wd1793_FLAG_PROTECTED);
		end else begin
				SetFlag(wd1793_FLAG_NOT_READY);
				SetFlag(wd1793_FLAG_PROTECTED);
		end;

		//if FRegs[4] and wd1793_PARAM_V > 0 then
	end;
	procedure Set_II_Flags;
	begin
		ClearFlag(wd1793_FLAG_BUSY);
		ClearFlag(wd1793_FLAG_LOST_DATA);
		ClearFlag(wd1793_FLAG_BAD_CRC);
	end;
begin
	//Отработка задержки записи в регистр
	if FRegisterDelay > 0 then begin
		Dec(FRegisterDelay, Counter);
		if FRegisterDelay <= 0 then
			WriteRegister(FRegisterToWrite, FValueToWrite);
	end;

	if FDelay > 0 then
		Dec(FDelay, Counter)
	else begin
		//Выполнение FCommand
		case FCommand of
			wd1793_COMMAND_RESTORE: begin
				FRegs[wd1793_REG_TRACK] := 0;
				Set_I_Flags(0, 1);
				SetINTRQ;
				FCommand := 0;
			end;
			wd1793_COMMAND_SEEK: begin
				Fregs[wd1793_REG_TRACK] := Fregs[wd1793_REG_DATA];

				Set_I_Flags(Fregs[wd1793_REG_TRACK], 1);

				SetINTRQ;
				FCommand := 0;
			end;
			wd1793_COMMAND_STEP: begin
				if FRegs[4] and wd1793_PARAM_T > 0 then
					Inc (Fregs[wd1793_REG_TRACK], FStepDir);

				Set_I_Flags(Fregs[wd1793_REG_TRACK], 1);

				SetINTRQ;
				FCommand := 0;
			end;
			wd1793_COMMAND_READ_SECTOR: begin
				if FSelectedDrive >=0 then begin
					FSectorSize := FDrives[FSelectedDrive].SeekSector(FRegs[wd1793_REG_TRACK], FRegs[wd1793_REG_SECTOR]);
					if FSectorSize > 0 then begin
						FDelay := wd1793_DELAY_NEXT_BYTE;
						FCommand := wd1793_COMMAND_READ_BYTE;
						FBytes := 0;
					end else begin
						Set_II_Flags;
						SetFlag(wd1793_FLAG_NOT_READY);
						SetINTRQ;
						FCommand := 0;
					end;
				end else begin
						SetFlag(wd1793_FLAG_NOT_READY);
				end;
			end;
			wd1793_COMMAND_WRITE_SECTOR: begin
				if FSelectedDrive >=0 then begin
					FSectorSize := FDrives[FSelectedDrive].SeekSector(FRegs[wd1793_REG_TRACK], FRegs[wd1793_REG_SECTOR]);
					if (FSectorSize > 0) and not FDrives[FSelectedDrive].IsProtected then begin
						FDelay := wd1793_DELAY_NEXT_BYTE;
						FCommand := wd1793_COMMAND_WRITE_BYTE;
						FBytes := 0;
						SetDRQ;
					end else begin
						Set_II_Flags;
						if FSectorSize < 0 then
							SetFlag(wd1793_FLAG_NOT_READY)
						else
							SetFlag(wd1793_FLAG_PROTECTED);
						SetINTRQ;
						FCommand := 0;
					end;
				end else begin
						SetFlag(wd1793_FLAG_NOT_READY);
				end;
			end;
			wd1793_COMMAND_READ_BYTE: begin
				if not GetDRQ then
					if FBytes < FSectorSize then begin
						//Чтение байтов сектора
						FRegs[wd1793_REG_DATA] := FDrives[FSelectedDrive].ReadNextByte;
						Inc(FBytes);
						SetDRQ;
					end else begin
						//Если дошли до конца
						Set_II_Flags;
						ClearFlag(wd1793_FLAG_PROTECTED);
						ClearFlag(wd1793_FLAG_DATA_TYPE);
						SetINTRQ;
						FCommand := 0;
					end;
			end;
			wd1793_COMMAND_WRITE_BYTE: begin
				if FBytes < FSectorSize then begin
					 if not GetDRQ then begin
						//Запись байтов сектора
						FDrives[FSelectedDrive].WriteNextByte(FRegs[wd1793_REG_DATA]);
						Inc(FBytes);
						SetDRQ;
					end
				end else begin
					//Если дошли до конца
					Set_II_Flags;
					ClearFlag(wd1793_FLAG_ERR_WRITE);
					SetINTRQ;
					FCommand := 0;
				end;
			end;
		end;
	end;
end;

function TWD1793.GetBusy:Boolean;
begin
	Result := (FRegs[wd1793_REG_STATUS] and wd1793_FLAG_BUSY) > 0;
end;

function TWD1793.GetSelectedDrive:Cardinal;
begin
	Result := FSelectedDrive;
end;

begin
	RegisterDeviceCreateFunc('wd1793', @CreateWD1793);
end.
