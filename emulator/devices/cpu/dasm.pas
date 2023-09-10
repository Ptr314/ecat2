unit dasm;
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

type
			TInstrByte=packed record
				Flag, Value: Byte;
			end;
			TInstrData=packed record
				Bytes:array [0..15] of TInstrByte;
				Len: Integer;
				Str: String [31];
			end;
			TInstrArray=array [0..1024*1024] of TInstrData;
			PInstrArray = ^TInstrArray;
			TByteArray = array [0..127] of Byte;
			PByteArray = ^TByteArray;
			TDisAsm = class
			private
				FInstrLoaded: Integer;
				FPInstr: PInstrArray;
				FInstrMaxLen: Integer;
			public
				constructor Create(CfgFile:String);
				property InstrMaxLen:Integer read FInstrMaxLen;
				function Disassemble(Arr:PByteArray; PC:Cardinal; MaxLen:Integer; var Output:String):Integer;
			end;
const
		INSTR_BUFFER_INCREMENT = 100;

implementation

uses SysUtils, StrUtils, Utils;

constructor TDisAsm.Create(CfgFile:String);
var F:TextFile;
		BufferLen: Integer;
		S, Code, Txt:String;
		P, P2, i: Integer;
		C:Char;
		H:String[2];
begin
	FInstrLoaded := 0;
	BufferLen := 0;
	FPInstr := nil;
	FInstrMaxLen := 0;
	
	AssignFile(F, CfgFile);
	Reset(F);
	while not EOF(F) do begin
		Readln(F, S);
		if S<>'' then
			if S[1]='@' then begin
				//Здесь обработка служебных команд
				//когда потребуется
			end else
			if S[1]<>';' then begin
				P := Pos(#9, S);
				Code := Copy(S, 0, P-1);
				P2 := PosEx(#9, S, P+1);
				if P2=0 then P2:=Length(S)+1;
				Txt := Copy(S, P+1, P2-P-1);
				Inc(FInstrLoaded);
				if FInstrLoaded > BufferLen then begin
					Inc(BufferLen, INSTR_BUFFER_INCREMENT);
					ReallocMem(FPInstr, BufferLen*SizeOf(TInstrData));
				end;
				FillChar(FPInstr^[FInstrLoaded-1], SizeOf(TInstrData), 0);
				with FPInstr^[FInstrLoaded-1] do begin
					Str := Txt;
					H:='';
					Len:=0;
					for i:=1 to Length(Code) do begin
						C:=Code[i];
						if C in ['0'..'9', 'A'..'F'] then begin
							H:=H+C;
							if Length(H)=2 then begin
								Bytes[Len].Flag := 0; //Это байт инструкции
								Bytes[Len].Value := ParseNumericValue('$'+H);
								Inc(Len);
								H:='';
							end;
						end else
						if C in ['a'..'z'] then begin
								Bytes[Len].Flag := 1; //Это байт данных
								Bytes[Len].Value := Ord(C);
								Inc(Len);
						end else
						if C<>' ' then Exception.Create('Не удалось разобрать код инструкции');
						if Len > FInstrMaxLen then FInstrMaxLen := Len;
					end;
				end;
			end;
	end;
	CloseFile(F);
	ReallocMem(FPInstr, FInstrLoaded*SizeOf(TInstrData));
end;

function TDisAsm.Disassemble(Arr:PByteArray; PC:Cardinal; MaxLen:Integer; var Output:String):Integer;
var i, j, P, c, v: Integer;
		S:String;
begin
	Result := 0;
	for i:=0 to FInstrLoaded-1 do begin
		with FPInstr^[i] do begin
			if Len > MaxLen then Continue; //Если эта инструкция длиннее буфера, идем к следующей
			for j:=0 to Len-1 do begin
				if (Bytes[j].Flag = 0) and (Bytes[j].Value <> Arr^[j]) then Break;
			end;
			if j=Len then begin
				Result := Len;
				S:=Str;
				P:=Pos('$nn', S);
				if P>0 then begin
					c := 0;
					v := 0;
					for j:=0 to Len-1 do
						if (Bytes[j].Flag = 1) and (Bytes[j].Value=Ord('n')) then begin
							Inc(v, Arr^[j] shl (c*8));
							Inc(c);
						end;
					S := AnsiReplaceStr(S, '$nn', IntToHex(v, 4));
				end;
				P:=Pos('$n', S);
				if P>0 then begin
					v:=0;
					for j:=0 to Len-1 do
						if (Bytes[j].Flag = 1) and (Bytes[j].Value=Ord('n')) then begin
							v := Arr^[j];
							Break;
						end;
					S := AnsiReplaceStr(S, '$n', IntToHex(v, 2));
				end;
				P:=Pos('$d', S);
				if P>0 then begin
					v:=0;
					for j:=0 to Len-1 do
						if (Bytes[j].Flag = 1) and (Bytes[j].Value=Ord('d')) then begin
							v := Arr^[j];
							Break;
						end;
					S := AnsiReplaceStr(S, '$d', IntToHex(v, 2));
				end;
				P:=Pos('PC+$e', S);
				if P>0 then begin
					v:=0;
					for j:=0 to Len-1 do
						if (Bytes[j].Flag = 1) and (Bytes[j].Value=Ord('e')) then begin
							v := Arr^[j];
							Break;
						end;
					S := AnsiReplaceStr(S, 'PC+$e', IntToHex(Integer(PC)+Len+Shortint(v), 4));
				end;
				Output := S;
				Exit;
			end;
		end;
	end;
end;


end.
