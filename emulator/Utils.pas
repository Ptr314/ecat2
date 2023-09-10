unit utils;
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
	SysUtils, StrUtils;

type
	TByteBuffer=array [0..1024*1024*1024] of Byte;
	PByteBuffer= ^TByteBuffer;

//Функция преобразовывает строку в число с учетом
//системы счисления и единицы измерения
//Примеры: $FFFF => 65535, #00000011 => 3, 64k => 65536
function ParseNumericValue(Str:String):Integer;

//Создание маски, которая применяется к значениям на шинах,
//чтобы отсечь незначимые биты
function CreateMask(Size, Shift: Cardinal): Cardinal;

procedure ConvertRange(S:String; var V1, V2: Cardinal);

function IntToBin(Value, Size: Cardinal):String;

//Получение части чиста по номеру его части в восьмеричной системе
function Get8Digit(val, pos: Cardinal):Byte;

//Преобразование восьмеричной чтроки в число
function OctToInt(Value:String):Cardinal;

procedure ReadHeader(FName: String; FBytes: Integer; var Buffer:array of Byte);
function GetFileSize(FName: String):Integer;

function Explode(var a: array of string; Border, S: string):Integer;

function FormatTime(T:Cardinal):String;

procedure CRC16_update(var CRC:Word; Buffer:PByteBuffer; Len:Word);
function CRC16(Buffer:PByteBuffer; Len:Word):Word;

function xor_check_sum(var Buffer:array of Byte; Len:Integer):Byte;
procedure encode_fm(V:Byte; var Buffer:array of Byte);
procedure encode_mfm(var BufferIn, BufferOut:array of Byte; Len: Integer);

function CalcBits(V: Cardinal; MaxBits:Cardinal=32):Cardinal;

implementation

uses Math;

function ParseNumericValue(Str:String):Integer;
var Base:Cardinal;
		S:String;
		L, W, i, D, V, Miltiplier:Cardinal;
		Digit: Char;
begin
	S:=UpperCase(Str);

	if Length(Str)=0 then Abort;

	if S[1] = '$' then Base := 16
	else
	if S[1] = '#' then Base := 2
	else Base:=10;

	if Base<>10 then S:=Copy(S, 2, Length(S)-1);

	if S[Length(S)] = 'K' then Miltiplier := 1024
	else Miltiplier := 1;

	if Miltiplier<>1 then S:=LeftStr(S, Length(S)-1);

	L:=Length(S);
	V:=0;
	W := 1;
	for i:=0 to L-1 do begin
		Digit := S[L-i];
		if (Digit < '0') or ((Digit > '9') and (Digit < 'A')) or (Digit > 'F') then
			raise EConvertError.Create('Ошибка преобразования числа ' + Str);
		if (Digit < 'A') then D:=Ord(Digit)-48 else D:=Ord(Digit)-(48+7);
		V := V + D * W;
		W := W * Base;
	end;

	Result := Integer(V * Miltiplier);
end;

function CreateMask(Size, Shift: Cardinal): Cardinal;
begin
	Result := (not ((Cardinal(-1) - 1) shl (Size-1))) shl Shift;
	//1                 FFFF
	//2                         FFFE
	//3                                FFF0
	//4       000F
	//5                                              00F0
end;

procedure ConvertRange(S:String; var V1, V2: Cardinal);
var P:Integer;
begin
	if S<>'' then begin
		P := Pos('-', S);
		if P>0 then begin
			V1 := ParseNumericValue(Copy(S, 1, P-1));
			V2 := ParseNumericValue(Copy(S, P+1, Length(S)-P));
		end else begin
			V1 := ParseNumericValue(S);
			V2 := V1;
		end;
	end else
		Abort;
end;

function IntToBin(Value, Size: Cardinal):String;
var V: Cardinal;
		i: Integer;
		S: String;
begin
	S := '';
	V := Value;
	for i:=1 to Size do begin
		S := IntToStr(V mod 2) + S;
		V := V shr 1; //V:=V/2
	end;
	Result := S;
end;

procedure ReadHeader(FName: String; FBytes: Integer; var Buffer:array of Byte);
var fh: Integer;
begin
	fh := FileOpen(FName, fmOpenRead);
	FileRead(fh, Buffer, fBytes);
	FileClose(fh);
end;

function Explode(var a: array of string; Border, S: string):Integer;
var
	S2: string;
  i: Integer;
begin
 i  := 0;
 S2 := S + Border;
 repeat
	 a[i] := Copy(S2, 0,Pos(Border, S2) - 1);
	 Delete(S2, 1, Length(a[i] + Border));
	 Inc(i);
 until S2 = '';
 Result := i;
end;

function Get8Digit(val, pos: Cardinal):Byte;
begin
  Result := (val shr ((pos shl 2) + pos)) and 7; 
end;

function OctToInt(Value:String):Cardinal;
var i: Integer;
		int: Cardinal;
begin
	 int := 0;
	 for i := 1 to Length(Value) do
	 begin
		 int := int * 8 + StrToInt(Copy(Value, i, 1));
	 end;
	 Result := int;
end;

function GetFileSize(FName: String):Integer;
var fh: Integer;
begin
	fh := FileOpen(FName, fmOpenRead);
	Result := FileSeek(fh,0,2);
	FileClose(fh);
end;

function FormatTime(T:Cardinal):String;
begin
	Result := Format('%d:%.2d:%.2d', [T div 3600, (T div 60) mod 60, T mod 60]);

end;

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

procedure CRC16_update(var CRC:Word; Buffer:PByteBuffer; Len:Word);
var tmp: Byte;
		p: Word;
begin
	 for p:=0 to Len-1 do begin
			tmp := Buffer^[p] xor (CRC shr 8);
			CRC := ((CRC_table[tmp] xor (CRC and $FF)) shl 8) + CRC_table[tmp+$100];
	 end;
end;

function CRC16(Buffer:PByteBuffer; Len:Word):Word;
var CRC: Word;
begin
	CRC:=0;
	CRC16_update(CRC, Buffer, Len);
	Result := CRC;
end;

function CalcBits(V: Cardinal; MaxBits:Cardinal=32):Cardinal;
var i:Integer;
begin
	Result := 0;
	for i:=0 to MaxBits-1 do
		Inc(Result, (V shr i) and 1);
end;

function xor_check_sum(var Buffer:array of Byte; Len:Integer):Byte;
var R:Byte;
		i:Integer;
begin
	R:=0;
	for i:=0 to Len-1 do R := R xor Buffer[i];
	Result := R;
end;

procedure encode_fm(V:Byte; var Buffer:array of Byte);
begin
	Buffer[0] := (V shr 1) or $AA;
	Buffer[1] := V or $AA;
end;

//Источник: agatemulator.sourceforge.net
procedure encode_mfm(var BufferIn, BufferOut:array of Byte; Len: Integer);
var NewLen: Integer;

const CodeTabl:array[0..63] of Byte =(
	$96,$97,$9A,$9B,$9D,$9E,$9F,$A6,$A7,$AB,$AC,$AD,$AE,$AF,$B2,$B3,
	$B4,$B5,$B6,$B7,$B9,$BA,$BB,$BC,$BD,$BE,$BF,$CB,$CD,$CE,$CF,$D3,
	$D6,$D7,$D9,$DA,$DB,$DC,$DD,$DE,$DF,$E5,$E6,$E7,$E9,$EA,$EB,$EC,
	$ED,$EE,$EF,$F2,$F3,$F4,$F5,$F6,$F7,$F9,$FA,$FB,$FC,$FD,$FE,$FF
);

begin
	NewLen := Ceil(Len * 4 /3)+1;
	FillChar(BufferOut, 0, NewLen);

	asm
		pushad
		mov	esi, BufferIn
		mov	edi, BufferOut
		mov	ebx, 2h
	@l2:	mov	ecx, 55h
	@l1:	dec	bl
		mov	al, [esi+ebx]
		shr	al, 1
		rcl	byte ptr [edi+ecx], 1
		shr	al, 1
		rcl	byte ptr [edi+ecx], 1
		mov	byte ptr [edi+56h+ebx], al
		dec	ecx
		jns	@l1
		or	ebx, ebx
		jne	@l2


		xor	al, al
		xor	ecx, ecx
		xor	ebx, ebx
	@l4:	mov	ah, [edi+ecx]
		mov	bl, ah
		xor	bl, al
		mov	al, ah
		mov	bl, byte ptr CodeTabl[ebx]
		mov	[edi+ecx], bl
		inc	ecx
		cmp	ecx, 156h
		jne	@l4
		mov	bl, al
		mov	bl, byte ptr CodeTabl[ebx]
		mov	[edi+ecx], bl
		popad
	end;
end;

end.
