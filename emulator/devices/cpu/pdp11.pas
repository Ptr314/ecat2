unit pdp11;
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
		Adapted from <http://code.google.com/p/ukncbtl/>

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
	TPDP11Context = packed record
    Model: Cardinal;
    m_internalTick: Word;     // How many ticks waiting to the end of current instruction
    m_psw: Word;              // Processor Status Word (PSW)
    m_R: array [0..7] of Word;             // Registers (R0..R5, R6=SP, R7=PC)
    m_okStopped: Boolean;        // "Processor stopped" flag
    m_savepc: Word;           // CPC register
    m_savepsw: Word;          // CPSW register
    m_stepmode: Boolean;         // Read TRUE if it's step mode
	  m_buserror: Boolean;			// Read TRUE if occured bus error for implementing double bus error if needed
	  m_haltpin: Boolean;			// HALT pin
		m_DCLOpin: Boolean;			// DCLO pin
		m_ACLOpin: Boolean;			// ACLO pin
    m_waitmode: Boolean;			// WAIT
	end;
  
	TPDP11command = procedure of Object;

	TPDP11 = class (TCPU)
	private
	  procedure SetHALTPin(value:Boolean);
	  procedure SetDCLOPin(value:Boolean);
	  procedure SetACLOPin(value:Boolean);
	  procedure MemoryError();
	  procedure SetInternalTick (tick:Word);
		procedure InitCommands;
		procedure RegisterMethodRef(a_start, a_end:Word; methodref:TPDP11command);
    function ReadMem(Address:Word):Byte;
    function ReadWord(Address:Word):Word;
    procedure WriteMem(Address:Word; Value:Byte);
    procedure WriteWord(Address:Word; Value:Word);
    procedure FetchInstruction();
    procedure TranslateInstruction();

    function CheckForNegative(byte_val:Byte):Boolean; overload;
    function CheckForNegative(word_val:Word):Boolean; overload;
    function CheckForZero(byte_val:Byte):Boolean; overload;
    function CheckForZero(word_val:Word):Boolean; overload;
    function CheckAddForOverflow(a, b: Byte):Boolean; overload;
    function CheckAddForOverflow(a, b: Word):Boolean; overload;
    function CheckSubForOverflow(a, b: Byte):Boolean; overload;
    function CheckSubForOverflow(a, b: Word):Boolean; overload;
    function CheckAddForCarry(a, b: Byte):Boolean; overload;
    function CheckAddForCarry(a, b: Word):Boolean; overload;
    function CheckSubForCarry(a, b: Byte):Boolean; overload;
    function CheckSubForCarry(a, b: Word):Boolean; overload;

	  function GetWordAddr (meth, reg: Byte): Word;
	  function GetByteAddr (meth, reg: Byte): Word;

  protected

    // Current instruction processing
    m_instruction: Word;        // Curent instruction
    m_regsrc: Integer;          // Source register number
    m_methsrc: Integer;         // Source address mode
    m_addrsrc: Word;            // Source address
    m_regdest: Integer;         // Destination register number
    m_methdest: Integer;        // Destination address mode
    m_addrdest: Word;           // Destination address

    // Interrupt processing
    m_STRTrq:Boolean;			      // Start interrupt pending
	  m_RPLYrq:Boolean;           // Hangup interrupt pending
	  m_ILLGrq:Boolean;			      // Illegal instruction interrupt pending
	  m_RSVDrq:Boolean;           // Reserved instruction interrupt pending
    m_TBITrq:Boolean;           // T-bit interrupt pending
	  m_ACLOrq:Boolean;           // Power down interrupt pending
    m_HALTrq:Boolean;           // HALT command or HALT signal
	  m_EVNTrq:Boolean;           // Timer event interrupt pending
    m_FIS_rq:Boolean;           // FIS command interrupt pending
    m_BPT_rq:Boolean;           // BPT command interrupt pending
    m_IOT_rq:Boolean;           // IOT command interrupt pending
    m_EMT_rq:Boolean;           // EMT command interrupt pending
    m_TRAPrq:Boolean;           // TRAP command interrupt pending
    m_virq: array [0..15] of Word;         // VIRQ vector
	  m_ACLOreset:Boolean;		    // Power fail interrupt request reset
	  m_EVNTreset:Boolean;		    // EVNT interrupt request reset;
	  m_VIRQreset:Integer;		    // VIRQ request reset for given device

    m_pExecuteMethodMap: array [0..65536] of TPDP11command;

		function GetPC:Cardinal; override;

    procedure ExecuteUNKNOWN ();  // Нет такой инструкции - просто вызывается TRAP 10
    procedure ExecuteHALT ();
    procedure ExecuteWAIT ();
  	procedure ExecuteRCPC	();
  	procedure ExecuteRCPS ();
  	procedure ExecuteWCPC	();
  	procedure ExecuteWCPS	();
  	procedure ExecuteMFUS ();
  	procedure ExecuteMTUS ();
    procedure ExecuteRTI ();
    procedure ExecuteBPT ();
    procedure ExecuteIOT ();
    procedure ExecuteRESET ();
  	procedure ExecuteSTEP	();
    procedure ExecuteRSEL ();
    procedure Execute000030 ();
    procedure ExecuteFIS ();
  	procedure ExecuteRUN	();
    procedure ExecuteRTT ();
    procedure ExecuteCCC ();
    procedure ExecuteSCC ();

    // One fiels
    procedure ExecuteRTS ();

    // Two fields
    procedure ExecuteJMP ();
    procedure ExecuteSWAB ();
    procedure ExecuteCLR ();
    procedure ExecuteCOM ();
    procedure ExecuteINC ();
    procedure ExecuteDEC ();
    procedure ExecuteNEG ();
    procedure ExecuteADC ();
    procedure ExecuteSBC ();
    procedure ExecuteTST ();
    procedure ExecuteROR ();
    procedure ExecuteROL ();
    procedure ExecuteASR ();
    procedure ExecuteASL ();
    procedure ExecuteMARK ();
    procedure ExecuteSXT ();
    procedure ExecuteMTPS ();
    procedure ExecuteMFPS ();

    // Branchs & interrupts
    procedure ExecuteBR ();
    procedure ExecuteBNE ();
    procedure ExecuteBEQ ();
    procedure ExecuteBGE ();
    procedure ExecuteBLT ();
    procedure ExecuteBGT ();
    procedure ExecuteBLE ();
    procedure ExecuteBPL ();
    procedure ExecuteBMI ();
    procedure ExecuteBHI ();
    procedure ExecuteBLOS ();
    procedure ExecuteBVC ();
    procedure ExecuteBVS ();
    procedure ExecuteBHIS ();
    procedure ExecuteBLO ();

    procedure ExecuteEMT ();
    procedure ExecuteTRAP ();

    // Three fields
    procedure ExecuteJSR ();
    procedure ExecuteXOR ();
    procedure ExecuteSOB ();
  	procedure ExecuteMUL ();
  	procedure ExecuteDIV ();
  	procedure ExecuteASH ();
  	procedure ExecuteASHC ();

    // Four fields
    procedure ExecuteMOV ();
    procedure ExecuteCMP ();
    procedure ExecuteBIT ();
    procedure ExecuteBIC ();
    procedure ExecuteBIS ();

    procedure ExecuteADD ();
    procedure ExecuteSUB ();

  public
    FContext: TPDP11Context;
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		function Execute:Cardinal; override;
    function GetPSW(): Word;
    function GetCPSW(): Word;
    function GetLPSW(): Byte;
    procedure SetPSW(word_val:Word);
    procedure SetCPSW(word_val:Word);
    procedure SetLPSW(byte_val:Byte);
    function GetReg(regno:Integer):Word;
    procedure SetReg(regno:Integer; word_val:Word);
    function GetLReg(regno:Integer):Byte;
    procedure SetLReg(regno:Integer; byte_val: Byte);
    function GetSP(): Word;
    procedure SetSP(word_val:Word);
    function GetCPC():Word;
    procedure SetPC(word_val:Word);
    procedure SetCPC(word_val:Word);

    procedure SetC(bFlag:Boolean);
    function GetC():Boolean;
    procedure SetV(bFlag:Boolean);
    function GetV():Boolean;
    procedure SetN(bFlag:Boolean);
    function GetN():Boolean;
    procedure SetZ(bFlag:Boolean);
    function GetZ():Boolean;
	  procedure SetHALT(bFlag:Boolean);
	  function GetHALT():Boolean;

    function IsStopped():Boolean;
    function IsHaltMode():Boolean;

    procedure TickEVNT();
    procedure InterruptVIRQ(que:Integer; interrupt:Word);

    function GetVIRQ(que:Integer): Word;
    function InterruptProcessing():Boolean;
  end;

const
  PDP11_VM1 = 0;
  PDP11_VM2 = 1;

  // Process Status Word (PSW) bits
  PSW_C = $001;     // Carry
  PSW_V = $002;     // Arithmetic overflow
  PSW_Z = $004;     // Zero result
  PSW_N = $008;     // Negative result
  PSW_T = $010;     // Trap/Debug
  PSW_P = $080;     // 0200 Priority
  PSW_HALT = $100;  // 0400 Halt

// Timings ///////////////////////////////////////////////////////////

//MOV -- 64
  MOV_TIMING: Array[0..7, 0..7] of Word =
(
		($000C, $0021, $0027, $0033, $002B, $0037, $0033, $0043),
		($0018, $0031, $0037, $0043, $003B, $0047, $0043, $0054),
		($0019, $0037, $0037, $0043, $003B, $0047, $0043, $0053),
		($0025, $0043, $0043, $004F, $0047, $0054, $004F, $0060),
		($0019, $0037, $0037, $0043, $003B, $0047, $0043, $0053),
		($0025, $0043, $0043, $004F, $0047, $0054, $004F, $0060),
		($0029, $0039, $003F, $004C, $003F, $004C, $004B, $005C),
		($0035, $0045, $004C, $0057, $004C, $0057, $0057, $0068)
);

  MOVB_TIMING: Array[0..7, 0..7] of Word =
(
		($000C, $0025, $002B, $0037, $002F, $003B, $003B, $0047),
		($0018, $0035, $003B, $0047, $003F, $004C, $004B, $0057),
		($0019, $003B, $003B, $0047, $0040, $004B, $004C, $0057),
		($0025, $0047, $0047, $0054, $004B, $0057, $0057, $0063),
		($0019, $003B, $003B, $0047, $0040, $004B, $004C, $0057),
		($0025, $0047, $0047, $0054, $004B, $0057, $0057, $0063),
		($0029, $003D, $0043, $004F, $0043, $004F, $0054, $005F),
		($0035, $0049, $004F, $005B, $004F, $005B, $005F, $006C)
);

  CMP_TIMING: Array[0..7, 0..7] of Word =
(

		($000C, $001C, $001D, $0029, $0021, $002D, $0035, $0041),
		($0018, $002D, $002D, $0039, $0031, $003D, $0045, $0051),
		($0019, $002D, $002D, $0039, $0031, $003D, $0045, $0051),
		($0025, $0039, $0039, $0045, $003D, $0049, $0051, $005E),
		($0019, $002D, $002D, $0039, $0031, $003D, $0045, $0051),
		($0025, $0039, $0039, $0045, $003D, $0049, $0051, $005E),
		($0029, $0035, $0035, $0041, $0035, $0041, $004D, $005A),
		($0035, $0041, $0041, $004E, $0041, $004E, $005A, $0065)
);

  CLR_TIMING: Array[0..7] of Word =
(
		$000C, $001C, $0023, $002F, $0023, $002F, $002F, $003F
);

  CRLB_TIMING: Array[0..7] of Word =
(
		$000C, $0021, $0027, $0033, $0027, $0033, $0037, $0043
);

  TST_TIMING: Array[0..7] of Word =
(
		$000C, $0018, $0019, $0025, $0019, $0025, $0031, $003D
);

  MTPS_TIMING: Array[0..7] of Word =
(
		$0018, $0029, $0029, $0035, $0029, $0035, $0041, $004D
);

  XOR_TIMING: Array[0..7] of Word =
(
		$000C, $0025, $002B, $0037, $002F, $003B, $003B, $0047
);

  ASH_TIMING: Array[0..7] of Word =
(
		$0029,	$003D, $003D, $0049, $0041, $004D, $0055, $0062
);
  ASH_S_TIMING=$0008;

  ASHC_TIMING: Array[0..7] of Word =
(
		$0039, $004E, $004D, $005A, $0051, $005D, $0066,	$0072
);
  ASHC_S_TIMING=$0008;

  MUL_TIMING: Array[0..7] of Word =
(
		$00B3, $00C7, $00C7, $00D4, $00CA, $00D8, $00E1, $00EC
);

  DIV_TIMING: Array[0..7] of Word =
(
		$00D3, $00E8, $00E7, $00F4, $00EB, $00F8,	$0100,	$010D 
);

  JMP_TIMING: Array[0..6] of Word =
(

		$002D, $002D, $003D, $002D, $003D, $0031,	$0041
);
  JSR_TIMING: Array[0..6] of Word =
(
		$0045, $0045, $0056, $0045, $0056, $0049, $0059
);


  BRANCH_TRUE_TIMING = $0025;
  BRANCH_FALSE_TIMING = $0010;
  BPT_TIMING = $0094;
  EMT_TIMING = $009C;
  RTI_TIMING = $0059;
  RTS_TIMING = $0031;
  NOP_TIMING = $0010;
  SOB_TIMING = $002D;
  SOB_LAST_TIMING = $0019; //last iteration of SOB
  BR_TIMING = $0025;
  MARK_TIMING = $0041;
  RESET_TIMING = $0433;

  n_0777 = $1FF;
  n_0600 = $180;
  n_0170 = $78;
  n_014 = $0C;
  n_020 = $10;
  n_030 = $18;
  n_034 = $1C;
  n_010 = $08;
  n_0174 = $7C;
  n_004 = $04;
  n_024 = $14;
  n_0200 = $80;
  n_0100 = $40;

implementation

function CreatePDP11(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TPDP11.Create(IM, ConfigDevice);
end;

constructor TPDP11.Create;
begin
	inherited Create(IM, ConfigDevice);

  FContext.Model := PDP11_VM2;

	FIAddress := CreateInterface(16, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_RW);

	InitCommands;

	//DebugMode :=DEBUG_STOPPED;
end;

procedure TPDP11.InitCommands;
begin
	//// Использем восьмеричные представления, чтобы не запутаться
	//// Данная процедура выполняется один раз, поэтому быстродействие не важно
	
	// Сначала заполняем таблицу ссылками на метод ExecuteUNKNOWN, выполняющий TRAP 10
	RegisterMethodRef( OctToInt('0000000'), OctToInt('0177777'), ExecuteUNKNOWN );

	RegisterMethodRef( OctToInt('0000000'), OctToInt('0000000'), ExecuteHALT );
	RegisterMethodRef( OctToInt('0000001'), OctToInt('0000001'), ExecuteWAIT );
	RegisterMethodRef( OctToInt('0000002'), OctToInt('0000002'), ExecuteRTI );
	RegisterMethodRef( OctToInt('0000003'), OctToInt('0000003'), ExecuteBPT );
	RegisterMethodRef( OctToInt('0000004'), OctToInt('0000004'), ExecuteIOT );
	RegisterMethodRef( OctToInt('0000005'), OctToInt('0000005'), ExecuteRESET );
	RegisterMethodRef( OctToInt('0000006'), OctToInt('0000006'), ExecuteRTT );

	RegisterMethodRef( OctToInt('0000010'), OctToInt('0000013'), ExecuteRUN );
	RegisterMethodRef( OctToInt('0000014'), OctToInt('0000017'), ExecuteSTEP );
	RegisterMethodRef( OctToInt('0000020'), OctToInt('0000020'), ExecuteRSEL );
	RegisterMethodRef( OctToInt('0000021'), OctToInt('0000021'), ExecuteMFUS );
	RegisterMethodRef( OctToInt('0000022'), OctToInt('0000023'), ExecuteRCPC );
	RegisterMethodRef( OctToInt('0000024'), OctToInt('0000027'), ExecuteRCPS );
	RegisterMethodRef( OctToInt('0000030'), OctToInt('0000030'), Execute000030 );
	RegisterMethodRef( OctToInt('0000031'), OctToInt('0000031'), ExecuteMTUS );
	RegisterMethodRef( OctToInt('0000032'), OctToInt('0000033'), ExecuteWCPC );
	RegisterMethodRef( OctToInt('0000034'), OctToInt('0000037'), ExecuteWCPS );

	RegisterMethodRef( OctToInt('0000100'), OctToInt('0000177'), ExecuteJMP );
	RegisterMethodRef( OctToInt('0000200'), OctToInt('0000207'), ExecuteRTS );  // RTS / RETURN

	RegisterMethodRef( OctToInt('0000240'), OctToInt('0000257'), ExecuteCCC );

	RegisterMethodRef( OctToInt('0000260'), OctToInt('0000277'), ExecuteSCC );

	RegisterMethodRef( OctToInt('0000300'), OctToInt('0000377'), ExecuteSWAB );

	RegisterMethodRef( OctToInt('0000400'), OctToInt('0000777'), ExecuteBR );
	RegisterMethodRef( OctToInt('0001000'), OctToInt('0001377'), ExecuteBNE );
	RegisterMethodRef( OctToInt('0001400'), OctToInt('0001777'), ExecuteBEQ );
	RegisterMethodRef( OctToInt('0002000'), OctToInt('0002377'), ExecuteBGE );
	RegisterMethodRef( OctToInt('0002400'), OctToInt('0002777'), ExecuteBLT );
	RegisterMethodRef( OctToInt('0003000'), OctToInt('0003377'), ExecuteBGT );
	RegisterMethodRef( OctToInt('0003400'), OctToInt('0003777'), ExecuteBLE );
	
	RegisterMethodRef( OctToInt('0004000'), OctToInt('0004777'), ExecuteJSR );  // JSR / CALL

	RegisterMethodRef( OctToInt('0005000'), OctToInt('0005077'), ExecuteCLR );
	RegisterMethodRef( OctToInt('0005100'), OctToInt('0005177'), ExecuteCOM );
	RegisterMethodRef( OctToInt('0005200'), OctToInt('0005277'), ExecuteINC );
	RegisterMethodRef( OctToInt('0005300'), OctToInt('0005377'), ExecuteDEC );
	RegisterMethodRef( OctToInt('0005400'), OctToInt('0005477'), ExecuteNEG );
	RegisterMethodRef( OctToInt('0005500'), OctToInt('0005577'), ExecuteADC );
	RegisterMethodRef( OctToInt('0005600'), OctToInt('0005677'), ExecuteSBC );
	RegisterMethodRef( OctToInt('0005700'), OctToInt('0005777'), ExecuteTST );
	RegisterMethodRef( OctToInt('0006000'), OctToInt('0006077'), ExecuteROR );
	RegisterMethodRef( OctToInt('0006100'), OctToInt('0006177'), ExecuteROL );
	RegisterMethodRef( OctToInt('0006200'), OctToInt('0006277'), ExecuteASR );
	RegisterMethodRef( OctToInt('0006300'), OctToInt('0006377'), ExecuteASL );
	
	RegisterMethodRef( OctToInt('0006400'), OctToInt('0006477'), ExecuteMARK );
	RegisterMethodRef( OctToInt('0006700'), OctToInt('0006777'), ExecuteSXT );

	RegisterMethodRef( OctToInt('0010000'), OctToInt('0017777'), ExecuteMOV );
	RegisterMethodRef( OctToInt('0020000'), OctToInt('0027777'), ExecuteCMP );
	RegisterMethodRef( OctToInt('0030000'), OctToInt('0037777'), ExecuteBIT );
	RegisterMethodRef( OctToInt('0040000'), OctToInt('0047777'), ExecuteBIC );
	RegisterMethodRef( OctToInt('0050000'), OctToInt('0057777'), ExecuteBIS );
	RegisterMethodRef( OctToInt('0060000'), OctToInt('0067777'), ExecuteADD );
	
	RegisterMethodRef( OctToInt('0070000'), OctToInt('0070777'), ExecuteMUL );
	RegisterMethodRef( OctToInt('0071000'), OctToInt('0071777'), ExecuteDIV );
	RegisterMethodRef( OctToInt('0072000'), OctToInt('0072777'), ExecuteASH );
	RegisterMethodRef( OctToInt('0073000'), OctToInt('0073777'), ExecuteASHC );
	RegisterMethodRef( OctToInt('0074000'), OctToInt('0074777'), ExecuteXOR );
	RegisterMethodRef( OctToInt('0075000'), OctToInt('0075037'), ExecuteFIS );
	RegisterMethodRef( OctToInt('0077000'), OctToInt('0077777'), ExecuteSOB );

	RegisterMethodRef( OctToInt('0100000'), OctToInt('0100377'), ExecuteBPL );
	RegisterMethodRef( OctToInt('0100400'), OctToInt('0100777'), ExecuteBMI );
	RegisterMethodRef( OctToInt('0101000'), OctToInt('0101377'), ExecuteBHI );
	RegisterMethodRef( OctToInt('0101400'), OctToInt('0101777'), ExecuteBLOS );
	RegisterMethodRef( OctToInt('0102000'), OctToInt('0102377'), ExecuteBVC );
	RegisterMethodRef( OctToInt('0102400'), OctToInt('0102777'), ExecuteBVS );
	RegisterMethodRef( OctToInt('0103000'), OctToInt('0103377'), ExecuteBHIS );  // BCC
	RegisterMethodRef( OctToInt('0103400'), OctToInt('0103777'), ExecuteBLO );   // BCS
	
	RegisterMethodRef( OctToInt('0104000'), OctToInt('0104377'), ExecuteEMT );
	RegisterMethodRef( OctToInt('0104400'), OctToInt('0104777'), ExecuteTRAP );
	
	RegisterMethodRef( OctToInt('0105000'), OctToInt('0105077'), ExecuteCLR );  // CLRB
	RegisterMethodRef( OctToInt('0105100'), OctToInt('0105177'), ExecuteCOM );  // COMB
	RegisterMethodRef( OctToInt('0105200'), OctToInt('0105277'), ExecuteINC );  // INCB
	RegisterMethodRef( OctToInt('0105300'), OctToInt('0105377'), ExecuteDEC );  // DECB
	RegisterMethodRef( OctToInt('0105400'), OctToInt('0105477'), ExecuteNEG );  // NEGB
	RegisterMethodRef( OctToInt('0105500'), OctToInt('0105577'), ExecuteADC );  // ADCB
	RegisterMethodRef( OctToInt('0105600'), OctToInt('0105677'), ExecuteSBC );  // SBCB
	RegisterMethodRef( OctToInt('0105700'), OctToInt('0105777'), ExecuteTST );  // TSTB
	RegisterMethodRef( OctToInt('0106000'), OctToInt('0106077'), ExecuteROR );  // RORB
	RegisterMethodRef( OctToInt('0106100'), OctToInt('0106177'), ExecuteROL );  // ROLB
	RegisterMethodRef( OctToInt('0106200'), OctToInt('0106277'), ExecuteASR );  // ASRB
	RegisterMethodRef( OctToInt('0106300'), OctToInt('0106377'), ExecuteASL );  // ASLB
	
	RegisterMethodRef( OctToInt('0106400'), OctToInt('0106477'), ExecuteMTPS );
	RegisterMethodRef( OctToInt('0106700'), OctToInt('0106777'), ExecuteMFPS );

	RegisterMethodRef( OctToInt('0110000'), OctToInt('0117777'), ExecuteMOV );  // MOVB
	RegisterMethodRef( OctToInt('0120000'), OctToInt('0127777'), ExecuteCMP );  // CMPB
	RegisterMethodRef( OctToInt('0130000'), OctToInt('0137777'), ExecuteBIT );  // BITB
	RegisterMethodRef( OctToInt('0140000'), OctToInt('0147777'), ExecuteBIC );  // BICB
	RegisterMethodRef( OctToInt('0150000'), OctToInt('0157777'), ExecuteBIS );  // BISB
	RegisterMethodRef( OctToInt('0160000'), OctToInt('0167777'), ExecuteSUB );
end;

function TPDP11.GetPC;
begin
	Result := FContext.m_R[7];
end;

procedure TPDP11.SetInternalTick (tick:Word);
begin
  FContext.m_internalTick := tick;
end;

function TPDP11.GetPSW(): Word;
begin
  Result := Fcontext.m_psw;
end;

function TPDP11.GetCPSW(): Word;
begin
  Result := FContext.m_savepsw;
end;

function TPDP11.GetLPSW(): Byte;
begin
  Result := Byte(Fcontext.m_psw and $FF);
end;

procedure TPDP11.SetPSW(word_val:Word);
begin
  FContext.m_psw := word_val and n_0777;
	if ((FContext.m_psw and n_0600) <> n_0600) then FContext.m_savepsw := FContext.m_psw;
end;

procedure TPDP11.SetCPSW(word_val:Word);
begin
  FContext.m_savepsw := word_val;
end;

procedure TPDP11.SetHALTPin(value:Boolean);
begin
  FContext.m_haltpin := value;
end;

procedure TPDP11.SetDCLOPin(value:Boolean);
begin
	with FContext do begin
    m_DCLOpin := value;
    if (m_DCLOpin) then begin
      m_okStopped := TRUE;

      m_stepmode := FALSE;
      m_buserror := FALSE;
      m_waitmode := FALSE;
      m_internalTick := 0;
      m_RPLYrq := FALSE; m_RSVDrq := FALSE; m_TBITrq := FALSE;
      m_ACLOrq := FALSE; m_HALTrq := FALSE; m_EVNTrq := FALSE; 
      m_ILLGrq := FALSE; m_FIS_rq := FALSE; m_BPT_rq  := FALSE;
      m_IOT_rq := FALSE; m_EMT_rq := FALSE; m_TRAPrq  := FALSE;
      FillChar(m_virq, sizeof(m_virq), 0);
      m_ACLOreset := FALSE; m_EVNTreset := FALSE;
      m_VIRQreset := 0;
      //m_pMemoryController->DCLO_Signal();
      //m_pMemoryController->ResetDevices();
      FIM.DM.Error(Self, 'DLCO signal isn''t supported yet');
    end;
  end;
end;

procedure TPDP11.SetACLOPin(value:Boolean);
begin
	with FContext do begin
    if (m_okStopped and not m_DCLOpin and m_ACLOpin and not value) then begin
      m_okStopped := FALSE;
      m_internalTick := 0;

      m_stepmode := FALSE;
      m_waitmode := FALSE;
      m_buserror := FALSE;
      m_RPLYrq := FALSE; m_RSVDrq := FALSE; m_TBITrq := FALSE;
      m_ACLOrq := FALSE; m_HALTrq := FALSE; m_EVNTrq := FALSE;
      m_ILLGrq := FALSE; m_FIS_rq := FALSE; m_BPT_rq := FALSE;
      m_IOT_rq := FALSE; m_EMT_rq := FALSE; m_TRAPrq := FALSE;
      FillChar(m_virq, sizeof(m_virq), 0);
      m_ACLOreset := FALSE; m_EVNTreset := FALSE;
      m_VIRQreset := 0;

      // "Turn On" interrupt processing
      m_STRTrq := TRUE;
    end;
    if (not m_okStopped and not m_DCLOpin and not m_ACLOpin and value) then begin
      m_ACLOrq := TRUE;
    end;
    m_ACLOpin := value;
  end;
end;

procedure TPDP11.MemoryError();
begin
  m_RPLYrq := TRUE;
end;

function TPDP11.Execute;
begin
  if (not FContext.m_waitmode) then begin
		FetchInstruction();  // Read next instruction from memory
		if (not m_RPLYrq) then begin
			FContext.m_buserror := FALSE;
			TranslateInstruction();  // Execute next instruction
		end;
	end;

	if (m_HALTrq or m_BPT_rq or m_IOT_rq or m_EMT_rq or m_TRAPrq or m_FIS_rq)
		then InterruptProcessing;

  Result := 1;
end;

procedure TPDP11.RegisterMethodRef(a_start, a_end:Word; methodref:TPDP11command);
var opcode:Integer;
begin
  for opcode := a_start to a_end do 
		m_pExecuteMethodMap[opcode] := methodref;
end;

procedure TPDP11.SetLPSW(byte_val:Byte);
begin
  with FContext do begin
    m_psw := (m_psw and $FF00) or Word(byte_val);
		if ((m_psw and n_0600) <> n_0600) then m_savepsw := m_psw;
  end;
end;

function TPDP11.GetReg(regno:Integer):Word;
begin
  Result := FContext.m_R[regno];
end;

procedure TPDP11.SetReg(regno:Integer; word_val:Word);
begin
  with FContext do begin
    m_R[regno] := word_val;
		if ((regno = 7) and ((m_psw and n_0600) <> n_0600))	then m_savepc := word_val;
  end;
end;

function TPDP11.GetLReg(regno:Integer):Byte;
begin
  Result := Byte(FContext.m_R[regno] and $FF);
end;

procedure TPDP11.SetLReg(regno:Integer; byte_val: Byte);
begin
  with FContext do begin
    m_R[regno] := (m_R[regno] and $FF00) or Word(byte_val);
		if ((regno = 7) and ((m_psw and n_0600)<>n_0600))	then m_savepc := m_R[7];
  end;
end;

function TPDP11.GetSP(): Word;
begin
  Result := FContext.m_R[6];
end;

procedure TPDP11.SetSP(word_val:Word);
begin
  FContext.m_R[6] := word_val;
end;

function TPDP11.GetCPC():Word;
begin
  Result := FContext.m_savepc;
end;

procedure TPDP11.SetPC(word_val:Word);
begin
  with FContext do begin
    m_R[7] := word_val;
		if ((m_psw and n_0600) <> n_0600) then m_savepc := word_val;
  end;
end;

procedure TPDP11.SetCPC(word_val:Word);
begin
  FContext.m_savepc := word_val;
end;

procedure TPDP11.SetC(bFlag:Boolean);
begin
  with FContext do begin
    if (bFlag) then m_psw := m_psw or PSW_C else m_psw := m_psw and not PSW_C;
	  if ((m_psw and n_0600) <> n_0600) then m_savepsw := m_psw;
  end;
end;

function TPDP11.GetC():Boolean;
begin
  Result := (FContext.m_psw and PSW_C) <> 0;
end;

procedure TPDP11.SetV(bFlag:Boolean);
begin
  with FContext do begin
    if (bFlag) then m_psw := m_psw or PSW_V else m_psw := m_psw and not PSW_V;
	  if ((m_psw and n_0600) <> n_0600) then m_savepsw := m_psw;
  end;
end;

function TPDP11.GetV():Boolean;
begin
  Result := (FContext.m_psw and PSW_V) <> 0;
end;

procedure TPDP11.SetN(bFlag:Boolean);
begin
  with FContext do begin
    if (bFlag) then m_psw := m_psw or PSW_N else m_psw := m_psw and not PSW_N;
	  if ((m_psw and n_0600) <> n_0600) then m_savepsw := m_psw;
  end;
end;

function TPDP11.GetN():Boolean;
begin
  Result := (FContext.m_psw and PSW_N) <> 0;
end;

procedure TPDP11.SetZ(bFlag:Boolean);
begin
  with FContext do begin
    if (bFlag) then m_psw := m_psw or PSW_Z else m_psw := m_psw and not PSW_Z;
	  if ((m_psw and n_0600) <> n_0600) then m_savepsw := m_psw;
  end;
end;

function TPDP11.GetZ():Boolean;
begin
  Result := (FContext.m_psw and PSW_Z) <> 0;
end;

procedure TPDP11.SetHALT(bFlag:Boolean);
begin
  with FContext do begin
    if (bFlag) then m_psw := m_psw or PSW_HALT else m_psw := m_psw and not PSW_HALT;
  end;
end;

function TPDP11.GetHALT():Boolean;
begin
  Result := (FContext.m_psw and PSW_HALT) <> 0;
end;

function TPDP11.IsStopped():Boolean;
begin
  Result := FContext.m_okStopped;
end;

function TPDP11.IsHaltMode():Boolean;
begin
  Result := (FContext.m_psw and PSW_HALT) <> 0;
end;

procedure TPDP11.TickEVNT();
begin
  with FContext do begin
    if (not m_okStopped) then m_EVNTrq := TRUE;
  end;
end;

procedure TPDP11.InterruptVIRQ(que:Integer; interrupt:Word);
begin
  with FContext do begin
    if (not m_okStopped) then m_virq[que] := interrupt;
  end;
end;

function TPDP11.GetVIRQ(que:Integer): Word;
begin
  Result := m_virq[que];
end;

function TPDP11.ReadMem(Address:Word):Byte;
begin
	//FIAddress.Change(Address);
	Result := Byte(Mapper.Read(Address));
	//FIAddress.Disconnect;
end;

function TPDP11.ReadWord(Address:Word):Word;
begin
  Result := Word(ReadMem(Address)) + (Word(ReadMem(Address+1)) shl 8);
end;


procedure TPDP11.WriteMem(Address:Word; Value:Byte);
begin
	//FIAddress.Change(Address);
	Mapper.Write(Address, Value);
	//FIAddress.Disconnect;
end;

procedure TPDP11.WriteWord(Address:Word; Value:Word);
begin
  WriteMem(Address, Byte(Value and $FF));
  WriteMem(Address+1, Byte(Value shr 8));
end;

function TPDP11.InterruptProcessing():Boolean;
var intrVector, selVector, new_pc,new_psw: Word;
    currMode: Boolean; // Current processor mode: TRUE = HALT mode, FALSE = USER mode
    intrMode: Boolean; // TRUE = HALT mode interrupt, FALSE = USER mode interrupt
    irq: Integer;
begin
  with FContext do begin
    intrVector := $FFFF;
    intrMode := FALSE;
    currMode := ((m_psw and PSW_HALT) <> 0);

    if (m_stepmode) then begin
      m_stepmode := FALSE;
    end else begin
       m_ACLOreset := FALSE;
       m_EVNTreset := FALSE;
       m_VIRQreset := 0;
       m_TBITrq := (m_psw and PSW_T) <> 0;  // T-bit

      if (m_STRTrq) then begin
        intrVector := 0; intrMode := TRUE;
        m_STRTrq := FALSE;
      end
      else if (m_HALTrq) then begin // HALT command
        intrVector := n_0170;  intrMode := TRUE;
        m_HALTrq := FALSE;
      end
      else if (m_BPT_rq) then begin // BPT command
        intrVector := n_014;  intrMode := FALSE;
        m_BPT_rq := FALSE;
      end
      else if (m_IOT_rq)  then begin // IOT command
        intrVector := n_020;  intrMode := FALSE;
        m_IOT_rq := FALSE;
      end
      else if (m_EMT_rq) then begin // EMT command
        intrVector := n_030;  intrMode := FALSE;
        m_EMT_rq := FALSE;
      end
      else if (m_TRAPrq) then begin // TRAP command
        intrVector := n_034;  intrMode := FALSE;
        m_TRAPrq := FALSE;
      end
      else if (m_FIS_rq) then begin // FIS commands -- Floating point Instruction Set
        intrVector := n_010;  intrMode := TRUE;
        m_FIS_rq := FALSE;
      end
      else if (m_RPLYrq) then begin // Зависание, priority 1
        if (m_buserror) then begin
          intrVector := n_0174; intrMode := TRUE;
        end
        else if (currMode) then begin
          intrVector := n_004;  intrMode := TRUE;
        end else begin
          intrVector := n_004; intrMode := FALSE;
        end;
        m_buserror := TRUE;
        m_RPLYrq := FALSE;
      end
      else if (m_ILLGrq) then begin
        intrVector := n_004;  intrMode := FALSE;
        m_ILLGrq := FALSE;
      end
      else if (m_RSVDrq) then begin // Reserved command, priority 2
        intrVector := n_010;  intrMode := FALSE;
        m_RSVDrq := FALSE;
      end
      else if (m_TBITrq and (not m_waitmode)) then begin// T-bit, priority 3
        intrVector := n_014;  intrMode := FALSE;
        m_TBITrq := FALSE;
      end
      else if (m_ACLOrq and ((m_psw and n_0600) <> n_0600))  then begin// ACLO, priority 4
        intrVector := n_024;  intrMode := FALSE;
        m_ACLOreset := TRUE;
      end
      else if (m_haltpin and ((m_psw and PSW_HALT) <> PSW_HALT)) then begin// HALT signal in USER mode, priority 5
        intrVector := n_0170;  intrMode := TRUE;
      end
      else if (m_EVNTrq and ((m_psw and n_0200) <> n_0200)) then begin // EVNT signal, priority 6
        intrVector := n_0100;  intrMode := FALSE;
        m_EVNTreset := TRUE;
      end
      else if ((m_psw and n_0200) <> n_0200) then begin // VIRQ, priority 7
        intrMode := FALSE;
        for irq := 1 to 15 do begin
          if (m_virq[irq] <> 0) then begin
            intrVector := m_virq[irq];
            m_VIRQreset := irq;
            break;
          end;
        end;
      end;
      if (intrVector <> $FFFF) then begin
        if (m_internalTick = 0) then m_internalTick := EMT_TIMING;  //ANYTHING UNKNOWN WILL CAUSE EXCEPTION (EMT)

        m_waitmode := FALSE;

        if (intrMode)  then begin // HALT mode interrupt
          selVector:= 0; //selVector := GetMemoryController()->GetSelRegister() & 0x0ff00;
          FIM.DM.Error(Self, 'interrupt in HALT mode');

          intrVector := intrVector or selVector;
          SetHALT(TRUE);
          new_pc := ReadWord(intrVector);
          new_psw := ReadWord(intrVector + 2);
          if (not m_RPLYrq) then begin
            SetPSW(new_psw);
            SetPC(new_pc);
          end;
        end
        else begin // USER mode interrupt
          SetHALT(FALSE);
          // Save PC/PSW to stack
          SetSP(GetSP() - 2);
          WriteWord(GetSP(), GetCPSW());
          SetSP(GetSP() - 2);
          if (not m_RPLYrq) then begin
            WriteWord(GetSP(), GetCPC());
            if (not m_RPLYrq) then begin
              if (m_ACLOreset) then m_ACLOrq := FALSE;
              if (m_EVNTreset) then m_EVNTrq := FALSE;
              if (m_VIRQreset <> 0) then m_virq[m_VIRQreset] := 0;
              new_pc := ReadWord(intrVector);
              new_psw := ReadWord(intrVector + 2);
              if ( not m_RPLYrq) then begin
                SetLPSW(new_psw and $FF);
                SetPC(new_pc);
              end;
            end;
          end;
        end;

        Result := TRUE; Exit;
      end;
    end;
    Result := FALSE;
  end;
end;

procedure TPDP11.FetchInstruction();
var pc: Word;
begin
  pc := GetPC();
	if ((pc and 1) <> 0) then FIM.DM.Error(Self, 'Unaligned command address');
  m_instruction := ReadWord(pc);
  SetPC(GetPC() + 2);
end;

procedure TPDP11.TranslateInstruction();
begin
  with FContext do begin
    // Prepare values to help decode the command
    m_regdest  := Get8Digit(m_instruction, 0);
    m_methdest := Get8Digit(m_instruction, 1);
    m_regsrc   := Get8Digit(m_instruction, 2);
    m_methsrc  := Get8Digit(m_instruction, 3);

    m_pExecuteMethodMap[m_instruction]();
  end;
end;

function TPDP11.CheckForNegative(byte_val:Byte):Boolean;
begin
  Result := (byte_val and $80) <> 0;
end;

function TPDP11.CheckForNegative(word_val:Word):Boolean;
begin
  Result := (word_val and $8000) <> 0;
end;

function TPDP11.CheckForZero(byte_val:Byte):Boolean;
begin
  Result := byte_val = 0;
end;

function TPDP11.CheckForZero(word_val:Word):Boolean;
begin
  Result := word_val = 0;
end;

function TPDP11.CheckAddForOverflow(a, b: Byte):Boolean;
var sum: Byte;
begin
  sum := a + b;
  result := (((not a xor b) and (a xor sum)) and $80) <> 0;
end;

function TPDP11.CheckAddForOverflow(a, b: Word):Boolean;
var sum: Word;
begin
  sum := a + b;
  Result := (((not a xor b) and (a xor sum)) and $8000) <> 0;
end;

function TPDP11.CheckSubForOverflow(a, b: Byte):Boolean;
var sum: Byte;
begin
  sum := a - b;
  Result := (((a xor b) and (not b xor sum)) and $80) <> 0;
end;

function TPDP11.CheckSubForOverflow(a, b: Word):Boolean;
var sum: Word;
begin
  sum := a - b;
  Result := (((a xor b) and (not b xor sum)) and $8000) <> 0;
end;

function TPDP11.CheckAddForCarry(a, b: Byte):Boolean;
var sum: Word;
begin
  sum := Word(a) + Word(b);
  Result := (sum and $FF00) <> 0;
end;

function TPDP11.CheckAddForCarry(a, b: Word):Boolean;
var sum: Cardinal;
begin
  sum := Cardinal(a) + Cardinal(b);
  Result :=  (sum and $FFFF0000) <> 0;
end;

function TPDP11.CheckSubForCarry(a, b: Byte):Boolean;
var sum: Word;
begin
  sum := Word(a) - Word(b);
  Result := (sum and $FF00) <> 0;
end;

function TPDP11.CheckSubForCarry(a, b: Word):Boolean;
var sum: Cardinal;
begin
  sum := Cardinal(a) - Cardinal(b);
  Result :=  (sum and $FFFF0000) <> 0;
end;

function TPDP11.GetWordAddr (meth, reg: Byte): Word;
var addr: Word;
begin
	addr := 0;

	case meth of
		1:   //(R)
      begin
  			addr := GetReg(reg);
      end;
		2:   //(R)+
      begin
  			addr := GetReg(reg);
			  SetReg(reg,addr+2);
			end;
		3:  //@(R)+
      begin
  			addr := GetReg(reg);
  			SetReg(reg, addr+2);
  			addr := ReadWord(addr);
      end;
		4: //-(R)
      begin
  			SetReg(reg, GetReg(reg)-2);
  			addr := GetReg(reg);
      end;
		5: //@-(R)
      begin
  			SetReg(reg, GetReg(reg)-2);
  			addr := GetReg(reg);
	  		addr := readWord(addr);
      end;
		6: //d(R)
      begin
  			addr := ReadWord(GetPC());
  			SetPC(GetPC()+2);
  			addr := GetReg(reg) + addr;
      end;
		7: //@d(r)
      begin
  			addr := ReadWord(GetPC());
  			SetPC(GetPC()+2);
  			addr :=GetReg(reg)+addr;
  			if (not m_RPLYrq) then addr := ReadWord(addr);
      end;
	end;
	Result := addr;
end;

function TPDP11.GetByteAddr (meth, reg: Byte): Word;
var addr: Word;
begin
	addr := 0;
	case meth of
		1:
      begin
  			addr := GetReg(reg);
      end;
		2:
      begin
  			addr := GetReg(reg);
        if reg<6 then
    			SetReg(reg, addr + 1)
        else
    			SetReg(reg, addr + 2);
			end;
		3:
      begin
  			addr := GetReg(reg);
  			SetReg(reg, addr+2);
  			addr := ReadWord(addr);
			end;
		4:
      begin
        if reg<6 then
    			SetReg(reg,GetReg(reg)-1)
        else
    			SetReg(reg,GetReg(reg)-2);
  			addr := GetReg(reg);
			end;
		5:
      begin
  			SetReg(reg, GetReg(reg)-2);
  			addr := GetReg(reg);
  			addr := ReadWord(addr);
			end;
		6: //d(R)
      begin
  			addr := ReadWord(GetPC());
  			SetPC(GetPC()+2);
  			addr := GetReg(reg) + addr;
			end;
		7: //@d(r)
      begin
  			addr := ReadWord(GetPC());
  			SetPC(GetPC()+2);
  			addr := GetReg(reg)+addr;
  			if (not m_RPLYrq) then addr := ReadWord(addr);
			end;
	end;
	Result := addr;
end;

procedure TPDP11.ExecuteUNKNOWN ();  // Нет такой инструкции - просто вызывается TRAP 10
begin
  FIM.DM.Error(Self, 'Invalid instruction');
  m_RSVDrq := TRUE;
end;

procedure TPDP11.ExecuteHALT ();
begin
  m_HALTrq := TRUE;
end;

procedure TPDP11.ExecuteWAIT ();
begin
  FContext.m_waitmode := TRUE;
end;

procedure TPDP11.ExecuteRCPC	();
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
      m_RSVDrq := TRUE;
      Exit;
    end;
    SetReg(0, m_savepc);
    m_internalTick := NOP_TIMING;
  end;
end;

procedure TPDP11.ExecuteRCPS ();
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
        m_RSVDrq := TRUE;
        Exit;
    end;
    SetReg(0, m_savepsw);
  	m_internalTick := NOP_TIMING;
  end;
end;

procedure TPDP11.ExecuteWCPC	();
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
      m_RSVDrq := TRUE;
      Exit;
    end;
    m_savepc := GetReg(0);
  	m_internalTick := NOP_TIMING;
  end;
end;

procedure TPDP11.ExecuteWCPS	();
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
      m_RSVDrq := TRUE;
      Exit;
    end;
    m_savepsw := GetReg(0);
	  m_internalTick := NOP_TIMING;
  end;
end;

procedure TPDP11.ExecuteMFUS (); //move from user space
var word_val: Word;
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
       m_RSVDrq := TRUE;
       Exit;
    end;
    //r0 = (r5)+
    SetHALT(FALSE);
    word_val := ReadWord(GetReg(5));
    SetHALT(TRUE);
    SetReg(5, GetReg(5)+2);
    if (not m_RPLYrq) then SetReg(0, word_val);
    m_internalTick := MOV_TIMING[0][2];
  end;
end;

procedure TPDP11.ExecuteMTUS (); //move to user space
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
      m_RSVDrq := TRUE;
      Exit;
    end;

    //-(r5)=r0
  	SetReg(5,GetReg(5)-2);
  	SetHALT(FALSE);
  	WriteWord(GetReg(5),GetReg(0));
  	SetHALT(TRUE);
  	m_internalTick := MOV_TIMING[0][2];
  end;
end;

procedure TPDP11.ExecuteRTI (); // RTI - Возврат из прерывания
var word_val: Word;
begin
  with FContext do begin
    word_val := ReadWord(GetSP());
    SetSP( GetSP() + 2 );
    if (m_RPLYrq) then exit;
    SetPC(word_val);  // Pop PC
    word_val := ReadWord ( GetSP() );  // Pop PSW --- saving HALT
    SetSP( GetSP() + 2 );
    if (m_RPLYrq) then exit;
    if(GetPC() < $E000) then              //0160000
      SetLPSW(Byte(word_val and $FF))
    else
      SetPSW(word_val); //load new mode
    m_internalTick := RTI_TIMING;
  end;
end;

procedure TPDP11.ExecuteBPT (); // BPT - Breakpoint
begin
  with FContext do begin
    m_BPT_rq := TRUE;
  	m_internalTick := BPT_TIMING;
  end;
end;

procedure TPDP11.ExecuteIOT (); // IOT - I/O trap
begin
  with FContext do begin
    m_IOT_rq := TRUE;
  	m_internalTick := EMT_TIMING;
  end;
end;

procedure TPDP11.ExecuteRESET ();
begin
  with FContext do begin
	  m_EVNTrq := FALSE;
  	//m_pMemoryController->ResetDevices();  // INIT signal
    FIM.DM.Error(Self, 'RESET command');
	  m_internalTick := RESET_TIMING;
  end;
end;

procedure TPDP11.ExecuteSTEP	();
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
      m_RSVDrq := TRUE;
      Exit;
    end;

    m_stepmode := TRUE;
  	SetPC(m_savepc);
  	SetPSW(m_savepsw);
  end;
end;

procedure TPDP11.ExecuteRSEL ();
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
      m_RSVDrq := TRUE;
      exit;
    end;

    //SetReg(0, GetMemoryController()->GetSelRegister());
    FIM.DM.Error(Self, 'RSEL command');
  end;
end;

procedure TPDP11.Execute000030 ();
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
      m_RSVDrq := TRUE;
      exit;
    end;

    //TODO: Реализовать команду
    //m_RPLYrq = TRUE;
    FIM.DM.Error(Self, '000030 command');
  end;
end;

procedure TPDP11.ExecuteFIS ();  // Floating point instruction set
begin
  m_FIS_rq := TRUE;
end;

procedure TPDP11.ExecuteRUN	();
begin
  with FContext do begin
    if ((m_psw and PSW_HALT) = 0) then begin
      m_RSVDrq := TRUE;
      exit;
    end;

  	SetPC(m_savepc);
  	SetPSW(m_savepsw);
  end;
end;

procedure TPDP11.ExecuteRTT (); // RTT - return from trace trap
var word_val: Word;
begin
  with FContext do begin
    word_val := ReadWord(GetSP());
    SetSP( GetSP() + 2 );
    if (m_RPLYrq) then exit;
    SetPC(word_val);  // Pop PC
    word_val := ReadWord ( GetSP() );  // Pop PSW --- saving HALT
    SetSP( GetSP() + 2 );
    if (m_RPLYrq) then exit;
    if(GetPC() < $E000) then             //0160000
      SetLPSW(Byte(word_val and $FF))
    else
      SetPSW(word_val); //load new mode

    m_stepmode := (word_val and PSW_T) <> 0;

    m_internalTick := RTI_TIMING;
  end;
end;

procedure TPDP11.ExecuteCCC ();
begin
  with FContext do begin
  	SetLPSW(GetLPSW() and not(m_instruction and $0F));
  	m_internalTick := NOP_TIMING;
  end;
end;

procedure TPDP11.ExecuteSCC ();
begin
  with FContext do begin
  	SetLPSW(GetLPSW() or (m_instruction and $0F));
  	m_internalTick := NOP_TIMING;
  end;
end;

    // One fiels
procedure TPDP11.ExecuteRTS (); // RTS - return from subroutine - Возврат из процедуры
var word_val: Word;
begin
	with FContext do begin
		SetPC(GetReg(m_regdest));
		word_val := ReadWord(GetSP());
		SetSP(GetSP()+2);
		if (m_RPLYrq) then exit;
		SetReg(m_regdest, word_val);
		m_internalTick := RTS_TIMING;
	end;
end;

		// Two fields
procedure TPDP11.ExecuteJMP ();   // JMP - jump: PC = &d (a-mode > 0)
var word_val: Word;
begin
	with FContext do begin
		if (m_methdest = 0) then begin // Неправильный метод адресации
			m_ILLGrq := TRUE;
			m_internalTick := EMT_TIMING;
		end else begin
			word_val := GetWordAddr(m_methdest, m_regdest);
			if (m_RPLYrq) then exit;
			SetPC(word_val);
			m_internalTick := JMP_TIMING[m_methdest-1];
		end;
	end;
end;

procedure TPDP11.ExecuteSWAB ();
var ea, dst: Word;
		new_psw: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;

		if (m_methdest <> 0) then begin
			ea := GetWordAddr(m_methdest,m_regdest);
			if (m_RPLYrq) then exit;
			dst := ReadWord(ea);
			if (m_RPLYrq) then exit;
		end	else
			dst := GetReg(m_regdest);

		dst := ((dst shr 8)and $FF) or (dst shl 8);

		if(m_methdest <> 0) then
			WriteWord(ea, dst)
		else
			SetReg(m_regdest, dst);

		if (m_RPLYrq) then exit;

		if ((dst and n_0200)<>0) then new_psw := new_psw or PSW_N;
		if ((dst and $FF) = 0) then new_psw := new_psw or PSW_Z;
		SetLPSW(new_psw);
		m_internalTick := MOV_TIMING[m_methdest][m_methdest];
	end;
end;


procedure TPDP11.ExecuteCLR ();
var dst_addr: Word;
begin
	with FContext do begin
		if(m_instruction and $8000 <> 0) then begin
			if(m_methdest <> 0) then begin
				dst_addr := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				ReadMem(dst_addr);
				if (m_RPLYrq) then exit;
				WriteMem(dst_addr, 0);
				if (m_RPLYrq) then exit;
			end	else
				SetLReg(m_regdest, 0);

			SetLPSW((GetLPSW() and $F0) or PSW_Z);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if(m_methdest <> 0) then begin
				dst_addr := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				WriteWord(dst_addr, 0);
				if (m_RPLYrq) then exit;
			end	else
				SetReg(m_regdest,0);

			SetLPSW((GetLPSW() and $F0) or PSW_Z);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;



procedure TPDP11.ExecuteCOM ();
var ea, dst_word: Word;
		new_psw, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest <> 0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_byte := GetLReg(m_regdest);

			dst_byte := not dst_byte;

			if(m_methdest <> 0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;
		
			if (dst_byte and n_0200 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest <> 0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_word := GetReg(m_regdest);

			dst_word := not dst_word;

			if(m_methdest <> 0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteINC ();
var ea, dst_word: Word;
		new_psw, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F1;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest <> 0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_byte := GetLReg(m_regdest);

			dst_byte := dst_byte + 1;

			if(m_methdest <> 0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and n_0200 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if (dst_byte = n_0200) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest <> 0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_word := GetReg(m_regdest);

			dst_word := dst_word + 1;

			if(m_methdest<>0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if (dst_word = $8000) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteDEC ();
var ea, dst_word: Word;
		new_psw, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F1;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest <> 0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_byte := GetLReg(m_regdest);

			dst_byte := dst_byte - 1;
		
			if(m_methdest<>0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and n_0200 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if (dst_byte = $7F) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_word := GetReg(m_regdest);

			dst_word := dst_word - 1;

			if(m_methdest<>0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if (dst_word = $7FFF) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteNEG ();
var ea, dst_word: Word;
		new_psw, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest<>0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_byte := GetLReg(m_regdest);

			dst_byte := 0 - dst_byte ;
		
			if(m_methdest<>0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and n_0200 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if (dst_byte = n_0200) then new_psw := new_psw or PSW_V;
			if (dst_byte <> 0) then new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_word := GetReg(m_regdest);

			dst_word := 0 - dst_word;

			if(m_methdest<>0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if (dst_word = $8000) then new_psw := new_psw or PSW_V;
			if (dst_word <> 0) then new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteADC ();
var ea, dst_word: Word;
		new_psw, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest<>0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_byte := GetLReg(m_regdest);

      if GetC() then dst_byte := dst_byte + 1;
		
			if(m_methdest<>0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and n_0200 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if ((dst_byte = n_0200) and GetC()) then new_psw := new_psw or PSW_V;
			if ((dst_byte = 0) and GetC()) then new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_word := GetReg(m_regdest);

			if GetC() then dst_word := dst_word + 1;

			if(m_methdest<>0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if ((dst_word = $8000) and GetC()) then new_psw := new_psw or PSW_V;
			if ((dst_word = 0) and GetC()) then new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteSBC ();
var ea, dst_word: Word;
		new_psw, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest<>0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_byte := GetLReg(m_regdest);

      if GetC() then dst_byte := dst_byte - 1;
		
			if(m_methdest<>0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and n_0200 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if ((dst_byte = $7F) and GetC()) then new_psw := new_psw or PSW_V;
			if ((dst_byte = $FF) and GetC()) then new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_word := GetReg(m_regdest);

			if GetC() then dst_word := dst_word - 1;

			if(m_methdest<>0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if ((dst_word = $7FFF) and GetC()) then new_psw := new_psw or PSW_V;
			if ((dst_word = $FFFF) and GetC()) then new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteTST ();
var ea, dst_word: Word;
		new_psw, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest<>0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_byte := GetLReg(m_regdest);

			if (dst_byte and n_0200 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := TST_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				dst_word := readWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				dst_word := GetReg(m_regdest);

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := TST_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteROR ();
var ea, src_word, dst_word: Word;
		new_psw, src_byte, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest<>0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				src_byte := GetLReg(m_regdest);

			dst_byte := src_byte shr 1;
			if GetC() then
				dst_byte := dst_byte or $80;

			if(m_methdest<>0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if (src_byte and 1 <> 0) then new_psw := new_psw or PSW_C;
			if (((new_psw and PSW_N)<>0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end else
				src_word := GetReg(m_regdest);

			dst_word := src_word shr 1;
			if GetC() then
				dst_word := dst_word or $8000;

			if(m_methdest<>0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if (src_word and 1 <> 0) then new_psw := new_psw or PSW_C;
			if (((new_psw and PSW_N)<>0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteROL ();
var ea, src_word, dst_word: Word;
		new_psw, src_byte, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest<>0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				src_byte := GetLReg(m_regdest);

			dst_byte := src_byte shl 1;
			if GetC() then
				dst_byte := dst_byte or 1;
		
			if(m_methdest<>0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if (src_byte and $80 <> 0) then new_psw := new_psw or PSW_C;
			if (((new_psw and PSW_N)<>0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				src_word := GetReg(m_regdest);

			dst_word := src_word shl 1;
			if GetC() then
				dst_word := dst_word or 1;

			if(m_methdest<>0) then 
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if (src_word and $8000 <> 0) then new_psw := new_psw or PSW_C;
			if (((new_psw and PSW_N)<>0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteASR ();
var ea, src_word, dst_word: Word;
		new_psw, src_byte, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest<>0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				src_byte := GetLReg(m_regdest);

			dst_byte := (src_byte shr 1) or (src_byte and $80);
		
			if(m_methdest<>0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if (src_byte and 1 <> 0) then new_psw := new_psw or PSW_C;
			if (((new_psw and PSW_N)<>0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				src_word := GetReg(m_regdest);

			dst_word := (src_word shr 1) or (src_word and $8000);

			if(m_methdest<>0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if (src_word and 1 <> 0) then new_psw := new_psw or PSW_C;
			if (((new_psw and PSW_N)<>0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteASL ();
var ea, src_word, dst_word: Word;
		new_psw, src_byte, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;
		if(m_instruction and $8000 <> 0) then begin
			if (m_methdest<>0) then begin
				ea := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src_byte := ReadMem(ea);
				if (m_RPLYrq) then exit;
			end	else
				src_byte := GetLReg(m_regdest);

			dst_byte := src_byte shl 1;
		
			if(m_methdest<>0) then
				WriteMem(ea,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if (src_byte and $80 <> 0) then new_psw := new_psw or PSW_C;
			if (((new_psw and PSW_N)<>0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end	else begin
			if (m_methdest<>0) then begin
				ea := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src_word := ReadWord(ea);
				if (m_RPLYrq) then exit;
			end	else
				src_word := GetReg(m_regdest);

			dst_word := src_word shl 1;

			if(m_methdest<>0) then
				WriteWord(ea,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if (src_word and $8000 <> 0) then new_psw := new_psw or PSW_C;
			if (((new_psw and PSW_N)<>0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
			SetLPSW(new_psw);
			m_internalTick := CLR_TIMING[m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteMARK ();
begin
	with FContext do begin
		SetSP( GetPC() + (m_instruction and $003F) * 2 );
		SetPC( GetReg(5) );
		SetReg(5, ReadWord( GetSP() ));
		SetSP( GetSP() + 2 );
		if (m_RPLYrq) then exit;
		m_internalTick := MARK_TIMING;
	end;
end;

procedure TPDP11.ExecuteSXT ();  // SXT - sign-extend
var ea: Word;
		new_psw: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F9;
		if(m_methdest<>0) then begin
			ea := GetWordAddr(m_methdest,m_regdest);
			if (m_RPLYrq) then exit;
			if GetN() then
				WriteWord(ea,$FFFF)
			else
				WriteWord(ea,0);
			if (m_RPLYrq) then exit;
		end	else
			if GetN() then
				SetReg(m_regdest,$FFFF)
			else
				SetReg(m_regdest,0);

		if (not GetN()) then new_psw := new_psw or PSW_Z;
		SetLPSW(new_psw);
		m_internalTick := CLR_TIMING[m_methdest];
	end;
end;

procedure TPDP11.ExecuteMTPS (); // MTPS - move to PS
var ea: Word;
		dst: Byte;
begin
	with FContext do begin
		if(m_methdest<>0) then begin
			ea := GetByteAddr(m_methdest,m_regdest);
			if (m_RPLYrq) then exit;
			dst := ReadMem(ea);
			if (m_RPLYrq) then exit;
		end	else
			dst := GetLReg(m_regdest);

		SetLPSW((GetLPSW() and $10) or (dst and $EF));
		SetPC(GetPC());
		m_internalTick := MTPS_TIMING[m_methdest];
	end;
end;

procedure TPDP11.ExecuteMFPS ();
var ea: Word;
		psw, new_psw: Byte;
begin
	with FContext do begin
		psw := GetLPSW();
		new_psw := psw and $F1;

		if (m_methdest<>0) then begin
			ea := GetByteAddr(m_methdest,m_regdest);
			if (m_RPLYrq) then exit;
			ReadMem(ea);
			if (m_RPLYrq) then exit;
			WriteMem(ea, psw);
			if (m_RPLYrq) then exit;
		end	else
			if (psw and $80 <> 0) then
				SetReg(m_regdest, Word(psw) or $FF00) //sign extend
			else
				SetReg(m_regdest, Word(psw));

		if (psw and $80 <> 0) then new_psw := new_psw or PSW_N;
		if (psw = 0) then new_psw := new_psw or PSW_Z;
		SetLPSW(new_psw);
		m_internalTick := CLR_TIMING[m_methdest];
	end;
end;

		// Branchs & interrupts
procedure TPDP11.ExecuteBR ();
begin
	with FContext do begin
		SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
		m_internalTick := BR_TIMING;
	end;
end;

procedure TPDP11.ExecuteBNE ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (not GetZ()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBEQ ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (GetZ()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBGE ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (GetN() = GetV()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBLT ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (GetN() <> GetV()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBGT ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (not ((GetN() <> GetV()) or GetZ())) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBLE ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if ((GetN() <> GetV()) or GetZ()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBPL ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (not GetN()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBMI ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (GetN()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBHI ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (not (GetZ() or GetC())) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBLOS ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (GetZ() or GetC()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBVC ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (not GetV()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBVS ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (GetV()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBHIS ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (not GetC()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteBLO ();
begin
	with FContext do begin
		m_internalTick := BRANCH_FALSE_TIMING;
		if (GetC()) then begin
			SetPC(GetPC() + (Smallint(Shortint(Byte(m_instruction and $FF)))) * 2 );
			m_internalTick := BRANCH_TRUE_TIMING;
		end;
	end;
end;

procedure TPDP11.ExecuteEMT (); // EMT - emulator trap
begin
	with FContext do begin
		m_EMT_rq := TRUE;
		m_internalTick := EMT_TIMING;
	end;
end;

procedure TPDP11.ExecuteTRAP ();
begin
	with FContext do begin
		m_TRAPrq := TRUE;
		m_internalTick := EMT_TIMING;
	end;
end;

		// Three fields
procedure TPDP11.ExecuteJSR (); // JSR - Jump subroutine: *--SP = R; R = PC; PC = &d (a-mode > 0)
var dst: Word;
begin
	with FContext do begin
		if (m_methdest = 0) then begin
			// Неправильный метод адресации
			m_ILLGrq := TRUE;
			m_internalTick := EMT_TIMING;
		end	else begin
			dst := GetWordAddr(m_methdest,m_regdest);
			if (m_RPLYrq) then exit;
			SetSP( GetSP() - 2 );
			WriteWord( GetSP(), GetReg(m_regsrc) );
			SetReg(m_regsrc, GetPC());
			SetPC(dst);
			if (m_RPLYrq) then exit;
			m_internalTick := JSR_TIMING[m_methdest-1];
		end;
	end;
end;

procedure TPDP11.ExecuteXOR ();
var dst, ea: Word;
		new_psw: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F1;
		if (m_methdest<>0) then begin
			ea := GetWordAddr(m_methdest,m_regdest);
			if (m_RPLYrq) then exit;
			dst := ReadWord(ea);
			if (m_RPLYrq) then exit;
		end	else
			dst := GetReg(m_regdest);

		dst := dst xor GetReg(m_regsrc);

		if(m_methdest<>0) then
			WriteWord(ea,dst)
		else
			SetReg(m_regdest,dst);
		if (m_RPLYrq) then exit;

		if (dst and $8000 <> 0) then new_psw := new_psw or PSW_N;
		if (dst = 0) then new_psw := new_psw or PSW_Z;
		SetLPSW(new_psw);
		m_internalTick := XOR_TIMING[m_methdest];
	end;
end;

procedure TPDP11.ExecuteSOB (); // SOB - subtract one: R = R - 1 ; if R != 0 : PC = PC - 2*nn
var dst: Word;
begin
	with FContext do begin
		dst := GetReg(m_regsrc);
		m_internalTick := SOB_LAST_TIMING;
		Dec(dst);
		SetReg(m_regsrc, dst);
		if (dst<>0) then begin
			m_internalTick := SOB_TIMING;
			SetPC(GetPC() - (m_instruction and $3F) * 2 );
		end;
	end;
end;

procedure TPDP11.ExecuteMUL ();
var dst, src, ea: Word;
		new_psw: Byte;
		res: Integer;
begin
	with FContext do begin
		dst := GetReg(m_regsrc);
		new_psw := GetLPSW() and $F0;

		if (m_methdest<>0) then ea := GetWordAddr(m_methdest,m_regdest);
		if (m_RPLYrq) then exit;
		if (m_methdest<>0) then
			src := ReadWord(ea)
		else
			src := GetReg(m_regdest);
		if (m_RPLYrq) then exit;

		res := Smallint(dst)*Smallint(src);

		SetReg(m_regsrc, res shr 16 );
		SetReg(m_regsrc or 1, res and $FFFF);

		if (res<0) then new_psw := new_psw or PSW_N;
		if (res=0) then new_psw := new_psw or PSW_Z;
		if ((res > 32767) or (res < -32768)) then new_psw := new_psw or PSW_C;
		SetLPSW(new_psw);
		m_internalTick := MUL_TIMING[m_methdest];
	end;
end;

procedure TPDP11.ExecuteDIV ();
var dst, src, ea: Word;
		new_psw: Byte;
		res, res1, src2, longsrc: Integer;
begin
	with FContext do begin
		//время надо считать тут
		new_psw := GetLPSW() and $F0;

		if (m_methdest<>0) then ea := GetWordAddr(m_methdest,m_regdest);
		if (m_RPLYrq) then exit;
		if (m_methdest<>0) then
			src2 := Integer(SmallInt(ReadWord(ea)))
		else
			src2 := Integer(SmallInt(GetReg(m_regdest)));

		if (m_RPLYrq) then exit;

		longsrc := Integer( (Cardinal(GetReg(m_regsrc)) shl 16) or Cardinal(GetReg(m_regsrc or 1)) );

		m_internalTick := DIV_TIMING[m_methdest];

		if(src2=0) then begin
			new_psw := new_psw or (PSW_V or PSW_C); //если делят на 0 -- то устанавливаем V и C
			SetLPSW(new_psw);
			exit; 
		end;	
		if ((longsrc = $80000000) and (src2 = -1)) then begin
			new_psw := new_psw or PSW_V; // переполняемся, товарищи
			SetLPSW(new_psw);
			exit;
		end;

		res := longsrc div src2;
		res1 := longsrc mod src2;

		if ((res > 32767) or (res < -32768)) then begin
			new_psw := new_psw or PSW_V; // переполняемся, товарищи
			SetLPSW(new_psw);
			exit;
		end;

		SetReg(m_regsrc or 1, res1 and $FFFF);
		SetReg(m_regsrc,res and $FFFF);

		if (res<0) then new_psw := new_psw or PSW_N;
		if (res=0) then new_psw := new_psw or PSW_Z;
		SetLPSW(new_psw);
	end;
end;

procedure TPDP11.ExecuteASH ();
var ea: Word;
		src, dst: SmallInt;
		new_psw: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;

		if (m_methdest<>0) then ea := GetWordAddr(m_methdest,m_regdest);
		if (m_RPLYrq) then exit;
		if (m_methdest<>0) then
			src := SmallInt(ReadWord(ea))
		else
			src := SmallInt(GetReg(m_regdest));
		if (m_RPLYrq) then exit;
		if (src and $20 <> 0) then
			src := src or $FFC0;
		dst := SmallInt(GetReg(m_regsrc));

		m_internalTick := ASH_TIMING[m_methdest];

		if (src >= 0) then begin
			while (src <> 0) do begin
				Dec(src);
				if (dst and $8000 <> 0) then
					new_psw := new_psw or PSW_C
				else
					new_psw := new_psw and not PSW_C;
				dst := dst shl 1;
				if ((dst<0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
				Inc(m_internalTick, ASH_S_TIMING);
			end;
		end	else begin
			while (src <> 0) do begin
				Inc(src);
				if (dst and 1 <> 0) then
					new_psw := new_psw or PSW_C
				else
					new_psw := new_psw and not PSW_C;
				dst := dst shr 1;
				Inc (m_internalTick, ASH_S_TIMING);
			end;
		end;
	
		SetReg(m_regsrc,dst);
		
		if (dst<0) then new_psw := new_psw or PSW_N;
		if (dst=0) then new_psw := new_psw or PSW_Z;
		SetLPSW(new_psw);
	end;
end;

procedure TPDP11.ExecuteASHC ();
var ea: Word;
		src: SmallInt;
		dst: LongInt;
		new_psw: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;

		if (m_methdest<>0) then ea := GetWordAddr(m_methdest,m_regdest);
		if (m_RPLYrq) then exit;
		if (m_methdest<>0) then
			src := SmallInt(ReadWord(ea))
		else
			src := SmallInt(GetReg(m_regdest));
		if (m_RPLYrq) then exit;
		if (src and $20 <> 0) then
			src := src or $FFC0;
		dst := LongInt((Cardinal(GetReg(m_regsrc)) shl 16) or Cardinal(GetReg(m_regsrc or 1)));
		m_internalTick := ASHC_TIMING[m_methdest];
		if (src >= 0) then begin
			while (src <> 0) do begin
				Dec(src);
				if (dst and $80000000 <> 0) then
					new_psw := new_psw or PSW_C
				else
					new_psw := new_psw and not PSW_C;
				dst := dst shl 1;
				if ((dst<0) <> ((new_psw and PSW_C)<>0)) then new_psw := new_psw or PSW_V;
				Inc(m_internalTick, ASHC_S_TIMING);
			end;
		end	else begin
			while (src <> 0) do begin
				Inc(src);
				if (dst and  1 <> 0) then
					new_psw := new_psw or PSW_C
				else
					new_psw := new_psw and not PSW_C;
				dst := dst shr 1;
				Inc(m_internalTick, ASHC_S_TIMING);
			end;
		end;
		
		SetReg(m_regsrc,Word(Cardinal(dst) shr 16));
		SetReg(m_regsrc or 1,Word(Cardinal(dst and $FFFF)));
		
		//SetN(dst<0); ??
		//SetZ(dst=0); ??
		if (dst<0) then new_psw := new_psw or PSW_N;
		if (dst=0) then new_psw := new_psw or PSW_Z;
		SetLPSW(new_psw);
	end;
end;

		// Four fields
procedure TPDP11.ExecuteMOV ();
var src_addr, dst_addr, dst_word: Word;
		new_psw, dst_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F1;

		if(m_instruction and $8000 <> 0) then begin
			if (m_methsrc<>0) then begin
				src_addr := GetByteAddr(m_methsrc,m_regsrc);
				if (m_RPLYrq) then exit;
				dst_byte := ReadMem(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				dst_byte := GetLReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				ReadMem(dst_addr);
				if (m_RPLYrq) then exit;
				WriteMem(dst_addr,dst_byte);
				if (m_RPLYrq) then exit;
			end	else
				SetReg(m_regdest,Word(SmallInt(ShortInt(dst_byte))));

			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := MOVB_TIMING[m_methsrc][m_methdest];
		end	else begin
			if (m_methsrc<>0) then begin
				src_addr := GetWordAddr(m_methsrc,m_regsrc);
				if (m_RPLYrq) then exit;
				dst_word := ReadWord(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				dst_word := GetReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				WriteWord(dst_addr,dst_word);
				if (m_RPLYrq) then exit;
			end	else
				SetReg(m_regdest,dst_word);

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := MOV_TIMING[m_methsrc][m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteCMP ();
var src_addr, dst_addr, dst_word, src_word, src2_word: Word;
		new_psw, dst_byte, src_byte, src2_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;

		if(m_instruction and $8000 <> 0) then begin
			if (m_methsrc<>0) then begin
				src_addr := GetByteAddr(m_methsrc,m_regsrc);
				if (m_RPLYrq) then exit;
				src_byte := ReadMem(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				src_byte := GetLReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetByteAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src2_byte := ReadMem(dst_addr);
				if (m_RPLYrq) then exit;
			end	else
				src2_byte := GetLReg(m_regdest);
		
			dst_byte := src_byte - src2_byte;
					//SetN( CheckForNegative((BYTE)(src - src2)) );
					//SetZ( CheckForZero((BYTE)(src - src2)) );
					//SetV( CheckSubForOverflow (src, src2) );
					//SetC( CheckSubForCarry (src, src2) );
			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			if (((src_byte xor src2_byte) and not(dst_byte xor src2_byte)) and $80 <> 0) then new_psw := new_psw or PSW_V;
			if (((not src_byte and src2_byte) or (not(src_byte xor src2_byte) and dst_byte)) and $80 <> 0) then new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CMP_TIMING[m_methsrc][m_methdest];
		end	else begin
			if (m_methsrc<>0) then begin
				src_addr := GetWordAddr(m_methsrc,m_regsrc);
				if (m_RPLYrq) then exit;
				src_word := ReadWord(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				src_word := GetReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetWordAddr(m_methdest,m_regdest);
				if (m_RPLYrq) then exit;
				src2_word := ReadWord(dst_addr);
				if (m_RPLYrq) then exit;
			end	else
				src2_word := GetReg(m_regdest);

			dst_word := src_word - src2_word;

					//SetN( CheckForNegative ((WORD)(src - src2)) );
					//SetZ( CheckForZero ((WORD)(src - src2)) );
					//SetV( CheckSubForOverflow (src, src2) );
					//SetC( CheckSubForCarry (src, src2) );
			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			if (((src_word xor src2_word) and not(dst_word xor src2_word)) and $8000 <> 0) then new_psw := new_psw or PSW_V;
			if (((not src_word and src2_word) or (not(src_word xor src2_word) and dst_word)) and $8000 <> 0) then new_psw := new_psw or PSW_C;
			SetLPSW(new_psw);
			m_internalTick := CMP_TIMING[m_methsrc][m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteBIT ();
var src_addr, dst_addr, dst_word, src_word, src2_word: Word;
		new_psw, dst_byte, src_byte, src2_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F1;

		if(m_instruction and $8000 <> 0) then begin
			if (m_methsrc<>0) then begin
				src_addr := GetByteAddr(m_methsrc, m_regsrc);
				if (m_RPLYrq) then exit;
				src_byte := ReadMem(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				src_byte := GetLReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetByteAddr(m_methdest, m_regdest);
				if (m_RPLYrq) then exit;
				src2_byte := ReadMem(dst_addr);
				if (m_RPLYrq) then exit;
			end	else
				src2_byte := GetLReg(m_regdest);

			dst_byte := src2_byte and src_byte;

			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := CMP_TIMING[m_methsrc][m_methdest];
		end	else begin
			if (m_methsrc<>0) then begin
				src_addr := GetWordAddr(m_methsrc, m_regsrc);
				if (m_RPLYrq) then exit;
				src_word := ReadWord(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				src_word := GetReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetWordAddr(m_methdest, m_regdest);
				if (m_RPLYrq) then exit;
				src2_word := ReadWord(dst_addr);
				if (m_RPLYrq) then exit;
			end	else
				src2_word := GetReg(m_regdest);

			dst_word := src2_word and src_word;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := CMP_TIMING[m_methsrc][m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteBIC ();
var src_addr, dst_addr, dst_word, src_word, src2_word: Word;
		new_psw, dst_byte, src_byte, src2_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F1;

		if(m_instruction and $8000 <> 0) then begin
			if (m_methsrc<>0) then begin
				src_addr := GetByteAddr(m_methsrc, m_regsrc);
				if (m_RPLYrq) then exit;
				src_byte := ReadMem(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				src_byte := GetLReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetByteAddr(m_methdest, m_regdest);
				if (m_RPLYrq) then exit;
				src2_byte := ReadMem(dst_addr);
				if (m_RPLYrq) then exit;
			end	else
				src2_byte := GetLReg(m_regdest);

			dst_byte := src2_byte and (not src_byte);

			if(m_methdest<>0) then
				WriteMem(dst_addr,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := MOVB_TIMING[m_methsrc][m_methdest];
		end	else begin
			if (m_methsrc<>0) then begin
				src_addr := GetWordAddr(m_methsrc, m_regsrc);
				if (m_RPLYrq) then exit;
				src_word := ReadWord(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				src_word := GetReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetWordAddr(m_methdest, m_regdest);
				if (m_RPLYrq) then exit;
				src2_word := ReadWord(dst_addr);
				if (m_RPLYrq) then exit;
			end	else
				src2_word := GetReg(m_regdest);

			dst_word := src2_word and (not src_word);

			if(m_methdest<>0) then
				WriteWord(dst_addr,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := MOV_TIMING[m_methsrc][m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteBIS ();
var src_addr, dst_addr, dst_word, src_word, src2_word: Word;
		new_psw, dst_byte, src_byte, src2_byte: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F1;

		if(m_instruction and $8000 <> 0) then begin
			if (m_methsrc<>0) then begin
				src_addr := GetByteAddr(m_methsrc, m_regsrc);
				if (m_RPLYrq) then exit;
				src_byte := ReadMem(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				src_byte := GetLReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetByteAddr(m_methdest, m_regdest);
				if (m_RPLYrq) then exit;
				src2_byte := ReadMem(dst_addr);
				if (m_RPLYrq) then exit;
			end	else
				src2_byte := GetLReg(m_regdest);

			dst_byte := src2_byte or src_byte;

			if(m_methdest<>0) then
				WriteMem(dst_addr,dst_byte)
			else
				SetLReg(m_regdest,dst_byte);
			if (m_RPLYrq) then exit;

			if (dst_byte and $80 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_byte = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := MOVB_TIMING[m_methsrc][m_methdest];
		end	else begin
			if (m_methsrc<>0) then begin
				src_addr := GetWordAddr(m_methsrc, m_regsrc);
				if (m_RPLYrq) then exit;
				src_word := ReadWord(src_addr);
				if (m_RPLYrq) then exit;
			end	else
				src_word := GetReg(m_regsrc);

			if (m_methdest<>0) then begin
				dst_addr := GetWordAddr(m_methdest, m_regdest);
				if (m_RPLYrq) then exit;
				src2_word := ReadWord(dst_addr);
				if (m_RPLYrq) then exit;
			end	else
				src2_word := GetReg(m_regdest);

			dst_word := src2_word or src_word;

			if(m_methdest<>0) then
				WriteWord(dst_addr,dst_word)
			else
				SetReg(m_regdest,dst_word);
			if (m_RPLYrq) then exit;

			if (dst_word and $8000 <> 0) then new_psw := new_psw or PSW_N;
			if (dst_word = 0) then new_psw := new_psw or PSW_Z;
			SetLPSW(new_psw);
			m_internalTick := MOV_TIMING[m_methsrc][m_methdest];
		end;
	end;
end;

procedure TPDP11.ExecuteADD ();
var src_addr, dst_addr, src, src2, dst: Word;
		new_psw: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;

		if (m_methsrc<>0) then begin
			src_addr := GetWordAddr(m_methsrc,m_regsrc);
			if (m_RPLYrq) then exit;
			src := ReadWord(src_addr);
			if (m_RPLYrq) then exit;
		end	else
		 src := GetReg(m_regsrc);

		if (m_methdest<>0) then begin
			dst_addr := GetWordAddr(m_methdest,m_regdest);
			if (m_RPLYrq) then exit;
			src2 := ReadWord(dst_addr);
			if (m_RPLYrq) then exit;
		end	else
			src2 := GetReg(m_regdest);

		dst := src2 + src;

		if(m_methdest<>0) then
			WriteWord(dst_addr, dst)
		else
			SetReg(m_regdest, dst);
		if (m_RPLYrq) then exit;

		if (dst and $8000 <> 0) then new_psw := new_psw or PSW_N;
		if (dst = 0) then new_psw := new_psw or PSW_Z;
		if ((not(src xor src2) and (dst xor src2)) and $8000 <> 0) then new_psw := new_psw or PSW_V;
		if (((src and src2) or ((src xor src2) and not dst)) and $8000 <> 0) then new_psw := new_psw or PSW_C;
		SetLPSW(new_psw);
		m_internalTick := MOVB_TIMING[m_methsrc][m_methdest];
	end;
end;

procedure TPDP11.ExecuteSUB ();
var src_addr, dst_addr, src, src2, dst: Word;
		new_psw: Byte;
begin
	with FContext do begin
		new_psw := GetLPSW() and $F0;

		if (m_methsrc<>0) then begin
			src_addr := GetWordAddr(m_methsrc,m_regsrc);
			if (m_RPLYrq) then exit;
			src := ReadWord(src_addr);
			if (m_RPLYrq) then exit;
		end	else
		 src := GetReg(m_regsrc);

		if (m_methdest<>0) then begin
			dst_addr := GetWordAddr(m_methdest,m_regdest);
			if (m_RPLYrq) then exit;
			src2 := ReadWord(dst_addr);
			if (m_RPLYrq) then exit;
		end	else
			src2 := GetReg(m_regdest);

		dst := src2 - src;

		if(m_methdest<>0) then
			WriteWord(dst_addr, dst)
		else
			SetReg(m_regdest, dst);
		if (m_RPLYrq) then exit;

		if (dst and $8000 <> 0) then new_psw := new_psw or PSW_N;
		if (dst = 0) then new_psw := new_psw or PSW_Z;
		if ((not(src xor src2) and (dst xor src2)) and $8000 <> 0) then new_psw := new_psw or PSW_V;
		if (((src and src2) or ((src xor src2) and not dst)) and $8000 <> 0) then new_psw := new_psw or PSW_C;
		SetLPSW(new_psw);
		m_internalTick := MOVB_TIMING[m_methsrc][m_methdest];
	end;
end;

begin
	RegisterDeviceCreateFunc('pdp11', @CreatePDP11);
end.
