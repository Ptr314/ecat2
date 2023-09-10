unit i8275;
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
		Config,
		Core;

type
	T8275 = class (TAddressableDevice)
	private
		FIAddress: TInterface;
		FIData: TInterface;
		Mode:Byte;
		RegIndex:Integer;
		FBlinkTicks:Cardinal;
		FCounter: Cardinal;
		FSystemClock : Cardinal;
		FBlinker: Boolean;
	protected
		function GetValue(Address:Cardinal):Cardinal; override;
		procedure SetValue(Address:Cardinal; Value:Cardinal); override;
	public
		RegMode:array[0..3] of Byte;
		RegCursor:array[0..1] of Byte;
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
		procedure Clock(Counter:Cardinal); override;
		property Blinker:Boolean read FBlinker;
	end;

implementation

function Create8275(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := T8275.Create(IM, ConfigDevice);
end;

constructor T8275.Create;
begin
	inherited Create(IM, ConfigDevice);

	FCounter:=0;
	Mode:=0;
	RegIndex:=0;

	FBlinker := false;
	
	FillChar(RegMode, SizeOf(RegMode), 0);
	FillChar(RegCursor, SizeOf(RegCursor), 0);

	FIAddress := CreateInterface(2, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_R);
end;

function T8275.GetValue(Address:Cardinal):Cardinal;
begin
	case Address of
		0: Result := 0;		//Регистр данных
		1: Result := $20;	//Регистр управления (20 - обратный ход луча)
	else
		Result := 0;
	end;
end;

procedure T8275.SetValue(Address:Cardinal; Value:Cardinal);
begin
	if (Address and 1)=0 then begin
		//Регистр данных
		if Mode=0 then begin
			//Режим 0 - программирование основных параметров
			RegMode[RegIndex and 3] := Byte(Value);
			Inc(RegIndex);
		end else
		if Mode=$80 then begin
			//Режим 80 - установка позиции курсора
			RegCursor[RegIndex and 1] := Byte(Value);
			Inc(RegIndex);
		end
	end	else begin
		//Регистр управления
		Mode := Byte(Value);
		RegIndex := 0;
	end;
end;

procedure T8275.Clock;
begin
	Inc(FCounter, Counter);
	if (FCounter > FBlinkTicks) then begin
		Dec(FCounter, FBlinkTicks);
		FBlinker := not FBlinker;
	end;
end;

procedure T8275.LoadConfig;
begin
	FSystemClock := TCPU(FIM.DM.GetDeviceByName('cpu')).ClockValue;
	FBlinkTicks := FSystemClock div 2;
end;

begin
	RegisterDeviceCreateFunc('i8275', @Create8275);
end.
