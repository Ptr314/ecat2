unit vg75display;
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
		Graphics, SysUtils,
		Config,
		Core, i8275, i8257;

type
	TVg75Display = class (TDisplay)
	private
		FMemory: TRAM;
		FFont: TROM;
		FVG75: T8275;
		FDMA: T8257;
		FChannel: Cardinal;
		FLines : array [0..399] of PStorage;
		FIHigh: TInterface;
		FAttrDelay: Boolean;
		FRGB: array [0..2] of Cardinal;
		FRGBInv: Boolean;
		procedure SetBitmapFormat(SX, SY: Cardinal; PF:TPixelFormat);
	public
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
		function GetScreen(Required:Boolean):TBitMap; override;
	end;

implementation

const
	VG75_8Colors : array [0..7] of TScreenColor = (
					(0, 0, 0), (  0,   0, 255), (  0, 255,   0), (  0, 255, 255),
					(255,   0,   0), (255,   0, 255), (255, 255,   0), (255, 255, 255)
					);


function CreateVg75Display(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TVg75Display.Create(IM, ConfigDevice);
end;

constructor TVg75Display.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIHigh := CreateInterface(1, 'high', MODE_R);

	SetBitmapFormat(78*6, 30*10, pf24bit);
end;

procedure TVg75Display.SetBitmapFormat(SX, SY: Cardinal; PF:TPixelFormat);
var	i: Cardinal;
begin
	FSX := SX;
	FSY := SY;
	FBitMap.Width:=SX;
	FBitMap.Height:=SY;
	FBitMap.PixelFormat:=PF;

	for i:=0 to FSY-1 do
		FLines[i] := FBitMap.ScanLine[i];
end;

procedure TVg75Display.LoadConfig;
var S:String;
		i:Integer;
begin
	inherited LoadConfig(SD);
	FMemory  := IM.DM.GetDeviceByName(FConfigData.Parameters['ram'].Value) as TRAM;
	FFont  := IM.DM.GetDeviceByName(FConfigData.Parameters['font'].Value) as TROM;
	FVG75  := IM.DM.GetDeviceByName(FConfigData.Parameters['vg75'].Value) as T8275;
	FDMA  := IM.DM.GetDeviceByName(FConfigData.Parameters['dma'].Value) as T8257;
	FChannel := StrToInt(FConfigData.Parameters['channel'].Value);
	try
		FAttrDelay := FConfigData.Parameters['attr_delay'].Value <> '0';
	except
		FAttrDelay := False;
	end;

	try
		S := FConfigData.Parameters['rgb'].Value;
	except
		S := '';
	end;
	if S <> '' then begin
		FRGBInv := S[1]='^';
		if FRGBInv then S := Copy(S, 2, 3);

		for i:=0 to 2 do
			FRGB[i] := StrToInt(S[i+1]);
	end else
		FillChar(FRGB, SizeOf(FRGB), $FF);
end;

function TVg75Display.GetScreen(Required:Boolean):TBitMap;
var i, j, k, row, Ofs, p1, FAColor:Cardinal;
		ii, AddMode: Integer;
		sign, V, c1, NextAttr, C:Byte;
		PP : PStorage;
		SA, CPL, LPS, H, Count, FH, P, Col, Lin, Adr : Cardinal;
		Invis, Blk, FAReverse, FAUnder, FABlink, FAHigh: Boolean;

	procedure SetAttr(V:Byte);
	begin
		FAReverse := (V and $10) <> 0;
		FAUnder := (V and $20) <> 0;
		FABlink := (V and $02) <> 0;
		FAHigh :=  (V and $01) <> 0;
		if FRGB[0] > 8 then
			FAColor := 7
		else begin
			FAColor := 	((V shr FRGB[2]) and $01) +         		//B
									(((V shr FRGB[1]) and $01) shl 1) +			//G
									(((V shr FRGB[0]) and $01) shl 2);			//R
			if FRGBInv then
				FAColor := FAColor xor $07;
		end;
	end;

begin
	SA := FDMA.FRgA[FChannel*2] + FDMA.FRgA[FChannel*2+1]*256;

	Invis := (FVG75.RegMode[3] and $40) = 0;
	CPL := (FVG75.RegMode[0] and $7F) + 1;						//Chars per line
	LPS := (FVG75.RegMode[1] and $3F) + 1;            //Lines per screen
	H := (FVG75.RegMode[2] and $0F) + 1;              //Character height
	AddMode := FVG75.RegMode[3] shr 7;								//Сдвиг номера строки знакогенаратора
	Count := CPL * LPS;                               //Всего символов на экран

	if (CPL*6 <> FSX) or (LPS*H <> FSY) then begin
		SetBitmapFormat(CPL*6, LPS*H, FBitmap.PixelFormat);
	end;

  //Старший бит адреса знакогенератора
	if FIHigh.Linked > 0 then
		FH := (FIHigh.Value and 1) shl 10
	else
		FH := 0;

	P := 0;
	FAReverse := False;
	FAUnder := False;
	FABlink := False;
	FAHigh := False;
	NextAttr := 0;
	FAColor := 7;
	for Lin:=0 to LPS-1 do begin
		Blk := False; //Флаг зачернения символов до конца строки после спецкода
		for Col:=0 to CPL-1 do begin
			if Blk or (P >= Count) then
				sign := $80
			else begin
				sign:=FMemory[SA+P];
				Inc(P);
				if (Sign and $80) <> 0 then begin
					if Sign = $F1 then begin
						Blk := True;
						Sign := $80;
						Inc(P);
					end else begin
						if (Sign and $40) = 0 then begin
							//Field Attributes
							if not FAttrDelay then begin
								SetAttr(Sign);
								NextAttr := 0;
							end else
								NextAttr := Sign;
							sign := $80;
						end;
						if Invis then begin
							sign:=FMemory[SA+P];
							Inc(P);
						end;
					end;
				end;
			end;
			C := Sign and $7F;
			Ofs := Col*18;
			for i:=0 to H-1 do begin
				Adr := Lin*H + i;
				ii := Integer(i) - AddMode;
				if ii < 0 then Inc(ii, H);
				if ii<8 then
					V:=Byte(not (FFont[FH + C*8+ Cardinal(ii)]))
				else
					V:=0;
				if ((Col=FVG75.RegCursor[0]) and (Lin=FVG75.RegCursor[1]) and
							(
							(((FVG75.RegMode[3] and $30)=$00) and FVG75.Blinker) or						//Мигающий блок
							(((FVG75.RegMode[3] and $30)=$10) and (i>7) and FVG75.Blinker) or	//Мигающее подчеркивание
							((FVG75.RegMode[3] and $30) =$20) or															//Немигающий блок
							(((FVG75.RegMode[3] and $30)=$30) and (i>7)) 									//Немигающее подчеркивание
							)
					 )
					or (FAReverse and (Sign<>$80))
					or (FABlink and FVG75.Blinker and (Sign<>$80))										//Атрибуты всегда черным?
					or (FAUnder and (i>7))
					then V := not V;
				for k:=0 to 5 do begin
					c1:=(V shr k) and 1;
					p1:=Ofs + (5-k)*3;
					FLines[Adr][p1]   := c1 * VG75_8Colors[FAColor, 2];
					FLines[Adr][p1+1] := c1 * VG75_8Colors[FAColor, 1];
					FLines[Adr][p1+2] := c1 * VG75_8Colors[FAColor, 0];
				end;
			end;
			if FAttrDelay and (NextAttr <> 0) then begin
				SetAttr(NextAttr);
				NextAttr := 0;
			end;
		end;
	end;
	Result := FBitmap;
end;

begin
	RegisterDeviceCreateFunc('vg75-display', @CreateVg75Display);
end.
