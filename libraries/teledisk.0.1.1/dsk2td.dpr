program dsk2td;
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
	SysUtils, Windows, DateUtils, StrUtils,
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

procedure Error(S:String);
begin
	if Length(S) > 0 then WritelnOEM(Pchar(S))
	else begin
		{WritelnOEM('������������� ���������:');} Writeln;
		WritelnOEM('dsk2td.exe -t=X -h=X -c=XX -n=XX -s=XXX [-d=X] input_file [output_file]'); Writeln;
		WritelnOEM('������������ ���������:');
		WritelnOEM(' -t[ype]=X             ��� ���������');
		WritelnOEM('                         0=5.25" / 96 tpi disk in 48 tpi drive');
		WritelnOEM('                         1=5.25" / 360K');
		WritelnOEM('                         2=5.25" / 1.2M');
		WritelnOEM('                         3=3.5"  / 720K');
		WritelnOEM('                         4=3.5"  / 1.44M');
		WritelnOEM('                         5=8"    / ?');
		WritelnOEM('                         6=3.5"  / ?');
		WritelnOEM(' -h[eads]=X            ���������� ������ (1, 2)');
		WritelnOEM(' -�[cylinders]=XX      ���������� ��������� (������ 40 ��� 80)');
		WritelnOEM(' -n[sec]=XX            ���������� ��������');
		WritelnOEM(' -s[ize]=XXX           ������ ������� (128, 256, 512, 1024)');
		Writeln;
		WritelnOEM('�������������� ���������:');
		//WritelnOEM(' -v[er]=XX             ������ Teledisk (*15=1.5)');
		WritelnOEM(' -d[ensity]=X          ��������� ������, ����/c (0=250, 1=300, 2=500)');
		WritelnOEM('                         (360K, 720K:  250 ����/c)');
		WritelnOEM('                         (1.2M, 1.44M: 500 ����/c)');
	end;
	Halt;
end;

var InputFile, OutputFile: String;
		i, j: Integer;
		S, param, value: String;

		TDHeader: TTDHeader;
		TDTrack: TTDTrack;
		TDSector: TTDSector;
		FH, FileLength: Integer;
		Buffer, SectorBuffer: PTDBuffer;

		Cylinders, ImageSize, SectSize, cyl, head, sec, PO: Integer;
		//Dummy: Byte;
		Dummy2: Word;

const Densities: array[0..2] of String = ('250', '300', '500');
			Drives: array[0..6] of String = ('5.25" / 96 tpi disk in 48 tpi drive', '5.25" / 360K', '5.25" / 1.2M', '3.5" / 720K', '3.5" / 1.44M', '8" / ?', '3.5" / ?');
			Sizes: array[0..5] of String = ('128', '256', '512', '1024', '2048', '4096');
begin
	if ParamCount=0 then Error('');
	InputFile:=''; OutputFile:='';
	Cylinders := 0;
	//Dummy := 0;
	TDHeader.dens := $FF;
	for i:=1 to ParamCount do begin
		S:= ParamStr(i);
		if S[1]='-' then begin
			j := Pos('=', S);
			if j=0 then Error('����������� �������� '+S)
			else begin
				param := AnsiLowerCase(Copy(S, 2, j-2));
				value := Trim(Copy(S, j+1, Length(S)-j+1));
				if Length(value)=0 then Error('�� ������� �������� ��������� '+param);
				if (param='t') or (param='type') then TDHeader.typ := StrToInt(value)
				else
				if (param='h') or (param='heads') then TDHeader.sides := StrToInt(value)
				else
				if (param='c') or (param='cylinders') then Cylinders := StrToInt(value)
				else
				if (param='n') or (param='nsec') then TDTrack.nsec := StrToInt(value)
				else
				if (param='s') or (param='size') then begin
					TDSector.secz := $FF;
					for j:=0 to 5 do
						if value=Sizes[j] then TDSector.secz := j;
					if TDSector.secz = $FF then Error('����������� ������ �������!');
				end
				else
				if (param='d') or (param='density') then TDHeader.dens := StrToInt(value)
				else
					Error('����������� �������� '+S);
			end;
		end else
			if InputFile='' then InputFile := S
			else
			if OutputFile='' then OutputFile := S
			else
			Error('����������� �������� '+S);

	end;

	if InputFile='' then Error('�� ������ ������� ����');
	if OutputFile='' then OutputFile := ChangeFileExt(InputFile, '.td0');

	with TDHeader do begin
		sig[0] := 'T';
		sig[1] := 'D';
		vol := 0;
		chk := 0;
		ver := $15;
		flag := 0;
		dos := 0;
	end;

	if (TDHeader.dens = $FF) then begin
		case TDHeader.typ of
			2,4: TDHeader.dens := 2;
			else TDHeader.dens := 0;
		end;
	end;
	SectSize := 1 shl (TDSector.secz+7);
	ImageSize := TDHeader.sides * Cylinders * TDTrack.nsec * SectSize;

	WriteOEM('������:           = '); Writeln(TDHeader.sides);
	WriteOEM('�������:          = '); Writeln(Cylinders);
	WriteOEM('��������:         = '); Writeln(TDTrack.nsec);
	WriteOEM('������ �������:   = '); Write(SectSize); WritelnOEM(' ����');
	WriteOEM('��������� ������: = '); Write(Densities[TDHeader.dens]); WritelnOEM(' ����/�');
	WriteOEM('��������:         = '); Writeln(Drives[TDHeader.typ]); 
	WriteOEM('������� ����      = '); Writeln(InputFile);
	WriteOEM('�������� ����     = '); Writeln(OutputFile);
	WriteOEM('������ �������    = $'); Writeln(IntToHex(TDHeader.ver, 2)); 

	TDHeader.crc := CRC16(@TDHeader, SizeOf(TDHeader)-2);


	FH := FileOpen(InputFile, fmOpenRead);
	FileLength := 0;
	Buffer := nil;
	if FH > 0 then begin
		FileLength := FileSeek(FH,0,2);
		FileSeek(FH,0,0);
		GetMem(Buffer, FileLength);
		if Assigned(Buffer) then
			FileRead(FH, Buffer^, FileLength)
		else Error('������ ��������� ������.');
		FileClose(FH);
	end	else Error('�� ������� ������� ����.');

	if ImageSize<>FileLength then begin
		FreeMem(Buffer);
		Writeln;
		WriteOEM('������: ������ ������ ('); Write(FileLength); WriteOEM(') �� ������������� ���������� ('); Write(ImageSize); WriteOEM(')!');
		Halt;
	end;

	GetMem(SectorBuffer, SectSize+1);
	FH := FileCreate(OutputFile);
	FileWrite(FH, TDHeader, SizeOf(TDHeader));

	for cyl:=0 to Cylinders-1 do
		for head:=0 to TDHeader.sides-1 do begin
			TDTrack.trk := cyl;
			TDTrack.head := head;
			TDTrack.crc := Byte(CRC16(@TDTrack, SizeOf(TDTrack)-1) and $FF);
			FileWrite(FH, TDTrack, SizeOf(TDTrack));
			for sec:=1 to TDTrack.nsec do begin
				PO := ((cyl*TDHeader.sides + head)*TDTrack.nsec + sec-1)*SectSize;
				TDSector.trk := cyl;
				TDSector.head := head;
				TDSector.sec := sec;
				TDSector.cntrl := 0;
				TDSector.crc := Byte(CRC16(@Buffer[PO], SectSize) and $FF);
				FileWrite(FH, TDSector, SizeOf(TDSector));
				Dummy2 := TeleDisk_EncodeSector(@Buffer[PO], SectorBuffer, SectSize);
				FileWrite(FH, Dummy2, 2);
				FileWrite(FH, SectorBuffer^, Dummy2);
				//Dummy2 := SectSize+1;
				//FileWrite(FH, Dummy2, 2);
				//FileWrite(FH, Dummy, 1);
				//FileWrite(FH, Buffer[PO], SectSize);
			end;
		end;
	TDTrack.nsec := $FF;
	FileWrite(FH, TDTrack, SizeOf(TDTrack));
	FileClose(FH);

	FreeMem(SectorBuffer);
end.
