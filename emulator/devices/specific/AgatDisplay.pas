unit AgatDisplay;
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
		Graphics, Classes,
		Config,
		Core;

type
	TAgatDisplay = class (TDisplay)
	private
		FPMode: TPort;
		FRam: array [0..1] of TRAM;
		FFont: TROM;

		FMode: Cardinal;						//����� ������
		FModule: Cardinal;					//����� ����� ������
		FBase: Cardinal;						//������� ����� ��������
		FPageSize: Cardinal;				//������ ��������
		
		FPrevMode: Cardinal;
		FLines : array [0..255] of PStorage;

		FSystemClock : Cardinal;
		FCounter: Cardinal;
		FBlinkTicks:Cardinal;
		FBlinker: Boolean;

		procedure MemoryChanged(Address: Cardinal);
		procedure DrawByte(Address:Cardinal);
	public
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
		procedure Clock(Counter:Cardinal); override;
		function GetScreen(Required:Boolean):TBitMap; override;
	end;

	const
	Agat_2Colors : array [0..1] of TScreenColor = ( (0, 0, 0), (255, 255, 255));
	Agat_16Colors : array [0..15] of TScreenColor = (
					(  0,   0,   0), (127,   0,   0), (  0, 127,   0), (127, 127,   0),
					(  0,   0, 127), (127,   0, 127), (  0, 127, 127), (255, 255, 255),
					(  0,		0, 	 0), (255,   0,   0), (  0, 255,   0), (255, 255,   0),
					(  0,   0, 255), (255,   0, 255), (  0, 255, 255), (255, 255, 255)
					);

implementation

function CreateAgatDisplay(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TAgatDisplay.Create(IM, ConfigDevice);
end;

constructor TAgatDisplay.Create;
var i:Cardinal;
begin
	inherited Create(IM, ConfigDevice);

	FSX := 512; //����� � 2 ���� ������, ����� ���������� ���-64
	FSY := 256;

	//������������� ������
	FBitMap.Width:=FSX;
	FBitMap.Height:=FSY;
	FBitMap.PixelFormat:=pf24bit;

	for i:=0 to 255 do
		FLines[i] := FBitMap.ScanLine[i];

	//����� ������������ ���������� ������
	//����� ��������� �������������� ����� ��� ��
	//���������
	FPrevMode := Cardinal(-1);

	FBlinker := False;
	FCounter := 0;
end;

procedure TAgatDisplay.LoadConfig;
begin
	inherited LoadConfig(SD);
	FPMode := IM.DM.GetDeviceByName(FConfigData.Parameters['mode'].Value) as TPort;
	FRam[0] := IM.DM.GetDeviceByName(FConfigData.Parameters['ram1'].Value) as TRAM;
	FRam[1] := IM.DM.GetDeviceByName(FConfigData.Parameters['ram2'].Value) as TRAM;
	FFont  := IM.DM.GetDeviceByName(FConfigData.Parameters['font'].Value) as TROM;

	//������ �� ������ �������� ����� ��� ������������ ������� ������������
	FRam[0].SetCallback(MemoryChanged, MODE_W);
	FRam[1].SetCallback(MemoryChanged, MODE_W);

	FSystemClock := TCPU(FIM.DM.GetDeviceByName('cpu')).ClockValue;
	FBlinkTicks := FSystemClock div 10;
end;

procedure TAgatDisplay.Clock(Counter:Cardinal);
begin
	//���� ��������� ����� ��� ������������� �������������,
	//��� ����������� ����������� ������������
	if (FPrevMode<>FPMode[0]) then begin
		FPrevMode := FPMode[0];
		FMode := FPMode[0] and $83;
		FModule := (FPMode[0] and $80) shr 7;
		FBase := ((FPMode[0] and $70) shr 4) * 8192;
		case FMode of
			$00:begin		//���
						FPageSize := 2048;
						Inc(FBase, ((FPMode[0] and $0C) shr 2) * 2048);
					end;
			$01:begin		//���
						FPageSize := 8192;
					end;
			$02,
			$82:begin		//���
						FPageSize := 2048;
						Inc(FBase, ((FPMode[0] and $0C) shr 2) * 2048);
					end;
			$03:begin		//���
						FPageSize := 8192;
					end;
		end;
		FValid := False;
	end;

	Inc(FCounter, Counter);
	if (FCounter > FBlinkTicks) then begin
		Dec(FCounter, FBlinkTicks);
		FBlinker := not FBlinker;
		if FMode=$02 then FValid := FALSE;
	end;

end;

procedure TAgatDisplay.MemoryChanged(Address: Cardinal);
begin
	//�������� - ���� ���� ��������� ��������� � ������ ������ ������,
	//��� ����� ����� ������� ����������
	if (Address >= FBase) and (Address < FBase + FPageSize) then begin
		DrawByte(Address-FBase);
		FRepaint := True;
	end;
end;

procedure TAgatDisplay.DrawByte(Address:Cardinal);
var V, V1, V2:Byte;
		c, i, j, k, Lin, O, p, cl, ccl:Cardinal;
		cc: array [0..1] of Cardinal;
begin
	V := FRam[FModule][FBase+Address];
	case FMode of
		$00:begin		//���
					Lin := (Address and $FFFFFFE0) shr 3;	//����� ������ ����� ������
					O := (Address and $1f) * 48; 					//�������� � ������ (8 ����� �� 3 ����� � �������� ����������)
					cc[0] := V shr 4;											//���� ������ �����
					cc[1] := V and $0F;                   //���� �������� �����
					for j:=0 to 1 do
						for k:=0 to 7 do begin
							p := O + j*24 + k*3;
							for i:=Lin to Lin+3 do begin
								FLines[i][p]  :=Agat_16Colors[cc[j], 2]; //B
								FLines[i][p+1]:=Agat_16Colors[cc[j], 1]; //G
								FLines[i][p+2]:=Agat_16Colors[cc[j], 0]; //R
							end;
						end;
				end;
		$01:begin		//���
					Lin := (Address and $FFFFFFC0) shr 5;	//����� ������ ����� ������
					O := (Address and $3f) * 24; 					//�������� � ������ (4 ����� �� 3 ����� � �������� ����������)
					cc[0] := V shr 4;                     //���� ������ �����
					cc[1] := V and $0F;                   //���� �������� �����
					for j:=0 to 1 do
						for k:=0 to 3 do begin
							p := O + j*12 + k*3;
							for i:=Lin to Lin+1 do begin
								FLines[i][p]  :=Agat_16Colors[cc[j], 2]; //B
								FLines[i][p+1]:=Agat_16Colors[cc[j], 1]; //G
								FLines[i][p+2]:=Agat_16Colors[cc[j], 0]; //R
							end;
						end;
				end;
		$02:begin		//���-32
					Lin := (Address and $FFFFFFC0) shr 3;					//����� ������ ����� ������
					O := 96+(Address and $3E) * 21; //�������� � ������ (7 ����� �� 3 ����� + �������� - 2 ����� �� ����������)
					V1 := FRam[Fmodule][FBase+(Address and $FFFFFFFE)];   //��� �������
					V2 := FRam[Fmodule][FBase+(Address and $FFFFFFFE)+1]; //�������
					cl := (V2 and $07) or ((V2 and $10) shr 1);
					for i:=0 to 7 do begin
						V := FFont[V1*8+i];                     //������ �� ���������������
						for k:=0 to 6 do begin                  //���������� ��� ����, ����� ��������
							c:=(V shr k) and 1;
							for j:=0 to 1 do begin
								p:= O + (6-k)*6 + j*3;
								//�������� � ��������
								if (V2 and $20 <> 0) or ((V2 and $08 <> 0) and FBlinker) then
									ccl := cl*c
								else
									ccl := cl*(c xor 1);
								FLines[Lin+i][p]  :=Agat_16Colors[ccl, 2]; //B
								FLines[Lin+i][p+1]:=Agat_16Colors[ccl, 1]; //G
								FLines[Lin+i][p+2]:=Agat_16Colors[ccl, 0]; //R
							end;
						end;
					end;
				end;
		$82:begin		//���-64
					Lin := (Address and $FFFFFFC0) shr 3;	//����� ������ ����� ������
					O := 96+(Address and $3f) * 21; 			//�������� � ������ (7 ����� �� 3 �����) � ������ ����
					V1 := FRam[Fmodule][FBase+Address];   //��� �������
					for i:=0 to 7 do begin
						V := FFont[V1*8+i];									//������ �� ���������������
						for k:=0 to 6 do begin							//���������� ��� ����, ����� ��������
							c:=	((V shr k) and 1)
									xor ((FPMode[0] and $04) shr 2); //��� �������� ������� ����������� ���������
							p:= O + (6-k)*3;
							FLines[Lin+i][p]  :=Agat_2Colors[c, 2]; //B
							FLines[Lin+i][p+1]:=Agat_2Colors[c, 1]; //G
							FLines[Lin+i][p+2]:=Agat_2Colors[c, 0]; //R
						end;
					end;
				end;
		$03:begin		//���
					Lin := Address shr 5;					//����� ����� ������
					O := (Address and $1f) * 48; //�������� � ������ (8 ����� �� 3 ����� � �������� ����������)
					for k:=0 to 7 do begin
						c:=(V shr k) and 1;
						//����������� �� 2 �����, �.�. ���������� ���������� � 2 ����
						//������ ���������
						for j:=0 to 1 do begin
							p:= O + (7-k)*6 + j*3;
							FLines[Lin][p]  :=Agat_2Colors[c, 2]; //B
							FLines[Lin][p+1]:=Agat_2Colors[c, 1]; //G
							FLines[Lin][p+2]:=Agat_2Colors[c, 0]; //R
						end;
					end;
				end;
	end;
end;

function TAgatDisplay.GetScreen(Required:Boolean):TBitMap;
var i:Cardinal;
begin
	if not FValid then begin
		{������ ���������}
		//� ��������� ������ ���� ��������� ������� ����
		if FMode and 3 = 2 then
			for i:=0 to 255 do begin
				FillChar(FLines[i][0], 96, 0);
				FillChar(FLines[i][1440], 96, 0);
			end;
		for i:=0 to FPageSize-1 do DrawByte(i);
		FValid := TRUE;
		FRepaint := FALSE;
		Result := FBitMap;
	end else begin
		if Required or FRepaint then begin
			Result := FBitMap;
			FRepaint := FALSE;
		end else
			Result := nil
	end;
end;

begin
	RegisterDeviceCreateFunc('agat-display', @CreateAgatDisplay);
end.
