{$A+,B-,D+,E-,F-,I+,L+,N-,O+,R-,S-,V-}
unit tdlzss10;
(*
 * LZHUF.C English version 1.0
 * Based on Japanese version 29-NOV-1988
 * LZSS coded by Haruhiko OKUMURA
 * Adaptive Huffman Coding coded by Haruyasu YOSHIZAKI
 * Edited and translated to English by Kenji RIKITAKE
 * Translated from C to Turbo Pascal by Douglas Webb   2/18/91
 *    Update and bug correction of TP version 4/29/91 (Sorry!!)
 *
 * Modified for Delphi by Panther (http://www.emuverse.ru) in 2009
 * for using with the Teledisk file fomat support library
 * Encoding procedures are removed. You may find them in the
 * original package.
 * Now LZHUnpack doesn't know the length of the output data, functions
 * were changed to get the "end" marker from the input stream.
 * Unfortunately, it gives some unnecessary bytes at the end, but I think
 * it is not important, wteledsk gives them too.
 * Version 0.1 from 15 Jan 2009
 *)

interface

TYPE

	//Integer => SmallInt Converted for Delphi to prevent from unexpected results
  //with its new Integer type
											
	PutBytesProc = PROCEDURE(VAR DTA; NBytes:WORD; VAR Bytes_Put : WORD);
	GetBytesProc = PROCEDURE(VAR DTA; NBytes:WORD; VAR Bytes_Got : WORD);

function LZHUnpack(GetBytes:GetBytesProc; PutBytes: PutBytesProc):Longint;

implementation

CONST
{ LZSS Parameters }
  N		= 4096;	{ Size of string buffer }
  F		= 60;	{ Size of look-ahead buffer }
  THRESHOLD	= 2;
  NUL		= N;	{ End of tree's node  }

{ Huffman coding parameters }
  N_CHAR   =	(256 - THRESHOLD + F);
		{ character code (:= 0..N_CHAR-1) }
  T 	   =	(N_CHAR * 2 - 1);	{ Size of table }
  R 	   =	(T - 1);		{ root position }
  MAX_FREQ =	$8000;
					{ update when cumulative frequency }
					{ reaches to this value }
{
 * Tables FOR encoding/decoding upper 6 bits of
 * sliding dictionary pointer
 }
{ encoder table }
  p_len : Array[0..63] of BYTE =
       ($03, $04, $04, $04, $05, $05, $05, $05,
	$05, $05, $05, $05, $06, $06, $06, $06,
	$06, $06, $06, $06, $06, $06, $06, $06,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$08, $08, $08, $08, $08, $08, $08, $08,
	$08, $08, $08, $08, $08, $08, $08, $08);

  p_code : Array [0..63] OF BYTE =
       ($00, $20, $30, $40, $50, $58, $60, $68,
	$70, $78, $80, $88, $90, $94, $98, $9C,
	$A0, $A4, $A8, $AC, $B0, $B4, $B8, $BC,
	$C0, $C2, $C4, $C6, $C8, $CA, $CC, $CE,
	$D0, $D2, $D4, $D6, $D8, $DA, $DC, $DE,
	$E0, $E2, $E4, $E6, $E8, $EA, $EC, $EE,
	$F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7,
	$F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF);

{ decoder table }
  d_code: Array [0..255] OF BYTE =
       ($00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$01, $01, $01, $01, $01, $01, $01, $01,
	$01, $01, $01, $01, $01, $01, $01, $01,
	$02, $02, $02, $02, $02, $02, $02, $02,
	$02, $02, $02, $02, $02, $02, $02, $02,
	$03, $03, $03, $03, $03, $03, $03, $03,
	$03, $03, $03, $03, $03, $03, $03, $03,
	$04, $04, $04, $04, $04, $04, $04, $04,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$06, $06, $06, $06, $06, $06, $06, $06,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$08, $08, $08, $08, $08, $08, $08, $08,
	$09, $09, $09, $09, $09, $09, $09, $09,
	$0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A,
	$0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B,
	$0C, $0C, $0C, $0C, $0D, $0D, $0D, $0D,
	$0E, $0E, $0E, $0E, $0F, $0F, $0F, $0F,
	$10, $10, $10, $10, $11, $11, $11, $11,
	$12, $12, $12, $12, $13, $13, $13, $13,
	$14, $14, $14, $14, $15, $15, $15, $15,
	$16, $16, $16, $16, $17, $17, $17, $17,
	$18, $18, $19, $19, $1A, $1A, $1B, $1B,
	$1C, $1C, $1D, $1D, $1E, $1E, $1F, $1F,
	$20, $20, $21, $21, $22, $22, $23, $23,
	$24, $24, $25, $25, $26, $26, $27, $27,
	$28, $28, $29, $29, $2A, $2A, $2B, $2B,
	$2C, $2C, $2D, $2D, $2E, $2E, $2F, $2F,
	$30, $31, $32, $33, $34, $35, $36, $37,
	$38, $39, $3A, $3B, $3C, $3D, $3E, $3F);

 d_len: Array[0..255] of BYTE =
       ($03, $03, $03, $03, $03, $03, $03, $03,
	$03, $03, $03, $03, $03, $03, $03, $03,
	$03, $03, $03, $03, $03, $03, $03, $03,
	$03, $03, $03, $03, $03, $03, $03, $03,
	$04, $04, $04, $04, $04, $04, $04, $04,
	$04, $04, $04, $04, $04, $04, $04, $04,
	$04, $04, $04, $04, $04, $04, $04, $04,
	$04, $04, $04, $04, $04, $04, $04, $04,
	$04, $04, $04, $04, $04, $04, $04, $04,
	$04, $04, $04, $04, $04, $04, $04, $04,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$05, $05, $05, $05, $05, $05, $05, $05,
	$06, $06, $06, $06, $06, $06, $06, $06,
	$06, $06, $06, $06, $06, $06, $06, $06,
	$06, $06, $06, $06, $06, $06, $06, $06,
	$06, $06, $06, $06, $06, $06, $06, $06,
	$06, $06, $06, $06, $06, $06, $06, $06,
	$06, $06, $06, $06, $06, $06, $06, $06,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$07, $07, $07, $07, $07, $07, $07, $07,
	$08, $08, $08, $08, $08, $08, $08, $08,
	$08, $08, $08, $08, $08, $08, $08, $08);

var
	getbuf : WORD = 0;
  getlen : BYTE = 0;
  putlen : BYTE = 0;
  putbuf : WORD = 0;
  textsize : longint = 0;
  codesize : longINT = 0;
  printcount : longint = 0;
  match_position : SmallInt = 0;
  match_length : SmallInt = 0;


TYPE
  Freqtype = Array[0..T] OF WORD; 
  FreqPtr = ^freqtype;
  PntrType = Array[0..PRED(T+N_Char)] OF SmallInt;
  pntrPtr = ^pntrType;
  SonType = Array[0..PRED(T)] OF SmallInt;
  SonPtr = ^SonType;


  TextBufType = Array[0..N+F-2] OF BYTE;
  TBufPtr = ^TextBufType;
  WordRay = Array[0..N] OF SmallInt;
  WordRayPtr = ^WordRay;
  BWordRay = Array[0..N+256] OF SmallInt;
  BWordRayPtr = ^BWordRay;

VAR
  text_buf : TBufPtr;
  lson,dad : WordRayPtr;
  rson : BWordRayPtr;
  freq : FreqPtr;	{ cumulative freq table }

{
 * pointing parent nodes.
 * area [T..(T + N_CHAR - 1)] are pointers FOR leaves
 }
  prnt : PntrPtr;

{ pointing children nodes (son[], son[] + 1)}
  son : SonPtr;

Procedure InitTree;  { Initializing tree }
VAR
	i : SmallInt;
BEGIN
	FOR i := N + 1 TO N + 256 DO
	rson^[i] := NUL;			{ root }
	FOR i := 0 TO N DO
	dad^[i] := NUL;			{ node }
END;

{ Huffman coding parameters }

Function GetBit(GetBytes:GetBytesProc): SmallInt;	{ get one bit }
VAR
	i: BYTE;
	i2 : SmallInt;
	res : Word;
BEGIN
	Result := -1;												//by default it fails
	WHILE (getlen <= 8) DO
		BEGIN
			GetBytes(i,1,res);
			if res = 0 then exit;						//reached the end of data
			i2 := i;
			getbuf := getbuf OR (i2 SHL (8 - getlen));
			INC(getlen,8);
		END;
	i2 := getbuf;
	getbuf := getbuf SHL 1;
	DEC(getlen);
	getbit := SmallInt((i2 < 0));
END;

Function GetByte(GetBytes:GetBytesProc): SmallInt;	{ get a byte }
VAR
  j : BYTE;
	i,result_ : WORD;
BEGIN
	Result := -1;															//by default it fails
	WHILE (getlen <= 8) DO
		BEGIN
			GetBytes(j,1,result_);
			if result_ = 0 then exit;							//reached the end of data
			i := j;
			getbuf := getbuf OR (i SHL (8 - getlen));
      INC(getlen,8);
    END;
  i := getbuf;
  getbuf := getbuf SHL 8;
  DEC(getlen,8);
  getbyte := SmallInt(i SHR 8);
END;

{ initialize freq tree }

Procedure StartHuff;
VAR
  i, j : SmallInt;
BEGIN
  FOR i := 0 to PRED(N_CHAR) DO
    BEGIN
      freq^[i] := 1;
      son^[i] := i + T;
      prnt^[i + T] := i;
    END;
  i := 0;
  j := N_CHAR;
  WHILE (j <= R) DO
    BEGIN
      freq^[j] := freq^[i] + freq^[i + 1];
      son^[j] := i;
      prnt^[i] := j;
      prnt^[i + 1] := j;
      INC(i,2);
      INC(j);
    END;
  freq^[T] := $ffff;
  prnt^[R] := 0;
END;

{ reconstruct freq tree }

PROCEDURE reconst;
VAR
 i, j, k, tmp : SmallInt;
 f, l : WORD;
BEGIN
 { halven cumulative freq FOR leaf nodes }
  j := 0;
  FOR i := 0 to PRED(T) DO
    BEGIN
      IF (son^[i] >= T) THEN
        BEGIN
	  freq^[j] := SUCC(freq^[i]) DIV 2;    {@@ Bug Fix MOD -> DIV @@}
	  son^[j] := son^[i];
	  INC(j);
	END;
    END;
  { make a tree : first, connect children nodes }
  i := 0;
  j := N_CHAR;
  WHILE (j < T) DO
    BEGIN
      k := SUCC(i);
      f := freq^[i] + freq^[k];
      freq^[j] := f;
      k := PRED(j);
      WHILE f < freq^[k] DO
        DEC(K);
      INC(k);
      l := (j - k) SHL 1;
      tmp := SUCC(k);
      move(freq^[k], freq^[tmp], l);
      freq^[k] := f;
      move(son^[k], son^[tmp], l);
      son^[k] := i;
      INC(i,2);
      INC(j);
    END;
    	{ connect parent nodes }
  FOR i := 0 to PRED(T) DO
    BEGIN
      k := son^[i];
      IF (k >= T) THEN
        BEGIN
	  prnt^[k] := i;
	END
      ELSE
        BEGIN
	  prnt^[k] := i;
          prnt^[SUCC(k)] := i;
	END;
    END;
END;

{ update freq tree }

Procedure update(c : SmallInt);
VAR
  i, j, k, l : SmallInt;
BEGIN
  IF (freq^[R] = MAX_FREQ) THEN
    BEGIN
      reconst;
    END;
  c := prnt^[c + T];
  REPEAT
    INC(freq^[c]);
    k := freq^[c];

	{ swap nodes to keep the tree freq-ordered }
   l := SUCC(C);
   IF (k > freq^[l]) THEN
     BEGIN
       WHILE (k > freq^[l]) DO
         INC(l);
       DEC(l);
       freq^[c] := freq^[l];
       freq^[l] := k;

       i := son^[c];
       prnt^[i] := l;
       IF (i < T) THEN prnt^[SUCC(i)] := l;

       j := son^[l];
       son^[l] := i;

       prnt^[j] := c;
       IF (j < T) THEN prnt^[SUCC(j)] := c;
       son^[c] := j;

       c := l;
     END;
   c := prnt^[c];
 UNTIL (c = 0);	{ REPEAT it until reaching the root }
END;

FUNCTION DecodeChar(GetBytes:GetBytesProc): SmallInt;
VAR
	c : WORD;
	ret: SmallInt;
BEGIN
	Result := -1; 								//by default it fails
	c := son^[R];
		{
		 * start searching tree from the root to leaves.
		 * choose node #(son[]) IF input bit = 0
		 * ELSE choose #(son[]+1) (input bit = 1)
		}
	WHILE (c < T) DO
		BEGIN
			ret := GetBit(GetBytes);
			if ret < 0 then exit;			//reached the end of data
			c := c + ret;
			c := son^[c];
    END;
  c := c - T;
  update(c);
  Decodechar := SmallInt(c);
END;

Function DecodePosition(GetBytes:GetBytesProc) : SmallInt;
VAR
	i, j, c : SmallInt;
	ret: SmallInt;
BEGIN
	Result := -1; 								//by default it fails
	{ decode upper 6 bits from given table }
	i := GetByte(GetBytes);
	if i<0 then exit;  						//reached the end of data
	c := WORD(d_code[i] SHL 6);
	j := d_len[i];

	{ input lower 6 bits directly }
	DEC(j,2);
	While j <> 0 DO
		BEGIN
			ret := GetBit(GetBytes);
			if ret < 0 then exit;    //reached the end of data
			i := (i SHL 1) + ret;
			DEC(J);
    END;
  DecodePosition := c OR i AND $3f;
END;

{ Compression }

Procedure InitLZH;
BEGIN
  getbuf := 0;
  getlen := 0;
  putlen := 0;
  putbuf := 0;
  textsize := 0;
  codesize := 0;
  printcount := 0;
  match_position := 0;
  match_length := 0;
  New(lson);
  New(dad);
  New(rson);
  New(text_buf);
  New(freq);
  New(prnt);
  New(son);
END;

Procedure EndLZH;
BEGIN
  Dispose(son);
  Dispose(prnt);
  Dispose(freq);
  Dispose(text_buf);
  Dispose(rson);
  Dispose(dad);
  Dispose(lson);
END;

function LZHUnpack(GetBytes:GetBytesProc; PutBytes: PutBytesProc):Longint;
VAR
  c, i, j, k, r : SmallInt;
  c2 : Byte;
  count : Longint;
	Put : Word;
	pos: SmallInt;
BEGIN
  InitLZH;
  StartHuff;
  r := N - F;
  FillChar(text_buf^[0],r,' ');
  Count := 0;
	While true DO BEGIN
			if count>734493 then begin
				Inc(Count);
				Dec(Count);
			end;
			c := DecodeChar(GetBytes);
			if c<0 then break;
			IF (c < 256) THEN BEGIN
					c2 := Lo(c);
					PutBytes(c2,1,Put);
					text_buf^[r] := c;
					INC(r);
					r := r AND PRED(N);
					INC(count);
					//write('+');
			END ELSE BEGIN
					pos := DecodePosition(GetBytes);
					if pos<0 then break;
					i := (r - SUCC(pos)) AND PRED(N);
					j := c - 255 + THRESHOLD;
					FOR k := 0 TO PRED(j) DO BEGIN
							c := text_buf^[(i + k) AND PRED(N)];
							c2 := Lo(c);
							PutBytes(c2,1,Put);
							text_buf^[r] := c;
							INC(r);
							r := r AND PRED(N);
							INC(count);
					END;
					//write('|');
			END;
    END;
  EndLZH;
	Result := count;
END;

END.
