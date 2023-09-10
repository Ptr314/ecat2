unit dsklib;
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

{$DEFINE USE_ZIP}

interface

uses 	Classes,
			{$IFDEF USE_ZIP}KAZip,{$ENDIF}
			DskDef, TeleDisk;

const
		DSKLIB_STRICT_DATA = $01;

		DSKLIB_OK = 0;
		DSKLIB_ERROR_UNKNOWN = 1;
		DSKLIB_ERROR_BAD_INI = 2;
		DSKLIB_ERROR_FILE = 3;

function DskLib_LoadFile(InputFile:String; var DiskInfo:TDiskInfo; Mode:Integer; Output:TStream):Integer;

implementation

uses SysUtils, IniFiles;

var KnownFiles: TStringList;

procedure DskLib_LoadConfig;
var Ini: TIniFile;

begin
	Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'dsklib.ini');
	Ini.ReadSectionValues('disk_images', KnownFiles);
	Ini.Free;
end;

function DskLib_GetKnownData(Ext:String; var DiskInfo:TDiskInfo):Integer;
var S:String;
		Vals: TStringList;
begin
	Result := DSKLIB_ERROR_UNKNOWN;
	if Ext[1]<>'.' then
		S := KnownFiles.Values[Ext]
	else
		S := KnownFiles.Values[Copy(Ext, 2, Length(Ext)-1)];
	if S='' then Exit;

	Vals := TStringList.Create;
	try
		Vals.DelimitedText := S;
		try
			Result := DSKLIB_ERROR_BAD_INI;
			with DiskInfo do begin
				Sides := StrToInt(Vals.Strings[0]);
				Tracks := StrToInt(Vals.Strings[1]);
				Sectors := StrToInt(Vals.Strings[2]);
				SectSize := StrToInt(Vals.Strings[3]);
				ImageSize := Sides * Tracks * Sectors * SectSize;
			end;
		except
			on EStringListError do exit;
		end;
	finally
		Vals.Free;
	end;
	Result := DSKLIB_OK;
end;

function DskLib_LoadImage(InputFile:String; Output:TStream):Integer; overload;
var	Input: TStream;
begin
	Result := DSKLIB_OK;
	try
		Input := TFileStream.Create(InputFile, fmOpenRead);
		try
			Output.CopyFrom(Input, 0);
		finally
			Input.Free;
		end;
	except
		Result := DSKLIB_ERROR_FILE;
	end;
end;

function DskLib_LoadImage(Input, Output:TStream):Integer; overload;
begin
	Result := DSKLIB_OK;
	try
		Output.CopyFrom(Input, 0);
	except
		Result := DSKLIB_ERROR_FILE;
	end;
end;

function DskLib_LoadFile(InputFile:String; var DiskInfo:TDiskInfo; Mode:Integer; Output:TStream):Integer;
var Ext: String;
		{$IFDEF USE_ZIP}
		MS: TStream;
		Zip: TKAZip;
		ZipEntry: TKAZipEntriesEntry;
		{$ENDIF}
begin
	Result := DSKLIB_OK;
	Ext:=AnsiLowerCase(ExtractFileExt(InputFile));
	if DskLib_GetKnownData(Ext, DiskInfo)=DSKLIB_OK then begin
		DskLib_LoadImage(InputFile, Output);
	end else
	if Ext='.td0' then begin
		Result := TeleDisk_LoadFile(InputFile, Output);
{$IFDEF USE_ZIP}
	end else
	if Ext='.zip' then begin
		Zip := TKAZip.Create(nil);
		try
			Zip.Open(InputFile);
			if Zip.Entries.Count=1 then begin
				ZipEntry := Zip.Entries.Items[0];
				Ext:=AnsiLowerCase(ExtractFileExt(ZipEntry.FileName));
				if (Ext='.td0') or (DskLib_GetKnownData(Ext, DiskInfo)=DSKLIB_OK) then begin
					MS := TMemoryStream.Create;
					try
						ZipEntry.ExtractToStream(MS);
						MS.Position := 0;
						if (Ext='.td0') then
							Result := TeleDisk_LoadFromStream(MS, Output)
						else
							Result := DskLib_LoadImage(MS, Output);
					finally
						MS.Free;
					end;
				end else
					Exception.Create('─рээ√щ ЇюЁьрЄ эх яюффхЁцштрхЄё ');
			end;
		finally
			Zip.Free;
		end;
{$ENDIF}
	end else
		Exception.Create('─рээ√щ ЇюЁьрЄ эх яюффхЁцштрхЄё ');
end;

begin
	KnownFiles := TStringList.Create;
	KnownFiles.Values['odi'] := '2,80,5,1024';
	KnownFiles.Values['od2'] := '2,85,10,1024';
	KnownFiles.Values['trd'] := '2,80,16,256';
	DskLib_LoadConfig;
end.
