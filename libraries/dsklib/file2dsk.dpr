program file2dsk;
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

{$APPTYPE CONSOLE}

uses
	Windows, SysUtils,	cpmdisk10;

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

var Dir, OutputFile, Confirm: String;
		Buffer: Pointer;
		FileHandle: Integer;
		DiskData: TCPMDiskData;
begin
	Dir := ParamStr(1);
	//if Dir='' then Dir := 'W:\Projects\eCat2\_exe\Software\Orion-128\zexall';
	if Dir='' then begin
		WritelnOEM('Формат запуска: file2dsk <входной_путь> <выходной файл>');
		exit;
	end;

	FillChar(DiskData, SizeOf(DiskData), 0);
	CPMDisk_LoadDir(Dir, Buffer, DiskData, CPM_MODE_USE_INI);

	OutputFile := ParamStr(2);
	if OutputFile='' then OutputFile := 'cpm_disk.odi';
	if FileExists(OutputFile) then begin
		WriteOEM('Выходной файл уже существует, перезаписать? (y/n):');
			readln(Confirm);
			if (Confirm<>'Y') and (Confirm<>'y') then Exit;
	end;

	FileHandle := FileCreate(OutputFile);
	if FileHandle > 0 then begin
		FileWrite(FileHandle, Buffer^, DiskData.ImageSize);
		FileClose(FileHandle);
	end;

	CPMDisk_Free(Buffer);
end.
