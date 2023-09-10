unit AgatFDC;
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

uses 	SysUtils,
			Config, Utils, Core, fdc, fdd;

type
	TAgatFDC140 = class (TFDC)
		FISelect: TInterface;
		FSelectedDrive: Integer;
		FMode: Cardinal;
		FData: Byte;
		FPrevPhase: Integer;
		FCurrentPhase: Integer;
		FSectorSize: Integer;
		FBytes: Integer;
		FDrivesCount: Cardinal;
		FDrives: array [0..1] of TCommonFDD;
		FTrack: array[0..1] of Byte;
		FSector: array[0..1] of Byte;
		procedure PhaseOn(N:Cardinal);
		procedure PhaseOff(N:Cardinal);
		procedure SelectDrive(N:Cardinal);
	protected
		function GetBusy:Boolean; override;
		function GetSelectedDrive:Cardinal; override;
		function GetValue(Address:Cardinal):Cardinal; override;
		procedure SetValue(Address:Cardinal; Value:Cardinal); override;
	public
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
	end;

implementation

const
			AGAT_FDC_READ = 0;
			AGAT_FDC_WRITE = 1;

function CreateAgatFDC140(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TAgatFDC140.Create(IM, ConfigDevice);
end;

constructor TAgatFDC140.Create;
begin
	inherited Create(IM, ConfigDevice);

	FISelect := CreateInterface(2, 'select', MODE_W);

	FPrevPhase := -1;
	FCurrentPhase := -1;
	FData := 0;
	FSectorSize := -1;

	FSelectedDrive := -1;
	FillChar(FTrack, Sizeof(FTrack), 0);
	FillChar(FSector, Sizeof(FSector), 0);
end;


function TAgatFDC140.GetBusy:Boolean;
begin
	Result := FALSE;
end;

function TAgatFDC140.GetSelectedDrive:Cardinal;
begin
	Result := FSelectedDrive;
end;

procedure TAgatFDC140.LoadConfig;
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
	for i:=0 to FDrivesCount-1 do begin
		FDrives[i] := IM.DM.GetDeviceByName(Parts[i]) as TCommonFDD;
		FDrives[i].StreamFormat := FDD_STREAM_MFM;
	end;
	FSelectedDrive := 0;
end;

function TAgatFDC140.GetValue(Address:Cardinal):Cardinal;
var A: Cardinal;
begin
	A := Address and $0F;
	Result := 0;
	case A of
		$0:PhaseOff(0);
		$1:PhaseOn(0);
		$2:PhaseOff(1);
		$3:PhaseOn(1);
		$4:PhaseOff(2);
		$5:PhaseOn(2);
		$6:PhaseOff(3);
		$7:PhaseOn(3);
		$A:FSelectedDrive := 0;
		$B:FSelectedDrive := 1;
		$C:	begin
					if FSectorSize<0 then FSectorSize := FDrives[FSelectedDrive].SectorSize;
					if FBytes = FSectorSize then begin
						if FSector[FSelectedDrive] = 16 then
							FSector[FSelectedDrive] := 0
						else
							Inc(FSector[FSelectedDrive]);
						FSectorSize := FDrives[FSelectedDrive].SeekSector(FTrack[FSelectedDrive], FSector[FSelectedDrive]);
						FBytes := 0;
					end;
					Result := FDrives[FSelectedDrive].ReadNextByte;
					Inc(FBytes);
				end;
		$E:FMode := AGAT_FDC_READ;
		$F:	begin
					FMode := AGAT_FDC_WRITE;
					//Write byte
				end;
	end;
end;

procedure TAgatFDC140.SetValue(Address:Cardinal; Value:Cardinal);
var A: Cardinal;
begin
	A := Address and $0F;
	case A of
		$0:PhaseOff(0);
		$1:PhaseOn(0);
		$2:PhaseOff(1);
		$3:PhaseOn(1);
		$4:PhaseOff(2);
		$5:PhaseOn(2);
		$6:PhaseOff(3);
		$7:PhaseOn(3);
		$A:SelectDrive(0);
		$B:SelectDrive(1);
		$D:	begin
					FData := Value;
				end;
		$E:FMode := AGAT_FDC_READ;
		$F:	begin
					FMode := AGAT_FDC_WRITE;
					//Write byte
				end;
	end;
end;

procedure TAgatFDC140.SelectDrive(N:Cardinal);
begin
	FSelectedDrive := 0;
	FISelect.Change(1 shl N);
	FCurrentPhase := -1;
end;

procedure TAgatFDC140.PhaseOn(N:Cardinal);
begin
	FPrevPhase := FCurrentPhase;
	FCurrentPhase := N;
end;

procedure TAgatFDC140.PhaseOff(N:Cardinal);
begin
	if (N=1) and (FPrevPhase=2) then begin
		//Step down
		if FTrack[FSelectedDrive]>0 then Dec(FTrack[FSelectedDrive]);
		FSector[FSelectedDrive] := 0;
		FSectorSize := FDrives[FSelectedDrive].SeekSector(FTrack[FSelectedDrive], FSector[FSelectedDrive]);
		FBytes := 0;
	end else
	if (N=3) and (FPrevPhase=2) then begin
		//Step up
		if FTrack[FSelectedDrive]<35 then Inc(FTrack[FSelectedDrive]);
		FSector[FSelectedDrive] := 0;
		FSectorSize := FDrives[FSelectedDrive].SeekSector(FTrack[FSelectedDrive], FSector[FSelectedDrive]);
		FBytes := 0;
	end;
end;

begin
	RegisterDeviceCreateFunc('agat-fdc140', @CreateAgatFDC140);
end.
