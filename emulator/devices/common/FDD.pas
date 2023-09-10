unit fdd;
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
		SysUtils, Dialogs, 
		Config, 
		Core, Utils;

type
	TCommonFDD = class (TComputerDevice)
	private
		FBuffer: PStorage;
		FSides: Integer;
		FTracks: Integer;
		FSectors: Integer;
		FSectorSize: Integer;
		FDiskSize: Integer;
		FStreamFormat: Cardinal;

		FSelector: Cardinal;

		FISelect: TInterface;
		FISide: TInterface;
		FIDensity: TInterface;

		FWriteProtect: Boolean;
		FLoaded: Boolean;

		FFiles: String;
		FFileName: String;

		FSide, FTrack, FSector, FByte: Integer;
		function TranslateAddress: Cardinal;
		function ConvertStreamFormat	(	Buffer:PStorage;
																		Stream_From, Stream_To:Cardinal;
																		OldSectorSize: Integer;
																		var NewSectorSize:Integer
																	):PStorage;
	protected
	public
		property SectorSize:Integer read FSectorSize;
		property IsProtected: Boolean read FWriteProtect;
		property IsLoaded: Boolean read FLoaded;
		property Files: String read FFiles;
		property FileName: String read FFileName;
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
		procedure LoadImage(FileName:String);
		procedure SaveImage(FileName:String);
		procedure UnLoad;
		function IsSelected: Boolean;
		function SeekSector(Track, Sector:Integer):Integer;
		function ReadNextByte: Byte;
		procedure WriteNextByte(Value: Byte);
		procedure ChangeProtection;
		property StreamFormat:Cardinal read FStreamFormat write FStreamFormat;
	end;

const
			FDD_STREAM_PLAIN = 0;
			FDD_STREAM_MFM = 1;
			FDD_STREAM_HEADERS = 2;

implementation

uses Math;

function CreateCommonFDD(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TCommonFDD.Create(IM, ConfigDevice);
end;

constructor TCommonFDD.Create;
begin
	inherited Create(IM, ConfigDevice);

	FISelect := CreateInterface(2, 'select', MODE_R);
	FISide := CreateInterface(1, 'side', MODE_R);
	FIDensity := CreateInterface(1, 'density', MODE_R);

	FBuffer := nil;
	FLoaded := false;

	StreamFormat := FDD_STREAM_PLAIN;
end;

procedure TCommonFDD.LoadConfig;
var FileName: String;
begin
	inherited LoadConfig(SD);
	try
		FSides := ParseNumericValue(FConfigData.Parameters['sides'].Value);
		FTracks := ParseNumericValue(FConfigData.Parameters['tracks'].Value);
		FSectors := ParseNumericValue(FConfigData.Parameters['sectors'].Value);
		FSectorSize := ParseNumericValue(FConfigData.Parameters['sector_size'].Value);
		FSelector := ParseNumericValue(FConfigData.Parameters['selector_value'].Value);
		FFiles := FConfigData.Parameters['files'].Value;
		FDiskSize := FSides*FTracks*FSectors*FSectorSize;
		FWriteProtect := FALSE;
	except
		raise Exception.Create('Неправильно заданы параметры дисковода '''+Name+'''!');
	end;
	try
		FileName := FConfigData.Parameters['image'].Value;
		if FileName<>'' then
			if FileExists(SD.SoftwarePath + FileName) then
				LoadImage(SD.SoftwarePath + FileName)
			else
			if FileExists(SD.SystemPath + FileName) then
				LoadImage(SD.SystemPath + FileName)
			else
				ShowMessage('Файл '''+FileName+''' не найден!')
	except
	end;
end;

procedure TCommonFDD.LoadImage(FileName:String);
var fh, FileSize: Integer;
		FTempBuffer: PStorage;
begin
	fh := FileOpen(FileName, fmOpenRead);
	FileSize := FileSeek(fh, 0, 2);
	if FDiskSize = FileSize then begin
		if Assigned(FBuffer) then FreeMem(FBuffer);
		GetMem(FTempBuffer, FDiskSize);
		FileSeek(fh, 0, 0);
		FileRead(fh, FTempBuffer^, FDiskSize);

		if FStreamFormat<>FDD_STREAM_PLAIN then begin
			FBuffer := ConvertStreamFormat(FTempBuffer, FDD_STREAM_PLAIN, FStreamFormat, FSectorSize, FSectorSize);
			FreeMem(FTempBuffer);
		end else
			FBuffer := FTempBuffer;

		FLoaded := true;
		FFileName := ExtractFileName(FileName);
	end else begin
		if FileSize<0 then
			ShowMessage('Файл образа диска для устройства '''+Name+''' не найден!')
		else
			ShowMessage('Размер файла образа не соответствует необходимым параметрам диска!');
		FFileName := '';
	end;
	FileClose(fh);
end;

procedure TCommonFDD.SaveImage(FileName:String);
var fh: Integer;
		BackupName: string;
begin
	if Assigned(FBuffer) then begin
		if FileExists(FileName) then
		begin
			BackupName := ExtractFileName(FileName);
			BackupName := ChangeFileExt(BackupName, '.bak');
			if not RenameFile(FileName, BackupName) then
				raise Exception.Create('Ошибка создания резервного файла. (Возможно, он уже существует)');
		end;
		fh := FileCreate(FileName);
		FileWrite(fh, FBuffer^, FDiskSize);
		FileClose(fh);
	end else
		raise Exception.Create('Диск не загружен, нет данных для сохранения!');
end;

function TCommonFDD.SeekSector(Track, Sector:Integer):Integer;
begin
	Result := -1;
	if Assigned(FBuffer) then begin
		FSide := not (FISide.Value) and 1;
		FTrack := Track;
		FSector := Sector;
		FByte := 0;
		if Sector > 0 then
			Result := FSectorSize
		else
		if FStreamFormat=FDD_STREAM_MFM then
			Result := 128
		else FIM.DM.Error(Self, 'Режим не поддерживается');
	end;
end;

function TCommonFDD.TranslateAddress: Cardinal;
begin
	Result := ((FTrack*FSides + FSide)*FSectors + FSector-1)*FSectorSize + FByte;
end;

function TCommonFDD.ReadNextByte: Byte;
begin
	if FByte >= FSectorSize then
		FIM.DM.Error(Self, 'Попытка чтения за пределами сектора!');
	if FSector=0 then
		//GAP
		Result := $FF
	else begin
		//Data
		Result := FBuffer^[TranslateAddress];
		Inc(FByte);
	end;
end;

procedure TCommonFDD.WriteNextByte(Value: Byte);
begin
	if FByte >= FSectorSize then
		FIM.DM.Error(Self, 'Попытка записи за пределами сектора!');
	//GAP пропускаем
	if FSector<>0 then begin
		FBuffer^[TranslateAddress] := Value;
		Inc(FByte);
	end;
end;

function TCommonFDD.IsSelected: Boolean;
begin
	Result := (FISelect.Value and $03) = FSelector;
end;

procedure TCommonFDD.UnLoad;
begin
	if Assigned(FBuffer) then FreeMem(FBuffer);
	FBuffer := nil;
	FLoaded := FALSE;
	FFileName := '';
end;

procedure TCommonFDD.ChangeProtection;
begin
	FWriteProtect := not FWriteProtect;
end;

function TCommonFDD.ConvertStreamFormat(Buffer:PStorage;
																				Stream_From, Stream_To:Cardinal;
																				OldSectorSize: Integer;
																				var NewSectorSize:Integer):PStorage;
var NewBuffer: PStorage;
		NewSize, SrcP, DstP: Integer;
		i, j, k, m: Byte;
		Buf: array [0..3] of Byte;
		DataSize: Cardinal;
begin
	case Stream_From of
		FDD_STREAM_PLAIN:
			case Stream_To of
				FDD_STREAM_MFM: begin
					DataSize := Ceil(OldSectorSize * 4 / 3);
					NewSectorSize := 3+8+3 + 5 + 3+DataSize+1+3 + 40;
					NewSize := FSides * FTracks * FSectors *	NewSectorSize;
					GetMem(NewBuffer, NewSize);
					for i:=0 to FSides-1 do
						for j:=0 to FTracks-1 do
							for k:=0 to FSectors - 1 do begin
								SrcP := (i*FTracks*FSectors + j*FSectors + k)*OldSectorSize;
								DstP := (i*FTracks*FSectors + j*FSectors + k)*NewSectorSize;
								//Пролог
								NewBuffer^[DstP+0] := $D5;
								NewBuffer^[DstP+1] := $AA;
								NewBuffer^[DstP+2] := $96;
								Inc(DstP, 3);
								//Поле адресов
								Buf[0]:=254; 	//volume
								Buf[1]:=j;		//track
								Buf[2]:=k;		//sector
								Buf[3]:=xor_check_sum(Buf, 3);
								for m:=0 to 3 do begin
									encode_fm(Buf[m], NewBuffer^[DstP]);
									Inc(DstP, 2);
								end;
								//Эпилог
								NewBuffer^[DstP+0] := $DE;
								NewBuffer^[DstP+1] := $AA;
								NewBuffer^[DstP+2] := $EB;
								Inc(DstP, 3);
								//GAP
								FillChar(NewBuffer^[DstP], 5, $FF);
								Inc(DstP, 5);
								//Пролог
								NewBuffer^[DstP+0] := $D5;
								NewBuffer^[DstP+1] := $AA;
								NewBuffer^[DstP+2] := $AD;
								Inc(DstP, 3);
								encode_mfm(Buffer^[SrcP], NewBuffer^[DstP], OldSectorSize);
								Inc(DstP, DataSize+1);
								NewBuffer^[DstP+0] := $DE;
								NewBuffer^[DstP+1] := $AA;
								NewBuffer^[DstP+2] := $EB;
								Inc(DstP, 3);
								FillChar(NewBuffer^[DstP], 40, $FF);
							end;
					Result := NewBuffer;
				end
			else
				Exception.Create('Данное преобразование форматов образов не поддерживается!');
			end
		else
			Exception.Create('Данное преобразование форматов образов не поддерживается!');
	end;
end;


begin
	RegisterDeviceCreateFunc('fdd', @CreateCommonFDD);
end.
