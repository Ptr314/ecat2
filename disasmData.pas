unit disasmData;
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

uses Classes, SysUtils, ComCtrls;

type
	T8080instr=record
		T:Byte;
		C:Byte;
		Name:String[10];
	end;
	T8080instrSet=array [0..255] of T8080instr;
	TdisasmBuffer = array [0..65535] of Byte;
	PdisasmBuffer = ^TdisasmBuffer;
const

	//Виды операций для дизассемблирования
	OP_SIMPLE=0;
	OP_DATA8=1;
	OP_DATA16=2;
	OP_ADDR16=3;

	CL_COMMON = 0;
	CL_BRANCH = 1;
	CL_JUMP = 2;
	CL_RET = 3;

	i8080instr:T8080instrSet=(
			{00}(T:OP_SIMPLE; C: CL_COMMON; Name: 'NOP'),
			{01}(T:OP_DATA16; C: CL_COMMON; Name: 'LXI B, '),
			{02}(T:OP_SIMPLE; C: CL_COMMON; Name: 'STAX B'),
			{03}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INX B'),
			{04}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INR B'),
			{05}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCR B'),
			{06}(T:OP_DATA8;  C: CL_COMMON; Name: 'MVI B, '),
			{07}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RLC'),
			{08}(T:OP_SIMPLE; C: CL_COMMON; Name: '*NOP'),
			{09}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DAD B'),
			{0A}(T:OP_SIMPLE; C: CL_COMMON; Name: 'LDAX B'),
			{0B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCX B'),
			{0C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INR C'),
			{0D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCR C'),
			{0E}(T:OP_DATA8;  C: CL_COMMON; Name: 'MVI C, '),
			{0F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RRC'),
			{10}(T:OP_SIMPLE; C: CL_COMMON; Name: '*NOP'),
			{11}(T:OP_DATA16; C: CL_COMMON; Name: 'LXI D, '),
			{12}(T:OP_SIMPLE; C: CL_COMMON; Name: 'STAX D'),
			{13}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INX D'),
			{14}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INR D'),
			{15}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCR D'),
			{16}(T:OP_DATA8;  C: CL_COMMON; Name: 'MVI D, '),
			{17}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RAL'),
			{18}(T:OP_SIMPLE; C: CL_COMMON; Name: '*NOP'),
			{19}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DAD D'),
			{1A}(T:OP_SIMPLE; C: CL_COMMON; Name: 'LDAX D'),
			{1B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCX D'),
			{1C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INR E'),
			{1D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCR E'),
			{1E}(T:OP_DATA8;  C: CL_COMMON; Name: 'MVI E, '),
			{1F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RAR'),
			{20}(T:OP_SIMPLE; C: CL_COMMON; Name: '*NOP'),
			{21}(T:OP_DATA16; C: CL_COMMON; Name: 'LXI H, '),
			{22}(T:OP_ADDR16; C: CL_COMMON; Name: 'SHLD '),
			{23}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INX H'),
			{24}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INR H'),
			{25}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCR H'),
			{26}(T:OP_DATA8;  C: CL_COMMON; Name: 'MVI H, '),
			{27}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DAA'),
			{28}(T:OP_SIMPLE; C: CL_COMMON; Name: '*NOP'),
			{29}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DAD H'),
			{2A}(T:OP_ADDR16; C: CL_COMMON; Name: 'LHLD '),
			{2B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCX H'),
			{2C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INR L'),
			{2D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCR L'),
			{2E}(T:OP_DATA8;  C: CL_COMMON; Name: 'MVI L, '),
			{2F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMA'),
			{30}(T:OP_SIMPLE; C: CL_COMMON; Name: '*NOP'),
			{31}(T:OP_DATA16; C: CL_COMMON; Name: 'LXI SP, '),
			{32}(T:OP_ADDR16; C: CL_COMMON; Name: 'STA '),
			{33}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INX SP'),
			{34}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INR M'),
			{35}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCR M'),
			{36}(T:OP_DATA8;  C: CL_COMMON; Name: 'MVI M, '),
			{37}(T:OP_SIMPLE; C: CL_COMMON; Name: 'STC'),
			{38}(T:OP_SIMPLE; C: CL_COMMON; Name: '*NOP'),
			{39}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DAD SP'),
			{3A}(T:OP_ADDR16; C: CL_COMMON; Name: 'LDA '),
			{3B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCX SP'),
			{3C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'INR A'),
			{3D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DCR A'),
			{3E}(T:OP_DATA8;  C: CL_COMMON; Name: 'MVI A, '),
			{3F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMC'),
			{40}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV B, B'),
			{41}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV B, C'),
			{42}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV B, D'),
			{43}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV B, E'),
			{44}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV B, H'),
			{45}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV B, L'),
			{46}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV B, M'),
			{47}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV B, A'),
			{48}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV C, B'),
			{49}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV C, C'),
			{4A}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV C, D'),
			{4B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV C, E'),
			{4C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV C, H'),
			{4D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV C, L'),
			{4E}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV C, M'),
			{4F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV C, A'),
			{50}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV D, B'),
			{51}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV D, C'),
			{52}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV D, D'),
			{53}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV D, E'),
			{54}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV D, H'),
			{55}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV D, L'),
			{56}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV D, M'),
			{57}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV D, A'),
			{58}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV E, B'),
			{59}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV E, C'),
			{5A}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV E, D'),
			{5B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV E, E'),
			{5C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV E, H'),
			{5D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV E, L'),
			{5E}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV E, M'),
			{5F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV E, A'),
			{60}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV H, B'),
			{61}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV H, C'),
			{62}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV H, D'),
			{63}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV H, E'),
			{64}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV H, H'),
			{65}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV H, L'),
			{66}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV H, M'),
			{67}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV H, A'),
			{68}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV L, B'),
			{69}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV L, C'),
			{6A}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV L, D'),
			{6B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV L, E'),
			{6C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV L, H'),
			{6D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV L, L'),
			{6E}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV L, M'),
			{6F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV L, A'),
			{70}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV M, B'),
			{71}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV M, C'),
			{72}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV M, D'),
			{73}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV M, E'),
			{74}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV M, H'),
			{75}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV M, L'),
			{76}(T:OP_SIMPLE; C: CL_COMMON; Name: 'HLT'),
			{77}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV M, A'),
			{78}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV A, B'),
			{79}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV A, C'),
			{7A}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV A, D'),
			{7B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV A, E'),
			{7C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV A, H'),
			{7D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV A, L'),
			{7E}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV A, M'),
			{7F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'MOV A, A'),
			{80}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADD B'),
			{81}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADD C'),
			{82}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADD D'),
			{83}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADD E'),
			{84}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADD H'),
			{85}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADD L'),
			{86}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADD M'),
			{87}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADD A'),
			{88}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADC B'),
			{89}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADC C'),
			{8A}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADC D'),
			{8B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADC E'),
			{8C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADC H'),
			{8D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADC L'),
			{8E}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADC M'),
			{8F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ADC A'),
			{90}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SUB B'),
			{91}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SUB C'),
			{92}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SUB D'),
			{93}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SUB E'),
			{94}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SUB H'),
			{95}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SUB L'),
			{96}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SUB M'),
			{97}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SUB A'),
			{98}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SBB B'),
			{99}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SBB C'),
			{9A}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SBB D'),
			{9B}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SBB E'),
			{9C}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SBB H'),
			{9D}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SBB L'),
			{9E}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SBB M'),
			{9F}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SBB A'),
			{A0}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ANA B'),
			{A1}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ANA C'),
			{A2}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ANA D'),
			{A3}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ANA E'),
			{A4}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ANA H'),
			{A5}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ANA L'),
			{A6}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ANA M'),
			{A7}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ANA A'),
			{A8}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XRA B'),
			{A9}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XRA C'),
			{AA}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XRA D'),
			{AB}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XRA E'),
			{AC}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XRA H'),
			{AD}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XRA L'),
			{AE}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XRA M'),
			{AF}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XRA A'),
			{B0}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ORA B'),
			{B1}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ORA C'),
			{B2}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ORA D'),
			{B3}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ORA E'),
			{B4}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ORA H'),
			{B5}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ORA L'),
			{B6}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ORA M'),
			{B7}(T:OP_SIMPLE; C: CL_COMMON; Name: 'ORA A'),
			{B8}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMP B'),
			{B9}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMP C'),
			{BA}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMP D'),
			{BB}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMP E'),
			{BC}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMP H'),
			{BD}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMP L'),
			{BE}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMP M'),
			{BF}(T:OP_SIMPLE; C: CL_COMMON; Name: 'CMP A'),
			{C0}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RNZ'),
			{C1}(T:OP_SIMPLE; C: CL_COMMON; Name: 'POP B'),
			{C2}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JNZ '),
			{C3}(T:OP_ADDR16; C: CL_JUMP; Name: 'JMP '),
			{C4}(T:OP_ADDR16; C: CL_BRANCH; Name: 'CNZ '),
			{C5}(T:OP_SIMPLE; C: CL_COMMON; Name: 'PUSH B'),
			{C6}(T:OP_DATA8;  C: CL_COMMON; Name: 'ADI '),
			{C7}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RST 0'),
			{C8}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RZ'),
			{C9}(T:OP_SIMPLE; C: CL_RET; Name: 'RET'),
			{CA}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JZ '),
			{CB}(T:OP_ADDR16; C: CL_BRANCH; Name: '*JMP '),
			{CC}(T:OP_ADDR16; C: CL_BRANCH; Name: 'CZ '),
			{CD}(T:OP_ADDR16; C: CL_BRANCH; Name: 'CALL '),
			{CE}(T:OP_DATA8;  C: CL_COMMON; Name: 'ACI '),
			{CF}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RST 1'),
			{D0}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RNC'),
			{D1}(T:OP_SIMPLE; C: CL_COMMON; Name: 'POP D'),
			{D2}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JNC '),
			{D3}(T:OP_DATA8;  C: CL_COMMON; Name: 'OUT '),
			{D4}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JNC '),
			{D5}(T:OP_SIMPLE; C: CL_COMMON; Name: 'PUSH D'),
			{D6}(T:OP_DATA8;  C: CL_COMMON; Name: 'SUI '),
			{D7}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RST 2'),
			{D8}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RC'),
			{D9}(T:OP_SIMPLE; C: CL_RET; Name: '*RET'),
			{DA}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JC '),
			{DB}(T:OP_DATA8;  C: CL_COMMON; Name: 'IN '),
			{DC}(T:OP_ADDR16; C: CL_BRANCH; Name: 'CC '),
			{DD}(T:OP_ADDR16; C: CL_BRANCH; Name: '*CALL '),
			{DE}(T:OP_DATA8;  C: CL_COMMON; Name: 'SBI '),
			{DF}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RST 3'),
			{E0}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RPO'),
			{E1}(T:OP_SIMPLE; C: CL_COMMON; Name: 'POP H'),
			{E2}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JPO '),
			{E3}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XTHL'),
			{E4}(T:OP_ADDR16; C: CL_BRANCH; Name: 'CPO '),
			{E5}(T:OP_SIMPLE; C: CL_COMMON; Name: 'PUSH H'),
			{E6}(T:OP_DATA8;  C: CL_COMMON; Name: 'ANI '),
			{E7}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RST 4'),
			{E8}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RPE'),
			{E9}(T:OP_SIMPLE; C: CL_COMMON; Name: 'PCHL'),
			{EA}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JPE '),
			{EB}(T:OP_SIMPLE; C: CL_COMMON; Name: 'XCHG'),
			{EC}(T:OP_ADDR16; C: CL_BRANCH; Name: 'CPE '),
			{ED}(T:OP_ADDR16; C: CL_BRANCH; Name: '*CALL '),
			{EE}(T:OP_DATA8;  C: CL_COMMON; Name: 'XRI '),
			{EF}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RST 5'),
			{F0}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RP'),
			{F1}(T:OP_SIMPLE; C: CL_COMMON; Name: 'POP PSW'),
			{F2}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JP '),
			{F3}(T:OP_SIMPLE; C: CL_COMMON; Name: 'DI'),
			{F4}(T:OP_ADDR16; C: CL_BRANCH; Name: 'CP '),
			{F5}(T:OP_SIMPLE; C: CL_COMMON; Name: 'PUSH PSW'),
			{F6}(T:OP_DATA8;  C: CL_COMMON; Name: 'ORI '),
			{F7}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RST 6'),
			{F8}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RM'),
			{F9}(T:OP_SIMPLE; C: CL_COMMON; Name: 'SPHL'),
			{FA}(T:OP_ADDR16; C: CL_BRANCH; Name: 'JM '),
			{FB}(T:OP_SIMPLE; C: CL_COMMON; Name: 'EI'),
			{FC}(T:OP_ADDR16; C: CL_BRANCH; Name: 'CM '),
			{FD}(T:OP_ADDR16; C: CL_BRANCH; Name: '*CALL '),
			{FE}(T:OP_DATA8;  C: CL_COMMON; Name: 'CPI '),
			{FF}(T:OP_SIMPLE; C: CL_COMMON; Name: 'RST 7')
	);
	//Длина команд в байтах
	i8080len:array [0..255] of Word = (
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

procedure DisAsm8080(Buffer:PdisasmBuffer; Base, Size: Integer; printAddr, printCodes:Boolean; Lines:TStrings; ProgressBar:TProgressBar);

implementation

procedure DisAsm8080;
var P, C, Adr, Next:Integer;
		LabelValues: array [0..1000] of Word;
		LabelsCount, L, i, j, k: Integer;
		strParam, strAdr, strLabel, strCodes: String;
		isIncorrect: Boolean;
	function isLabel(Adr:Integer):Boolean;
	var i:Integer;
	begin
		Result := false;
		for i:=0 to LabelsCount-1 do
			if LabelValues[i]=Adr then begin
				Result := true;
				break;
			end;
	end;
	procedure AddLabel(Adr:Integer);
	begin
		if not isLabel(Adr) then begin
			Inc(LabelsCount);
			LabelValues[LabelsCount-1] := Adr;
		end;
	end;
begin
	Lines.BeginUpdate;
	Lines.Clear;
	//Первый проход - поиск меток
	ProgressBar.Position := 0;
	LabelsCount := 1;
	LabelValues[0] := Base;
	L:=0;
	while L < LabelsCount do begin
		P:=LabelValues[L]-Base;
		while P<Size do begin
			C:=Buffer[P];
			if (i8080instr[C].C=CL_BRANCH) or (i8080instr[C].C=CL_JUMP) then begin
				Adr := Buffer[P+1] + Buffer[P+2]*256;
				if (Adr >= Base) and (Adr < Base+Size) then
					AddLabel(Adr);
			end;
			if L=0 then begin
				ProgressBar.Position := Round(P / Size * 100);
			end;
			Inc(P, i8080len[C]);
		end;
		Inc(L);
	end;

	//Сортировка меток
	for i:=2 to LabelsCount do
		for j:=0 to LabelsCount-i do
			if LabelValues[j] > LabelValues[j+1] then begin
				k := LabelValues[j];
				LabelValues[j] := LabelValues[j+1];
				LabelValues[j+1] := k;
			end;
	ProgressBar.Position := 0;

	//Второй проход - дизассемблирование
	strAdr := '';
	strCodes := '';
	for L:=0 to LabelsCount-1 do begin
		if L<LabelsCount-1 then
			Next := LabelValues[L+1]
		else
			Next := Base+Size;
		P:=LabelValues[L]-Base;
		while P+Base < Next do begin
			C:=Buffer[P];

			//Проверка, чтобы команда не вылезала за сегмент
			if P+Base+i8080len[C] <= Next then begin
				if printAddr then strAdr := IntToHex(P+Base, 4)+': ';

				if printCodes then begin
					strCodes := IntToHex(C, 2)+' ';
					if i8080len[C]=1 then
						strCodes := strCodes + '       '
					else
					if i8080len[C]=2 then
						strCodes := strCodes + IntToHex(Buffer[P+1], 2)+ '     '
					else
					if i8080len[C]=3 then
						strCodes := strCodes + IntToHex(Buffer[P+1], 2) + ' ' + IntToHex(Buffer[P+2], 2)+ '  ';
				end;

				if isLabel(P+Base) then
					strLabel := 'L_'+IntToHex(P+Base, 4)+': '
				else
					strLabel := '        ';

				if (i8080instr[C].T=OP_DATA16) or (i8080instr[C].T=OP_ADDR16) then begin
					strParam := IntToHex(Buffer[P+1] + Buffer[P+2]*256, 4);
					if (i8080instr[C].T=OP_ADDR16) and ((i8080instr[C].C=CL_BRANCH) or (i8080instr[C].C=CL_JUMP)) then
						strParam := 'L_' + strParam
					else begin
						strParam := strParam + 'H';
						if i8080instr[C].T=OP_ADDR16 then
							strParam := '[' + strParam + ']';
					end;
				end else
				if i8080instr[C].T=OP_DATA8 then
					strParam := IntToHex(Buffer[P+1], 2) + 'H'
				else
					strParam := '';

				Lines.Add(strAdr + strCodes + strLabel +	i8080instr[C].Name + strParam);
				Inc(P, i8080len[C]);

				isIncorrect := False;
			end else
				isIncorrect := True;

			//Вывод конца сегмента в качестве данных
			if  (P+Base < Next) and																			     //Не конец сегмента
					((i8080instr[C].C=CL_RET) or (i8080instr[C].C=CL_JUMP) or	  //был безусловный переход
					isIncorrect)																								//Или предыдущая команда вылезла за сегмент

			then begin
				strLabel := '        ';
				if printCodes then strCodes := '          ' else strCodes := '';
				strAdr := '';
				strParam := '';
				k:=0;
				while P+Base < Next do begin
					if k mod 4 = 0 then begin
						if Length(strParam) <> 0 then
							Lines.Add(strAdr + strCodes + strLabel + strParam);
						if printAddr then strAdr := IntToHex(P+Base,4)+': ';
						strParam := 'DB ';
					end;
					C:=Buffer[P];
					strParam := strParam + IntToHex(C, 2) + 'H';
					Inc(P);
					if (P+Base < Next) and (k mod 4 <> 3) then strParam := strParam + ', ';
					Inc(k);
				end;
				if Length(strParam) > 3 then
					Lines.Add(strAdr + strCodes + strLabel + strParam);
			end;
			ProgressBar.Position := Round(P / Size * 100);
		end;
	end;
	//Вывод
	//for i:=0 to LabelsCount-1 do
	//	Lines.Add(IntToHex(LabelValues[i], 4));
	Lines.EndUpdate;
end;

end.
