unit Z80;

interface

uses Core, Utils, Config;

{$i z80_tables.inc}

type
	TZ80 = class (TCPU)
	private
	protected
		function GetPC:Cardinal; override;
		{$IFDEF REC_CONTEXT}
		function GetContextCRC:Word; override;
		{$ENDIF}
	public
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure LoadConfig(const SD:TSystemData); override;
		function Execute:Cardinal; override;
	end;


procedure Z80Reset;
function z80_execute:Integer;

procedure pop(var wpval:Word);
procedure push(wpval:Word);

function peekb(addr : integer) : Byte;
procedure pokeb(addr : integer; val : Byte);
procedure pokew(addr : integer; val : Word);
function peekw(Addr:Word):Word;

procedure Z80_NMI;
procedure create_cpu;

type
   pair=record
        case boolean of
           false: (l,h:Byte);
           true: (W:Word);
        end;
    quadruple=record
					 case byte of
							0: (b1,b2,b3,b4:Byte);
							1: (w1,w2:Word);
							2: (q:longint);
					 end;

// Main Z80 registers
var
		af, bc, de, hl:pair;
		ix, iy:pair;
		sp, pc:pair;
		ir: Pair;
		rtemp,im   : Byte;
		AF2,BC2,DE2,HL2: Pair; { == AF' BC' DE' HL'}
		iff1, iff2, bit7_r: Byte;
		halt:boolean;
		qtemp:Quadruple;
		ptemp:pair;

	MM: TMemoryMapper;

implementation

function peekb(addr : integer) : Byte;
begin
	Result := Byte(MM.Read(addr));
end;

function peekw(Addr:Word):Word;
begin
 peekw:=(peekb(addr+1) shl 8) or peekb(addr);
end;

procedure pokeb(addr : integer; val : Byte);
begin
	MM.Write(addr, val);
end;

procedure pokew(addr : integer; val:word);
var value:pair absolute val;
begin
    pokeb(addr, value.l); pokeb(addr + 1, value.h);
end;

function inb(port : Word) : byte;
begin
		Result := MM.ReadPort((port and $FF)+port*256);
end;

procedure outb(port : Word; outbyte : byte);
begin
		MM.WritePort((port and $FF)+port*256, outbyte);
end;

var t_state:integer;

{$i z80_procs.inc}
{$i z80_cbops.inc}
{$i z80_edops.inc}
{$i z80_ops.inc}

function nxtpcb: integer;
	var dummy: integer;
begin
	 inc(ir.l);
	 dummy:=peekb(pc.W);
	 inc(pc.w);
	 result := dummy;
end;

function z80_execute:Integer;
begin
	t_state:=0;
	if halt then z80_std[0] else z80_std[nxtpcb];
	Result := t_state;
end;

procedure Z80_NMI;
begin
  iff2:=iff1;
  iff1:=0;
  inc(ir.l);
  push(pc.W);
  pc.W:=102;
  inc(t_state,11);
 end;


procedure Z80Reset;
begin
	iff1:=0;iff2:=0;
				bit7_r:=0;
				halt:=false;
				af.W:=0;af2.W:=0;
	hl.W:=0;hl2.W:=0;
				de.W:=0;de2.W:=0;
				bc.W:=0;bc2.W:=0;
	//ix.W:=$FFFF;iy.W:=$FFFF;
	ix.W:=0;iy.W:=0;

				//im:=1;
				im:=0;
				ir.W:=0;
        sp.W:=0;pc.W:=0;
				t_state:=0;
end;

procedure calc_intable;
var i,j:Byte;
begin
  for i:=0 to 255 do
  begin
        { $ifndef assembler}
        if i=0 then j:=64 else j:=0;
	add8_table[i]:=(i and 168) or (j); (* Just HVC to do! *)
	sub8_table[i]:=(i and 168) or (j) or 2;
	cpsub8_table[i]:=(i and 128) or (j) or 2; (* 5 bits left.. *)
        { $endif}
        in_table[i]:=(i and 168) or (parity[i]);
	in_table[0]:=in_table[0] or 64; (* Don't forget to keep old C flag *)
  end;
end;

procedure create_cpu;
begin
 createcb;createed;create_std;
 calc_intable;
end;

constructor TZ80.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIAddress := CreateInterface(16, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_RW);

	create_cpu;
  Z80Reset;
end;

procedure TZ80.LoadConfig;
begin
	inherited LoadConfig(SD);
	MM := Mapper;
end;


function TZ80.Execute;
begin

	if FReset then begin
		Z80Reset;
		FReset := FALSE;
	end;

	Result := z80_execute;

end;

function TZ80.GetPC;
begin
	Result := Cardinal(pc.w);
end;

{$IFDEF REC_CONTEXT}
function TZ80.GetContextCRC;
var CRC: Word;
		W:Word;
begin
	CRC := 0;
	W := af.w;
	W := W and $FFD7; //1111 1111 1101 0111
	CRC16_update(CRC, @W, 2);
	CRC16_update(CRC, @bc.w, 2);
	CRC16_update(CRC, @de.w, 2);
	CRC16_update(CRC, @hl.w, 2);
	CRC16_update(CRC, @ix.w, 2);
	CRC16_update(CRC, @iy.w, 2);
	CRC16_update(CRC, @sp.w, 2);
	CRC16_update(CRC, @pc.w, 2);
	//CRC16_update(CRC, @ir.l, 1);
	//CRC16_update(CRC, @ir.h, 1);
	CRC16_update(CRC, @im, 1);
	W := af2.w;
	W := W and $FFD7; //1111 1111 1101 0111
	CRC16_update(CRC, @W, 2);
	CRC16_update(CRC, @bc2.w, 2);
	CRC16_update(CRC, @de2.w, 2);
	CRC16_update(CRC, @hl2.w, 2);
	CRC16_update(CRC, @iff1, 1);
	CRC16_update(CRC, @iff2, 1);
	Result := CRC;
end;
{$ENDIF}

function CreateZ80(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TZ80.Create(IM, ConfigDevice);
end;

begin
	RegisterDeviceCreateFunc('z80', @CreateZ80);
end.
