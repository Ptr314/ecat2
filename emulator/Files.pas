unit Files;
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

uses  SysUtils, Dialogs,
			Emulator, Core, Utils;

procedure HandleExternalFile(Emulator:TEmulator; FileName:String);
{function HandleFileForTape(FileName:String; var Buffer:PStorage):Cardinal;}

implementation

procedure LoadORD(Emulator:TEmulator; FileName:String);
var fh: Integer;
		Delta, Offset, Len, P:Integer;
		Buffer: PStorage;
		RamPage: TRAM;
		Hdr: array [0..255] of Byte;
		Bios: TROM;
		AddToDisk: Boolean;
		CRC: Word;

	function FindFreePosition(Buffer:PStorage; Top:Integer):Integer;
	var Found:Boolean;
			Delta, L: Integer;
	begin
		Delta := 0;
		Found:=False;
		while (Delta < Top) and not Found do begin
			if Buffer[Delta] = $FF then Found:=TRUE
			else begin
				L:=Buffer[Delta + 10] + Buffer[Delta + 11]*256;
				Inc(Delta, L + 16);
			end;
		end;
		if Found then Result:=Delta else Result:=-1;
	end;

begin
	try
		Bios := TROM(Emulator.DM.GetDeviceByName('bios'));
		CRC := CRC16(PByteBuffer(Bios.Buffer), Bios.Size);
		AddToDisk := (CRC<>$A85E); //Монитор-1
	except
		AddToDisk := True;
	end;
	
	if (AnsiLowerCase(ExtractFileExt(FileName))='.rko') then begin
		ReadHeader(FileName, 256, Hdr);
		P := 0;
		while (Hdr[P]<>$E6) and (P<256) do Inc(P);
		Inc(P, 5);
		Offset := P;
		Len :=Hdr[P+10]+Hdr[P+11]*256 + 16{header};
	end else begin
		ReadHeader(FileName, 16, Hdr);
		Offset := 0;
		Len :=Hdr[10]+Hdr[11]*256 + 16{header};
	end;

	if AddToDisk then begin
		RamPage := Emulator.DM.GetDeviceByName('ram1') as TRAM;
		Buffer := RamPage.Buffer;
		Delta := FindFreePosition(Buffer, 48*1024); //Чтобы на залезть в область цвета
		if (Delta < 0) or (Delta + Len > 48*1024) then begin
			RamPage := Emulator.DM.GetDeviceByName('ram2') as TRAM;
			Buffer := RamPage.Buffer;
			Delta := FindFreePosition(Buffer, 60*1024);
			if (Delta < 0) or (Delta + Len > 60*1024) then begin
				RamPage := Emulator.DM.GetDeviceByName('ram3') as TRAM;
				Buffer := RamPage.Buffer;
				Delta := FindFreePosition(Buffer, 60*1024);
				if (Delta < 0) or (Delta + Len > 60*1024) then begin
					ShowMessage('Не удалось найти достаточно места на RAM-дисках!');
					Exit;
				end;
			end;
		end;
	end else begin
		RamPage := Emulator.DM.GetDeviceByName('ram0') as TRAM;
		Buffer := RamPage.Buffer;
		//Отрезаем заголовки
		Inc(Offset, 8);
		Dec(Len, 16);
		Delta :=Hdr[Offset]*256+Hdr[Offset+1];
		Inc(Offset, 8);
	end;

	fh := FileOpen(FileName, fmOpenRead);
	if Offset>0 then FileSeek(fh, Offset, 0);
	FileRead(fh, Buffer[Delta], Len);
	Buffer[Delta + Len]:=$FF;
	FileClose(fh);
end;

procedure LoadRK(Emulator:TEmulator; FileName:String);
var fh: Integer;
		Hdr: array [0..15] of Byte;
		Delta, Offset, Len:Integer;
		Buffer: PStorage;
		RamPage: TRAM;
begin
	ReadHeader(FileName, 16, Hdr);
	Offset := 4;
	Delta :=Hdr[0]*256+Hdr[1];
	Len :=Hdr[2]*256+Hdr[3];
	RamPage := Emulator.DM.GetDeviceByName('ram') as TRAM;
	Buffer := RamPage.Buffer;

	fh := FileOpen(FileName, fmOpenRead);
	if Offset>0 then FileSeek(fh, Offset, 0);
	FileRead(fh, Buffer[Delta], Len);
	FileClose(fh);
end;


procedure HandleExternalFile;
var Ext:String;
begin
	Ext := AnsiLowerCase(ExtractFileExt(FileName));
	if (Ext='.ord') or (Ext='.bru') or (Ext='.rko') then LoadORD(Emulator, FileName)
	else
	if (Ext='.rk') or (Ext='.rkr')  or (Ext='.rkm') or (Ext='.rka') then LoadRK(Emulator, FileName)
	else
		MessageDlg('Данный формат пока не поддерживается!', mtError, [mbOK], 0);
end;

{function ConvertRKTapeStream(TmpBuf:PStorage; var Buffer:PStorage; L:Cardinal);
var i:Integer;
		B: Byte;
		T: PartsRec;
const B2: array [0..1] of Byte = (2, 1);
begin
	GetMem(Buffer, L*2);
	for i:=0 to L-1 do begin
		B:= TmpBuf^[i];
		T.W :=
	end;
	Result := L*2;
end;

function TapeORD(FileName:String; var Buffer:PStorage):Cardinal;
var	fh: Integer;
		FL, L, Preamble, StartByte, StopByte:Cardinal;
		TmpBuf: PStorage;
begin
	Preamble := 256;
	StartByte := 1;
	StopByte := 0;
	AssignFile(F, FileName);
	Reset(F);
	FL := GetFileSize(FileName);
	L := FL + Preamble + StartByte + StopByte
	GetMem(TmpBuf, L);
	if Preamble>0 then
		FillChar(TmpBuf^, Preamble, 0);
	if StartByte>0 then
		TmpBuf^[Preamble] := $E6;

	fh := FileOpen(FileName, fmOpenRead);
	FileRead(fh, TmpBuf^[Preamble+StartByte], FL);
	FileClose(fh);

	if StopByte>0 then
		TmpBuf^[FL + Preamble + StartByte] := $E6;

	Result := ConvertRKTapeStream(TmpBuf, Buffer, L);
	FreeMem(TmpBuf);
end;

function HandleFileForTape(FileName:String; var Buffer:PStorage):Cardinal;
var Ext:String;
begin
	Ext := AnsiLowerCase(ExtractFileExt(FileName));
	if (Ext='.ord') or (Ext='.bru') or (Ext='.rko') then Result:=TapeORD(FileName, Buffer)
	else
		MessageDlg('Данный формат пока не поддерживается!', mtError, [mbOK], 0);
end;
}

end.
