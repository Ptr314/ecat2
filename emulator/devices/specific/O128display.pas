unit O128display;
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
		Graphics, Classes,
		Config,
		Core;

type
	TO128Display = class (TDisplay)
	private
		FPMode: TPort;
		FPScreen: TPort;
		FRMain: TRAM;
		FRColor: TRAM;

		FBase: Cardinal;
		FPrevMode: Cardinal;
		FPrevScreen: Cardinal;
		FLines : array [0..255] of PStorage;

		FI50HzEnable: TInterface;
		FI50Hz: TInterface;
		F50HzCounter: Cardinal;
		F50hzTicks: Cardinal;
		F50hzLength: Cardinal;
		F50hzActive: Boolean;
		procedure MemoryChanged(Address: Cardinal);
		procedure DrawByte(Address:Cardinal);
	public
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
		procedure Clock(Counter:Cardinal); override;
		function GetScreen(Required:Boolean):TBitMap; override;
	end;

	const
	Orion128_MonoColors : array [0..3] of TScreenColor = ( (0, 0, 0), (0, 255, 0), ( 40, 180, 200), (250, 250,  50));
	Orion128_4Colors : array [0..7] of TScreenColor = (
					(  0,   0,   0), (127,   0,   0), (  0, 127,   0), (  0,   0, 127),
					(127, 127, 127), (  0, 127, 127), (127,   0, 127), (127, 127,  0)
					);
	Orion128_16Colors : array [0..15] of TScreenColor = (
					(  0,   0,   0), (  0,   0, 127), (  0, 127,   0), (  0, 127, 127),
					(127,   0,   0), (127,   0, 127), (127, 127,   0), (127, 127, 127),
					(127, 127, 127), (  0,   0, 255), (  0, 255,   0), (  0, 255, 255),
					(255,   0,   0), (255,   0, 255), (255, 255,   0), (255, 255, 255)
					);

implementation

function CreateO128Display(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TO128Display.Create(IM, ConfigDevice);
end;

constructor TO128Display.Create;
var Cpu: TCPU;
		i: Cardinal;
begin
	inherited Create(IM, ConfigDevice);

	FSX := 384;
	FSY := 256;

	//Инициализация растра
	FBitMap.Width:=FSX;
	FBitMap.Height:=FSY;
	FBitMap.PixelFormat:=pf24bit;

	for i:=0 to 255 do
		FLines[i] := FBitMap.ScanLine[i];

	//Здесь запоминаются предыдущие режимы
	//чтобы полностью перерисовывать экран при их
	//изменении
	FPrevMode := Cardinal(-1);
	FPrevScreen := Cardinal(-1);

  //Генератор прерывания 50 Гц для Z80 Card II
	FI50HzEnable := CreateInterface(1, 'enable50hz', MODE_R);
	FI50Hz := CreateInterface(1, 'out50hz', MODE_W);
	F50HzCounter := 0;
	Cpu := IM.DM.GetDeviceByName('cpu') as TCPU;
	F50hzTicks := Cpu.ClockValue div 50;
	F50hzLength := 100; //In CPU ticks
	F50hzActive := False;
end;

procedure TO128Display.LoadConfig;
begin
	inherited LoadConfig(SD);
	FPMode := IM.DM.GetDeviceByName(FConfigData.Parameters['mode'].Value) as TPort;
	FPScreen := IM.DM.GetDeviceByName(FConfigData.Parameters['screen'].Value) as TPort;
	FRMain  := IM.DM.GetDeviceByName(FConfigData.Parameters['rmain'].Value) as TRAM;
	FRColor := IM.DM.GetDeviceByName(FConfigData.Parameters['color'].Value, False) as TRAM;

  //Ставим на память обратный вызов для отслеживания измения видеостраниц
	FRMain.SetCallback(MemoryChanged, MODE_W);
	FRColor.SetCallback(MemoryChanged, MODE_W);
end;

procedure TO128Display.Clock(Counter:Cardinal);
begin
	//Если изменился режим или переключилась видеостраница,
	//все изображение объявляется некорректным
	if (FPrevScreen <> FPScreen[0]) or (FPrevMode<>FPMode[0]) then begin
		FPrevScreen := FPScreen[0];
		FPrevMode := FPMode[0];
		FBase := $C000-FPScreen[0]*$4000;
		FValid := False;
	end;

	Inc (F50HzCounter, Counter);
	if F50HzCounter > F50hzTicks then begin
		Dec(F50HzCounter, F50hzTicks);
		F50hzActive := True;
		if (FI50HzEnable.Value and $1 = $1) then begin
			FI50Hz.Change(0);
		end;
	end else
	if (F50HzCounter > F50hzLength) and F50hzActive then begin
		F50hzActive := False;
		FI50Hz.Change(1);
	end;
end;

procedure TO128Display.MemoryChanged(Address: Cardinal);
begin
	if (Address >= FBase) and (Address < FBase + $3000) then begin
		DrawByte(Address-FBase);
		FRepaint := True;
		//FValid := False;
	end;
end;

function TO128Display.GetScreen(Required:Boolean):TBitMap;
var i:Cardinal;
begin
	if not FValid then begin
		for i:=0 to $2FFF do DrawByte(i);
		FValid := TRUE;
		FRepaint := FALSE;
		Result := FBitMap;
	end else begin
		if Required or FRepaint then begin
			Result := FBitMap;
			FRepaint := FALSE;
		end else
			Result := nil
	end;
end;

procedure TO128Display.DrawByte(Address:Cardinal);
var k, p1, Mode0, Mode1, Mode2, Ofs, Lin:Cardinal;
		c, c1, c2, c3, c4: Byte;
begin
	Lin := Address and $FF;				//Номер строки на экране
	Ofs := (Address shr 8) * 24; 	//8 точек по тра байта
	
	Mode2:=(FPMode[0] and 4);
	Mode1:=(FPMode[0] and 2);

	if Mode2=0 then begin
		if Mode1=0 then begin
			//Монохромный
			Mode0:=(FPMode[0] and 1) shl 1;
			c:=FRMain[FBase+Address];
			for k:=0 to 7 do begin
				c1:=((c shr k) and 1) or Mode0;
				p1:=Ofs + (7-k)*3;
				FLines[Lin][p1]  :=Orion128_MonoColors[c1, 2]; //B
				FLines[Lin][p1+1]:=Orion128_MonoColors[c1, 1]; //G
				FLines[Lin][p1+2]:=Orion128_MonoColors[c1, 0]; //R
			end;
		end else begin
			//Гашение
			FillChar(FLines[Lin][Ofs], 8*3, 0);
		end;
	end else
	if Mode1=2 then begin
		//16 цветов
		c:=FRMain[FBase+Address];
		c2:=FRColor[FBase+Address];
		for k:=0 to 7 do begin
			c1:=(not (c shr k)) and 1;
			c3:=(c2 shr (4*c1)) and $0F; //Если основной цвет, то берем младшие 4 бита, иначе - старшие
			p1:=Ofs + (7-k)*3;
			FLines[Lin][p1]:=Orion128_16Colors[c3, 2];   //B
			FLines[Lin][p1+1]:=Orion128_16Colors[c3, 1]; //G
			FLines[Lin][p1+2]:=Orion128_16Colors[c3, 0]; //R
		end;
	end else begin
		//4 цвета
		Mode0:=(FPMode[0] and 1) shl 2;
		c:=FRMain[FBase+Address];
		c1:=FRColor[FBase+Address];
		for k:=0 to 7 do begin
			c2:=(c shr k) and 1;
			c3:=(c1 shr k) and 1;
			c4:=((c2 shl 1) or c3) or Mode0;
			p1:=Ofs + (7-k)*3;
			FLines[Lin][p1]  :=Orion128_4Colors[c4, 2];   //B
			FLines[Lin][p1+1]:=Orion128_4Colors[c4, 1]; //G
			FLines[Lin][p1+2]:=Orion128_4Colors[c4, 0]; //R
		end;
	end;
end;

begin
	RegisterDeviceCreateFunc('orion-128-display', @CreateO128Display);
end.
