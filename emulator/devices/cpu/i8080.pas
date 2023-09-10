unit i8080;
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
		SysUtils,
		Config,
		Utils, Core;

type
	T8080Context=packed record
		case Integer of
			0: (C,B,E,D,L,H:Byte;													//Основные регистры
					M:Byte;																		//Псевдо-регистр для правильной индексации аккумулятора
					A:Byte; 		                           		//Аккумулятор
					F:Byte;                             			//Флаги
					SP:Word;																	//Указатель стека
					PC:Word;																	//Указатель команд
					PC2: Word;																//Адрес текущей команды, используется для отладки
					isHalted :Boolean;												//Останов, разрешение прерываний
					IntEnable: Cardinal;
					);
			1: (BC:Word;																	//Сдвоенные регистры
					DE:Word;
					HL:Word);
			2: (RegArray8:array [0..7] of Byte);					//Массив для индексного доступа к регистрам  A-H
			3: (RegArray16:array [0..2] of Word);					//Массив для индексного доступа к регистрам BC, DE, HL
	end;

	T8080 = class (TCPU)
	private
		FINMI: TInterface;
		FIINT: TInterface;
		FIINTE: TInterface;
		FIM1: TInterface;
	protected
		function GetPC:Cardinal; override;
		{$IFDEF REC_CONTEXT}
		function GetContextCRC:Word; override;
		{$ENDIF}
	public
		FContext: T8080Context;
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		function Execute:Cardinal; override;
		property Context:T8080Context read FContext;
	end;

	T8080Instruction=record
		T:Byte;
		Name:String[10];
	end;
	T8080InstructionsSet=array [0..255] of T8080Instruction;

const
	//Значения битов регистра флагов
	F_CARRY=$01;			//Перенос
	F_PARITY=$04;			//Четность
	F_HALF_CARRY=$10;	//Частичный перенос
	F_ZERO=$40;				//Ноль
	F_SIGN=$80;				//Знак
	F_ALL=	F_CARRY + F_PARITY + F_HALF_CARRY + F_ZERO + F_SIGN;

	//Таблица преобразования номера 8-ми разрядного регистра
	//в индекс массива RegArray8
	REGISTERS8:array [0..7] of Byte = (1, 0, 3, 2, 5, 4, 6, 7);

		//Таблица значений флага чётности
	PARITY:array [0..255] of Byte = (
								4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,     // 00-0F
								0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,     // 10-1F
								0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,     // 20-2F
								4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,     // 30-3F
								0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,     // 40-4F
								4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,     // 50-5F
								4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,     // 60-6F
								0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,     // 70-7F
								0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,     // 80-8F
								4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,     // 90-9F
								4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,     // A0-AF
								0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,     // B0-BF
								4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,     // C0-CF
								0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,     // D0-DF
								0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,     // E0-EF
								4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4);    // F0-FF

	//Таблица значений флагов нуля и знака
	ZERO_SIGN:array [0..255] of byte =(
			F_ZERO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,     								// 00-0F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,          								// 10-1F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,          								// 20-2F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,         									// 30-3F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 											    // 40-4F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    								      // 50-5F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,          								// 60-6F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,          								// 70-7F */
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,  // 80-8F */
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,  // 90-9F */
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,  // A0-AF */
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,  // B0-BF */
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,  // C0-CF */
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,  // D0-DF */
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,  // E0-EF */
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,
			F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN,F_SIGN);	// F0-FF */

	//Таблица преобразования номера условия во флаг
	CONDITIONS:array [0..7, 0..1] of Byte =((F_ZERO, 0),		 			//NOT ZERO
																					(F_ZERO, F_ZERO),			//ZERO
																					(F_CARRY, 0),	 				//NOT CARRY
																					(F_CARRY, F_CARRY),		//CARRY
																					(F_PARITY, 0),	 			//ODD
																					(F_PARITY, F_PARITY), //NOT ODD
																					(F_SIGN, 0),		 			//POSITIVE
																					(F_SIGN, F_SIGN));		//NEGATIVE
	//Время исполнения инструкций
	//Первый элемент - в случае отсутствия перехода, второй - при переходе
	//Для обычных операторов эти значения равны
	TIMING:array [0..255, 0..1] of Byte = (
								(4, 4),   (10, 10), (7, 7),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (4, 4), 
								(4, 4),   (10, 10), (7, 7),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (4, 4),        // 00-0F
								(4, 4),   (10, 10), (7, 7),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (4, 4), 
								(4, 4),   (10, 10), (7, 7),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (4, 4),        // 10-1F
								(4, 4),   (10, 19), (16, 16), (5, 5),   (5, 5),   (5, 5),   (7, 7),   (4, 4),
								(4, 4),   (10, 10), (16, 16), (5, 5),   (5, 5),   (5, 5),   (7, 7),   (4, 4),        // 20-2F
								(4, 4),   (10, 10), (13, 13), (5, 5),   (10, 10), (10, 10), (10, 10), (4, 4),
								(4, 4),   (10, 10), (13, 13), (5, 5),   (5, 5),   (5, 5),   (7, 7),   (4, 4),        // 30-3F
								(5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (5, 5),
								(5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (5, 5),        // 40-4F
								(5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (5, 5), 
								(5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (5, 5),        // 50-5F
								(5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (5, 5), 
								(5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (5, 5),        // 60-6F
								(7, 7),   (7, 7),   (7, 7),   (7, 7),   (7, 7),   (7, 7),   (4, 4),   (7, 7), 
								(5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (5, 5),   (7, 7),   (5, 5),        // 70-7F
								(4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (7, 7),   (4, 4), 
								(4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (7, 7),   (4, 4),        // 80-8F
								(4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (7, 7),   (4, 4), 
								(4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (7, 7),   (4, 4),        // 90-9F
								(4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (7, 7),   (4, 4), 
								(4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (7, 7),   (4, 4),        // A0-AF
								(4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (7, 7),   (4, 4), 
								(4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (4, 4),   (7, 7),   (4, 4),        // B0-BF
								(5, 11),  (11, 11), (10, 10), (10, 10), (11, 17), (11, 11), (7, 7),   (11, 11), 
								(5, 11),  (10, 10), (10, 10), (10, 10), (11, 17), (17, 17), (7, 7),   (11, 11),      // C0-CF
								(5, 11),  (11, 11), (10, 10), (10, 10), (11, 17), (11, 11), (7, 7),   (11, 11),
								(5, 11),  (10, 10), (10, 10), (10, 10), (11, 17), (17, 17), (7, 7),   (11, 11),      // D0-DF
								(5, 11),  (11, 11), (10, 10), (18, 18), (11, 17), (11, 11), (7, 7),   (11, 11),
								(5, 11),  (5, 5),   (10, 10), (4, 4),   (11, 17), (17, 17), (7, 7),   (11, 11),      // E0-EF
								(5, 11),  (11, 11), (10, 10), (4, 4),   (11, 17), (11, 11), (7, 7),   (11, 11),
								(5, 11),  (5, 5),   (10, 10), (4, 4),   (11, 17), (17, 17), (7, 7),   (11, 11));  	 // F0-FF

	i8080Instructions:T8080InstructionsSet=(
			{00}(T:OP_SIMPLE; Name: 'NOP'),
			{01}(T:OP_DATA16; Name: 'LXI B, '),
			{02}(T:OP_SIMPLE; Name: 'STAX B'),
			{03}(T:OP_SIMPLE; Name: 'INX B'),
			{04}(T:OP_SIMPLE; Name: 'INR B'),
			{05}(T:OP_SIMPLE; Name: 'DCR B'),
			{06}(T:OP_DATA8; Name: 'MVI B, '),
			{07}(T:OP_SIMPLE; Name: 'RLC'),
			{08}(T:OP_SIMPLE; Name: '*NOP'),
			{09}(T:OP_SIMPLE; Name: 'DAD B'),
			{0A}(T:OP_SIMPLE; Name: 'LDAX B'),
			{0B}(T:OP_SIMPLE; Name: 'DCX B'),
			{0C}(T:OP_SIMPLE; Name: 'INR C'),
			{0D}(T:OP_SIMPLE; Name: 'DCR C'),
			{0E}(T:OP_DATA8; Name: 'MVI C, '),
			{0F}(T:OP_SIMPLE; Name: 'RRC'),
			{10}(T:OP_SIMPLE; Name: '*NOP'),
			{11}(T:OP_DATA16; Name: 'LXI D, '),
			{12}(T:OP_SIMPLE; Name: 'STAX D'),
			{13}(T:OP_SIMPLE; Name: 'INX D'),
			{14}(T:OP_SIMPLE; Name: 'INR D'),
			{15}(T:OP_SIMPLE; Name: 'DCR D'),
			{16}(T:OP_DATA8; Name: 'MVI D, '),
			{17}(T:OP_SIMPLE; Name: 'RAL'),
			{18}(T:OP_SIMPLE; Name: '*NOP'),
			{19}(T:OP_SIMPLE; Name: 'DAD D'),
			{1A}(T:OP_SIMPLE; Name: 'LDAX D'),
			{1B}(T:OP_SIMPLE; Name: 'DCX D'),
			{1C}(T:OP_SIMPLE; Name: 'INR E'),
			{1D}(T:OP_SIMPLE; Name: 'DCR E'),
			{1E}(T:OP_DATA8; Name: 'MVI E, '),
			{1F}(T:OP_SIMPLE; Name: 'RAR'),
			{20}(T:OP_SIMPLE; Name: '*NOP'),
			{21}(T:OP_DATA16; Name: 'LXI H, '),
			{22}(T:OP_ADDR16; Name: 'SHLD '),
			{23}(T:OP_SIMPLE; Name: 'INX H'),
			{24}(T:OP_SIMPLE; Name: 'INR H'),
			{25}(T:OP_SIMPLE; Name: 'DCR H'),
			{26}(T:OP_DATA8; Name: 'MVI H, '),
			{27}(T:OP_SIMPLE; Name: 'DAA'),
			{28}(T:OP_SIMPLE; Name: '*NOP'),
			{29}(T:OP_SIMPLE; Name: 'DAD H'),
			{2A}(T:OP_ADDR16; Name: 'LHLD '),
			{2B}(T:OP_SIMPLE; Name: 'DCX H'),
			{2C}(T:OP_SIMPLE; Name: 'INR L'),
			{2D}(T:OP_SIMPLE; Name: 'DCR L'),
			{2E}(T:OP_DATA8; Name: 'MVI L, '),
			{2F}(T:OP_SIMPLE; Name: 'CMA'),
			{30}(T:OP_SIMPLE; Name: '*NOP'),
			{31}(T:OP_DATA16; Name: 'LXI SP, '),
			{32}(T:OP_ADDR16; Name: 'STA '),
			{33}(T:OP_SIMPLE; Name: 'INX SP'),
			{34}(T:OP_SIMPLE; Name: 'INR M'),
			{35}(T:OP_SIMPLE; Name: 'DCR M'),
			{36}(T:OP_DATA8; Name: 'MVI M, '),
			{37}(T:OP_SIMPLE; Name: 'STC'),
			{38}(T:OP_SIMPLE; Name: '*NOP'),
			{39}(T:OP_SIMPLE; Name: 'DAD SP'),
			{3A}(T:OP_ADDR16; Name: 'LDA '),
			{3B}(T:OP_SIMPLE; Name: 'DCX SP'),
			{3C}(T:OP_SIMPLE; Name: 'INR A'),
			{3D}(T:OP_SIMPLE; Name: 'DCR A'),
			{3E}(T:OP_DATA8; Name: 'MVI A, '),
			{3F}(T:OP_SIMPLE; Name: 'CMC'),
			{40}(T:OP_SIMPLE; Name: 'MOV B, B'),
			{41}(T:OP_SIMPLE; Name: 'MOV B, C'),
			{42}(T:OP_SIMPLE; Name: 'MOV B, D'),
			{43}(T:OP_SIMPLE; Name: 'MOV B, E'),
			{44}(T:OP_SIMPLE; Name: 'MOV B, H'),
			{45}(T:OP_SIMPLE; Name: 'MOV B, L'),
			{46}(T:OP_SIMPLE; Name: 'MOV B, M'),
			{47}(T:OP_SIMPLE; Name: 'MOV B, A'),
			{48}(T:OP_SIMPLE; Name: 'MOV C, B'),
			{49}(T:OP_SIMPLE; Name: 'MOV C, C'),
			{4A}(T:OP_SIMPLE; Name: 'MOV C, D'),
			{4B}(T:OP_SIMPLE; Name: 'MOV C, E'),
			{4C}(T:OP_SIMPLE; Name: 'MOV C, H'),
			{4D}(T:OP_SIMPLE; Name: 'MOV C, L'),
			{4E}(T:OP_SIMPLE; Name: 'MOV C, M'),
			{4F}(T:OP_SIMPLE; Name: 'MOV C, A'),
			{50}(T:OP_SIMPLE; Name: 'MOV D, B'),
			{51}(T:OP_SIMPLE; Name: 'MOV D, C'),
			{52}(T:OP_SIMPLE; Name: 'MOV D, D'),
			{53}(T:OP_SIMPLE; Name: 'MOV D, E'),
			{54}(T:OP_SIMPLE; Name: 'MOV D, H'),
			{55}(T:OP_SIMPLE; Name: 'MOV D, L'),
			{56}(T:OP_SIMPLE; Name: 'MOV D, M'),
			{57}(T:OP_SIMPLE; Name: 'MOV D, A'),
			{58}(T:OP_SIMPLE; Name: 'MOV E, B'),
			{59}(T:OP_SIMPLE; Name: 'MOV E, C'),
			{5A}(T:OP_SIMPLE; Name: 'MOV E, D'),
			{5B}(T:OP_SIMPLE; Name: 'MOV E, E'),
			{5C}(T:OP_SIMPLE; Name: 'MOV E, H'),
			{5D}(T:OP_SIMPLE; Name: 'MOV E, L'),
			{5E}(T:OP_SIMPLE; Name: 'MOV E, M'),
			{5F}(T:OP_SIMPLE; Name: 'MOV E, A'),
			{60}(T:OP_SIMPLE; Name: 'MOV H, B'),
			{61}(T:OP_SIMPLE; Name: 'MOV H, C'),
			{62}(T:OP_SIMPLE; Name: 'MOV H, D'),
			{63}(T:OP_SIMPLE; Name: 'MOV H, E'),
			{64}(T:OP_SIMPLE; Name: 'MOV H, H'),
			{65}(T:OP_SIMPLE; Name: 'MOV H, L'),
			{66}(T:OP_SIMPLE; Name: 'MOV H, M'),
			{67}(T:OP_SIMPLE; Name: 'MOV H, A'),
			{68}(T:OP_SIMPLE; Name: 'MOV L, B'),
			{69}(T:OP_SIMPLE; Name: 'MOV L, C'),
			{6A}(T:OP_SIMPLE; Name: 'MOV L, D'),
			{6B}(T:OP_SIMPLE; Name: 'MOV L, E'),
			{6C}(T:OP_SIMPLE; Name: 'MOV L, H'),
			{6D}(T:OP_SIMPLE; Name: 'MOV L, L'),
			{6E}(T:OP_SIMPLE; Name: 'MOV L, M'),
			{6F}(T:OP_SIMPLE; Name: 'MOV L, A'),
			{70}(T:OP_SIMPLE; Name: 'MOV M, B'),
			{71}(T:OP_SIMPLE; Name: 'MOV M, C'),
			{72}(T:OP_SIMPLE; Name: 'MOV M, D'),
			{73}(T:OP_SIMPLE; Name: 'MOV M, E'),
			{74}(T:OP_SIMPLE; Name: 'MOV M, H'),
			{75}(T:OP_SIMPLE; Name: 'MOV M, L'),
			{76}(T:OP_SIMPLE; Name: 'HLT'),
			{77}(T:OP_SIMPLE; Name: 'MOV M, A'),
			{78}(T:OP_SIMPLE; Name: 'MOV A, B'),
			{79}(T:OP_SIMPLE; Name: 'MOV A, C'),
			{7A}(T:OP_SIMPLE; Name: 'MOV A, D'),
			{7B}(T:OP_SIMPLE; Name: 'MOV A, E'),
			{7C}(T:OP_SIMPLE; Name: 'MOV A, H'),
			{7D}(T:OP_SIMPLE; Name: 'MOV A, L'),
			{7E}(T:OP_SIMPLE; Name: 'MOV A, M'),
			{7F}(T:OP_SIMPLE; Name: 'MOV A, A'),
			{80}(T:OP_SIMPLE; Name: 'ADD B'),
			{81}(T:OP_SIMPLE; Name: 'ADD C'),
			{82}(T:OP_SIMPLE; Name: 'ADD D'),
			{83}(T:OP_SIMPLE; Name: 'ADD E'),
			{84}(T:OP_SIMPLE; Name: 'ADD H'),
			{85}(T:OP_SIMPLE; Name: 'ADD L'),
			{86}(T:OP_SIMPLE; Name: 'ADD M'),
			{87}(T:OP_SIMPLE; Name: 'ADD A'),
			{88}(T:OP_SIMPLE; Name: 'ADC B'),
			{89}(T:OP_SIMPLE; Name: 'ADC C'),
			{8A}(T:OP_SIMPLE; Name: 'ADC D'),
			{8B}(T:OP_SIMPLE; Name: 'ADC E'),
			{8C}(T:OP_SIMPLE; Name: 'ADC H'),
			{8D}(T:OP_SIMPLE; Name: 'ADC L'),
			{8E}(T:OP_SIMPLE; Name: 'ADC M'),
			{8F}(T:OP_SIMPLE; Name: 'ADC A'),
			{90}(T:OP_SIMPLE; Name: 'SUB B'),
			{91}(T:OP_SIMPLE; Name: 'SUB C'),
			{92}(T:OP_SIMPLE; Name: 'SUB D'),
			{93}(T:OP_SIMPLE; Name: 'SUB E'),
			{94}(T:OP_SIMPLE; Name: 'SUB H'),
			{95}(T:OP_SIMPLE; Name: 'SUB L'),
			{96}(T:OP_SIMPLE; Name: 'SUB M'),
			{97}(T:OP_SIMPLE; Name: 'SUB A'),
			{98}(T:OP_SIMPLE; Name: 'SBB B'),
			{99}(T:OP_SIMPLE; Name: 'SBB C'),
			{9A}(T:OP_SIMPLE; Name: 'SBB D'),
			{9B}(T:OP_SIMPLE; Name: 'SBB E'),
			{9C}(T:OP_SIMPLE; Name: 'SBB H'),
			{9D}(T:OP_SIMPLE; Name: 'SBB L'),
			{9E}(T:OP_SIMPLE; Name: 'SBB M'),
			{9F}(T:OP_SIMPLE; Name: 'SBB A'),
			{A0}(T:OP_SIMPLE; Name: 'ANA B'),
			{A1}(T:OP_SIMPLE; Name: 'ANA C'),
			{A2}(T:OP_SIMPLE; Name: 'ANA D'),
			{A3}(T:OP_SIMPLE; Name: 'ANA E'),
			{A4}(T:OP_SIMPLE; Name: 'ANA H'),
			{A5}(T:OP_SIMPLE; Name: 'ANA L'),
			{A6}(T:OP_SIMPLE; Name: 'ANA M'),
			{A7}(T:OP_SIMPLE; Name: 'ANA A'),
			{A8}(T:OP_SIMPLE; Name: 'XRA B'),
			{A9}(T:OP_SIMPLE; Name: 'XRA C'),
			{AA}(T:OP_SIMPLE; Name: 'XRA D'),
			{AB}(T:OP_SIMPLE; Name: 'XRA E'),
			{AC}(T:OP_SIMPLE; Name: 'XRA H'),
			{AD}(T:OP_SIMPLE; Name: 'XRA L'),
			{AE}(T:OP_SIMPLE; Name: 'XRA M'),
			{AF}(T:OP_SIMPLE; Name: 'XRA A'),
			{B0}(T:OP_SIMPLE; Name: 'ORA B'),
			{B1}(T:OP_SIMPLE; Name: 'ORA C'),
			{B2}(T:OP_SIMPLE; Name: 'ORA D'),
			{B3}(T:OP_SIMPLE; Name: 'ORA E'),
			{B4}(T:OP_SIMPLE; Name: 'ORA H'),
			{B5}(T:OP_SIMPLE; Name: 'ORA L'),
			{B6}(T:OP_SIMPLE; Name: 'ORA M'),
			{B7}(T:OP_SIMPLE; Name: 'ORA A'),
			{B8}(T:OP_SIMPLE; Name: 'CMP B'),
			{B9}(T:OP_SIMPLE; Name: 'CMP C'),
			{BA}(T:OP_SIMPLE; Name: 'CMP D'),
			{BB}(T:OP_SIMPLE; Name: 'CMP E'),
			{BC}(T:OP_SIMPLE; Name: 'CMP H'),
			{BD}(T:OP_SIMPLE; Name: 'CMP L'),
			{BE}(T:OP_SIMPLE; Name: 'CMP M'),
			{BF}(T:OP_SIMPLE; Name: 'CMP A'),
			{C0}(T:OP_SIMPLE; Name: 'RNZ'),
			{C1}(T:OP_SIMPLE; Name: 'POP B'),
			{C2}(T:OP_ADDR16; Name: 'JNZ '),
			{C3}(T:OP_ADDR16; Name: 'JMP '),
			{C4}(T:OP_ADDR16; Name: 'CNZ '),
			{C5}(T:OP_SIMPLE; Name: 'PUSH B'),
			{C6}(T:OP_DATA8; Name: 'ADI '),
			{C7}(T:OP_SIMPLE; Name: 'RST 0'),
			{C8}(T:OP_SIMPLE; Name: 'RZ'),
			{C9}(T:OP_SIMPLE; Name: 'RET'),
			{CA}(T:OP_ADDR16; Name: 'JZ '),
			{CB}(T:OP_ADDR16; Name: '*JMP '),
			{CC}(T:OP_ADDR16; Name: 'CZ '),
			{CD}(T:OP_ADDR16; Name: 'CALL '),
			{CE}(T:OP_DATA8; Name: 'ACI '),
			{CF}(T:OP_SIMPLE; Name: 'RST 1'),
			{D0}(T:OP_SIMPLE; Name: 'RNC'),
			{D1}(T:OP_SIMPLE; Name: 'POP D'),
			{D2}(T:OP_ADDR16; Name: 'JNC '),
			{D3}(T:OP_DATA8; Name: 'OUT '),
			{D4}(T:OP_ADDR16; Name: 'JNC '),
			{D5}(T:OP_SIMPLE; Name: 'PUSH D'),
			{D6}(T:OP_DATA8; Name: 'SUI '),
			{D7}(T:OP_SIMPLE; Name: 'RST 2'),
			{D8}(T:OP_SIMPLE; Name: 'RC'),
			{D9}(T:OP_SIMPLE; Name: '*RET'),
			{DA}(T:OP_ADDR16; Name: 'JC '),
			{DB}(T:OP_DATA8; Name: 'IN '),
			{DC}(T:OP_ADDR16; Name: 'CC '),
			{DD}(T:OP_ADDR16; Name: '*CALL '),
			{DE}(T:OP_DATA8; Name: 'SBI '),
			{DF}(T:OP_SIMPLE; Name: 'RST 3'),
			{E0}(T:OP_SIMPLE; Name: 'RPO'),
			{E1}(T:OP_SIMPLE; Name: 'POP H'),
			{E2}(T:OP_ADDR16; Name: 'JPO '),
			{E3}(T:OP_SIMPLE; Name: 'XTHL'),
			{E4}(T:OP_ADDR16; Name: 'CPO '),
			{E5}(T:OP_SIMPLE; Name: 'PUSH H'),
			{E6}(T:OP_DATA8; Name: 'ANI '),
			{E7}(T:OP_SIMPLE; Name: 'RST 4'),
			{E8}(T:OP_SIMPLE; Name: 'RPE'),
			{E9}(T:OP_SIMPLE; Name: 'PCHL'),
			{EA}(T:OP_ADDR16; Name: 'JPE '),
			{EB}(T:OP_SIMPLE; Name: 'XCHG'),
			{EC}(T:OP_ADDR16; Name: 'CPE '),
			{ED}(T:OP_ADDR16; Name: '*CALL '),
			{EE}(T:OP_DATA8; Name: 'XRI '),
			{EF}(T:OP_SIMPLE; Name: 'RST 5'),
			{F0}(T:OP_SIMPLE; Name: 'RP'),
			{F1}(T:OP_SIMPLE; Name: 'POP PSW'),
			{F2}(T:OP_ADDR16; Name: 'JP '),
			{F3}(T:OP_SIMPLE; Name: 'DI'),
			{F4}(T:OP_ADDR16; Name: 'CP '),
			{F5}(T:OP_SIMPLE; Name: 'PUSH PSW'),
			{F6}(T:OP_DATA8; Name: 'ORI '),
			{F7}(T:OP_SIMPLE; Name: 'RST 6'),
			{F8}(T:OP_SIMPLE; Name: 'RM'),
			{F9}(T:OP_SIMPLE; Name: 'SPHL'),
			{FA}(T:OP_ADDR16; Name: 'JM '),
			{FB}(T:OP_SIMPLE; Name: 'EI'),
			{FC}(T:OP_ADDR16; Name: 'CM '),
			{FD}(T:OP_ADDR16; Name: '*CALL '),
			{FE}(T:OP_DATA8; Name: 'CPI '),
			{FF}(T:OP_SIMPLE; Name: 'RST 7')
	);

	//Длина команд в байтах
	I8080LENGTHS:array [0..255] of Word = (
								1,3,1,1,1,1,2,1,1,1,1,1,1,1,2,1,     // 00-0F
								1,3,1,1,1,1,2,1,1,1,1,1,1,1,2,1,     // 10-1F
								1,3,3,1,1,1,2,1,1,1,3,1,1,1,2,1,     // 20-2F
								1,3,3,1,1,1,2,1,1,1,3,1,1,1,2,1,     // 30-3F
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,     // 40-4F
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,     // 50-5F
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,     // 60-6F
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,     // 70-7F
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,     // 80-8F
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,     // 90-9F
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,     // A0-AF
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,     // B0-BF
								1,1,3,3,3,1,2,1,1,1,3,1,3,3,2,1,     // C0-CF
								1,1,3,2,3,1,2,1,1,1,3,2,3,1,2,1,     // D0-DF
								1,1,3,1,3,1,2,1,1,1,3,1,3,1,2,1,     // E0-EF
								1,1,3,1,3,1,2,1,1,1,3,1,3,1,2,1);    // F0-FF

implementation

function Create8080(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := T8080.Create(IM, ConfigDevice);
end;

constructor T8080.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIAddress := CreateInterface(16, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_RW);
	FINMI := CreateInterface(1, 'nmi', MODE_R);
	FIINT := CreateInterface(1, 'int', MODE_R);
	FIINTE := CreateInterface(1, 'inte', MODE_W);
	FIM1 := CreateInterface(1, 'm1', MODE_W);
end;

function T8080.Execute;
var
	Command: Byte;
	XX, YYY, ZZZ, PP, Q: Cardinal;
	T, D:PartsRec;
	Timer: Cardinal;

	function ReadMem(Address:Word):Byte;
	begin
		//FIAddress.Change(Address);
		Result := Byte(Mapper.Read(Address));
		//FIAddress.Disconnect;
	end;

	procedure WriteMem(Address:Word; Value:Byte);
	begin
		//FIAddress.Change(Address);
		Mapper.Write(Address, Value);
		//FIAddress.Disconnect;
	end;

	function ReadPort(Address:Byte):Byte;
	begin
		//FIAddress.Change(Address);
		Result := Mapper.ReadPort(Word(Address) + (Address shl 8));
		//FIAddress.Disconnect;
	end;

	procedure WritePort(Address:Byte; Value:Byte);
	begin
		//FIAddress.Change(Address);
		Mapper.WritePort(Word(Address) + (Address shl 8), Value);
		//FIAddress.Disconnect;
	end;

	function NextByte:Byte;
	begin
		Result := ReadMem(FContext.PC);
		Inc(FContext.PC);
	end;

	function ReadCommand:Byte;
	begin
		//Установка M1
		Result := NextByte;
		//Сброс M1
	end;

	function CalcAllFlags(V1, V2, Value:Cardinal):Byte;
	begin
		Result := (V1 xor V2 xor Value) and F_HALF_CARRY 	//HALF CARRY
					 or ((Value shr 8) and F_CARRY) 						//CARRY
					 or ZERO_SIGN[Value and $FF] 								//ZERO, SIGN
					 or PARITY[Value and $FF] 									//PARITY
	end;

	procedure doRET;
	begin
		T.L := ReadMem(FContext.SP);
		T.H := ReadMem(FContext.SP+1);
		FContext.PC := T.W;
		Inc(FContext.SP, 2);
	end;

	procedure doJUMP;
	begin
		T.L := NextByte;
		T.H := NextByte;
		FContext.PC := T.W;
	end;

	procedure doCALL;
	begin
		T.L := NextByte;
		T.H := NextByte;
		Dec(FContext.SP, 2);
		WriteMem(FContext.SP, FContext.PC and $FF);
		WriteMem(FContext.SP+1, FContext.PC shr 8);
		FContext.PC := T.W;
	end;

begin
	//Первоначальный сброс
	if FReset then begin
		FContext.PC := 0;
		FContext.isHalted := false;
		FContext.IntEnable := 0;
		FIINTE.Change(FContext.IntEnable);
		FReset := FALSE;
	end;

	//Так как в процессе выполнения команды PC меняется, запоминаем его
	//в отдельной переменной, которая может использоваться при отладке.
	FContext.PC2 := FContext.PC;

	//if FContext.PC = $FC3C then
		//DebugMode:=DEBUG_STOPPED;
		//T.L := 0;

	Command := NextByte;


	if DebugMode<>DEBUG_OFF then begin
		if DebugMode=DEBUG_STOPPED then	begin
			Command := $76; //HALT
			Dec(FContext.PC);
		end;
	end;


	//XX YYY ZZZ
	//   PPQ

	XX := Command shr 6;
	YYY := (Command shr 3) and $07;
	ZZZ := Command and $07;
	PP := (YYY shr 1) and $03;
	Q := YYY and 1;

  //По умолчанию берем время выполнения по первому значению
	Timer := TIMING[Command, 0];

	case XX of
		//00_YYY_ZZZ
		0:begin
			case ZZZ of
				//00_YYY_000
				0:begin
					//NOP
				end;
				//00_YYY_001
				1:begin
					case Q of
						//00_RP0_001
						0:begin
							//LXI RP, DATA16
							T.L := NextByte;
							T.H := NextByte;
							if PP=3 then
								FContext.SP := T.W
							else
								FContext.RegArray16[PP] := T.W;
						end;
						//00_RP1_001
						1:begin
							//DAD RP
							if PP=3 then
								T.C := Cardinal(FContext.HL) + FContext.SP
							else
								T.C := Cardinal(FContext.HL) + FContext.RegArray16[PP];
							FContext.HL := T.W;
							//Перенос
							if (T.C and $10000) <> 0 then
								FContext.F := FContext.F or F_CARRY
							else
								FContext.F := FContext.F and (F_ALL - F_CARRY);
						end;
					end;
				end;
				//00_YYY_010
				2:begin
					case YYY of
						//00_0R0_010
						0,2:begin
							//STAX [R], A
							WriteMem(FContext.RegArray16[PP and 1], FContext.A);
						end;
						//00_0R1_010
						1,3:begin
							//LDAX A, [R]
							FContext.A := ReadMem(FContext.RegArray16[PP and 1])
						end;
						//00_100_010
						4:begin
							//SHLD ADDR16
							T.L := NextByte;
							T.H := NextByte;
							WriteMem(T.W, FContext.L);
							WriteMem(T.W+1, FContext.H);
						end;
						//00_101_010
						5:begin
							//LHLD ADDR16
							T.L := NextByte;
							T.H := NextByte;
							FContext.L := ReadMem(T.W);
							FContext.H := ReadMem(T.W+1);
						end;
						//00_110_010
						6:begin
							//STA ADDR16
							T.L := NextByte;
							T.H := NextByte;
							WriteMem(T.W, FContext.A);
						end;
						//00_111_010
						7:begin
							//LDA ADDR16
							T.L := NextByte;
							T.H := NextByte;
							FContext.A := ReadMem(T.W);
						end;
					end;
				end;
				//00_YYY_011
				3:begin
					case Q of
						//00_RP0_011
						0:begin
							//INX RP
							if PP=3 then
								Inc(FContext.SP)
							else
								Inc(FContext.RegArray16[PP]);
						end;
						//00_RP1_011
						1:begin
							//DCX RP
							if PP=3 then
								Dec(FContext.SP)
							else
								Dec(FContext.RegArray16[PP]);
						end;
					end;
				end;
				//00_YYY_100
				4:begin
					//INR SSS
					if YYY=6 then
						T.L := ReadMem(FContext.HL)
					else
						T.L := FContext.RegArray8[REGISTERS8[YYY]];
					D.C := Cardinal(T.L) + 1;
					//Обнуляем все флаги, кроме переноса
					FContext.F := FContext.F and F_CARRY;
					FContext.F := FContext.F or (CalcAllFlags(T.L, 1, D.C) and (F_ALL - F_CARRY));
					if YYY=6 then
						WriteMem(FContext.HL, D.L)
					else
						FContext.RegArray8[REGISTERS8[YYY]] := D.L;
				end;
				//00_YYY_101
				5:begin
					//DCR SSS
					if YYY=6 then
						T.L := ReadMem(FContext.HL)
					else
						T.L := FContext.RegArray8[REGISTERS8[YYY]];
					D.C := Cardinal(Integer(T.L) - 1);
					//Обнуляем все флаги, кроме переноса
					FContext.F := FContext.F and F_CARRY;
					FContext.F := FContext.F or (CalcAllFlags(T.L, $FF, D.C) and (F_ALL - F_CARRY));
					if YYY=6 then
						WriteMem(FContext.HL, D.L)
					else
						FContext.RegArray8[REGISTERS8[YYY]] := D.L;
				end;
				//00_YYY_110
				6:begin
					//MVI DDD, DATA8
					T.L := NextByte;
					if YYY=6 then
						WriteMem(FContext.HL, T.L)
					else
						FContext.RegArray8[REGISTERS8[YYY]] := T.L;
				end;
				//00_YYY_111
				7:begin
					case YYY of
						//00_000_111
						0:begin
							//RLC
							T.W := Word(FContext.A) shl 1;
							//Старший бит A переехал в младший бит T.H
							FContext.A := T.L or (T.H and 1);
							FContext.F := (FContext.F and (F_ALL - F_CARRY)) or (T.H and 1);
						end;
						//00_001_111
						1:begin
							//RRC
							FContext.F := (FContext.F and (F_ALL - F_CARRY)) or (FContext.A and 1);
							T.W := Word(FContext.A) shl 7;
							//Младший бит А перехал в старший бит T.L
							FContext.A := T.H or (T.L and $80);
						end;
						//00_010_111
						2:begin
							//RAL
							T.W := Word(FContext.A) shl 1;
							FContext.A := T.L or (FContext.F and F_CARRY);
							FContext.F := (FContext.F and (F_ALL - F_CARRY)) or (T.H and 1);
						end;
						//00_011_111
						3:begin
							//RAR
							T.W := Word(FContext.A) shl 7;
							FContext.A := T.H or ((FContext.F and F_CARRY) shl 7);
							FContext.F := (FContext.F and (F_ALL - F_CARRY)) or ((T.L shr 7) and 1);
						end;
						//00_100_111
						4:begin
							//DAA
							T.W := FContext.A;
							D.W := 0;
							if ((T.L and $0F) > 9) or (FContext.F and F_HALF_CARRY <> 0) then
								Inc (D.L, 6);
							if ((T.L and $F0) > $90) or (FContext.F and F_CARRY <> 0) then
								Inc (D.L, $60);
							Inc(T.W, D.W);
							FContext.A := T.L;
							FContext.F := CalcAllFlags(T.L, D.L, T.W);
						end;
						//00_101_111
						5:begin
							//CMA
							FContext.A := not FContext.A;
						end;
						//00_110_111
						6:begin
							//STC
							FContext.F := FContext.F or F_CARRY;
						end;
						//00_111_111
						7:begin
							//CMC
							FContext.F := FContext.F xor F_CARRY;
						end;
					end;
				end;
			end;
		end;
		//01_YYY_ZZZ
		1:begin
			if Command=$76 then
				FContext.isHalted := TRUE
			else begin
				//MOV DDD, SSS
				if ZZZ=6 then
					T.L := ReadMem(FContext.HL)
				else
					T.L := FContext.RegArray8[REGISTERS8[ZZZ]];
				if YYY=6 then
					WriteMem(FContext.HL, T.L)
				else
					FContext.RegArray8[REGISTERS8[YYY]] := T.L;
			end;
		end;
		//10_YYY_ZZZ
		2:begin
			if ZZZ=6 then
				T.W := ReadMem(FContext.HL)
			else
				T.W := FContext.RegArray8[REGISTERS8[ZZZ]];
			case YYY of
				0:begin
					//ADD
					D.W := Word(FContext.A) + T.W;
					FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
					FContext.A := D.L;
				end;
				1:begin
					//ADC
					Inc(T.W, FContext.F and F_CARRY);
					D.W := Word(FContext.A) + T.W;
					FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
					FContext.A := D.L;
				end;
				2:begin
					//SUB
					D.W := Word(Integer(FContext.A) - T.W);
					FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
					FContext.A := D.L;
				end;
				3:begin
					//SBB
					//A = A - (B + CARRY)
					Inc(T.W, FContext.F and F_CARRY);
					D.W := Word(Integer(FContext.A) - T.W);
					FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
					FContext.A := D.L;
				end;
				4:begin
					//ANA
					D.W := FContext.A and T.W;
					FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
					FContext.A := D.L;
				end;
				5:begin
					//XRA
					D.W := FContext.A xor T.W;
					FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
					FContext.A := D.L;
				end;
				6:begin
					//ORA
					D.W := FContext.A or T.W;
					FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
					FContext.A := D.L;
				end;
				7:begin
					//CMP
					D.W := Word(Integer(FContext.A) - T.W);
					FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
				end;
			end;
		end;
		//11_YYY_ZZZ
		3:begin
			case ZZZ of
				//11_YYY_000
				0:begin
					//RET IF
					if ((FContext.F and CONDITIONS[YYY, 0]) xor CONDITIONS[YYY, 1])=0 then begin
						doRET;
						Timer := TIMING[Command, 1];
					end;
				end;
				//11_YYY_001
				1:begin
					case Q of
						//11_RP0_001
						0:begin
							//POP RP
							T.L := ReadMem(FContext.SP);
							T.H := ReadMem(FContext.SP+1);
							if PP=3 then begin
								FContext.F := T.L;
								FContext.A := T.H;
							end else
								FContext.RegArray16[PP] := T.W;
							Inc(FContext.SP, 2);
						end;
						1:begin
							case PP of
								//11_001_001
								0:begin
									//RET
									doRET;
								end;
								//11_011_001
								1:begin
									//?
									doRET;
								end;
								//11_101_001
								2:begin
									//PCHL
									FContext.PC := FContext.HL;
								end;
								//11_111_001
								3:begin
									//SPHL
									FContext.SP := FContext.HL;
								end;
							end;
						end;
					end;
				end;
				//11_YYY_010
				2:begin
					//JUMP IF
					if ((FContext.F and CONDITIONS[YYY, 0]) xor CONDITIONS[YYY, 1])=0 then begin
						doJUMP;
						Timer := TIMING[Command, 1];
					end else begin
						T.L := NextByte;
						T.H := NextByte;
					end;
				end;
				//11_YYY_011
				3:begin
					case YYY of
						//11_000_011
						0:begin
							//JMP ADDR16
							doJUMP;
						end;
						//11_001_011
						1:begin
							//?CB
							doJUMP;
						end;
						//11_010_011
						2:begin
							//OUT port
							WritePort(NextByte, FContext.A);
						end;
						//11_011_011
						3:begin
							//IN port
							FContext.A := ReadPort(NextByte);
						end;
						//11_100_011
						4:begin
							//XTHL
							T.L := ReadMem(FContext.SP);
							T.H := ReadMem(FContext.SP+1);
							WriteMem(FContext.SP, FContext.L);
							WriteMem(FContext.SP+1, FContext.H);
							FContext.HL := T.W;
						end;
						//11_101_011
						5:begin
							//XCHG
							T.W := FContext.HL;
							FContext.HL := FContext.DE;
							FContext.DE := T.W;
						end;
						//11_110_011
						6:begin
							//DI
							FContext.IntEnable := 0;
							FIINTE.Change(FContext.IntEnable);
						end;
						//11_111_011
						7:begin
							//EI
							FContext.IntEnable := 1;
							FIINTE.Change(FContext.IntEnable);
						end;
					end;
				end;
				//11_YYY_100
				4:begin
					//CALL IF
					if ((FContext.F and CONDITIONS[YYY, 0]) xor CONDITIONS[YYY, 1])=0 then begin
						doCALL;
						Timer := TIMING[Command, 1];
					end else begin
						T.L := NextByte;
						T.H := NextByte;
					end;
				end;
				//11_YYY_101
				5:begin
					case Q of
						//11_RP0_101
						0:begin
							//PUSH RP
							if PP=3 then begin
								T.L := FContext.F;
								T.H := FContext.A;
							end else
								T.W := FContext.RegArray16[PP];
							Dec(FContext.SP, 2);
							WriteMem(FContext.SP, T.L);
							WriteMem(FContext.SP+1, T.H);
						end;
						//11_PP1_101
						1:begin
								//CALL
								doCALL;
						end;
					end;
				end;
				//11_YYY_110
				6:begin
					T.W := NextByte;
					case YYY of
						0:begin
							//ADI
							D.W := Word(FContext.A) + T.W;
							FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
							FContext.A := D.L;
						end;
						1:begin
							//ACI
							Inc(T.W, FContext.F and F_CARRY);
							D.W := Word(FContext.A) + T.W;
							FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
							FContext.A := D.L;
						end;
						2:begin
							//SUI
							D.W := Word(Integer(FContext.A) - T.W);
							FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
							FContext.A := D.L;
						end;
						3:begin
							//SBI
							//A = A - (B + CARRY)
							Inc(T.W, FContext.F and F_CARRY);
							D.W := Word(Integer(FContext.A) - T.W);
							FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
							FContext.A := D.L;
						end;
						4:begin
							//ANI
							D.W := FContext.A and T.W;
							FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
							FContext.A := D.L;
						end;
						5:begin
							//XRI
							D.W := FContext.A xor T.W;
							FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
							FContext.A := D.L;
						end;
						6:begin
							//ORI
							D.W := FContext.A or T.W;
							FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
							FContext.A := D.L;
						end;
						7:begin
							//CPI
							D.W := Word(Integer(FContext.A) - T.W);
							FContext.F := CalcAllFlags(FContext.A, T.W, D.W);
						end;
					end;
				end;
				//11_YYY_111
				7:begin
					//RST
					T.W := FContext.PC;
					Dec(FContext.SP, 2);
					WriteMem(FContext.SP, T.L);
					WriteMem(FContext.SP+1, T.H);
					FContext.PC := YYY shl 3;
				end;
			end;
		end;
	end;

	if DebugMode=DEBUG_STEP then DebugMode:=DEBUG_STOPPED;
	if DebugMode=DEBUG_BRAKES then
		if CheckBreakPoint(FContext.PC) then
			DebugMode := DEBUG_STOPPED;

	Result:=Timer;
end;

function T8080.GetPC;
begin
	Result := FContext.PC;
end;

{$IFDEF REC_CONTEXT}
function T8080.GetContextCRC;
begin
	Result := CRC16(@FContext, SizeOf(FContext));
end;
{$ENDIF}

begin
	RegisterDeviceCreateFunc('i8080', @Create8080);
end.
