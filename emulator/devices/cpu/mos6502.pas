unit mos6502;
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

uses Core, Utils, Config;

type
	T6502Context = packed record
		A, X, Y, P, S: Byte;
		case Integer of
			0: (PC: Word);
			1: (PCL, PCH: Byte);
	end;
	T6502command = procedure (Command: Byte; var Cycles:Cardinal) of Object;
	T6502 = class (TCPU)
	private
		FIInt: TInterface; {int}
		FINmi: TInterface; {nmi}
		FISO: TInterface;	 {so}
		
		FCommands: array [0..255] of T6502command;
		function ReadMem(Address:Word):Byte;
		procedure WriteMem(Address:Word; Value:Byte);
		function NextByte:Byte;
		function Get2ndOperand(Command:Byte; var Cycles:Cardinal):Byte;
		function Get2ndAddress(Command:Byte; var Cycles:Cardinal):Word;
		procedure CalcFlags(Value, Mask:Cardinal);
		procedure SetFlag(Flag, Value:Cardinal);

		procedure _ADC(Command: Byte; var Cycles:Cardinal);
		procedure _AND(Command: Byte; var Cycles:Cardinal);
		procedure _ASL(Command: Byte; var Cycles:Cardinal);
		procedure _BRANCH(Command: Byte; var Cycles:Cardinal);
		procedure _BIT(Command: Byte; var Cycles:Cardinal);
		procedure _BRK(Command: Byte; var Cycles:Cardinal);
		procedure _CLC(Command: Byte; var Cycles:Cardinal);
		procedure _CLD(Command: Byte; var Cycles:Cardinal);
		procedure _CLI(Command: Byte; var Cycles:Cardinal);
		procedure _CLV(Command: Byte; var Cycles:Cardinal);
		procedure _CMP(Command: Byte; var Cycles:Cardinal);
		procedure _CPX(Command: Byte; var Cycles:Cardinal);
		procedure _CPY(Command: Byte; var Cycles:Cardinal);
		procedure _DEC(Command: Byte; var Cycles:Cardinal);
		procedure _DEX(Command: Byte; var Cycles:Cardinal);
		procedure _DEY(Command: Byte; var Cycles:Cardinal);
		procedure _EOR(Command: Byte; var Cycles:Cardinal);
		procedure _INC(Command: Byte; var Cycles:Cardinal);
		procedure _INX(Command: Byte; var Cycles:Cardinal);
		procedure _INY(Command: Byte; var Cycles:Cardinal);
		procedure _JMP(Command: Byte; var Cycles:Cardinal);
		procedure _JSR(Command: Byte; var Cycles:Cardinal);
		procedure _LDA(Command: Byte; var Cycles:Cardinal);
		procedure _LDX(Command: Byte; var Cycles:Cardinal);
		procedure _LDY(Command: Byte; var Cycles:Cardinal);
		procedure _LSR(Command: Byte; var Cycles:Cardinal);
		procedure _NOP(Command: Byte; var Cycles:Cardinal);
		procedure _ORA(Command: Byte; var Cycles:Cardinal);
		procedure _PHA(Command: Byte; var Cycles:Cardinal);
		procedure _PHP(Command: Byte; var Cycles:Cardinal);
		procedure _PLA(Command: Byte; var Cycles:Cardinal);
		procedure _PLP(Command: Byte; var Cycles:Cardinal);
		procedure _ROL(Command: Byte; var Cycles:Cardinal);
		procedure _ROR(Command: Byte; var Cycles:Cardinal);
		procedure _RTI(Command: Byte; var Cycles:Cardinal);
		procedure _RTS(Command: Byte; var Cycles:Cardinal);
		procedure _SBC(Command: Byte; var Cycles:Cardinal);
		procedure _SEC(Command: Byte; var Cycles:Cardinal);
		procedure _SED(Command: Byte; var Cycles:Cardinal);
		procedure _SEI(Command: Byte; var Cycles:Cardinal);
		procedure _STA(Command: Byte; var Cycles:Cardinal);
		procedure _STX(Command: Byte; var Cycles:Cardinal);
		procedure _STY(Command: Byte; var Cycles:Cardinal);
		procedure _TAX(Command: Byte; var Cycles:Cardinal);
		procedure _TAY(Command: Byte; var Cycles:Cardinal);
		procedure _TSX(Command: Byte; var Cycles:Cardinal);
		procedure _TXA(Command: Byte; var Cycles:Cardinal);
		procedure _TXS(Command: Byte; var Cycles:Cardinal);
		procedure _TYA(Command: Byte; var Cycles:Cardinal);

    //Недокументированные
		procedure __ANE(Command: Byte; var Cycles:Cardinal);
		procedure __ANC(Command: Byte; var Cycles:Cardinal);
		procedure __ANC2(Command: Byte; var Cycles:Cardinal);
		procedure __ARR(Command: Byte; var Cycles:Cardinal);
		procedure __ASR(Command: Byte; var Cycles:Cardinal);
		procedure __DCP(Command: Byte; var Cycles:Cardinal);
		procedure __ISB(Command: Byte; var Cycles:Cardinal);
		procedure __LAS(Command: Byte; var Cycles:Cardinal);
		procedure __LAX(Command: Byte; var Cycles:Cardinal);
		procedure __LXA(Command: Byte; var Cycles:Cardinal);
		procedure __RLA(Command: Byte; var Cycles:Cardinal);
		procedure __RRA(Command: Byte; var Cycles:Cardinal);
		procedure __SAX(Command: Byte; var Cycles:Cardinal);
		procedure __SBX(Command: Byte; var Cycles:Cardinal);
		procedure __SHA(Command: Byte; var Cycles:Cardinal);
		procedure __SHS(Command: Byte; var Cycles:Cardinal);
		procedure __SHX(Command: Byte; var Cycles:Cardinal);
		procedure __SHY(Command: Byte; var Cycles:Cardinal);
		procedure __SLO(Command: Byte; var Cycles:Cardinal);
		procedure __SRE(Command: Byte; var Cycles:Cardinal);
		procedure __KILL(Command: Byte; var Cycles:Cardinal);
		procedure __NOP(Command: Byte; var Cycles:Cardinal);

		procedure InitCommands;
	protected
		function GetPC:Cardinal; override;
	public
		FContext: T6502Context;
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		function Execute:Cardinal; override;
		property Context:T6502Context read FContext;
	end;

const
	//Значения битов регистра флагов
	F_C = $01;
	F_Z = $02;
	F_I = $04;
	F_D = $08;
	F_B = $10;
	F_5 = $20;
	F_V = $40;
	F_N = $80;
	F_ALL=	F_C + F_Z + F_I + F_D + F_B + F_5 + F_V + F_N;

	//Таблица значений флагов нуля и знака
	ZERO_SIGN:array [0..255] of byte =(
			F_Z,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  // 00-0F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    // 10-1F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    // 20-2F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    // 30-3F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 		// 40-4F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    // 50-5F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    // 60-6F */
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    // 70-7F */
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,  	// 80-8F */
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,  	// 90-9F */
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,  	// A0-AF */
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,  	// B0-BF */
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,  	// C0-CF */
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,  	// D0-DF */
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,  	// E0-EF */
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N,
			F_N,F_N,F_N,F_N,F_N,F_N,F_N,F_N);		// F0-FF */

	MOS6502_TIME:array [0..255] of byte =(
		7,6,2,8,3,3,5,5,3,2,2,2,4,4,6,6,
		2,5,2,8,4,4,6,6,2,4,2,7,5,5,7,7,
		6,6,2,8,3,3,5,5,4,2,2,2,4,4,6,6,
		2,5,2,8,4,4,6,6,2,4,2,7,5,5,7,7,
		6,6,2,8,3,3,5,5,3,2,2,2,3,4,6,6,
		2,5,2,8,4,4,6,6,2,4,2,7,5,5,7,7,
		6,6,2,8,3,3,5,5,4,2,2,2,5,4,6,6,
		2,5,2,8,4,4,6,6,2,4,2,7,5,5,7,7,
		2,6,2,6,3,3,3,3,2,2,2,2,4,4,4,4,
		2,6,2,6,4,4,4,4,2,5,2,5,5,5,5,5,
		2,6,2,6,3,3,3,3,2,2,2,2,4,4,4,4,
		2,5,2,5,4,4,4,4,2,4,2,5,4,4,4,4,
		2,6,2,8,3,3,5,5,2,2,2,2,4,4,6,6,
		2,5,2,8,4,4,6,6,2,4,2,7,5,5,7,7,
		2,6,2,8,3,3,5,5,2,2,2,2,4,4,6,6,
		2,5,2,8,4,4,6,6,2,4,2,7,5,5,7,7
	);

implementation

function Create6502(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := T6502.Create(IM, ConfigDevice);
end;

constructor T6502.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIAddress := CreateInterface(16, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_RW);

	FINmi := CreateInterface(1, 'nmi', MODE_R);
	FIInt := CreateInterface(1, 'int', MODE_R);
	FISO := CreateInterface(1, 'so', MODE_R);

	InitCommands;

	//DebugMode :=DEBUG_STOPPED;
end;

procedure T6502.InitCommands;
begin
	FCommands[$00] := _BRK;
	FCommands[$01] := _ORA;
	FCommands[$02] := __KILL;
	FCommands[$03] := __SLO;
	FCommands[$04] := __NOP;
	FCommands[$05] := _ORA;
	FCommands[$06] := _ASL;
	FCommands[$07] := __SLO;
	FCommands[$08] := _PHP;
	FCommands[$09] := _ORA;
	FCommands[$0A] := _ASL;
	FCommands[$0B] := __ANC;
	FCommands[$0C] := __NOP;
	FCommands[$0D] := _ORA;
	FCommands[$0E] := _ASL;
	FCommands[$0F] := __SLO;

	FCommands[$10] := _BRANCH;
	FCommands[$11] := _ORA;
	FCommands[$12] := __KILL;
	FCommands[$13] := __SLO;
	FCommands[$14] := __NOP;
	FCommands[$15] := _ORA;
	FCommands[$16] := _ASL;
	FCommands[$17] := __SLO;
	FCommands[$18] := _CLC;
	FCommands[$19] := _ORA;
	FCommands[$1A] := __NOP;
	FCommands[$1B] := __SLO;
	FCommands[$1C] := __NOP;
	FCommands[$1D] := _ORA;
	FCommands[$1E] := _ASL;
	FCommands[$1F] := __SLO;

	FCommands[$20] := _JSR;
	FCommands[$21] := _AND;
	FCommands[$22] := __KILL;
	FCommands[$23] := __RLA;
	FCommands[$24] := _BIT;
	FCommands[$25] := _AND;
	FCommands[$26] := _ROL;
	FCommands[$27] := __RLA;
	FCommands[$28] := _PLP;
	FCommands[$29] := _AND;
	FCommands[$2A] := _ROL;
	FCommands[$2B] := __ANC2;
	FCommands[$2C] := _BIT;
	FCommands[$2D] := _AND;
	FCommands[$2E] := _ROL;
	FCommands[$2F] := __RLA;

	FCommands[$30] := _BRANCH;
	FCommands[$31] := _AND;
	FCommands[$32] := __KILL;
	FCommands[$33] := __RLA;
	FCommands[$34] := __NOP;
	FCommands[$35] := _AND;
	FCommands[$36] := _ROL;
	FCommands[$37] := __RLA;
	FCommands[$38] := _SEC;
	FCommands[$39] := _AND;
	FCommands[$3A] := __NOP;
	FCommands[$3B] := __RLA;
	FCommands[$3C] := __NOP;
	FCommands[$3D] := _AND;
	FCommands[$3E] := _ROL;
	FCommands[$3F] := __RLA;

	FCommands[$40] := _RTI;
	FCommands[$41] := _EOR;
	FCommands[$42] := __KILL;
	FCommands[$43] := __SRE;
	FCommands[$44] := __NOP;
	FCommands[$45] := _EOR;
	FCommands[$46] := _LSR;
	FCommands[$47] := __SRE;
	FCommands[$48] := _PHA;
	FCommands[$49] := _EOR;
	FCommands[$4A] := _LSR;
	FCommands[$4B] := __ASR;
	FCommands[$4C] := _JMP;
	FCommands[$4D] := _EOR;
	FCommands[$4E] := _LSR;
	FCommands[$4F] := __SRE;

	FCommands[$50] := _BRANCH;
	FCommands[$51] := _EOR;
	FCommands[$52] := __KILL;
	FCommands[$53] := __SRE;
	FCommands[$54] := __NOP;
	FCommands[$55] := _EOR;
	FCommands[$56] := _LSR;
	FCommands[$57] := __SRE;
	FCommands[$58] := _CLI;
	FCommands[$59] := _EOR;
	FCommands[$5A] := __NOP;
	FCommands[$5B] := __SRE;
	FCommands[$5C] := __NOP;
	FCommands[$5D] := _EOR;
	FCommands[$5E] := _LSR;
	FCommands[$5F] := __SRE;

	FCommands[$60] := _RTS;
	FCommands[$61] := _ADC;
	FCommands[$62] := __KILL;
	FCommands[$63] := __RRA;
	FCommands[$64] := __NOP;
	FCommands[$65] := _ADC;
	FCommands[$66] := _ROR;
	FCommands[$67] := __RRA;
	FCommands[$68] := _PLA;
	FCommands[$69] := _ADC;
	FCommands[$6A] := _ROR;
	FCommands[$6B] := __ARR;
	FCommands[$6C] := _JMP;
	FCommands[$6D] := _ADC;
	FCommands[$6E] := _ROR;
	FCommands[$6F] := __RRA;

	FCommands[$70] := _BRANCH;
	FCommands[$71] := _ADC;
	FCommands[$72] := __KILL;
	FCommands[$73] := __RRA;
	FCommands[$74] := __NOP;
	FCommands[$75] := _ADC;
	FCommands[$76] := _ROR;
	FCommands[$77] := __RRA;
	FCommands[$78] := _SEI;
	FCommands[$79] := _ADC;
	FCommands[$7A] := __NOP;
	FCommands[$7B] := __RRA;
	FCommands[$7C] := __NOP;
	FCommands[$7D] := _ADC;
	FCommands[$7E] := _ROR;
	FCommands[$7F] := __RRA;

	FCommands[$80] := __NOP;
	FCommands[$81] := _STA;
	FCommands[$82] := __NOP;
	FCommands[$83] := __SAX;
	FCommands[$84] := _STY;
	FCommands[$85] := _STA;
	FCommands[$86] := _STX;
	FCommands[$87] := __SAX;
	FCommands[$88] := _DEY;
	FCommands[$89] := __NOP;
	FCommands[$8A] := _TXA;
	FCommands[$8B] := __ANE;
	FCommands[$8C] := _STY;
	FCommands[$8D] := _STA;
	FCommands[$8E] := _STX;
	FCommands[$8F] := __SAX;

	FCommands[$90] := _BRANCH;
	FCommands[$91] := _STA;
	FCommands[$92] := __KILL;
	FCommands[$93] := __SHA;
	FCommands[$94] := _STY;
	FCommands[$95] := _STA;
	FCommands[$96] := _STX;
	FCommands[$97] := __SAX;
	FCommands[$98] := _TYA;
	FCommands[$99] := _STA;
	FCommands[$9A] := _TXS;
	FCommands[$9B] := __SHS;
	FCommands[$9C] := __SHY;
	FCommands[$9D] := _STA;
	FCommands[$9E] := __SHX;
	FCommands[$9F] := __SHA;

	FCommands[$A0] := _LDY;
	FCommands[$A1] := _LDA;
	FCommands[$A2] := _LDX;
	FCommands[$A3] := __LAX;
	FCommands[$A4] := _LDY;
	FCommands[$A5] := _LDA;
	FCommands[$A6] := _LDX;
	FCommands[$A7] := __LAX;
	FCommands[$A8] := _TAY;
	FCommands[$A9] := _LDA;
	FCommands[$AA] := _TAX;
	FCommands[$AB] := __LXA;
	FCommands[$AC] := _LDY;
	FCommands[$AD] := _LDA;
	FCommands[$AE] := _LDX;
	FCommands[$AF] := __LAX;

	FCommands[$B0] := _BRANCH;
	FCommands[$B1] := _LDA;
	FCommands[$B2] := __KILL;
	FCommands[$B3] := __LAX;
	FCommands[$B4] := _LDY;
	FCommands[$B5] := _LDA;
	FCommands[$B6] := _LDX;
	FCommands[$B7] := __LAX;
	FCommands[$B8] := _CLV;
	FCommands[$B9] := _LDA;
	FCommands[$BA] := _TSX;
	FCommands[$BB] := __LAS;
	FCommands[$BC] := _LDY;
	FCommands[$BD] := _LDA;
	FCommands[$BE] := _LDX;
	FCommands[$BF] := __LAX;

	FCommands[$C0] := _CPY;
	FCommands[$C1] := _CMP;
	FCommands[$C2] := __NOP;
	FCommands[$C3] := __DCP;
	FCommands[$C4] := _CPY;
	FCommands[$C5] := _CMP;
	FCommands[$C6] := _DEC;
	FCommands[$C7] := __DCP;
	FCommands[$C8] := _INY;
	FCommands[$C9] := _CMP;
	FCommands[$CA] := _DEX;
	FCommands[$CB] := __SBX;
	FCommands[$CC] := _CPY;
	FCommands[$CD] := _CMP;
	FCommands[$CE] := _DEC;
	FCommands[$CF] := __DCP;

	FCommands[$D0] := _BRANCH;
	FCommands[$D1] := _CMP;
	FCommands[$D2] := __KILL;
	FCommands[$D3] := __DCP;
	FCommands[$D4] := __NOP;
	FCommands[$D5] := _CMP;
	FCommands[$D6] := _DEC;
	FCommands[$D7] := __DCP;
	FCommands[$D8] := _CLD;
	FCommands[$D9] := _CMP;
	FCommands[$DA] := __NOP;
	FCommands[$DB] := __DCP;
	FCommands[$DC] := __NOP;
	FCommands[$DD] := _CMP;
	FCommands[$DE] := _DEC;
	FCommands[$DF] := __DCP;

	FCommands[$E0] := _CPX;
	FCommands[$E1] := _SBC;
	FCommands[$E2] := __NOP;
	FCommands[$E3] := __ISB;
	FCommands[$E4] := _CPX;
	FCommands[$E5] := _SBC;
	FCommands[$E6] := _INC;
	FCommands[$E7] := __ISB;
	FCommands[$E8] := _INX;
	FCommands[$E9] := _SBC;
	FCommands[$EA] := _NOP;
	FCommands[$EB] := _SBC; {!!!}
	FCommands[$EC] := _CPX;
	FCommands[$ED] := _SBC;
	FCommands[$EE] := _INC;
	FCommands[$EF] := __ISB;

	FCommands[$F0] := _BRANCH;
	FCommands[$F1] := _SBC;
	FCommands[$F2] := __KILL;
	FCommands[$F3] := __ISB;
	FCommands[$F4] := __NOP;
	FCommands[$F5] := _SBC;
	FCommands[$F6] := _INC;
	FCommands[$F7] := __ISB;
	FCommands[$F8] := _SED;
	FCommands[$F9] := _SBC;
	FCommands[$FA] := __NOP;
	FCommands[$FB] := __ISB;
	FCommands[$FC] := __NOP;
	FCommands[$FD] := _SBC;
	FCommands[$FE] := _INC;
	FCommands[$FF] := __ISB;
end;

function T6502.GetPC;
begin
	Result := FContext.PC;
end;

function T6502.ReadMem(Address:Word):Byte;
begin
	//FIAddress.Change(Address);
	Result := Byte(Mapper.Read(Address));
	//FIAddress.Disconnect;
end;

procedure T6502.WriteMem(Address:Word; Value:Byte);
begin
	//FIAddress.Change(Address);
	Mapper.Write(Address, Value);
	//FIAddress.Disconnect;
end;

function T6502.NextByte:Byte;
begin
	Result := ReadMem(FContext.PC);
	Inc(FContext.PC);
end;

function T6502.Execute;
var
	Command: Byte;
	C: Cardinal;
begin
	//Первоначальный сброс
	if FReset then begin
		FContext.PCL := ReadMem($FFFC);
		FContext.PCH := ReadMem($FFFD);
		FReset := FALSE;
	end;

	if DebugMode<>DEBUG_OFF then begin
		if DebugMode=DEBUG_STOPPED then	begin
			Result := 4;
			Exit;
		end;
	end;

	Command := NextByte;
	C:=MOS6502_TIME[Command]; 
	FCommands[Command](Command, C);

	if DebugMode=DEBUG_STEP then DebugMode:=DEBUG_STOPPED;
	if DebugMode=DEBUG_BRAKES then
		if CheckBreakPoint(FContext.PC) then
			DebugMode := DEBUG_STOPPED;
	Result := C;
	
end;

function T6502.Get2ndOperand(Command:Byte; var Cycles:Cardinal):Byte;
var M:Byte;
		T, T2:PartsRec;
begin
	M:= (Command and $1C) shr 2;
	T.C := 0; T2.C := 0;
	Result := 0;
	case M of
		0:begin
				//ind, x
				T.L := NextByte;
				Inc(T.C, FContext.X);
				T.H := 0; {Вопрос: заворачивается ли адрес на 0-ю страницу?}
				T2.L := ReadMem(T.W);
				T2.H := ReadMem(T.W+1);
				Result := ReadMem(T2.W);
			end;
		1:begin
				//zp
				T.L := NextByte;
				Result := ReadMem(T.W);
			end;
		2:begin
				//imm
				Result := NextByte;
			end;
		3:begin
				//abs
				T.L := NextByte;
				T.H := NextByte;
				Result := ReadMem(T.W);
			end;
		4:begin
				//ind, y
				T.L := NextByte;
				T.H := 0; {Вопрос: заворачивается ли адрес на 0-ю страницу?}
				T2.L := ReadMem(T.W);
				T2.H := ReadMem(T.W+1);
				Inc(T2.C, FContext.Y);
				Result := ReadMem(T2.W);
				{Здесь добавить 1 такт при пересечении границы страницы}
			end;
		5:begin
				//zp, x
				T.L := NextByte;
				Inc(T.C, FContext.X);
				T.H := 0; {Вопрос: заворачивается ли адрес на 0-ю страницу?}
				Result := ReadMem(T.W);
			end;
		6:begin
				//abs, y
				T.L := NextByte;
				T.H := NextByte;
				Inc(T.C, FContext.Y);
				Result := ReadMem(T.W);
				{Здесь добавить 1 такт при пересечении границы страницы}
			end;
		7:begin
				//abs, x
				T.L := NextByte;
				T.H := NextByte;
				Inc(T.C, FContext.X);
				Result := ReadMem(T.W);
				{Здесь добавить 1 такт при пересечении границы страницы}
			end;
		else FIM.DM.Error(Self, 'Неизвестный режим адресации');
	end;
end;

function T6502.Get2ndAddress(Command:Byte; var Cycles:Cardinal):Word;
var M:Byte;
		T, T2:PartsRec;
begin
	M:= (Command and $1C) shr 2;
	T.C := 0; T2.C := 0;
	Result := 0;
	case M of
		1:begin
				//zp
				T.L := NextByte;
				Result := T.W;
			end;
		3:begin
				//abs
				T.L := NextByte;
				T.H := NextByte;
				Result := T.W;
			end;
		4:begin
				//ind, y
				T.L := NextByte;
				T.H := 0; {Вопрос: заворачивается ли адрес на 0-ю страницу?}
				T2.L := ReadMem(T.W);
				T2.H := ReadMem(T.W+1);
				Inc(T2.C, FContext.Y);
				Result := T2.W;
				{Здесь добавить 1 такт при пересечении границы страницы}
			end;
		5:begin
				//zp, x
				T.L := NextByte;
				Inc(T.C, FContext.X);
				T.H := 0; {Вопрос: заворачивается ли адрес на 0-ю страницу?}
				Result := T.W;
			end;
		6:begin
				//abs, y
				T.L := NextByte;
				T.H := NextByte;
				Inc(T.C, FContext.Y);
				Result := T.W;
				{Здесь добавить 1 такт при пересечении границы страницы}
			end;
		7:begin
				//abs, x
				T.L := NextByte;
				T.H := NextByte;
				Inc(T.C, FContext.X);
				Result := T.W;
			end;
		else FIM.DM.Error(Self, 'Режим адресации не реализован');
	end;
end;

procedure T6502.CalcFlags(Value, Mask:Cardinal);
var T: Byte;
begin
	T :=  ZERO_SIGN[Value and $FF] 	 		//ZERO, SIGN
				or ((Value shr 8) and F_C);		//CARRY
	FContext.P := (FContext.P and not Mask) or (T and Mask); 
end;

procedure T6502.SetFlag(Flag, Value:Cardinal);
begin
	FContext.P := (FContext.P and not Flag) or (Value and Flag); 
end;

procedure T6502._ADC;
var V:Byte;
		T: PartsRec;
begin
	V := Get2ndOperand(Command, Cycles); {std}
	if FContext.P and F_B = 0 then begin
		//Двоичный режим
		T.C := FContext.A + V + (FContext.P and F_C);

		CalcFlags(T.C, F_N+F_Z+F_C);
		SetFlag(F_V, ((FContext.A xor T.L) and (V xor T.L)) shr 1);

		FContext.A := T.L;
	end else begin
		//BCD-режим
		FIM.DM.Error(Self, 'BCD');
	end;
end;

procedure T6502._AND;
var V:Byte;
begin
	V := Get2ndOperand(Command, Cycles); {std}
	FContext.A := FContext.A and V;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502._ASL;
var A, T: PartsRec;
begin
	if Command=$0A then begin
		//ASL A
		T.W := FContext.A shl 1;
		CalcFlags(T.W, F_N+F_Z+F_C);
		FContext.A := T.L;
	end else begin
		//ASL mem
		A.W := Get2ndAddress(Command, Cycles); {std}
		T.W := ReadMem(A.W) shl 1;
		CalcFlags(T.W, F_N+F_Z+F_C);
		WriteMem(A.W, T.L);
	end;
end;

procedure T6502._BRANCH;
var Branch: Boolean;
		V: Byte;
begin
	Branch := False;
	case Command of
		$D0: Branch := (FContext.P and F_Z) = 0;		//BNE
		$F0: Branch := (FContext.P and F_Z) = F_Z;	//BEQ
		$90: Branch := (FContext.P and F_C) = 0;	  //BCC
		$B0: Branch := (FContext.P and F_C) = F_C;	//BCS
		$10: Branch := (FContext.P and F_N) = 0;	  //BPL
		$30: Branch := (FContext.P and F_N) = F_N;  //BMI
		$50: Branch := (FContext.P and F_V) = 0;	  //BVC
		$70: Branch := (FContext.P and F_V) = F_V;  //BVS
		else FIM.DM.Error(Self, 'Неизвестная команда перехода');
	end;
	V := NextByte;
	if Branch then FContext.PC := Word(FContext.PC + ShortInt(V));
end;

procedure T6502._BIT;
var V: Byte;
begin
	V := Get2ndOperand(Command, Cycles); {std}
	CalcFlags(FContext.A and V, F_Z);
	SetFlag(F_V+F_N, V);
end;

procedure T6502._BRK;
begin
	WriteMem(FContext.S+$100, FContext.PCH);
	Dec(FContext.S);
	WriteMem(FContext.S+$100, FContext.PCL);
	Dec(FContext.S);
	WriteMem(FContext.S+$100, FContext.P);
	Dec(FContext.S);
	SetFlag(F_B+F_I, F_B+F_I);
	FContext.PCL := ReadMem($FFFE);
	FContext.PCH := ReadMem($FFFF);
end;

procedure T6502._CLC;
begin
	SetFlag(F_C, 0);
end;

procedure T6502._CLD;
begin
	SetFlag(F_D, 0);
end;

procedure T6502._CLI;
begin
	SetFlag(F_I, 0);
end;

procedure T6502._CLV;
begin
	SetFlag(F_V, 0);
end;

procedure T6502._CMP;
var V:Byte;
		T: PartsRec;
begin
	V := Get2ndOperand(Command, Cycles); {std}
	T.C := FContext.A - V;
	CalcFlags(T.C, F_N+F_Z+F_C);
end;

procedure T6502._CPX;
var V:Byte;
		T: PartsRec;
begin
	case Command of
		$E0: V := NextByte;
	else
		V := Get2ndOperand(Command, Cycles); {std}
	end;
	T.C := FContext.X - V;
	CalcFlags(T.C, F_N+F_Z+F_C);
end;

procedure T6502._CPY;
var V:Byte;
		T: PartsRec;
begin
	case Command of
		$C0: V := NextByte;
	else
		V := Get2ndOperand(Command, Cycles); {std}
	end;
	T.C := FContext.Y - V;
	CalcFlags(T.C, F_N+F_Z+F_C);
end;

procedure T6502._DEC;
var A, T: PartsRec;
begin
	A.W := Get2ndAddress(Command, Cycles); {std}
	T.W := ReadMem(A.W) - 1;
	CalcFlags(T.C, F_N+F_Z);
	WriteMem(A.W, T.L);
end;

procedure T6502._DEX;
var T: PartsRec;
begin
	T.W := FContext.X - 1;
	CalcFlags(T.C, F_N+F_Z);
	FContext.X := T.L;
end;

procedure T6502._DEY;
var T: PartsRec;
begin
	T.W := FContext.Y - 1;
	CalcFlags(T.C, F_N+F_Z);
	FContext.Y := T.L;
end;

procedure T6502._EOR;
var V:Byte;
begin
	V := Get2ndOperand(Command, Cycles); {std}
	FContext.A := FContext.A xor V;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502._INC;
var A, T: PartsRec;
begin
	A.W := Get2ndAddress(Command, Cycles); {std}
	T.W := ReadMem(A.W) + 1;
	CalcFlags(T.C, F_N+F_Z);
	WriteMem(A.W, T.L);
end;

procedure T6502._INX;
var T: PartsRec;
begin
	T.W := FContext.X + 1;
	CalcFlags(T.C, F_N+F_Z);
	FContext.X := T.L;
end;

procedure T6502._INY;
var T: PartsRec;
begin
	T.W := FContext.Y + 1;
	CalcFlags(T.C, F_N+F_Z);
	FContext.Y := T.L;
end;

procedure T6502._JMP;
var A, T: PartsRec;
begin
	A.L := NextByte;
	A.H := NextByte;
	case Command of
		$4C:T := A;
		$6C:begin
					T.L := ReadMem(A.W);
					T.H := ReadMem(A.W+1);
				end;
		else FIM.DM.Error(Self, 'Неизвестная команда JMP');
	end;
	FContext.PC := T.W;
end;

procedure T6502._JSR;
var A: PartsRec;
begin
	A.L := NextByte;
	A.H := NextByte;
	WriteMem(FContext.S+$100, FContext.PCH);
	Dec(FContext.S);
	WriteMem(FContext.S+$100, FContext.PCL);
	Dec(FContext.S);
	FContext.PC := A.W;
end;

procedure T6502._LDA;
begin
	FContext.A := Get2ndOperand(Command, Cycles); {std}
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502._LDX;
var T: PartsRec;
begin
	//Здесь нестандартная адресация
	case Command of
		$A2: FContext.X := NextByte; 	//LDX #imm
		$B6:begin 										//LDX ZP,Y
					T.C := 0;
					T.L := NextByte;
					Inc(T.C, FContext.Y);
					T.H := 0; {! Вопрос: заворачивается ли адрес на 0-ю страницу? !}
					FContext.X := ReadMem(T.W);
				end;
		$BE:begin 										//LDX ABS,Y
					T.C := 0;
					T.L := NextByte;
					T.H := NextByte;
					Inc(T.C, FContext.Y);
					FContext.X := ReadMem(T.W);
				end;
		else
			FContext.X := Get2ndOperand(Command, Cycles);
	end;
	CalcFlags(FContext.X, F_N+F_Z);
end;

procedure T6502._LDY;
begin
	//Здесь нестандартная адресация
	case Command of
		$A0: FContext.Y := NextByte; //LDY #imm
		else
			FContext.Y := Get2ndOperand(Command, Cycles);
	end;
	CalcFlags(FContext.Y, F_N+F_Z);
end;

procedure T6502._LSR;
var A, T: PartsRec;
		V: Byte;
begin
	if Command=$4A then begin
		//LSR A
		SetFlag(F_C, FContext.A);
		T.L := FContext.A shr 1;
		CalcFlags(T.L, F_N+F_Z);
		FContext.A := T.L;
	end else begin
		//LSR mem
		A.W := Get2ndAddress(Command, Cycles); {std}
		V := ReadMem(A.W);
		SetFlag(F_C, V);
		T.L := V shr 1;
		CalcFlags(T.L, F_N+F_Z);
		WriteMem(A.W, T.L);
	end;
end;

procedure T6502._NOP;
begin
	//Собссно, NOP
end;

procedure T6502._ORA;
var V:Byte;
begin
	V := Get2ndOperand(Command, Cycles); {std}
	FContext.A := FContext.A or V;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502._PHA;
begin
	WriteMem(FContext.S+$100, FContext.A);
	Dec(FContext.S);
end;

procedure T6502._PHP;
begin
	WriteMem(FContext.S+$100, FContext.P);
	Dec(FContext.S);
end;

procedure T6502._PLA;
begin
	Inc(FContext.S);
	FContext.A := ReadMem(FContext.S+$100);
end;

procedure T6502._PLP;
begin
		Inc(FContext.S);
		FContext.P := ReadMem(FContext.S+$100) or F_5;
end;

procedure T6502._ROL;
var A, T: PartsRec;
		V: Byte;
begin
	if Command=$2A then begin
		//ROL A
		T.W := (Word(FContext.A) shl 1) or (FContext.P and F_C);
		SetFlag(F_C, T.H);
		CalcFlags(T.L, F_N+F_Z);
		FContext.A := T.L;
	end else begin
		//ROL mem
		A.W := Get2ndAddress(Command, Cycles); {std}
		V := ReadMem(A.W);
		T.W := (Word(V) shl 1) or (FContext.P and F_C);
		SetFlag(F_C, T.H);
		CalcFlags(T.L, F_N+F_Z);
		WriteMem(A.W, T.L);
	end;
end;

procedure T6502._ROR;
var A, T: PartsRec;
begin
	if Command=$6A then begin
		//ROR A
		T.H := FContext.P and F_C;
		T.L := FContext.A;
		SetFlag(F_C, T.L);
		T.W := T.W shr 1;
		CalcFlags(T.L, F_N+F_Z);
		FContext.A := T.L;
	end else begin
		//ROR mem
		A.W := Get2ndAddress(Command, Cycles); {std}
		T.H := FContext.P and F_C;
		T.L := ReadMem(A.W);
		SetFlag(F_C, T.L);
		T.W := T.W shr 1;
		CalcFlags(T.L, F_N+F_Z);
		WriteMem(A.W, T.L);
	end;
end;

procedure T6502._RTI;
begin
	Inc(FContext.S);
	FContext.P := ReadMem(FContext.S+$100);
	Inc(FContext.S);
	FContext.PCL := ReadMem(FContext.S+$100);
	Inc(FContext.S);
	FContext.PCH := ReadMem(FContext.S+$100);
end;

procedure T6502._RTS;
begin
	Inc(FContext.S);
	FContext.PCL := ReadMem(FContext.S+$100);
	Inc(FContext.S);
	FContext.PCH := ReadMem(FContext.S+$100);
end;

procedure T6502._SBC;
var V:Byte;
		T: PartsRec;
begin
	V := Get2ndOperand(Command, Cycles); {std}
	if FContext.P and F_B = 0 then begin
		//Двоичный режим
		T.C := FContext.A - V - (FContext.P and F_C);

		CalcFlags(T.C, F_N+F_Z+F_C);
		SetFlag(F_V, ((FContext.A xor V) and (FContext.A xor T.L)) shr 1);

		FContext.A := T.L;
	end else begin
		//BCD-режим
		FIM.DM.Error(Self, 'BCD');
	end;
end;

procedure T6502._SEC;
begin
		SetFlag(F_C, F_C);
end;

procedure T6502._SED;
begin
	SetFlag(F_D, F_D);
end;

procedure T6502._SEI;
begin
	SetFlag(F_I, F_I);
end;

procedure T6502._STA;
var A: PartsRec;
begin
	A.W := Get2ndAddress(Command, Cycles); {std}
	WriteMem(A.W, FContext.A);
end;

procedure T6502._STX;
var A: PartsRec;
begin
	case Command of
		$96:begin								//STX ZP,Y
					A.C := 0;
					A.L := NextByte;
					Inc(A.C, FContext.Y);
					A.H := 0; {! Вопрос: заворачивается ли адрес на 0-ю страницу? !}
				end;
		else
			A.W := Get2ndAddress(Command, Cycles);
	end;
	WriteMem(A.W, FContext.X);
end;

procedure T6502._STY;
var A: PartsRec;
begin
	A.W := Get2ndAddress(Command, Cycles); {std}
	WriteMem(A.W, FContext.Y);
end;

procedure T6502._TAX;
begin
	FContext.X := FContext.A;
	CalcFlags(FContext.X, F_N+F_Z);
end;

procedure T6502._TAY;
begin
	FContext.Y := FContext.A;
	CalcFlags(FContext.Y, F_N+F_Z);
end;

procedure T6502._TSX;
begin
	FContext.X := FContext.S;
	CalcFlags(FContext.X, F_N+F_Z);
end;

procedure T6502._TXA;
begin
	FContext.A := FContext.X;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502._TXS;
begin
	FContext.S := FContext.X;
	//На флаги не влияет?
end;

procedure T6502._TYA;
begin
	FContext.A := FContext.Y;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502.__ANE;
var T: PartsRec;
begin
	T.L := NextByte;
	FContext.A := FContext.A and T.L;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502.__ANC;
begin
	__ANE($8B, Cycles);
	_ASL($0A, Cycles);
end;

procedure T6502.__ANC2;
begin
	__ANE($8B, Cycles);
	_ROL($2A, Cycles);
end;

procedure T6502.__ARR;
begin
	if FContext.P and F_B = 0 then begin
		__ANE($8B, Cycles);
		_ROR($6A, Cycles);
		SetFlag(F_N+F_V, FContext.A);
		CalcFlags(FContext.A, F_Z);
		SetFlag(F_C, ((FContext.A  shr 1) xor FContext.A) shr 5);
	end else begin
		//BCD-режим
		FIM.DM.Error(Self, 'BCD');
	end;
end;

procedure T6502.__ASR;
begin
	__ANE($8B, Cycles);
	_LSR($4A, Cycles);
end;

procedure T6502.__DCP;
var A, T: PartsRec;
		V: Byte;
begin
	//DEC
	A.W := Get2ndAddress(Command, Cycles); {std}
	V := ReadMem(A.W);
	T.W := V - 1;
	WriteMem(A.W, T.L);

  //CMP
	T.C := FContext.A - V;
	CalcFlags(T.C, F_N+F_Z+F_C);
end;

procedure T6502.__ISB;
var A, T: PartsRec;
		V: Byte;
begin
	//INC
	A.W := Get2ndAddress(Command, Cycles); {std}
	V := ReadMem(A.W);
	T.W := V + 1;
	WriteMem(A.W, T.L);

	//SBC
	if FContext.P and F_B = 0 then begin
		//Двоичный режим
		T.C := FContext.A - V - (FContext.P and F_C);

		CalcFlags(T.C, F_N+F_Z+F_C);
		SetFlag(F_V, ((FContext.A xor V) and (FContext.A xor T.L)) shr 1);

		FContext.A := T.L;
	end else begin
		//BCD-режим
		FIM.DM.Error(Self, 'BCD');
	end;
end;

procedure T6502.__LAS;
var A: PartsRec;
begin
	A.L := NextByte;
	A.H := NextByte;
	FContext.A := ReadMem(A.W) and FContext.S;
	FContext.S := FContext.A;
	FContext.X := FContext.A;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502.__LAX;
var T: PartsRec;
		V: Byte;
begin
	case Command of
		$B7:begin
					//zp, Y !!!!!!!!!
					T.C := 0;
					T.L := NextByte;
					Inc(T.C, FContext.Y {!!!!!!} );
					T.H := 0;
					V := ReadMem(T.W);
				end;
		$BF:begin
					//abs, Y !!!!!!!!!
					T.C := 0;
					T.L := NextByte;
					T.H := NextByte;
					Inc(T.C, FContext.Y);
					V := ReadMem(T.W);
				end;
		else begin
					V := Get2ndOperand(Command, Cycles);
				end;
	end;
	FContext.A := V;
	FContext.X := V;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502.__LXA;
var	V: Byte;
begin
	V := NextByte;
	FContext.A := V;
	FContext.X := V;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502.__RLA;
var A, T: PartsRec;
		V: Byte;
begin
	//ROL mem
	A.W := Get2ndAddress(Command, Cycles); {std}
	V := ReadMem(A.W);
	T.W := (Word(V) shl 1) or (FContext.P and F_C);
	SetFlag(F_C, T.H);
	CalcFlags(T.L, F_N+F_Z);
	WriteMem(A.W, T.L);

	//AND mem
	FContext.A := FContext.A and V;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502.__RRA;
var A, T: PartsRec;
		V: Byte;
begin
	{! Вопрос с флагом С, который участвует в обоих операциях !}

	//ROR mem
	A.W := Get2ndAddress(Command, Cycles); {std}
	V := ReadMem(A.W);

	T.H := FContext.P and F_C;
	T.L := V;
	SetFlag(F_C, T.L);
	T.W := T.W shr 1;
	CalcFlags(T.L, F_N+F_Z);
	WriteMem(A.W, T.L);

	//ADC mem
	T.C := FContext.A + V + (FContext.P and F_C);
	CalcFlags(T.C, F_N+F_Z+F_C);
	SetFlag(F_V, ((FContext.A xor T.L) and (V xor T.L)) shr 1);
	FContext.A := T.L;

end;

procedure T6502.__SAX;
var A: PartsRec;
begin
	case Command of
		$97:begin                		//SAX zp,Y
					A.C := 0;
					A.L := NextByte;
					Inc(A.C, FContext.Y);
					A.H := 0;
				end;
		else
			A.W := Get2ndAddress(Command, Cycles);
	end;
	WriteMem(A.W, FContext.A and FContext.X);
end;

procedure T6502.__SBX;
var T: PartsRec;
		V: Byte;
begin
	V := NextByte;
	T.C := (FContext.A and FContext.X) - V;
	FContext.X := T.L;
	CalcFlags(T.C, F_N+F_Z+F_C);
end;

procedure T6502.__SHA;
var A: PartsRec;
begin
	case Command of
		$9F:begin			//SHA abs,Y
					A.C := 0;
					A.L := NextByte;
					A.H := NextByte;
					Inc(A.C, FContext.Y);
				end;
		else
			A.W := Get2ndAddress(Command, Cycles);
	end;
	WriteMem(A.W, FContext.A and FContext.X and (A.H+1));
end;

procedure T6502.__SHS;
var A: PartsRec;
begin
	A.W := Get2ndAddress(Command, Cycles);
	WriteMem(A.W, FContext.S and (A.H+1));
	FContext.S := FContext.A and FContext.X;
end;

procedure T6502.__SHX;
var A: PartsRec;
begin
	A.C := 0;
	A.L := NextByte;
	A.H := NextByte;
	Inc(A.C, FContext.Y);
	WriteMem(A.W, FContext.X and (A.H+1));
end;

procedure T6502.__SHY;
var A: PartsRec;
begin
	{! не ясно, какой индексный регистр должен использоваться !}
	A.W := Get2ndAddress(Command, Cycles);
	WriteMem(A.W, FContext.Y and (A.H+1));
end;

procedure T6502.__SLO;
var A, T: PartsRec;
		V: Byte;
begin
	//ASL mem
	A.W := Get2ndAddress(Command, Cycles);
	V := ReadMem(A.W);
	T.W := Word(V) shl 1;
	CalcFlags(T.W, F_N+F_Z+F_C);
	WriteMem(A.W, T.L);

	//ORA
	FContext.A := FContext.A or V;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502.__SRE;
var A, T: PartsRec;
		V: Byte;
begin
	//LSR mem
	A.W := Get2ndAddress(Command, Cycles);
	V := ReadMem(A.W);
	SetFlag(F_C, V);
	T.L := V shr 1;
	CalcFlags(T.L, F_N+F_Z);
	WriteMem(A.W, T.L);

	//XOR
	FContext.A := FContext.A xor V;
	CalcFlags(FContext.A, F_N+F_Z);
end;

procedure T6502.__NOP;
begin
	Get2ndOperand(Command, Cycles);
end;

procedure T6502.__KILL;
begin
	FIM.DM.Error(Self, 'Некорректная команда, вызывающая зависание');
end;

begin
	RegisterDeviceCreateFunc('6502', @Create6502);
end.
