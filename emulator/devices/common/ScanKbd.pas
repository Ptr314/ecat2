unit ScanKbd;
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

interface

uses
		Dialogs, SysUtils, StrUtils,
		Config,
		Core, Keyboard, Utils;

const
		cMaxScanKeys = 200;

type
	TScanKbdData = record
		Key: Cardinal;
		Scan: Cardinal;
		Output: Cardinal;
	end;

	TScanKbd = class (TKeyboard)
	private
		FIScan: TInterface;
		FIOutput: TInterface;
		FICtrl: TInterface;
		FIShift: TInterface;
		FIRusLat: TInterface;
		FKeysCount: Cardinal;
		FScanLines: Cardinal;
		FOutLines: Cardinal;
		FScanData: array [0..cMaxScanKeys-1] of TScanKbdData;
		FKeyArray: array [0..15] of Cardinal;
		FKCtrl: Word;
		FKShift: Word;
		FKRusLat: Word;
		procedure ScanChanged(NewValue, OldValue: Cardinal);
		procedure CalculateOut;
	public
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
		procedure KeyDown(Key:Word); override;
		procedure KeyUp(Key:Word); override;
	end;

implementation

constructor TScanKbd.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIScan := CreateInterface(8, 'scan', MODE_R, ScanChanged);
	FIOutput := CreateInterface(8, 'output', MODE_W);
	FICtrl := CreateInterface(1, 'ctrl', MODE_W);
	FIShift := CreateInterface(1, 'shift', MODE_W);
	FIRusLat := CreateInterface(1, 'ruslat', MODE_W);

	FKeysCount :=0;

	FillChar(FKeyArray, Sizeof(FKeyArray), 255);
end;

function CreateScanKbd(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TScanKbd.Create(IM, ConfigDevice);
end;

procedure TScanKbd.LoadConfig;
var j:Integer;
		Layout, Entity : String;
		ScanBit, OutputBit: Cardinal;
		KeyCode: Integer;
begin
	inherited LoadConfig(SD);

	Layout := AdjustLineBreaks(Trim(FConfigData.Parameters['@layout'].Right_extended),tlbsLF);
	Layout := AnsiReplaceStr(Layout, #9, ' ');
	Layout := TrimLeft(Layout);
	ScanBit := 0;
	OutputBit := 0;
	while Length(Layout)>0 do begin
		if Layout[1] = #10 then begin
			Inc(OutputBit);
			ScanBit := 0;
			Layout := TrimLeft(Layout);
		end else
		if Layout[1] = ' ' then begin
			Inc(ScanBit);
			Layout := TrimLeft(Layout);
		end else
		if Layout[1] = '|' then begin
			Layout := AnsiRightStr(Layout, Length(Layout)-1);
		end else begin
			Entity := '';
			j := 1;
			while (j<=Length(Layout)) and not (Layout[j] in [' ', #10, '|']) do Inc(j);
			Entity := Copy(Layout, 1, j-1);
			if Entity<>'__' then begin
				KeyCode := TranslateNameToCode(Entity);
				if KeyCode<0 then
					raise Exception.Create('�������� ���������� �������� ����������� ��� ������� '''+Entity+'''!');
				Inc(FKeysCount);
				with FScanData[FKeysCount-1] do begin
					Key := KeyCode;
					Scan := ScanBit;
					Output := OutputBit;
				end;
			end;
			Layout := AnsiRightStr(Layout, Length(Layout)-Length(Entity));
		end;
	end;
	FScanLines := ScanBit+1;
	FOutLines := ScanBit+1;

	FKCtrl := TranslateNameToCode(FConfigData.Parameters['ctrl'].Value);
	FKShift := TranslateNameToCode(FConfigData.Parameters['shift'].Value);
	FKRusLat := TranslateNameToCode(FConfigData.Parameters['ruslat'].Value);
end;

procedure TScanKbd.KeyDown(Key:Word);
var i:Integer;
		L: Cardinal;
begin
	if Key=FKCtrl then FICtrl.Change(0)
	else
	if Key=FKShift then FIShift.Change(0)
	else
	if Key=FKRusLat then FIRusLat.Change(0)
	else
	for i:=0 to FKeysCount-1 do
		if FScanData[i].Key = Key then begin
			//����� ������� �����, �� ������� ��������� �������
			L := FScanData[i].Scan;
			//���������� ��������������� ���
			FKeyArray[L] := FKeyArray[L] and not CreateMask(1, FScanData[i].Output);
			CalculateOut;
		end;
end;

procedure TScanKbd.KeyUp(Key:Word);
var i:Integer;
		L: Cardinal;
begin
	if Key=FKCtrl then FICtrl.Change(1)
	else
	if Key=FKShift then FIShift.Change(1)
	else
	if Key=FKRusLat then FIRusLat.Change(1)
	else
	for i:=0 to FKeysCount-1 do
		if FScanData[i].Key = Key then begin
			//����� ������� �����, �� ������� ��������� �������
			L := FScanData[i].Scan;
			//������������� ��������������� ���
			FKeyArray[L] := FKeyArray[L] or CreateMask(1, FScanData[i].Output);
			CalculateOut;
		end;
end;

procedure TScanKbd.ScanChanged(NewValue, OldValue: Cardinal);
begin
	CalculateOut;
end;

procedure TScanKbd.CalculateOut;
var i:Integer;
		OutValue: Cardinal;
		Mask: Integer;
begin
	OutValue := Cardinal(-1);
	for i:=0 to FScanLines-1 do begin
		//���� ������� ��� ����� �������
		Mask := CreateMask(1, i);
		if FIScan.Value and Mask = 0 then
			OutValue := OutValue and FKeyArray[i];
	end;
	//if (FIScan.Value and $FF <> 0) and (OutValue and $FF <> $FF) then
	//	FIM.DM.Error(Self, IntToHex(FIScan.Value, 2) +': ' + IntToHex(OutValue, 2));

	FIOutput.Change(OutValue);
	//FIControl.Change(7);
end;

begin
	RegisterDeviceCreateFunc('scan-keyboard', @CreateScanKbd);
end.
