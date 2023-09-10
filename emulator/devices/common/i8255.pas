unit i8255;
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
		Core;

type
	T8255 = class (TAddressableDevice)
	private
		FIAddress: TInterface;
		FIData: TInterface;
		FIPortA: TInterface;
		FIPortB: TInterface;
		FIPortCH: TInterface;
		FIPortCL: TInterface;
		procedure PortAChanged(NewValue, OldValue: Cardinal);
		procedure PortBChanged(NewValue, OldValue: Cardinal);
		procedure PortCHChanged(NewValue, OldValue: Cardinal);
		procedure PortCLChanged(NewValue, OldValue: Cardinal);
	protected
		function GetValue(Address:Cardinal):Cardinal; override;
		procedure SetValue(Address:Cardinal; Value:Cardinal); override;
	public
		FRegs:array[0..3] of Byte;
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
	end;

//var
//	DebugString: String;

implementation

function Create8255(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := T8255.Create(IM, ConfigDevice);
end;

constructor T8255.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIAddress := CreateInterface(2, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_R);
	FIPortA := CreateInterface(8, 'A', MODE_W, PortAChanged);
	FIPortB := CreateInterface(8, 'B', MODE_W, PortBChanged);
	FIPortCH := CreateInterface(4, 'CH', MODE_W, PortCHChanged);
	FIPortCL := CreateInterface(4, 'CL', MODE_W, PortCLChanged);
end;

function T8255.GetValue(Address:Cardinal):Cardinal;
begin
	//if Address and 3 = 2 then Result:=Cardinal(-1) else
	//	if Address and 3 = 1 then Result:=FIPortB.Value else
			Result := FRegs[Address and 3];
			//Result := Cardinal(-1);
end;

procedure T8255.SetValue(Address:Cardinal; Value:Cardinal);
var N, BitVal, BitNum, BitMask:Cardinal;
begin
	N := Address and 3;
	case N of
		0:begin
				if (FRegs[3] and $60) = 0 then begin
					//Если в режиме вывода
					if (FRegs[3] and $10) = 0 then begin
						FRegs[N] := Byte(Value);
						FIPortA.Change(Value);
					end;
				end else
					FIM.DM.Error(Self, 'Канал ''A'' 8255 переведен в режим, который в данный момент не поддерживается!');
		end;
		1:begin
				if (FRegs[3] and 4) = 0 then begin
					//Если в режиме вывода
					if (FRegs[3] and 2) = 0 then begin
						FRegs[N] := Byte(Value);
						FIPortB.Change(Value);
					end;
				end else
					FIM.DM.Error(Self, 'Канал ''B'' 8255 переведен в режим, который в данный момент не поддерживается!');
		end;
		2:begin
				//Верхняя половина
				if (FRegs[3] and 8) = 0 then begin
					FRegs[N] := FRegs[N] and $0F;
					FRegs[N] := FRegs[N] or (Byte(Value) and $F0);
					FIPortCH.Change(FRegs[N] shr 4);
				end;
				//Нижняя половина
				if (FRegs[3] and 1) = 0 then begin
					FRegs[N] := FRegs[N] and $F0;
					FRegs[N] := FRegs[N] or (Byte(Value) and $0F);
					FIPortCL.Change(FRegs[N]);
				end;
		end;
		3:begin
				//Установка режима
				if (Value and $80) <> 0 then begin
					FRegs[N] := Byte(Value);
					if (FRegs[3] and $10) = 0 then
						FIPortA.Mode := MODE_W
					else
						FIPortA.Mode := MODE_R;
					if (FRegs[3] and $02) = 0 then
						FIPortB.Mode := MODE_W
					else
						FIPortB.Mode := MODE_R;
					if (FRegs[3] and $08) = 0 then
						FIPortCH.Mode := MODE_W
					else
						FIPortCH.Mode := MODE_R;
					if (FRegs[3] and $01) = 0 then
						FIPortCL.Mode := MODE_W
					else
						FIPortCL.Mode := MODE_R;
				end else begin
					//Оперирование битами
					BitNum := Value shr 1;
					BitVal := (Value and 1) shl BitNum;
					BitMask := 1 shl BitNum;
					//FRegs[2] := (FRegs[2] and not BitMask) or BitVal;
					//Так правильнее, потому что вызовет изменение на внешних выводах
					SetValue(2, (FRegs[2] and not BitMask) or BitVal);
				end;
		end;
	end;

	//DebugString:='A: '+IntToStr(FRegs[0])+' B: '+IntToStr(FRegs[1])+' C: '+IntToStr(FRegs[2]);

end;

procedure T8255.PortAChanged;
begin
	if (FRegs[3] and $60) = 0 then begin
		//Если в режиме ввода
		if (FRegs[3] and $10) = $10 then begin
			FRegs[0] := Byte(NewValue);
		end;
	end else
		FIM.DM.Error(Self, 'Канал ''A'' 8255 переведен в режим, который в данный момент не поддерживается!');
end;

procedure T8255.PortBChanged;
begin
	if (FRegs[3] and 4) = 0 then begin
		//Если в режиме ввода
		if (FRegs[3] and 2) = 2 then begin
			FRegs[1] := Byte(NewValue);
		end;
	end else
		FIM.DM.Error(Self, 'Канал ''B'' 8255 переведен в режим, который в данный момент не поддерживается!');
end;

procedure T8255.PortCHChanged;
begin
	if (FRegs[3] and 8) = 8 then begin
		FRegs[2] := FRegs[2] and $0F;
		FRegs[2] := FRegs[2] or Byte(NewValue) and $F0;
	end;
end;

procedure T8255.PortCLChanged;
begin
	if (FRegs[3] and 1) = 1 then begin
		FRegs[2] := FRegs[2] and $F0;
		FRegs[2] := FRegs[2] or Byte(NewValue) and $0F;
	end;
end;

begin
	RegisterDeviceCreateFunc('i8255', @Create8255);
end.
