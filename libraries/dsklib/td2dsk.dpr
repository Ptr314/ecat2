program td2dsk;
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

		Version: 0.1 29/01/2009.

Russian:
		���� ���� �������� ��������� ����������� ������������, �� ������
		�������������� � �������� ��� �� �������� �������� GNU General Public
		License, �������������� Free Software Foundation, ������ 3, ���
		����� �������, �� ���� ����������.

		��������� ���������������� � ��������, ��� ��� �������� ��������,
		�� ��� �����-���� ��������, � ��� ����� ��������������� ��������
		������������ �������� ��� ����������� ��� ������������ �����.
		��������� �������� ����� �������� GNU General Public License.

		����� ������ �������� ������ ������������ ������ � ���� ������,
		� ��������� ������ �� ������ �������� �� �� ������
		<http://www.gnu.org/licenses/>

		�����: Panther <http://www.emuverse.ru/wiki/User:Panther>
}

{$APPTYPE CONSOLE}

uses
	SysUtils, Windows, DateUtils,
	teledisk10;

procedure WriteOEM(S:PChar);
var SOut: PChar;
begin
	SOut:=StrAlloc(StrLen(S)+1);
	CharToOEM(S, SOut);
	Write(SOut);
	StrDispose(SOut);
end;

procedure WritelnOEM(S:PChar);
begin
	WriteOEM(S); writeln;
end;

var InputFile, OutputFile: String;
		Res: Integer;
		Image: Pointer;
		TDInfo: TTeleDiskInfo;
		Confirm: String;
		i: Integer;
begin
	InputFile := ParamStr(1);
	//if InputFile='' then InputFile := '216ADV.TD0';
	if InputFile='' then begin
		WritelnOEM('������ �������: td2dsk <�������_����> [�������� ����]');
		exit;
	end;
	WriteOEM('����               = '); WritelnOEM(PChar(InputFile));
	Res := TeleDisk_LoadFile(InputFile, TDInfo, Image, TD_MODE_CHECK_CRC);
	if Res = TD_RESULT_OK then begin
		try
			with TDInfo do begin
				WriteOEM  ('������             = '); Writeln(Sides);
				WriteOEM  ('�������            = '); Writeln(Tracks);
				WriteOEM  ('��������           = '); Writeln(Sectors);
				WriteOEM  ('������ �������     = '); Writeln(SectSize);
				WriteOEM  ('������ ������      = '); Writeln(ImageSize);
				WriteOEM  ('����� �����������  = '); Writeln(CommentLen);
				if CommentLen > 0 then begin
					WriteOEM  ('���� �����������   = ');
					Writeln(DateTimeToStr(EncodeDateTime(Comment_yr, Comment_mon, Comment_day,
												Comment_hr, Comment_min, Comment_sec, 0)));
					while (CommentLen>0) and (Comment[CommentLen-1]=#0) do
						Dec(CommentLen);
					Writeln;
					for i:=0 to CommentLen-1 do begin
						if Comment[i]=#0 then Writeln
						else Write(Comment[i]);
					end;
					Writeln;
				end;
			end;
			OutputFile := ParamStr(2);
			if OutputFile='' then OutputFile := ChangeFileExt(InputFile, '.dsk');
			Writeln;
			WriteOEM('�����              = '); WritelnOEM(PChar(OutputFile));
			Writeln;
			if FileExists(OutputFile) then begin
				WriteOEM('�������� ���� ��� ����������, ������������? (y/n):');
					readln(Confirm);
					if (Confirm<>'Y') and (Confirm<>'y') then Exit;
				end;
			if TeleDisk_SaveImage(Image, TDInfo.ImageSize, OutputFile)<>TD_RESULT_OK then
				writelnOEM('������: �� ������� �������� �������� ����');
		finally
			TeleDisk_Free(Image);
		end;
	end else
		case Res of
			TD_ERROR_FILE:        writelnOEM('������: �� ������� ��������� ������� ����!');
			TD_ERROR_MEMORY:      writelnOEM('������: �� ������� �������� ����� � ������!');
			TD_ERROR_BAD_HEADER:  writelnOEM('������: ������ �� ��������� ��� ���� ���������!');
			TD_ERROR_UNSUPPORTED: writelnOEM('������: ������ ������ �� ��������������!');
			TD_ERROR_BAD_SECTOR:  writelnOEM('������: ��������� ������� �������� �������� ������!');
			TD_ERROR_BAD_CRC:     writelnOEM('������ CRC: ������� ���� ���������!');
			TD_ERROR_BAD_DATA,
			TD_ERROR_BAD_PATTERN: writelnOEM('������: ������ �������� �������� ������!');
		end;
end.
