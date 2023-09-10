unit i8253;
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
    Config,
		Core;

type
	T8253 = class (TAddressableDevice)
	private
		//����� ������ ���������
		Modes:array [0..2] of Byte;
		//��� ����������� ������
		IsBCD:array [0..2] of Byte;
		//������� �������� ������
		Orders:array [0..2] of Byte;
		//������ ����������� � �������� ������
		Indexes:array [0..2] of Byte;
		//��������� �� ��������
		Loaded:array [0..2] of Byte;
		//���� �������� ��� ���������� ���������
		Counting:array [0..2] of Byte;
		//��������� ������
		StartData:array [0..5] of Byte;
		//������� �������� ���������
		Counters:array [0..5] of Byte;
		//������ ��� ����������
		ReadData:array [0..5] of Byte;
		//��������� ������ GATE
		Gates:array [0..2] of Byte;
		//����� ��������� �� ���������� ��������� ��������
		NeedRestart:array [0..2] of Byte;

		FIAddress: TInterface;
		FIData: TInterface;
		FIOutput: TInterface;
		FIGate: TInterface;
		procedure GateChanged(NewValue, OldValue: Cardinal);
	protected
		procedure Init;
		function GetValue(Address:Cardinal):Cardinal; override;
		procedure SetValue(Address:Cardinal; Value:Cardinal); override;
		procedure Count(A, Increment: Cardinal);
		procedure StartCount(A:Cardinal);
		procedure Reload(A:Cardinal);
		procedure SetOut(A, Mode: Cardinal);
	public
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure Clock(Counter:Cardinal); override;
	end;

	const
	//������ ����� � ������� ���������� ��������
	//������ ������ ������������� ������ �������
	MODE_SET_OUT=0;							//�������� OUT ����� ��������� ������ (0, 1)
	COUNTER_LOAD_DEC_VALUE=1;		//�������� ���������� (0=>1, 1=>2)
	COUNTER_LOAD_AUTO_START=2;	//���������� ����� �������� ��������
	COUNTER_START_OUT=3;				//�������� OUT ����� ������� ����� (0, 1, ��������)
	COUNTER_END_OUT=4;					//�������� OUT ����� ����� ����� (0, 1, �� ������)
	COUNTER_END_RESTART=5;			//����-���������� �����
	GATE_0_OUT=6;								//�������� OUT ���� GATE=0
	GATE_0_STOP=7;							//������� ����� �� GATE=0
	GATE_01_OUT=8;							//�������� OUT �� �������������� ������ GATE
	GATE_01_RESET=9;            //���������� ����� �� �������������� ������ GATE

	//��������� �� ��� ������ ��������, ����� ���� �� 8 ����
	I8253_MODES:array [0..9, 0..7] of Byte =
										((0, 1, 1, 1, 1, 1, 1, 1), //MODE_SET_OUT
										 (0, 0, 0, 1, 0, 0, 0, 1), //COUNTER_LOAD_DEC_VALUE
										 (1, 0, 1, 1, 1, 0, 1, 1), //COUNTER_LOAD_AUTO_START
										 (0, 0, 1, 2, 1, 1, 1, 2), //COUNTER_START_OUT
										 (1, 1, 0, 3, 0, 0, 0, 3), //COUNTER_END_OUT
										 (0, 0, 1, 1, 0, 0, 1, 1), //COUNTER_END_RESTART
										 (3, 3, 1, 1, 3, 3, 1, 1), //GATE_0_OUT
										 (1, 0, 1, 1, 1, 0, 1, 1), //GATE_0_STOP
										 (3, 0, 3, 3, 3, 3, 3, 3), //GATE_01_OUT
										 (0, 1, 1, 1, 0, 1, 1, 1));//GATE_01_RESET


implementation

function Create8253(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := T8253.Create(IM, ConfigDevice);
end;

procedure T8253.Init;
begin
	FillChar(Modes, SizeOf(Modes), 0);
	FillChar(IsBCD, SizeOf(IsBCD), 0);
	FillChar(Orders, SizeOf(Orders), 0);
	FillChar(Indexes, SizeOf(Indexes), 0);
	FillChar(Counting, SizeOf(Counting), 0);
	FillChar(StartData, SizeOf(StartData), 0);
	FillChar(Counters, SizeOf(Counters), 0);
	FillChar(NeedRestart, SizeOf(NeedRestart), 0);
	FillChar(Loaded, SizeOf(Loaded), 0);
end;

constructor T8253.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIAddress := CreateInterface(2, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_R);
	FIOutput := CreateInterface(3, 'output', MODE_W);
	FIGate := CreateInterface(3, 'gate', MODE_R, GateChanged);

	Init;
end;

function T8253.GetValue(Address:Cardinal):Cardinal;
var A: Cardinal;
begin
	A := Address and $03;
	if A=3 then Result := 0
	else begin
		Result := ReadData[A*2 + Indexes[A]];
		Indexes[A] := Indexes[A] xor $01;
	end;
end;

procedure T8253.SetValue(Address:Cardinal; Value:Cardinal);
var A, C, V: Cardinal;
begin
	A := Address and $03;

	case A of
		3:		begin
						//control word
						C := (Value shr 6) and $03;				 	//����� ������
						if (Value and $30) <> 0 then begin
							IsBCD[C] := Value and $01;  				//BCD-�����
							Orders[C] := (Value shr 4) and $03; //����� ������
							Modes[C] := (Value shr 1) and $07;  //����� ������ ������
							//�������� ������� ����������� ������
							Loaded[C]  := 0;
							Indexes[C] := 0;
							if Orders[C] = 2 then	Inc(Indexes[C]); //������ �������
							//��������� ����
							Counting[C] := 0;
							//������������� OUT
							V:= I8253_MODES[MODE_SET_OUT, Modes[C]];
							FIOutput.Change( (FIOutput.Value and not (1 shl C)) or (V shl C));
						end else begin
							//�������� ��������� ��� ������
							ReadData[C*2] := Counters[C*2];
							Indexes[C] := 0;
							//��������� ������ ���� �������� ���� ��������,
							//��� ������ �� ������ �������� �� ���, � ����� ������ ������� ������
							//if Orders[C] = 2 then Inc(Indexes[C]);
						end;
					end;
		0..2: begin
						//counters
						StartData[A*2+Indexes[A]] := Byte(Value);
						//Inc(Indexes[A]);
						//Indexes[A] := Indexes[A] and $01;
						Indexes[A] := Indexes[A] xor $01;
						//���� ���� ��������� ������ ���� ����,
						//��� ��� ��������� ���, ��������� �������
						if (Orders[A] <> 3) or (Indexes[A]=0) then begin
							Loaded[A] := 1;
							if I8253_MODES[COUNTER_LOAD_AUTO_START, Modes[A]] <> 0 then
								NeedRestart[A] := 1;
						end;
					end;
	end;

end;

procedure T8253.Clock(Counter:Cardinal);
begin
	Count(0, Counter);
	Count(1, Counter);
	Count(2, Counter);
end;

procedure T8253.Count(A, Increment: Cardinal);
var Ctr, V: Integer;
		I2: Cardinal;
begin
	//���������, �������� �� �������
	if Loaded[A] = 1 then begin
		if NeedRestart[A] = 1 then begin
			StartCount(A);
			NeedRestart[A] := 0;
		end;
		if Counting[A] = 1 then begin
			I2 := Increment;
			//�������� �������� �� 2 ��� �������� ����������
			if I8253_MODES[COUNTER_LOAD_DEC_VALUE, Modes[A]] = 1 then
				I2 := I2 shl 1;
			Ctr := Integer(Counters[A*2] + Counters[A*2+1]*256);
			V := Ctr - Integer(I2);
			if (V > 0) or (Ctr = 0) then begin
				//��������� �������� ��� ���������� �����
				Counters[A*2]   := Byte(V);
				Counters[A*2+1] := Byte(V shr 8);
			end else begin
				//��������� �����
				//������������� �����
				SetOut(A, COUNTER_END_OUT);
				//��������� ����
				Counting[A] := 0;
				//������� �����, ���� ����
				if I8253_MODES[COUNTER_END_RESTART, Modes[A]]=1 then
					NeedRestart[A] := 1;
			end;
			
		end;
	end;
end;

procedure T8253.StartCount(A:Cardinal);
begin
	SetOut(A, COUNTER_START_OUT);
	//��������� �������� ���������
	Reload(A);
	//��������� ����
	if Gates[A]=1 then Counting[A] := 1;
end;

procedure T8253.Reload(A:Cardinal);
begin
	Counters[A*2] := StartData[A*2];
	Counters[A*2+1] := StartData[A*2+1];
end;

//��������� ��������� ����� �������� � ����� ������ � ������� �������
//� ������������� ����� � ������ ��������
procedure T8253.SetOut(A, Mode: Cardinal);
var M, V, Mask: Cardinal;
begin
	M := I8253_MODES[Mode, Modes[A]];
	V := FIOutput.Value;
	Mask := 1 shl A;
	case M of
			0: FIOutput.Change(V and not Mask); //0
			1: FIOutput.Change(V or Mask);      //1
			2: FIOutput.Change(V xor Mask); 		//��������
		//3: 																	//�� ������
	end;
end;

procedure T8253.GateChanged(NewValue, OldValue: Cardinal);
var A, G0, G1: Cardinal;
begin
	for A:=0 to 2 do begin
		G0 := (OldValue shr A) and $01;
		G1 := (NewValue shr A) and $01;
		if G1<>G0 then begin
			if G1=0 then begin
				SetOut(A, GATE_0_OUT);
				if I8253_MODES[GATE_0_STOP, Modes[A]] = 1 then Counting[A] := 0;
			end else begin
				//G1=1
				Counting[A] := 1;
				SetOut(A, GATE_01_OUT);
				if I8253_MODES[GATE_01_RESET, Modes[A]] = 1 then Reload(A);
			end;
			Gates[A] := G1;
		end;
	end;
end;

begin
	RegisterDeviceCreateFunc('i8253', @Create8253);
end.
