unit cpmdisk10;
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

		Some data structures are used from Odi.wcx plugin taken from
		http://orion-z.hoter.ru/

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

		Этот модуль основан на исследованиях, выполненных Willy, результаты
		которых можно найти здесь: <http://www.fpns.net/willy/wteledsk.htm>

Пример использования:
var Buffer: Pointer;
		DiskData: TCPMDiskData;

FillChar(DiskData, SizeOf(DiskData), 0);
Res := CPMDisk_LoadDir(Dir, Buffer, DiskData, CPM_MODE_USE_INI);
if Res=CPM_RESULT_OK then begin
	//
	// Использование образа Buffer^
	//
	CPMDisk_Free(Buffer);
end;
}

interface
type
	TCPMDiskData = packed record
		Sides: Integer;
		Tracks: Integer;
		Sectors: Integer;
		SectSize: Integer;
		ImageSize: Integer;
		System: array [0..15] of Char;
		Boot: array [0..15] of Char;
	end;
	PCPMDiskData = ^TCPMDiskData;

															//BLS = 2^n - размер блока. 2^11=2048
	TBootDPB = packed record    // Disk Parameters Header (BOOT .. BOOT+1EH, BOOT+1FH=CRC)
//-------------------------------------------------------------------- Orion specific
							 jump: array [0..7] of byte;
							 PAGE1: byte;   //=01
							 PAGE2: byte;   //=01
							 LEN1:  byte;   // размер физ. сектора (1=256, 2=512, 3=1024) 				=03 (1024)
							 LEN2:  byte;   // сторон (0=one_side, 1=double_sided)								=01 (ds)
							 SEC:   word;   // физ. секторов в дорожке														=0005
							 TRK:   word;   // физ. дорожек (1 сторона)														=0050 (80)
//-------------------------------------------------------------------- CP/M standard
							 SPT:   word;   // лог. секторов (128) в дорожке											=0028 (40)
							 BSH:   byte;   // Block Shift = n-7																	=04 (2048)
							 BLM:   byte;   // Block Mask  = 2^BSH-1                            	=0F (2048)
							 EXM:   byte;   // Extent Mask (0=16k, 1=32k, 3=64k, 7=128k)		      =00 (16k)
															//						 (2^(BSH-2)-1) для DSM<256
															// 	           (2^(BSH-3)-1) для DSM>=256		  	      =00 (16k) ?
							 DSM:   word;   // user space in blocks																=0184
															//((LEN2+1)*SEC*TRK - OFF*SEC)*(2^(LEN1+7)/BLS - CKS*128/BLS
							 DRM:   word;   // max quantity of file records (FCBs) in catalog			=007F
							 AL:    word;   // 16-bit Directory Allocation Pattern								=00C0
							 CKS:   word;   // Directory Check Sum = catalog size (in logical blocks)	=0020 (4k)
							 OFF:   word;   // system tracks						=0004 (20k)
							 CRC:   byte;   // simple additional CRC beginning with 066h					=C5
						 end;
	PBootDPB= ^TBootDPB;

	TFCBExtents = array[0..7] of word;

	TFCBFileName = array[0..10] of char;

	TFCB = packed record
					 User:       byte;
					 FileName:   TFCBFileName;
					 FCBordinalN:word;                    // partial sequentional number (= "size div 128" for filesystems where each FCB addresses > 16384 bytes)
					 dummy:      byte;
					 SizePartial:byte;                    // current part size in 128bytes logical blocks (= size mod 128)
					 FCBextents: TFCBExtents;             // used 2k extents chain. 0, E5E5 - unused
				 end;
	PFCB = ^TFCB;
	TAllocBuffer = array [0..1024*1024] of Byte;
	PAllocBuffer = ^TAllocBuffer;

const
			CPM_INIFILE_NAME  = '_disk.ini';
			CPM_BOOTFILE_NAME = '_boot.bin';

			CPM_RESULT_OK = 0;
			CPM_ERROR_INVALID_INI = 1;
			CPM_ERROR_DIR_FULL = 2;
			CPM_ERROR_DISK_FULL = 3;
			CPM_ERROR_NO_FORMAT = 4;
			CPM_ERROR_NO_BOOT = 5;

			CPM_MODE_USE_DATA = $00;			//DATA ONLY
			CPM_MODE_USE_INI  = $01;			//INI, BOOT, DATA
			CPM_MODE_USE_BOOT = $02; 			//BOOT, INI, DATA

	DPBdefault: TBootDPB =
		(jump: ($C3, $20, $00, $00, $53, $44, $43, $32);
		 page1: $01;
		 page2: $01;
		 len1:  $03;
		 len2:  $01;
		 sec:   $0005;
		 trk:   $0050;
		 spt:   $0028;
		 bsh:   $04;
		 blm:   $0F;
		 exm:   $00;
		 dsm:   $0184;
		 drm:   $007F;
		 al:    $00C0;
		 cks:   $0020;
		 off:   $0004;
		 crc:   $D3);

	MAX_USER = 15;
	BLOCKS_IN_EXTENT = 8;
		 
function CPMDisk_LoadDir(Dir:String; var Buffer:Pointer; var DefDiskData: TCPMDiskData; Mode: Integer): Integer;

procedure CPMDisk_Free(Buffer:Pointer);

implementation

uses SysUtils, INIFiles, Math;

function DPB_CRC(const DPB:TBootDPB):byte;
var i:integer;
begin
	Result:=$66;
	for i:=0 to SizeOf(DPB)-SizeOf(DPB.CRC) do
		Result:=Result + byte(PChar(@DPB)[i]);
end;


function CPM_CreateEmpty(const DiskData:TCPMDiskData; BootFile:String): Pointer;
var DPB:TBootDPB;
		ImageSize, BootSize: Integer;
		fh: Integer;
		Buffer: Pointer;
		BootBuffer: Pointer;
begin
	if (BootFile<>'') and FileExists(BootFile) then begin
		fh := FileOpen(BootFile, fmOpenRead);
		BootSize := FileSeek(fh,0,2);
		FileSeek(fh,0,0);
		GetMem(BootBuffer, BootSize);
		FileRead(fh, BootBuffer^, BootSize);
		FileClose(fh);
		Move(BootBuffer^, DPB, SizeOf(DPB));
	end else begin
		BootSize:=0; BootBuffer := nil;
		Move(DPBdefault, DPB, SizeOf(TBootDPB));
		DPB.OFF := 0;  //Здесь удостовериться, возможно, 0 тоже подойдет
	end;

	DPB.LEN1 := Round(Log2(DiskData.SectSize))-7;
	DPB.LEN2 := DiskData.Sides - 1;
	DPB.SEC  := DiskData.Sectors;
	DPB.TRK  := DiskData.Tracks;
	DPB.SPT  := (DiskData.SectSize shr 7) * DiskData.Sectors;
	//DPB.BSH := default;
	//DPB.BLM := default;
	//DPB.EXM := default;
	//DPB.AL  := default;
	//DPB.CKS := default;

	DPB.DSM := DPB.SEC * (DPB.TRK - DPB.OFF) - (DPB.CKS shr 3);
	DPB.DRM := DPB.CKS shl 2 - 1;
	DPB.CRC := DPB_CRC(DPB);

	ImageSize := Integer(DPB.LEN2+1) * DPB.TRK * DPB.SEC * (128 shl DPB.LEN1);
	GetMem(Buffer, ImageSize);
	FillChar(Buffer^, ImageSize, $E5);
	if BootSize=0 then
		Move(DPB, Buffer^, SizeOf(DPB))
	else begin
		Move(BootBuffer^, Buffer^, BootSize);
		//Move(DPB, Buffer^, SizeOf(DPB));
		FreeMem(BootBuffer);
	end;
	Result := Buffer;
end;

//Функция добавляет файл к образу. В данном случае она ищет первый
//пустой экстент и пишет файл. Если понадобится несколько экстентов,
//а следующие окажутся заняты, функция испортит данные. В этом сучае
//ее придется переписать. Хотя пока нет функции удаления файлов,
//это не важно
function CPM_AddFile(FileName: String; user: Byte; Buffer: Pointer; AllocData:PAllocBuffer):Integer;
var DPB:TBootDPB;
		CatalogOffset, P, i, Bytes_Read, Log_Read: Integer;
		FCB : PFCB;
		BlocksCount, BlockSize, CurrBlock, ExtentNum:Integer;
		FileSize, fh, FileBlocks: Integer;
		FCBFileName: TFCBFileName;
		FName, FExt: string;
		j: Word;
begin
	Result := CPM_RESULT_OK;
	Move(Buffer^, DPB, SizeOf(DPB));

	BlockSize := 1 shl (DPB.BSH + 7);
	BlocksCount:=DPB.DSM*2*1024 div BlockSize;

	if DPB.OFF > 0 then
		CatalogOffset := DPB.OFF * DPB.SEC * (128 shl DPB.LEN1)
	else
		CatalogOffset := BlockSize;
	//DataOffset := CatalogOffset + DPB.CKS*128;


	FillChar(FCBFileName, SizeOf(FCBFileName), ' ');
	FExt  := ExtractFileExt(FileName);
	FName := ExtractFileName(FileName);
	FName := AnsiUpperCase(Copy(FName, 1, Length(FName)-Length(FExt)));
	FExt := AnsiUpperCase(Copy(FExt, 2, Length(FExt)-1));
	for i:=0 to Min(8, Length(FName))-1 do FCBFileName[i]:=FName[i+1];
	for i:=0 to Min(3, Length(FExt))-1 do FCBFileName[i+8]:=FExt[i+1];

	fh := FileOpen(FileName, fmOpenRead);
	if fh>=0 then
		try
			FileSize := FileSeek(fh,0,2);
			FileSeek(fh,0,0);
			//GetMem(BootBuffer, BootSize);
			//FileRead(fh, BootBuffer^, BootSize);
			FileBlocks := FileSize div BlockSize;
			if FileSize mod BlockSize > 0 then Inc(FileBlocks);

			CurrBlock := BLOCKS_IN_EXTENT;
			ExtentNum := -1;
			for i:=0 to FileBlocks-1 do begin
				if CurrBlock = BLOCKS_IN_EXTENT then begin
					Inc (ExtentNum);
					//Ищем свободную запись каталога
					P:=0;
					while P <= DPB.DRM do begin
						FCB := @(PChar(Buffer)[CatalogOffset + P*SizeOf(TFCB)]);
						if FCB^.User <> $E5 then Inc(P) else break;
					end;
					if P <= DPB.DRM then begin
						//Здесь заполняем элемент каталога
						FCB^.User := user;
						Move(FCBFileName, FCB^.FileName, SizeOF(FCBFileName));
						FCB^.FCBordinalN := ExtentNum;
						FCB^.dummy := 0;
						FCB^.SizePartial := 0;
						FillChar(FCB^.FCBextents, SizeOf(FCB^.FCBextents), 0);
					end else begin
						Result := CPM_ERROR_DIR_FULL;
						Exit;
					end;
					CurrBlock := 0;
				end;

				//Ищем свободный блок
				for j:=0 to BlocksCount-1 do
					if AllocData^[j]=0 then break;

				if j < BlocksCount then begin
					FCB^.FCBextents[CurrBlock] := j;
					AllocData^[j] := 1;
					Bytes_Read := FileRead(fh, PChar(Buffer)[CatalogOffset+j*BlockSize], BlockSize);
					Log_Read := Bytes_Read div 128;
					if Bytes_Read mod 128 > 0 then begin
						//Если разер файла не кратен 128, увеличим его на 1 блок и допишем
						//маркер конца текста
						Inc(Log_Read);
						PChar(Buffer)[CatalogOffset+j*BlockSize+Bytes_Read] := #$1A;
					end;
					Inc(FCB^.SizePartial, Log_Read);
				end else begin
						Result := CPM_ERROR_DISK_FULL;
						Exit;
				end;

				Inc(CurrBlock);
			end;
		finally
			FileClose(fh);
		end;
end;

function CPM_AddDir(Dir: String; user: Byte; Buffer: Pointer; AllocData:PAllocBuffer):Integer;
var SR: TSearchRec;
begin
	Result := CPM_RESULT_OK;
	if FindFirst(Dir+'\*.*', faAnyFile-faDirectory, SR)=0 then begin
		repeat
			if (sr.Name<>'.') and (sr.Name<>'..') then begin
				CPM_AddFile(Dir+'\'+sr.Name, user, Buffer, AllocData);
			end;
		until FindNext(sr) <> 0;
		FindClose(sr);
	end;
end;

function CPM_CreateAlloc(Buffer:Pointer):PAllocBuffer;
var BlocksCount, BlockSize, i:Integer;
begin
	with PBootDPB(Buffer)^ do begin
		BlockSize := 1 shl (BSH + 7);
		BlocksCount:=DSM*2*1024 div BlockSize;
		GetMem(Result, BlocksCount);
		FillChar(Result^, BlocksCount, 0);
		for i:=0 to Pred(CKS*128 div BlockSize) do Result^[i]:=1;
	end;
end;

function FillDataFromINI(const CfgFile:String; var DiskData:TCPMDiskData):Integer;
var
		INIFile: TINIFile;
begin
	INIFile := TINIFile.Create(CfgFile);
	with DiskData do begin
		Sides := INIFile.ReadInteger('parameters', 'sides', Sides);
		Tracks := INIFile.ReadInteger('parameters', 'tracks', Tracks);
		Sectors := INIFile.ReadInteger('parameters', 'sectors', Sectors);
		SectSize := INIFile.ReadInteger('parameters', 'sector_size', SectSize);
		StrCopy(System, PChar(INIFile.ReadString('parameters', 'system', System)));
		StrCopy(Boot, PChar(INIFile.ReadString('parameters', 'boot', Boot)));
	end;
	INIFile.Free;
	Result := CPM_RESULT_OK;
end;

function FillDataFromBoot(const BootFile:String; var DiskData:TCPMDiskData):Integer;
var DPB:TBootDPB;
		fh: Integer;
begin
	fh := FileOpen(BootFile, fmOpenRead);
	if fh>=0 then begin
		FileRead(fh, DPB, SizeOf(DPB));
		FileClose(fh);
		with DiskData do begin
			Sides := DPB.LEN2+1;
			Tracks := DPB.TRK;
			Sectors := DPB.SEC;
			SectSize := 128 shl DPB.LEN1;
			StrCopy(Boot, PChar(ExtractFileName(BootFile)));
		end;
		Result := CPM_RESULT_OK;
	end else
		Result := CPM_ERROR_NO_BOOT;
end;


function CPMDisk_LoadDir(Dir:String; var Buffer:Pointer; var DefDiskData: TCPMDiskData; Mode: Integer): Integer;
var DiskData: TCPMDiskData;
		Dir2, CfgFile: String;
		SR: TSearchRec;
		u: Byte;
		BootFile: String;
		AllocData:PAllocBuffer;
begin
	Result := CPM_RESULT_OK;
	Dir2 := IncludeTrailingPathDelimiter(Dir);
	CfgFile := Dir2 + CPM_INIFILE_NAME;
	BootFile := Dir2 + CPM_BOOTFILE_NAME;

	Move(DefDiskData, DiskData, SizeOf(DiskData));
	if (Mode and CPM_MODE_USE_INI) <> 0 then begin
		if FileExists(CfgFile) then
			FillDataFromINI(CfgFile, DiskData)
		else
		if FileExists(BootFile) then
			FillDataFromBoot(BootFile, DiskData);
	end else
	if (Mode and CPM_MODE_USE_BOOT) <> 0 then begin
		if FileExists(BootFile) then
			FillDataFromBoot(BootFile, DiskData)
		else
		if FileExists(CfgFile) then
			FillDataFromINI(CfgFile, DiskData);
	end;

	with DiskData do begin
		ImageSize := Sides * Tracks * Sectors * SectSize;
		if ImageSize=0 then begin
			Result := CPM_ERROR_NO_FORMAT;
			Exit;
		end;
		if StrComp(System, '')=0 then StrCopy(System, 'cpm22');
		if StrComp(Boot, '')<>0 then
			BootFile := Dir2 + Boot;
	end;

	if not FileExists(BootFile) then BootFile := '';

	Move(DiskData, DefDiskData, SizeOf(DiskData));

	Buffer    := CPM_CreateEmpty(DiskData, BootFile);
	AllocData := CPM_CreateAlloc(Buffer);

	if FindFirst(Dir2+'user0', faDirectory, SR)=0 then
		for u:=0 to MAX_USER do CPM_AddDir(Dir2+'user'+IntToStr(u), u, Buffer, AllocData)
	else
		CPM_AddDir(Dir2, 0, Buffer, AllocData);

	FreeMem(AllocData);
end;

procedure CPMDisk_Free(Buffer:Pointer);
begin
	FreeMem(Buffer);
end;


end.
