unit TeleDisk10;
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

		This module is based on a work by Willy, which you can find here:
		<http://www.fpns.net/willy/wteledsk.htm>

		Version: 0.2 29/01/2010.

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

		Этот модуль основан на исследованиях, выполненных Willy, результаты
		которых можно найти здесь: <http://www.fpns.net/willy/wteledsk.htm>

Упрощенный пример использования:

var Image:  Pointer;
		TDInfo: TTeleDiskInfo;

Res := TeleDisk_LoadFile(InputFile, TDInfo, Image, 0);
if Res=TD_RESULT_OK then begin
	//
	// Работа с образом по адресу Image, например
	// TeleDisk_SaveImage(Image, TDInfo.ImageSize, OutputFile);
	//
	TeleDisk_Free(Image);
end;
}

{$DEFINE DEBUG_BASIC}
{DEFINE DEBUG_ANOMALIES}
{DEFINE DEBUG_DETAIL}
{$DEFINE DEBUG_IGNORED}

interface

type 	TTDHeader = packed record
				sig: array [0..1] of Char;				//Сигнатура "TD" или "td"
				vol: 		Byte;											//Номер тома. 0 для TD0
				chk:		Byte;											//Сигнатура, одинаковая для всех томов
				ver: 		Byte;											//Для версий 2.11-2.16 равно 15H
				dens:		Byte;											//Плотность записи. Обычно 0.
				typ:		Byte;											//Тип устройства. 1 = 360K, 2 =	1.2M,
																					//3 = 720K, 4 = 1.44M.
				flag:		Byte;               			//Старший бит - наличие комментария
				dos:		Byte;                     //DOS mode? Обычно 00H
				sides:	Byte;											//Кол-во сторон
				crc:		Word;											//CRC первых 10 байт записи
			end;
			TTDComment = packed record
				crc:					Word;
				len: 					Word;
				yr, mon, day,
				hr, min, sec:	Byte;
			end;
			TTDTrack = packed record
				nsec:	Byte;												//Кол-во секторов в дорожке
				trk:	Byte;												//Номер дорожки, начиная с 0
				head:	Byte;												//Номер стороны, начиная с 0
				crc: 	Byte;
			end;
			TTDSector = packed record
				trk:	Byte;
				head:	Byte;
				sec:	Byte;
				secz:	Byte;
				cntrl:Byte;
				crc:	Byte;
			end;
			TTDRepeat = packed record
				count: Word;
				case Integer of
					0: (pat: array [0..1] of Byte);
					1: (patw: Word);
			end;
			TTDPattern = packed record
				flag:		Byte;
				count:	Byte;
			end;
			TTeleDiskInfo=packed record
				Sides:  		Byte;
				Tracks: 		Byte;
				Sectors:		Byte;
				SectSize: 	Word;
				ImageSize:	Cardinal;
				CommentLen: Word;
				Comment_yr:Word;
				Comment_mon, Comment_day,
				Comment_hr, Comment_min, Comment_sec:	Byte;
				Comment: array [0..1023] of Char;
			end;
			TTDBuffer=array [0..1024*1024*1024] of Byte;
			PTDBuffer= ^TTDBuffer;
			TTDLZSS=record
				InPtr, OutPtr: Integer;
				InSize, OutSize: Integer;
				InBuffer, OutBuffer: PTDBuffer;
			end;

var LZSS: TTDLZSS;
const
			TD_RESULT_OK         = 0;

			TD_ERROR_UNSUPPORTED = 1;		 //Данный формат не поддерживается
			TD_ERROR_BAD_HEADER  = 2;		 //Заголовок файла содержит неверные данные
			TD_ERROR_BAD_CRC     = 3;		 //Сектор содержит неверные данные
			TD_ERROR_BAD_SECTOR  = 4;		 //Заголовок сектора содержит неверные данные
			TD_ERROR_BAD_DATA    = 5;		 //Сектор содержит неверные данные
			TD_ERROR_BAD_PATTERN = 6;    //Запись повторения содержит неверные данные
			TD_ERROR_FILE        = 7;		 //Ошибка при работе с файлами
			TD_ERROR_MEMORY      = 8;		 //Ошибка при выделении памяти

			TD_MODE_LOAD_ONLY      = $01;
			TD_MODE_NOT_DECOMPRESS = $02;
			TD_MODE_CHECK_CRC      = $04;

			TD_DECODE_BUFFER = 8192;			//Шаг увеличения размера выходного буфера
																		//при распаковке LZSS

//Function loads InputFile and returns buffer at Image^ and disk info in TDInfo
function TeleDisk_LoadFile(const InputFile: ShortString; var TDInfo:TTeleDiskInfo; var Image:Pointer; Mode:Integer):Integer;

//Function allocates memory and loads given file into it
//The result is the length of the loaded file, otherwise it is zero
//If the data is compressed by LZSS, it is being decompressed
function TeleDisk_Load(const FileName:ShortString; var Buffer:Pointer; var FileLength:Integer; Mode:Integer):Integer;

//Function saves data from a buffer to a file
function TeleDisk_SaveImage(Buffer:Pointer; Size:Integer; const FileName:ShortString):Integer; stdcall;

//This function must be used to free memory allocated by TeleDisk_Load
procedure TeleDisk_Free(Buffer:Pointer); stdcall;

//Function fills the record TDInfo using data from the input stream
//Important! This function doesn't check sector data's CRC even TD_MODE_CHECK_CRC is selected
//because it doesn't unpack it for performance reasons.
//Only main and track headers are checked.
//TeleDisk_Info must get uncompressed data
function TeleDisk_Info(Input:PTDBuffer; InputSize:Integer; var TDInfo:TTeleDiskInfo; Mode:Integer):Integer;

//Function decodes input stream to the output
//Output must be a buffer allocated using TDInfo
//which must be got previously from TeleDisk_Info
//TeleDisk_Decode must get uncompressed data
function TeleDisk_Decode(Input:PTDBuffer; InputSize:Integer; Output:PTDBuffer; var TDInfo:TTeleDiskInfo; Mode:Integer):Integer; stdcall;

//Function encodes sector data from one buffer to another
function TeleDisk_EncodeSector(BufferIn, BufferOut:PTDBuffer; Size:Integer):Integer; stdcall;

const
	CRC_table: array [0..511] of Byte = (
$00,$a0,$e1,$41,$63,$c3,$82,$22,$c7,$67,$26,$86,$a4,$04,$45,$e5,
$2f,$8f,$ce,$6e,$4c,$ec,$ad,$0d,$e8,$48,$09,$a9,$8b,$2b,$6a,$ca,
$5e,$fe,$bf,$1f,$3d,$9d,$dc,$7c,$99,$39,$78,$d8,$fa,$5a,$1b,$bb,
$71,$d1,$90,$30,$12,$b2,$f3,$53,$b6,$16,$57,$f7,$d5,$75,$34,$94,
$bc,$1c,$5d,$fd,$df,$7f,$3e,$9e,$7b,$db,$9a,$3a,$18,$b8,$f9,$59,
$93,$33,$72,$d2,$f0,$50,$11,$b1,$54,$f4,$b5,$15,$37,$97,$d6,$76,
$e2,$42,$03,$a3,$81,$21,$60,$c0,$25,$85,$c4,$64,$46,$e6,$a7,$07,
$cd,$6d,$2c,$8c,$ae,$0e,$4f,$ef,$0a,$aa,$eb,$4b,$69,$c9,$88,$28,

$d8,$78,$39,$99,$bb,$1b,$5a,$fa,$1f,$bf,$fe,$5e,$7c,$dc,$9d,$3d,
$f7,$57,$16,$b6,$94,$34,$75,$d5,$30,$90,$d1,$71,$53,$f3,$b2,$12,
$86,$26,$67,$c7,$e5,$45,$04,$a4,$41,$e1,$a0,$00,$22,$82,$c3,$63,
$a9,$09,$48,$e8,$ca,$6a,$2b,$8b,$6e,$ce,$8f,$2f,$0d,$ad,$ec,$4c,
$64,$c4,$85,$25,$07,$a7,$e6,$46,$a3,$03,$42,$e2,$c0,$60,$21,$81,
$4b,$eb,$aa,$0a,$28,$88,$c9,$69,$8c,$2c,$6d,$cd,$ef,$4f,$0e,$ae,
$3a,$9a,$db,$7b,$59,$f9,$b8,$18,$fd,$5d,$1c,$bc,$9e,$3e,$7f,$df,
$15,$b5,$f4,$54,$76,$d6,$97,$37,$d2,$72,$33,$93,$b1,$11,$50,$f0,

$00,$97,$b9,$2e,$e5,$72,$5c,$cb,$ca,$5d,$73,$e4,$2f,$b8,$96,$01,
$03,$94,$ba,$2d,$e6,$71,$5f,$c8,$c9,$5e,$70,$e7,$2c,$bb,$95,$02,
$06,$91,$bf,$28,$e3,$74,$5a,$cd,$cc,$5b,$75,$e2,$29,$be,$90,$07,
$05,$92,$bc,$2b,$e0,$77,$59,$ce,$cf,$58,$76,$e1,$2a,$bd,$93,$04,
$0c,$9b,$b5,$22,$e9,$7e,$50,$c7,$c6,$51,$7f,$e8,$23,$b4,$9a,$0d,
$0f,$98,$b6,$21,$ea,$7d,$53,$c4,$c5,$52,$7c,$eb,$20,$b7,$99,$0e,
$0a,$9d,$b3,$24,$ef,$78,$56,$c1,$c0,$57,$79,$ee,$25,$b2,$9c,$0b,
$09,$9e,$b0,$27,$ec,$7b,$55,$c2,$c3,$54,$7a,$ed,$26,$b1,$9f,$08,

$8f,$18,$36,$a1,$6a,$fd,$d3,$44,$45,$d2,$fc,$6b,$a0,$37,$19,$8e,
$8c,$1b,$35,$a2,$69,$fe,$d0,$47,$46,$d1,$ff,$68,$a3,$34,$1a,$8d,
$89,$1e,$30,$a7,$6c,$fb,$d5,$42,$43,$d4,$fa,$6d,$a6,$31,$1f,$88,
$8a,$1d,$33,$a4,$6f,$f8,$d6,$41,$40,$d7,$f9,$6e,$a5,$32,$1c,$8b,
$83,$14,$3a,$ad,$66,$f1,$df,$48,$49,$de,$f0,$67,$ac,$3b,$15,$82,
$80,$17,$39,$ae,$65,$f2,$dc,$4b,$4a,$dd,$f3,$64,$af,$38,$16,$81,
$85,$12,$3c,$ab,$60,$f7,$d9,$4e,$4f,$d8,$f6,$61,$aa,$3d,$13,$84,
$86,$11,$3f,$a8,$63,$f4,$da,$4d,$4c,$db,$f5,$62,$a9,$3e,$10,$87
);

procedure CRC16_update(var CRC:Word; Buffer:PTDBuffer; Len:Word);
function CRC16(Buffer:PTDBuffer; Len:Word):Word;

implementation

uses SysUtils, tdlzss10;

procedure CRC16_update(var CRC:Word; Buffer:PTDBuffer; Len:Word);
var tmp: Byte;
		p: Word;
begin
	 for p:=0 to Len-1 do begin
			tmp := Buffer^[p] xor (CRC shr 8);
			CRC := ((CRC_table[tmp] xor (CRC and $FF)) shl 8) + CRC_table[tmp+$100];
	 end;
end;

function CRC16(Buffer:PTDBuffer; Len:Word):Word;
var CRC: Word;
begin
	CRC:=0;
	CRC16_update(CRC, Buffer, Len);
	Result := CRC;
end;

procedure DumpHex(const Buffer:PTDBuffer; Datalen:Integer);
var p:Integer;
		c: Byte;
		S1, S2:String;
begin
	S1:='';
	S2:='';
	for p:=1 to DataLen do begin
		c := Buffer^[p-1];
		S1 := S1+IntToHex(c, 2)+' ';
		if (Buffer^[p-1] < 32) then
			S2 := S2 + '.'
		else
			S2 := S2 + Chr(c);
		if (p mod 16 = 0) then begin
			writeln(S1+'    '+S2);
			S1:='';	S2:='';
		end;
	end;
		if (DataLen mod 16 <> 0) then
			writeln(S1+'    '+S2);
end;

function TeleDisk_Info(Input:PTDBuffer; InputSize:Integer; var TDInfo:TTeleDiskInfo; Mode:Integer):Integer;
begin
	Result := TeleDisk_Decode(Input, InputSize, nil, TDInfo, Mode);
end;

//Service functions for the LZSS unpacking
procedure GetData(var Target; NoBytes:Word; var Actual_Bytes:Word);
begin
	if LZSS.InPtr + NoBytes < LZSS.InSize then
		Actual_Bytes := NoBytes
	else
		Actual_Bytes := LZSS.InSize - LZSS.InPtr;

	Move(LZSS.InBuffer^[LZSS.InPtr], Target, Actual_Bytes);
	Inc(LZSS.InPtr, Actual_Bytes);
end;

procedure PutData(var Source; NoBytes:Word; var Actual_Bytes:Word);
begin
	Actual_Bytes := NoBytes;
	if LZSS.OutPtr + NoBytes > LZSS.OutSize then begin
		Inc(LZSS.OutSize, TD_DECODE_BUFFER);
		ReallocMem(LZSS.OutBuffer, LZSS.OutSize);
	end;
	Move(Source, LZSS.OutBuffer^[LZSS.OutPtr], NoBytes);
	Inc(LZSS.OutPtr, NoBytes);
end;

function TeleDisk_Load(const FileName:ShortString; var Buffer:Pointer; var FileLength:Integer; Mode:Integer):Integer;
var FileHandle: Integer;
		TDHeader: TTDHeader;
		crc: Word;
begin
	FileHandle := FileOpen(FileName, fmOpenRead);
	if FileHandle > 0 then begin
		FileLength := FileSeek(FileHandle,0,2);
		FileSeek(FileHandle,0,0);
		GetMem(Buffer, FileLength);
		if Assigned(Buffer) then
			FileRead(FileHandle, Buffer^, FileLength)
		else begin
			Result := TD_ERROR_MEMORY;
			FileClose(FileHandle);
			Exit;
		end;

		FileClose(FileHandle);

		if (Mode and TD_MODE_LOAD_ONLY = 0) then begin
			Move(Buffer^, TDHeader, SizeOf(TTDHeader));
			if not((TDHeader.sig[0]='T') and (TDHeader.sig[1]='D')) then
				if ((TDHeader.sig[0]='t') and (TDHeader.sig[1]='d')) then begin
					if (Mode and TD_MODE_NOT_DECOMPRESS = 0) then begin
						TDHeader.sig[0] := 'T';
						TDHeader.sig[1] := 'D';  // make it a normal compression image!
						crc := CRC16(@TDHeader, SizeOf(TDHeader)-SizeOf(TDHeader.crc));
						TDHeader.crc := crc;
						with LZSS do begin
							InPtr := SizeOf(TDHeader);
							InSize := FileLength;
							OutSize := TD_DECODE_BUFFER;
							InBuffer := Buffer;
							GetMem(OutBuffer, OutSize);
							Move(TDHeader, OutBuffer^, SizeOf(TDHeader));
							OutPtr := SizeOf(TDHeader);
							LZHUnpack(GetData, PutData);
							ReallocMem(OutBuffer, OutPtr);
							FreeMem(Buffer);
							Buffer := OutBuffer;
							FileLength := OutPtr;
						end;
					end;
					Result := TD_RESULT_OK;
					Exit;
				end else begin
					Result := TD_ERROR_BAD_HEADER;
					if Assigned(Buffer) then FreeMem(Buffer);
					Exit;
				end;
		end;
		Result := TD_RESULT_OK;
	end else
		Result := TD_ERROR_FILE;
end;

function TeleDisk_SaveImage(Buffer:Pointer; Size:Integer; const FileName:ShortString):Integer;
var FileHandle: Integer;
begin
	FileHandle := FileCreate(FileName);
	if FileHandle > 0 then begin
		FileWrite(FileHandle, Buffer^, Size);
		FileClose(FileHandle);
		Result := TD_RESULT_OK;
	end else Result:=TD_ERROR_FILE;
end;

procedure TeleDisk_Free(Buffer:Pointer);
begin
	FreeMem(Buffer);
end;

function TeleDisk_RLEExpand(Input:PTDBuffer; DataLen:Integer; Output:PTDBuffer):Integer;
var P, PO, Rep, PatSize: Integer;
		TDRepeat: TTDRepeat;
		TDPattern: TTDPattern;
begin
	Result := TD_RESULT_OK;
	case Input^[0] of
		0: begin
				{$IFDEF DEBUG_DETAIL}Writeln('  DATA: RAW;    LENGTH: '+IntToStr(DataLen-1));{$ENDIF}
				Move(Input^[1], Output^, DataLen-1);
		end;
		1: begin
				Move(Input^[1], TDRepeat, SizeOf(TTDRepeat));
				{$IFDEF DEBUG_DETAIL}Writeln('  DATA: REPEAT; VALUE: '+IntToHex(TDRepeat.pat[0], 2)+','+IntToHex(TDRepeat.pat[1], 2)+'; COUNT: '+IntToStr(TDRepeat.count));{$ENDIF}
				for Rep:=0 to TDRepeat.count-1 do begin
					Output^[Rep*2]:=TDRepeat.pat[0];
					Output^[Rep*2+1]:=TDRepeat.pat[1];
				end;
		end;
		2: begin
				{$IFDEF DEBUG_DETAIL}Writeln('  DATA: FRAGMENTED; LENGTH: '+IntToStr(DataLen));{$ENDIF}
				P:=1;
				PO := 0;
				while (P < DataLen) do begin
					//what kind of pattern do we have?
					Move(Input^[P], TDPattern, SizeOf(TTDPattern)); Inc(P, SizeOf(TTDPattern));
					if TDPattern.flag=0 then begin
						{$IFDEF DEBUG_DETAIL}Writeln('   PATTERN: RAW; LENGTH: '+IntToStr(TDPattern.count));{$ENDIF}
						//this pattern is raw data, which we have to get from the input stream
						Move(Input^[P], Output^[PO], TDPattern.count);
						Inc(P, TDPattern.count);
						Inc(PO, TDPattern.count);
					end else
					if TDPattern.flag<5 then begin
						PatSize := 1 shl TDPattern.flag;
						{$IFDEF DEBUG_DETAIL}Writeln('   PATTERN: REPEAT; LENGTH: '+IntToStr(PatSize)+'; REPEAT: '+IntToStr(TDPattern.count));{$ENDIF}
						//this pattern is a repetition of the data, following after the record
						//and it's size is a power of two of the flag's value
						//and it repeats "count" times
						for Rep:=1 to TDPattern.count do begin
							Move(Input^[P], Output^[PO], PatSize);
							Inc(PO, PatSize);
						end;
						Inc(P, PatSize);
					end else begin
						{$IFDEF DEBUG_DETAIL}Writeln('ERROR: TDPattern.flag > 4');{$ENDIF}
						Result := TD_ERROR_BAD_PATTERN;
						Exit;
					end;
				end;
		end;
		else Result := TD_ERROR_BAD_DATA;
	end;
end;

function TeleDisk_Decode(Input:PTDBuffer; InputSize:Integer; Output:PTDBuffer; var TDInfo:TTeleDiskInfo; Mode:Integer):Integer;
var P, PO, Sector, SectSize:Integer;
		TDHeader: TTDHeader;
		TDComment: TTDComment;
		{$IFDEF DEBUG_BASIC}CommentStr: array [0..1023] of Char;{$ENDIF}
		TDTrack: TTDTrack;
		TDSector: TTDSector;
		DataLen: Word;
		CRC: Word;
		Terminated: Boolean;
		{$IFDEF DEBUG_IGNORED}TmpBuf: PTDBuffer;{$ENDIF}
begin
	Result:=TD_RESULT_OK;
	if not Assigned(Output) then FillChar(TDInfo, SizeOf(TDInfo), 0);

	{$IFDEF DEBUG_IGNORED}TmpBuf:=nil;{$ENDIF}

	//Let's begin from the first byte
	P:=0;

	//Reading a header
	Move(Input^[P], TDHeader, SizeOf(TTDHeader)); Inc(P, SizeOf(TTDHeader));
	{$IFDEF DEBUG_BASIC}Write('Signature: ');{$ENDIF}
	{$IFDEF DEBUG_BASIC}Writeln(TDHeader.sig);{$ENDIF}
	if not((TDHeader.sig[0]='T') and (TDHeader.sig[1]='D')) then
		if ((TDHeader.sig[0]='t') and (TDHeader.sig[1]='d')) then begin
			Result := TD_ERROR_UNSUPPORTED;
			Exit;
		end else begin
			Result := TD_ERROR_BAD_HEADER;
			Exit;
		end;
	if (Mode and TD_MODE_CHECK_CRC <> 0) then begin
		CRC := CRC16(@TDHeader, SizeOf(TDHeader)-SizeOf(TDHeader.crc));
		if CRC<>TDHeader.crc then begin
			Result := TD_ERROR_BAD_CRC;
			Exit;
		end;
	end;

	//Testing for a comment
	if TDHeader.flag and $80 > 0 then	begin
		{$IFDEF DEBUG_BASIC}Writeln('COMMENT: BEGIN');{$ENDIF}
		Move(Input^[P], TDComment, SizeOf(TTDComment)); Inc(P, SizeOf(TTDComment));
		if (TDComment.len < SizeOf(TDInfo.Comment)) then begin
			Move(Input^[P], TDInfo.Comment, TDComment.len);
			{$IFDEF DEBUG_BASIC}Move(Input^[P], CommentStr, TDComment.len);{$ENDIF}
		end else begin
			Move(Input^[P], TDInfo.Comment, SizeOf(TDInfo.Comment));
			{$IFDEF DEBUG_BASIC}Move(Input^[P], CommentStr, SizeOf(TDInfo.Comment));{$ENDIF}
		end;
		TDInfo.Comment_yr := TDComment.yr+1900; TDInfo.Comment_mon := TDComment.mon+1;
		TDInfo.Comment_day := TDComment.day;
		TDInfo.Comment_hr := TDComment.hr; TDInfo.Comment_min := TDComment.min;
		TDInfo.Comment_sec := TDComment.sec;
		Inc(P, TDComment.len);
		TDInfo.CommentLen := TDComment.len;
		{$IFDEF DEBUG_BASIC}Writeln(CommentStr);{$ENDIF}
		{$IFDEF DEBUG_BASIC}Writeln('COMMENT: END');{$ENDIF}
	end;

	//while not the end of data
	while P < InputSize do begin
		//Reading of the next track record
		Move(Input^[P], TDTrack, SizeOf(TTDTrack)); Inc(P, SizeOf(TTDTrack));
		if TDTrack.nsec=$FF then Break;

		if (Mode and TD_MODE_CHECK_CRC <> 0) then begin
			CRC := CRC16(@TDTrack, SizeOf(TDTrack)-SizeOf(TDTrack.crc));
			if (CRC and $FF)<>TDTrack.crc then begin
				Result := TD_ERROR_BAD_CRC;
				Exit;
			end;
		end;

		{$IFDEF DEBUG_BASIC}Writeln('TRACK: '+IntToStr(TDTrack.trk)+'; HEAD: '+IntToStr(TDTrack.head)+'; SECTORS: '+IntToStr(TDTrack.nsec));{$ENDIF}
		//for each sector
		Terminated := false;
		for Sector:=1 to TDTrack.nsec do begin
			//getting the next sector record
			Move(Input^[P], TDSector, SizeOf(TTDSector)); Inc(P, SizeOf(TTDSector));
			if (TDSector.trk<>TDTrack.trk) or (TDSector.head<>TDTrack.head) then begin
				Result := TD_ERROR_BAD_SECTOR;
				Exit;
			end;
			if TDSector.sec <> $65 then begin
				//if (Mode and TD_MODE_CHECK_CRC <> 0) then begin
				//	CRC := CRC16(@TDSector, SizeOf(TDSector)-SizeOf(TDSector.crc));
				//end;
				SectSize := 1 shl (TDSector.secz+7);
				{$IFDEF DEBUG_BASIC}Write(' SECTOR: '+IntToStr(TDSector.sec)+'; SIZE: '+IntToStr(SectSize)+'; Flags=$',IntToHex(TDSector.cntrl, 2));{$ENDIF}
				{$IFDEF DEBUG_ANOMALIES}if (TDSector.cntrl<>0) then Write(' SECTOR: '+IntToStr(TDTrack.head)+':'+IntToStr(TDTrack.trk)+':'+IntToStr(TDSector.sec)+'; SIZE: '+IntToStr(SectSize)+'; Flags=$',IntToHex(TDSector.cntrl, 2));{$ENDIF}
				{$IFDEF DEBUG_IGNORED}if not Assigned(TmpBuf) then GetMem(TmpBuf, SectSize);{$ENDIF}
				if ((TDSector.cntrl and $30) = 0) and ((TDSector.secz and $F8) = 0) then begin
					if not Assigned(Output) then begin
						TDInfo.SectSize := SectSize;
						if (TDSector.sec <= TDTrack.nsec) and (TDSector.sec > TDInfo.Sectors) then
							TDInfo.Sectors := TDSector.sec;
					end;
					//let's get the destination's offset
					PO := ((TDSector.trk*TDInfo.Sides + TDSector.head)*TDInfo.Sectors + TDSector.sec-1)*TDInfo.SectSize;
					if TDSector.cntrl=$10 then begin
						{$IFDEF DEBUG_BASIC}Writeln('; TYPE: EMPTY');{$ENDIF}
						{$IFDEF DEBUG_ANOMALIES}Writeln('; TYPE: EMPTY');{$ENDIF}
						//if the sector is empty, we fill it with zeroes
						FillChar(Output^[PO], TDInfo.SectSize, 0);
					end else begin
						Move(Input^[P], DataLen, SizeOf(DataLen)); Inc(P, SizeOf(DataLen));
						if TDSector.sec <= TDTrack.nsec then begin
							{$IFDEF DEBUG_BASIC}Writeln('; DATALEN: '+IntToStr(DataLen));{$ENDIF}
							if Assigned(Output) then begin
							TeleDisk_RLEExpand(@(Input^[P]), DataLen, @(Output^[PO]));
								if (Mode and TD_MODE_CHECK_CRC <> 0) then begin
									CRC:=CRC16(@(Output^[PO]), SectSize);
									if (CRC and $FF) <> TDSector.crc then begin
										Result := TD_ERROR_BAD_CRC;
										Exit;
									end;
								end;
							end;
						end
							{$IFDEF DEBUG_BASIC}else begin
								Writeln('; IGNORED');
								{$IFDEF DEBUG_IGNORED}
									TeleDisk_RLEExpand(@(Input^[P]), DataLen, TmpBuf);
									DumpHex(TmpBuf, SectSize);
								{$ENDIF}
							end{$ENDIF}
							{$IFDEF DEBUG_ANOMALIES}else begin
								Writeln('; IGNORED');
								{$IFDEF DEBUG_IGNORED}
									TeleDisk_RLEExpand(@(Input^[P]), DataLen, TmpBuf);
									DumpHex(TmpBuf, SectSize);
								{$ENDIF}
							end{$ENDIF};
						Inc(P, DataLen);
					end;
				end else begin
					{$IFDEF DEBUG_BASIC}Writeln(' SECTOR: '+IntToStr(TDSector.sec)+'; TRACK: '+IntToStr(TDSector.trk)+'; HEAD: '+IntToStr(TDSector.head)+'; SIZE: '+IntToStr(SectSize)+'; TYPE: GHOST');{$ENDIF}
				end;
			end else begin
				{$IFDEF DEBUG_BASIC}Writeln('  TERMINATED because of sec=$65 is got');{$ENDIF}
				Terminated := True;
				Break;
			end;
		end; //for sector:=1 to ...

		//Calculating info
		if (not Assigned(Output)) and (not Terminated) then
			with TDInfo do begin
				if TDTrack.trk  >= Tracks then Tracks := TDTrack.trk  + 1;
				if TDTrack.head >= Sides  then Sides  := TDTrack.head + 1;
			end;

		if Terminated then Break;
	end; //while P < InputSize
	//That's all, finally we need to calculate the image's size
	if not Assigned(Output) then
		with TDInfo do ImageSize := Sides * Tracks * Sectors * SectSize;
end;

function TeleDisk_LoadFile(const InputFile: ShortString; var TDInfo:TTeleDiskInfo; var Image:Pointer; Mode:Integer):Integer;
var Buffer: Pointer;
		FileLength: Integer;
begin
	Result := TeleDisk_Load(InputFile, Buffer, FileLength, Mode);
	if Result = TD_RESULT_OK then begin
		Result := TeleDisk_Info(Buffer, FileLength, TDInfo, Mode);
		if Result = TD_RESULT_OK then begin
			GetMem(Image, TDInfo.ImageSize);
			Result := TeleDisk_Decode(Buffer, FileLength, Image, TDInfo, Mode);
		end;
		TeleDisk_Free(Buffer);
	end;
end;

function TeleDisk_EncodeSector(BufferIn, BufferOut:PTDBuffer; Size:Integer):Integer; stdcall;
var DataLen, i{, InPtr, OutPtr}: Integer;
		TmpW, Cnt: Word;
		TDRepeat: TTDRepeat;
begin
	TmpW := BufferIn^[0] + BufferIn^[1]*256;
	Cnt := 0;
	for i:=0 to (Size div 2)-1 do
		if TmpW = BufferIn^[i*2] + BufferIn^[i*2+1]*256 then Inc(Cnt);
	if Cnt=Size div 2 then begin
		DataLen := SizeOf(TTDRepeat)+1;
		TDRepeat.count := Cnt;
		TDRepeat.patw := TmpW;
		BufferOut^[0] := 1;
		Move(TDRepeat, BufferOut^[1], SizeOf(TTDRepeat));
	end else begin
	{
		InPtr :=0; OutPtr := 0;
		while InPtr < Size do begin
			for i:=1 to 4 do begin
				InPtr2 := InPtr;
				PatLen := 1 shl i;
				Cnt := 0;
				while InPtr2 < Size do begin
					CntEq := 0;
					j := 0;
					while (j < PatLen) and (InPtr2 + j*(Cnt+1) < Size) do begin
						if BufferIn[InPtr2 + j] = BufferIn[InPtr2 + j*(Cnt+1)] then Inc(CntEq);
						Inc(j);
					end;
					if CntEq = PatLen then Inc(Cnt);
				end;
			end;
		end;
	}
		DataLen := Size + 1;
		BufferOut^[0] := 0;
		Move(BufferIn^, BufferOut^[1], Size);
	end;
	Result := DataLen;
end;

end.
