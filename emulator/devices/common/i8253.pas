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
    Config,
		Core;

type
	T8253 = class (TAddressableDevice)
	private
		//Режим работы счетчиков
		Modes:array [0..2] of Byte;
		//Тип загруженных данных
		IsBCD:array [0..2] of Byte;
		//Порядок загрузки данных
		Orders:array [0..2] of Byte;
		//Индесы загружаемых в счетчики байтов
		Indexes:array [0..2] of Byte;
		//Загружены ли счетчики
		Loaded:array [0..2] of Byte;
		//Флаг останова для считывания счетчиков
		Counting:array [0..2] of Byte;
		//Начальные данные
		StartData:array [0..5] of Byte;
		//Текущие значения счетчиков
		Counters:array [0..5] of Byte;
		//Данные для считывания
		ReadData:array [0..5] of Byte;
		//Состояния входов GATE
		Gates:array [0..2] of Byte;
		//Старт счетчиков по следующему тактовому импульсу
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
	//Номера строк в таблице управления режимами
	//Каждая строка соответствует своему событию
	MODE_SET_OUT=0;							//Значение OUT после установки режима (0, 1)
	COUNTER_LOAD_DEC_VALUE=1;		//Значение декремента (0=>1, 1=>2)
	COUNTER_LOAD_AUTO_START=2;	//Автозапуск после загрузки счетчика
	COUNTER_START_OUT=3;				//Значение OUT после запуска счета (0, 1, инверсия)
	COUNTER_END_OUT=4;					//Значение OUT после конца счета (0, 1, не влияет)
	COUNTER_END_RESTART=5;			//Авто-перезапуск счета
	GATE_0_OUT=6;								//Значение OUT если GATE=0
	GATE_0_STOP=7;							//Останов счета по GATE=0
	GATE_01_OUT=8;							//Значение OUT по положительному фронту GATE
	GATE_01_RESET=9;            //Перезапуск счета по положительному фронту GATE

	//Добавляем по два лишних значения, чтобы было по 8 байт
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
						C := (Value shr 6) and $03;				 	//Номер канала
						if (Value and $30) <> 0 then begin
							IsBCD[C] := Value and $01;  				//BCD-режим
							Orders[C] := (Value shr 4) and $03; //Число байтов
							Modes[C] := (Value shr 1) and $07;  //Режим работы канала
							//Обнуляем счетчик загруженных данных
							Loaded[C]  := 0;
							Indexes[C] := 0;
							if Orders[C] = 2 then	Inc(Indexes[C]); //Только старший
							//Запрещаем счет
							Counting[C] := 0;
							//Устанавливаем OUT
							V:= I8253_MODES[MODE_SET_OUT, Modes[C]];
							FIOutput.Change( (FIOutput.Value and not (1 shl C)) or (V shl C));
						end else begin
							//Фиксация счетчиков для чтения
							ReadData[C*2] := Counters[C*2];
							Indexes[C] := 0;
							//Следующие строки надо включить если окажется,
							//что данные не всегда читаются по два, и нужно учесть влияние режима
							//if Orders[C] = 2 then Inc(Indexes[C]);
						end;
					end;
		0..2: begin
						//counters
						StartData[A*2+Indexes[A]] := Byte(Value);
						//Inc(Indexes[A]);
						//Indexes[A] := Indexes[A] and $01;
						Indexes[A] := Indexes[A] xor $01;
						//Если надо загрузить только один байт,
						//или уже загружено два, запускаем процесс
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
	//Проверяем, загружен ли счетчик
	if Loaded[A] = 1 then begin
		if NeedRestart[A] = 1 then begin
			StartCount(A);
			NeedRestart[A] := 0;
		end;
		if Counting[A] = 1 then begin
			I2 := Increment;
			//Умножаем значение на 2 для двойного декремента
			if I8253_MODES[COUNTER_LOAD_DEC_VALUE, Modes[A]] = 1 then
				I2 := I2 shl 1;
			Ctr := Integer(Counters[A*2] + Counters[A*2+1]*256);
			V := Ctr - Integer(I2);
			if (V > 0) or (Ctr = 0) then begin
				//Сохраняем значение для следующего цикла
				Counters[A*2]   := Byte(V);
				Counters[A*2+1] := Byte(V shr 8);
			end else begin
				//Достигнут конец
				//Устанавливаем выход
				SetOut(A, COUNTER_END_OUT);
				//Запрещаем счет
				Counting[A] := 0;
				//Рестарт счета, если надо
				if I8253_MODES[COUNTER_END_RESTART, Modes[A]]=1 then
					NeedRestart[A] := 1;
			end;
			
		end;
	end;
end;

procedure T8253.StartCount(A:Cardinal);
begin
	SetOut(A, COUNTER_START_OUT);
	//Загружаем регистры счетчиков
	Reload(A);
	//Разрешаем счет
	if Gates[A]=1 then Counting[A] := 1;
end;

procedure T8253.Reload(A:Cardinal);
begin
	Counters[A*2] := StartData[A*2];
	Counters[A*2+1] := StartData[A*2+1];
end;

//Процедура принимает номер счетчика и номер строки в таблице режимов
//и устанавливает выход в нужное значение
procedure T8253.SetOut(A, Mode: Cardinal);
var M, V, Mask: Cardinal;
begin
	M := I8253_MODES[Mode, Modes[A]];
	V := FIOutput.Value;
	Mask := 1 shl A;
	case M of
			0: FIOutput.Change(V and not Mask); //0
			1: FIOutput.Change(V or Mask);      //1
			2: FIOutput.Change(V xor Mask); 		//Инверсия
		//3: 																	//Не влияет
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
