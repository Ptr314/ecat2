var cbdis: Shortint;
    addr: Word;
    cb: Array[0..255] of procedure; {Sprung-Tabelle}

procedure rlc_b;
begin
af.l:=rlcr_f[bc.h];
bc.h:=rlcr_a[bc.h];
inc(t_state,8);
end;

procedure rlc_c;
begin
af.l:=rlcr_f[bc.l];
bc.l:=rlcr_a[bc.l];
inc(t_state,8);
end;

procedure rlc_d;
begin
af.l:=rlcr_f[de.h];
de.h:=rlcr_a[de.h];
inc(t_state,8);
end;

procedure rlc_e;
begin
af.l:=rlcr_f[de.l];
de.l:=rlcr_a[de.l];
inc(t_state,8);
end;

procedure rlc_h;
begin
af.l:=rlcr_f[hl.h];
hl.h:=rlcr_a[hl.h];
inc(t_state,8);
end;

procedure rlc_l;
begin
af.l:=rlcr_f[hl.l];
hl.l:=rlcr_a[hl.l];
inc(t_state,8);
end;

procedure rlc;
var btemp:Byte;
begin
      btemp:=peekb(ADDR);
      af.l:=rlcr_f[btemp];
      pokeb(ADDR,rlcr_a[btemp]);
      inc(t_state,23);
end;

procedure rlc_a;
begin
af.l:=rlcr_f[af.h];
af.h:=rlcr_a[af.h];
inc(t_state,8);
end;

procedure rrc_b;
begin
af.l:=rrcr_f[bc.h];
bc.h:=rrcr_a[bc.h];
inc(t_state,8);
end;

procedure rrc_c;
begin
af.l:=rrcr_f[bc.l];
bc.l:=rrcr_a[bc.l];
inc(t_state,8);
end;

procedure rrc_d;
begin
af.l:=rrcr_f[de.h];
de.h:=rrcr_a[de.h];
inc(t_state,8);
end;

procedure rrc_e;
begin
af.l:=rrcr_f[de.l];
de.l:=rrcr_a[de.l];
inc(t_state,8);
end;

procedure rrc_h;
begin
af.l:=rrcr_f[hl.h];
hl.h:=rrcr_a[hl.h];
inc(t_state,8);
end;

procedure rrc_l;
begin
af.l:=rrcr_f[hl.l];
hl.l:=rrcr_a[hl.l];
inc(t_state,8);
end;

procedure rrc_a;
begin
af.l:=rrcr_f[af.h];
af.h:=rrcr_a[af.h];
inc(t_state,8);
end;

procedure rrc;
var btemp:Byte;
begin
btemp:=peekb(ADDR);
af.l:=rrcr_f[btemp];
pokeb(ADDR,rrcr_a[btemp]);
inc(t_state,15);
end;

procedure rl_b;
begin
if af.l and 1=0 then
begin
af.l:=rlr_f[0][bc.h];
bc.h:=rlr_a[0][bc.h];
end
else
begin
af.l:=rlr_f[1][bc.h];
bc.h:=rlr_a[1][bc.h];
end;
inc(t_state,8);
end;

procedure rl_c;
begin
if af.l and 1=0 then
begin
af.l:=rlr_f[0][bc.l];
bc.l:=rlr_a[0][bc.l];
end
else
begin
af.l:=rlr_f[1][bc.l];
bc.l:=rlr_a[1][bc.l];
end;
inc(t_state,8);
end;

procedure rl_d;
begin
if af.l and 1=0 then
begin
af.l:=rlr_f[0][de.h];
de.h:=rlr_a[0][de.h];
end
else
begin
af.l:=rlr_f[1][de.h];
de.h:=rlr_a[1][de.h];
end;
inc(t_state,8);
end;

procedure rl_e;
begin
if af.l and 1=0 then
begin
af.l:=rlr_f[0][de.l];
de.l:=rlr_a[0][de.l];
end
else
begin
af.l:=rlr_f[1][de.l];
de.l:=rlr_a[1][de.l];
end;
inc(t_state,8);
end;

procedure rl_h;
begin
if af.l and 1=0 then
begin
af.l:=rlr_f[0][hl.h];
hl.h:=rlr_a[0][hl.h];
end
else
begin
af.l:=rlr_f[1][hl.h];
hl.h:=rlr_a[1][hl.h];
end;
inc(t_state,8);
end;

procedure rl_l;
begin
if af.l and 1=0 then
begin
af.l:=rlr_f[0][hl.l];
hl.l:=rlr_a[0][hl.l];
end
else
begin
af.l:=rlr_f[1][hl.l];
hl.l:=rlr_a[1][hl.l];
end;
inc(t_state,8);
end;

procedure rl;
var btemp:Byte;
begin
if af.l and 1=0 then
 begin
  btemp:=peekb(Addr);
  af.l:=rlr_f[0][btemp];
  pokeb(Addr,rlr_a[0][btemp]);
 end
else
 begin
  btemp:=peekb(Addr);
  af.l:=rlr_f[1][btemp];
  pokeb(Addr,rlr_a[1][btemp]);
 end;
 inc(t_state,15);
end;

procedure rl_a;
begin
if af.l and 1=0 then
begin
af.l:=rlr_f[0][af.h];
af.h:=rlr_a[0][af.h];
end
else
begin
af.l:=rlr_f[1][af.h];
af.h:=rlr_a[1][af.h];
end;
inc(t_state,8);
end;

procedure rr_b;
begin
if af.l and 1=0 then
begin
af.l:=rrr_f[0][bc.h];
bc.h:=rrr_a[0][bc.h];
end
else
begin
af.l:=rrr_f[1][bc.h];
bc.h:=rrr_a[1][bc.h];
end;
inc(t_state,8);
end;

procedure rr_c;
begin
if af.l and 1=0 then
begin
af.l:=rrr_f[0][bc.l];
bc.l:=rrr_a[0][bc.l];
end
else
begin
af.l:=rrr_f[1][bc.l];
bc.l:=rrr_a[1][bc.l];
end;
inc(t_state,8);
end;

procedure rr_d;
begin
if af.l and 1=0 then
begin
af.l:=rrr_f[0][de.h];
de.h:=rrr_a[0][de.h];
end
else
begin
af.l:=rrr_f[1][de.h];
de.h:=rrr_a[1][de.h];
end;
inc(t_state,8);
end;

procedure rr_e;
begin
if af.l and 1=0 then
begin
af.l:=rrr_f[0][de.l];
de.l:=rrr_a[0][de.l];
end
else
begin
af.l:=rrr_f[1][de.l];
de.l:=rrr_a[1][de.l];
end;
inc(t_state,8);
end;

procedure rr_h;
begin
if af.l and 1=0 then
begin
af.l:=rrr_f[0][hl.h];
hl.h:=rrr_a[0][hl.h];
end
else
begin
af.l:=rrr_f[1][hl.h];
hl.h:=rrr_a[1][hl.h];
end;
inc(t_state,8);
end;

procedure rr_l;
begin
if af.l and 1=0 then
begin
af.l:=rrr_f[0][hl.l];
hl.l:=rrr_a[0][hl.l];
end
else
begin
af.l:=rrr_f[1][hl.l];
hl.l:=rrr_a[1][hl.l];
end;
inc(t_state,8);
end;

procedure rr;
var btemp:Byte;
begin
if af.l and 1=0 then
begin
btemp:=peekb(Addr);
af.l:=rrr_f[0][btemp];
pokeb(Addr,rrr_a[0][btemp]);
end
else
begin
btemp:=peekb(Addr);
af.l:=rrr_f[1][btemp];
pokeb(Addr,rrr_a[1][btemp]);
end;
inc(t_state,15);
end;

procedure rr_a;
begin
if af.l and 1=0 then
begin
af.l:=rrr_f[0][af.h];
af.h:=rrr_a[0][af.h];
end
else
begin
af.l:=rrr_f[1][af.h];
af.h:=rrr_a[1][af.h];
end;
inc(t_state,8);
end;

procedure sla_b;
begin
af.l:=sla_f[bc.h];
bc.h:=sla_a[bc.h];
inc(t_state,8);
end;

procedure sla_c;
begin
af.l:=sla_f[bc.l];
bc.l:=sla_a[bc.l];
inc(t_state,8);
end;

procedure sla_d;
begin
af.l:=sla_f[de.h];
de.h:=sla_a[de.h];
inc(t_state,8);
end;

procedure sla_e;
begin
af.l:=sla_f[de.l];
de.l:=sla_a[de.l];
inc(t_state,8);
end;

procedure sla_h;
begin
af.l:=sla_f[hl.h];
hl.h:=sla_a[hl.h];
inc(t_state,8);
end;

procedure sla_l;
begin
af.l:=sla_f[hl.l];
hl.l:=sla_a[hl.l];
inc(t_state,8);
end;

procedure sla;
var btemp:Byte;
begin
btemp:=peekb(Addr);
af.l:=sla_f[btemp];
pokeb(Addr,sla_a[btemp]);
inc(t_state,15);
end;

procedure CBsla_a;
begin
af.l:=sla_f[af.h];
af.h:=sla_a[af.h];
inc(t_state,8);
end;

procedure sra_b;
begin
af.l:=sra_f[bc.h];
bc.h:=sra_a[bc.h];
inc(t_state,8);
end;

procedure sra_c;
begin
af.l:=sra_f[bc.l];
bc.l:=sra_a[bc.l];
inc(t_state,8);
end;

procedure sra_d;
begin
af.l:=sra_f[de.h];
de.h:=sra_a[de.h];
inc(t_state,8);
end;

procedure sra_e;
begin
af.l:=sra_f[de.l];
de.l:=sra_a[de.l];
inc(t_state,8);
end;

procedure sra_h;
begin
af.l:=sra_f[hl.h];
hl.h:=sra_a[hl.h];
inc(t_state,8);
end;

procedure sra_l;
begin
af.l:=sra_f[hl.l];
hl.l:=sra_a[hl.l];
inc(t_state,8);
end;

procedure sra;
var btemp:Byte;
begin
btemp:=peekb(Addr);
af.l:=sra_f[btemp];
pokeb(Addr,sra_a[btemp]);
inc(t_state,15);
end;

procedure CBsra_a;
begin
af.l:=sra_f[af.h];
af.h:=sra_a[af.h];
inc(t_state,8);
end;

procedure sll_b;
begin
af.l:=sll_f[bc.h];
bc.h:=sll_a[bc.h];
inc(t_state,8);
end;

procedure sll_c;
begin
af.l:=sll_f[bc.l];
bc.l:=sll_a[bc.l];
inc(t_state,8);
end;

procedure sll_d;
begin
af.l:=sll_f[de.h];
de.h:=sll_a[de.h];
inc(t_state,8);
end;

procedure sll_e;
begin
af.l:=sll_f[de.l];
de.l:=sll_a[de.l];
inc(t_state,8);
end;

procedure sll_h;
begin
af.l:=sll_f[hl.h];
hl.h:=sll_a[hl.h];
inc(t_state,8);
end;

procedure sll_l;
begin
af.l:=sll_f[hl.l];
hl.l:=sll_a[hl.l];
inc(t_state,8);
end;

procedure sll;
var btemp:Byte;
begin
        btemp:=peekb(Addr);
af.l:=sll_f[btemp];
pokeb(Addr,sll_a[btemp]);
inc(t_state,15);
end;

procedure CBsll_a;
begin
af.l:=sll_f[af.h];
af.h:=sll_a[af.h];
inc(t_state,8);
end;

procedure srl_b;
begin
af.l:=srl_f[bc.h];
bc.h:=srl_a[bc.h];
inc(t_state,8);
end;

procedure srl_c;
begin
af.l:=srl_f[bc.l];
bc.l:=srl_a[bc.l];
inc(t_state,8);
end;

procedure srl_d;
begin
af.l:=srl_f[de.h];
de.h:=srl_a[de.h];
inc(t_state,8);
end;

procedure srl_e;
begin
af.l:=srl_f[de.l];
de.l:=srl_a[de.l];
inc(t_state,8);
end;

procedure srl_h;
begin
af.l:=srl_f[hl.h];
hl.h:=srl_a[hl.h];
inc(t_state,8);
end;

procedure srl_l;
begin
af.l:=srl_f[hl.l];
hl.l:=srl_a[hl.l];
inc(t_state,8);
end;

procedure srl;
var btemp:Byte;
begin
        btemp:=peekb(Addr);
af.l:=srl_f[btemp];
pokeb(Addr,srl_a[btemp]);
inc(t_state,15);
end;

procedure CBsrl_a;
begin
af.l:=srl_f[af.h];
af.h:=srl_a[af.h];
inc(t_state,8);
end;

procedure bit0_b;
begin
af.l:=bit_f0[bc.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit0_c;
begin
af.l:=bit_f0[bc.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit0_d;
begin
af.l:=bit_f0[de.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit0_e;
begin
af.l:=bit_f0[de.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit0_h;
begin
af.l:=bit_f0[hl.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit0_l;
begin
af.l:=bit_f0[hl.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit0;
begin
af.l:=bit_f0[peekb(Addr)] or (af.l and 1);
inc(t_state,12);
end;

procedure bit0_a;
begin
af.l:=bit_f0[af.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit1_b;
begin
af.l:=bit_f1[bc.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit1_c;
begin
af.l:=bit_f1[bc.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit1_d;
begin
af.l:=bit_f1[de.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit1_e;
begin
af.l:=bit_f1[de.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit1_h;
begin
af.l:=bit_f1[hl.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit1_l;
begin
af.l:=bit_f1[hl.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit1;
begin
af.l:=bit_f1[peekb(Addr)] or (af.l and 1);
inc(t_state,12);
end;

procedure bit1_a;
begin
af.l:=bit_f1[af.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit2_b;
begin
af.l:=bit_f2[bc.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit2_c;
begin
af.l:=bit_f2[bc.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit2_d;
begin
af.l:=bit_f2[de.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit2_e;
begin
af.l:=bit_f2[de.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit2_h;
begin
af.l:=bit_f2[hl.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit2_l;
begin
af.l:=bit_f2[hl.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit2;
begin
af.l:=bit_f2[peekb(Addr)] or (af.l and 1);
inc(t_state,12);
end;

procedure bit2_a;
begin
af.l:=bit_f2[af.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit3_b;
begin
af.l:=bit_f3[bc.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit3_c;
begin
af.l:=bit_f3[bc.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit3_d;
begin
af.l:=bit_f3[de.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit3_e;
begin
af.l:=bit_f3[de.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit3_h;
begin
af.l:=bit_f3[hl.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit3_l;
begin
af.l:=bit_f3[hl.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit3;
begin
af.l:=bit_f3[peekb(Addr)] or (af.l and 1);
inc(t_state,12);
end;

procedure bit3_a;
begin
af.l:=bit_f3[af.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit4_b;
begin
af.l:=bit_f4[bc.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit4_c;
begin
af.l:=bit_f4[bc.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit4_d;
begin
af.l:=bit_f4[de.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit4_e;
begin
af.l:=bit_f4[de.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit4_h;
begin
af.l:=bit_f4[hl.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit4_l;
begin
af.l:=bit_f4[hl.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit4;
begin
af.l:=bit_f4[peekb(Addr)] or (af.l and 1);
inc(t_state,12);
end;

procedure bit4_a;
begin
af.l:=bit_f4[af.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit5_b;
begin
af.l:=bit_f5[bc.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit5_c;
begin
af.l:=bit_f5[bc.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit5_d;
begin
af.l:=bit_f5[de.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit5_e;
begin
af.l:=bit_f5[de.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit5_h;
begin
af.l:=bit_f5[hl.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit5_l;
begin
af.l:=bit_f5[hl.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit5;
begin
af.l:=bit_f5[peekb(Addr)] or (af.l and 1);
inc(t_state,12);
end;

procedure bit5_a;
begin
af.l:=bit_f5[af.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit6_b;
begin
af.l:=bit_f6[bc.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit6_c;
begin
af.l:=bit_f6[bc.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit6_d;
begin
af.l:=bit_f6[de.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit6_e;
begin
af.l:=bit_f6[de.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit6_h;
begin
af.l:=bit_f6[hl.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit6_l;
begin
af.l:=bit_f6[hl.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit6;
begin
af.l:=bit_f6[peekb(Addr)] or (af.l and 1);
inc(t_state,12);
end;

procedure bit6_a;
begin
af.l:=bit_f6[af.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit7_b;
begin
af.l:=bit_f7[bc.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit7_c;
begin
af.l:=bit_f7[bc.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit7_d;
begin
af.l:=bit_f7[de.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit7_e;
begin
af.l:=bit_f7[de.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit7_h;
begin
af.l:=bit_f7[hl.h] or (af.l and 1);
inc(t_state,8);
end;

procedure bit7_l;
begin
af.l:=bit_f7[hl.l] or (af.l and 1);
inc(t_state,8);
end;

procedure bit7;
begin
af.l:=bit_f7[peekb(Addr)] or (af.l and 1);
inc(t_state,12);
end;

procedure bit7_a;
begin
af.l:=bit_f7[af.h] or (af.l and 1);
inc(t_state,8);
end;

procedure res0_b;
begin
bc.h:=bc.h and 254;
inc(t_state,8);
end;

procedure res0_c;
begin
bc.l:=bc.l and 254;
inc(t_state,8);
end;

procedure res0_d;
begin
de.h:=de.h and 254;
inc(t_state,8);
end;

procedure res0_e;
begin
de.l:=de.l and 254;
inc(t_state,8);
end;

procedure res0_h;
begin
hl.h:=hl.h and 254;
inc(t_state,8);
end;

procedure res0_l;
begin
hl.l:=hl.l and 254;
inc(t_state,8);
end;

procedure res0;
begin
pokeb(Addr,peekb(Addr) and 254);
inc(t_state,15);
end;

procedure res0_a;
begin
af.h:=af.h and 254;
inc(t_state,8);
end;

procedure res1_b;
begin
bc.h:=bc.h and 253;
inc(t_state,8);
end;

procedure res1_c;
begin
bc.l:=bc.l and 253;
inc(t_state,8);
end;

procedure res1_d;
begin
de.h:=de.h and 253;
inc(t_state,8);
end;

procedure res1_e;
begin
de.l:=de.l and 253;
inc(t_state,8);
end;

procedure res1_h;
begin
hl.h:=hl.h and 253;
inc(t_state,8);
end;

procedure res1_l;
begin
hl.l:=hl.l and 253;
inc(t_state,8);
end;

procedure res1;
begin
pokeb(Addr,peekb(Addr) and 253);
inc(t_state,15);
end;

procedure res1_a;
begin
af.h:=af.h and 253;
inc(t_state,8);
end;

procedure res2_b;
begin
bc.h:=bc.h and 251;
inc(t_state,8);
end;

procedure res2_c;
begin
bc.l:=bc.l and 251;
inc(t_state,8);
end;

procedure res2_d;
begin
de.h:=de.h and 251;
inc(t_state,8);
end;

procedure res2_e;
begin
de.l:=de.l and 251;
inc(t_state,8);
end;

procedure res2_h;
begin
hl.h:=hl.h and 251;
inc(t_state,8);
end;

procedure res2_l;
begin
hl.l:=hl.l and 251;
inc(t_state,8);
end;

procedure res2;
begin
pokeb(Addr,peekb(Addr) and 251);
inc(t_state,15);
end;

procedure res2_a;
begin
af.h:=af.h and 251;
inc(t_state,8);
end;

procedure res3_b;
begin
bc.h:=bc.h and 247;
inc(t_state,8);
end;

procedure res3_c;
begin
bc.l:=bc.l and 247;
inc(t_state,8);
end;

procedure res3_d;
begin
de.h:=de.h and 247;
inc(t_state,8);
end;

procedure res3_e;
begin
de.l:=de.l and 247;
inc(t_state,8);
end;

procedure res3_h;
begin
hl.h:=hl.h and 247;
inc(t_state,8);
end;

procedure res3_l;
begin
hl.l:=hl.l and 247;
inc(t_state,8);
end;

procedure res3;
begin
pokeb(Addr,peekb(Addr) and 247);
inc(t_state,15);
end;

procedure res3_a;
begin
af.h:=af.h and 247;
inc(t_state,8);
end;

procedure res4_b;
begin
bc.h:=bc.h and 239;
inc(t_state,8);
end;

procedure res4_c;
begin
bc.l:=bc.l and 239;
inc(t_state,8);
end;

procedure res4_d;
begin
de.h:=de.h and 239;
inc(t_state,8);
end;

procedure res4_e;
begin
de.l:=de.l and 239;
inc(t_state,8);
end;

procedure res4_h;
begin
hl.h:=hl.h and 239;
inc(t_state,8);
end;

procedure res4_l;
begin
hl.l:=hl.l and 239;
inc(t_state,8);
end;

procedure res4;
begin
pokeb(Addr,peekb(Addr) and 239);
inc(t_state,15);
end;

procedure res4_a;
begin
af.h:=af.h and 239;
inc(t_state,8);
end;

procedure res5_b;
begin
bc.h:=bc.h and 223;
inc(t_state,8);
end;

procedure res5_c;
begin
bc.l:=bc.l and 223;
inc(t_state,8);
end;

procedure res5_d;
begin
de.h:=de.h and 223;
inc(t_state,8);
end;

procedure res5_e;
begin
de.l:=de.l and 223;
inc(t_state,8);
end;

procedure res5_h;
begin
hl.h:=hl.h and 223;
inc(t_state,8);
end;

procedure res5_l;
begin
hl.l:=hl.l and 223;
inc(t_state,8);
end;

procedure res5;
begin
pokeb(Addr,peekb(Addr) and 223);
inc(t_state,15);
end;

procedure res5_a;
begin
af.h:=af.h and 223;
inc(t_state,8);
end;

procedure res6_b;
begin
bc.h:=bc.h and 191;
inc(t_state,8);
end;

procedure res6_c;
begin
bc.l:=bc.l and 191;
inc(t_state,8);
end;

procedure res6_d;
begin
de.h:=de.h and 191;
inc(t_state,8);
end;

procedure res6_e;
begin
de.l:=de.l and 191;
inc(t_state,8);
end;

procedure res6_h;
begin
hl.h:=hl.h and 191;
inc(t_state,8);
end;

procedure res6_l;
begin
hl.l:=hl.l and 191;
inc(t_state,8);
end;

procedure res6;
begin
pokeb(Addr,peekb(Addr) and 191);
inc(t_state,15);
end;

procedure res6_a;
begin
af.h:=af.h and 191;
inc(t_state,8);
end;

procedure res7_b;
begin
bc.h:=bc.h and 127;
inc(t_state,8);
end;

procedure res7_c;
begin
bc.l:=bc.l and 127;
inc(t_state,8);
end;

procedure res7_d;
begin
de.h:=de.h and 127;
inc(t_state,8);
end;

procedure res7_e;
begin
de.l:=de.l and 127;
inc(t_state,8);
end;

procedure res7_h;
begin
hl.h:=hl.h and 127;
inc(t_state,8);
end;

procedure res7_l;
begin
hl.l:=hl.l and 127;
inc(t_state,8);
end;

procedure res7;
begin
pokeb(Addr,peekb(Addr) and 127);
inc(t_state,15);
end;

procedure res7_a;
begin
af.h:=af.h and 127;
inc(t_state,8);
end;

procedure set0_b;
begin
bc.h:=bc.h or 1;
inc(t_state,8);
end;

procedure set0_c;
begin
bc.l:=bc.l or 1;
inc(t_state,8);
end;

procedure set0_d;
begin
de.h:=de.h or 1;
inc(t_state,8);
end;

procedure set0_e;
begin
de.l:=de.l or 1;
inc(t_state,8);
end;

procedure set0_h;
begin
hl.h:=hl.h or 1;
inc(t_state,8);
end;

procedure set0_l;
begin
hl.l:=hl.l or 1;
inc(t_state,8);
end;

procedure set0;
begin
pokeb(Addr,peekb(Addr) or 1);
inc(t_state,15);
end;

procedure set0_a;
begin
af.h:=af.h or 1;
inc(t_state,8);
end;

procedure set1_b;
begin
bc.h:=bc.h or 2;
inc(t_state,8);
end;

procedure set1_c;
begin
bc.l:=bc.l or 2;
inc(t_state,8);
end;

procedure set1_d;
begin
de.h:=de.h or 2;
inc(t_state,8);
end;

procedure set1_e;
begin
de.l:=de.l or 2;
inc(t_state,8);
end;

procedure set1_h;
begin
hl.h:=hl.h or 2;
inc(t_state,8);
end;

procedure set1_l;
begin
hl.l:=hl.l or 2;
inc(t_state,8);
end;

procedure set1;
begin
pokeb(Addr,peekb(Addr) or 2);
inc(t_state,15);
end;

procedure set1_a;
begin
af.h:=af.h or 2;
inc(t_state,8);
end;

procedure set2_b;
begin
bc.h:=bc.h or 4;
inc(t_state,8);
end;

procedure set2_c;
begin
bc.l:=bc.l or 4;
inc(t_state,8);
end;

procedure set2_d;
begin
de.h:=de.h or 4;
inc(t_state,8);
end;

procedure set2_e;
begin
de.l:=de.l or 4;
inc(t_state,8);
end;

procedure set2_h;
begin
hl.h:=hl.h or 4;
inc(t_state,8);
end;

procedure set2_l;
begin
hl.l:=hl.l or 4;
inc(t_state,8);
end;

procedure set2;
begin
pokeb(Addr,peekb(Addr) or 4);
inc(t_state,15);
end;

procedure set2_a;
begin
af.h:=af.h or 4;
inc(t_state,8);
end;

procedure set3_b;
begin
bc.h:=bc.h or 8;
inc(t_state,8);
end;

procedure set3_c;
begin
bc.l:=bc.l or 8;
inc(t_state,8);
end;

procedure set3_d;
begin
de.h:=de.h or 8;
inc(t_state,8);
end;

procedure set3_e;
begin
de.l:=de.l or 8;
inc(t_state,8);
end;

procedure set3_h;
begin
hl.h:=hl.h or 8;
inc(t_state,8);
end;

procedure set3_l;
begin
hl.l:=hl.l or 8;
inc(t_state,8);
end;

procedure set3;
begin
pokeb(Addr,peekb(Addr) or 8);
inc(t_state,15);
end;

procedure set3_a;
begin
af.h:=af.h or 8;
inc(t_state,8);
end;

procedure set4_b;
begin
bc.h:=bc.h or 16;
inc(t_state,8);
end;

procedure set4_c;
begin
bc.l:=bc.l or 16;
inc(t_state,8);
end;

procedure set4_d;
begin
de.h:=de.h or 16;
inc(t_state,8);
end;

procedure set4_e;
begin
de.l:=de.l or 16;
inc(t_state,8);
end;

procedure set4_h;
begin
hl.h:=hl.h or 16;
inc(t_state,8);
end;

procedure set4_l;
begin
hl.l:=hl.l or 16;
inc(t_state,8);
end;

procedure set4;
begin
pokeb(Addr,peekb(Addr) or 16);
inc(t_state,15);
end;

procedure set4_a;
begin
af.h:=af.h or 16;
inc(t_state,8);
end;

procedure set5_b;
begin
bc.h:=bc.h or 32;
inc(t_state,8);
end;

procedure set5_c;
begin
bc.l:=bc.l or 32;
inc(t_state,8);
end;

procedure set5_d;
begin
de.h:=de.h or 32;
inc(t_state,8);
end;

procedure set5_e;
begin
de.l:=de.l or 32;
inc(t_state,8);
end;

procedure set5_h;
begin
hl.h:=hl.h or 32;
inc(t_state,8);
end;

procedure set5_l;
begin
hl.l:=hl.l or 32;
inc(t_state,8);
end;

procedure set5;
begin
pokeb(Addr,peekb(Addr) or 32);
inc(t_state,15);
end;

procedure set5_a;
begin
af.h:=af.h or 32;
inc(t_state,8);
end;

procedure set6_b;
begin
bc.h:=bc.h or 64;
inc(t_state,8);
end;

procedure set6_c;
begin
bc.l:=bc.l or 64;
inc(t_state,8);
end;

procedure set6_d;
begin
de.h:=de.h or 64;
inc(t_state,8);
end;

procedure set6_e;
begin
de.l:=de.l or 64;
inc(t_state,8);
end;

procedure set6_h;
begin
hl.h:=hl.h or 64;
inc(t_state,8);
end;

procedure set6_l;
begin
hl.l:=hl.l or 64;
inc(t_state,8);
end;

procedure set6;
begin
pokeb(Addr,peekb(Addr) or 64);
inc(t_state,15);
end;

procedure set6_a;
begin
af.h:=af.h or 64;
inc(t_state,8);
end;

procedure set7_b;
begin
bc.h:=bc.h or 128;
inc(t_state,8);
end;

procedure set7_c;
begin
bc.l:=bc.l or 128;
inc(t_state,8);
end;

procedure set7_d;
begin
de.h:=de.h or 128;
inc(t_state,8);
end;

procedure set7_e;
begin
de.l:=de.l or 128;
inc(t_state,8);
end;

procedure set7_h;
begin
hl.h:=hl.h or 128;
inc(t_state,8);
end;

procedure set7_l;
begin
hl.l:=hl.l or 128;
inc(t_state,8);
end;

procedure set7;
begin
pokeb(Addr,peekb(Addr) or 128);
inc(t_state,15);
end;

procedure set7_a;
begin
af.h:=af.h or 128;
inc(t_state,8);
end;

procedure createCB;
begin
CB[0]:=rlc_b;
CB[1]:=rlc_c;
CB[2]:=rlc_d;
CB[3]:=rlc_e;
CB[4]:=rlc_h;
CB[5]:=rlc_l;
CB[6]:=rlc;
CB[7]:=rlc_a;
CB[8]:=rrc_b;
CB[9]:=rrc_c;
CB[10]:=rrc_d;
CB[11]:=rrc_e;
CB[12]:=rrc_h;
CB[13]:=rrc_l;
CB[14]:=rrc;
CB[15]:=rrc_a;
CB[16]:=rl_b;
CB[17]:=rl_c;
CB[18]:=rl_d;
CB[19]:=rl_e;
CB[20]:=rl_h;
CB[21]:=rl_l;
CB[22]:=rl;
CB[23]:=rl_a;
CB[24]:=rr_b;
CB[25]:=rr_c;
CB[26]:=rr_d;
CB[27]:=rr_e;
CB[28]:=rr_h;
CB[29]:=rr_l;
CB[30]:=rr;
CB[31]:=rr_a;
CB[32]:=sla_b;
CB[33]:=sla_c;
CB[34]:=sla_d;
CB[35]:=sla_e;
CB[36]:=sla_h;
CB[37]:=sla_l;
CB[38]:=sla;
CB[39]:=CBsla_a;
CB[40]:=sra_b;
CB[41]:=sra_c;
CB[42]:=sra_d;
CB[43]:=sra_e;
CB[44]:=sra_h;
CB[45]:=sra_l;
CB[46]:=sra;
CB[47]:=CBsra_a;
CB[48]:=sll_b;
CB[49]:=sll_c;
CB[50]:=sll_d;
CB[51]:=sll_e;
CB[52]:=sll_h;
CB[53]:=sll_l;
CB[54]:=sll;
CB[55]:=CBsll_a;
CB[56]:=srl_b;
CB[57]:=srl_c;
CB[58]:=srl_d;
CB[59]:=srl_e;
CB[60]:=srl_h;
CB[61]:=srl_l;
CB[62]:=srl;
CB[63]:=CBsrl_a;
CB[64]:=bit0_b;
CB[65]:=bit0_c;
CB[66]:=bit0_d;
CB[67]:=bit0_e;
CB[68]:=bit0_h;
CB[69]:=bit0_l;
CB[70]:=bit0;
CB[71]:=bit0_a;
CB[72]:=bit1_b;
CB[73]:=bit1_c;
CB[74]:=bit1_d;
CB[75]:=bit1_e;
CB[76]:=bit1_h;
CB[77]:=bit1_l;
CB[78]:=bit1;
CB[79]:=bit1_a;
CB[80]:=bit2_b;
CB[81]:=bit2_c;
CB[82]:=bit2_d;
CB[83]:=bit2_e;
CB[84]:=bit2_h;
CB[85]:=bit2_l;
CB[86]:=bit2;
CB[87]:=bit2_a;
CB[88]:=bit3_b;
CB[89]:=bit3_c;
CB[90]:=bit3_d;
CB[91]:=bit3_e;
CB[92]:=bit3_h;
CB[93]:=bit3_l;
CB[94]:=bit3;
CB[95]:=bit3_a;
CB[96]:=bit4_b;
CB[97]:=bit4_c;
CB[98]:=bit4_d;
CB[99]:=bit4_e;
CB[100]:=bit4_h;
CB[101]:=bit4_l;
CB[102]:=bit4;
CB[103]:=bit4_a;
CB[104]:=bit5_b;
CB[105]:=bit5_c;
CB[106]:=bit5_d;
CB[107]:=bit5_e;
CB[108]:=bit5_h;
CB[109]:=bit5_l;
CB[110]:=bit5;
CB[111]:=bit5_a;
CB[112]:=bit6_b;
CB[113]:=bit6_c;
CB[114]:=bit6_d;
CB[115]:=bit6_e;
CB[116]:=bit6_h;
CB[117]:=bit6_l;
CB[118]:=bit6;
CB[119]:=bit6_a;
CB[120]:=bit7_b;
CB[121]:=bit7_c;
CB[122]:=bit7_d;
CB[123]:=bit7_e;
CB[124]:=bit7_h;
CB[125]:=bit7_l;
CB[126]:=bit7;
CB[127]:=bit7_a;
CB[128]:=res0_b;
CB[129]:=res0_c;
CB[130]:=res0_d;
CB[131]:=res0_e;
CB[132]:=res0_h;
CB[133]:=res0_l;
CB[134]:=res0;
CB[135]:=res0_a;
CB[136]:=res1_b;
CB[137]:=res1_c;
CB[138]:=res1_d;
CB[139]:=res1_e;
CB[140]:=res1_h;
CB[141]:=res1_l;
CB[142]:=res1;
CB[143]:=res1_a;
CB[144]:=res2_b;
CB[145]:=res2_c;
CB[146]:=res2_d;
CB[147]:=res2_e;
CB[148]:=res2_h;
CB[149]:=res2_l;
CB[150]:=res2;
CB[151]:=res2_a;
CB[152]:=res3_b;
CB[153]:=res3_c;
CB[154]:=res3_d;
CB[155]:=res3_e;
CB[156]:=res3_h;
CB[157]:=res3_l;
CB[158]:=res3;
CB[159]:=res3_a;
CB[160]:=res4_b;
CB[161]:=res4_c;
CB[162]:=res4_d;
CB[163]:=res4_e;
CB[164]:=res4_h;
CB[165]:=res4_l;
CB[166]:=res4;
CB[167]:=res4_a;
CB[168]:=res5_b;
CB[169]:=res5_c;
CB[170]:=res5_d;
CB[171]:=res5_e;
CB[172]:=res5_h;
CB[173]:=res5_l;
CB[174]:=res5;
CB[175]:=res5_a;
CB[176]:=res6_b;
CB[177]:=res6_c;
CB[178]:=res6_d;
CB[179]:=res6_e;
CB[180]:=res6_h;
CB[181]:=res6_l;
CB[182]:=res6;
CB[183]:=res6_a;
CB[184]:=res7_b;
CB[185]:=res7_c;
CB[186]:=res7_d;
CB[187]:=res7_e;
CB[188]:=res7_h;
CB[189]:=res7_l;
CB[190]:=res7;
CB[191]:=res7_a;
CB[192]:=set0_b;
CB[193]:=set0_c;
CB[194]:=set0_d;
CB[195]:=set0_e;
CB[196]:=set0_h;
CB[197]:=set0_l;
CB[198]:=set0;
CB[199]:=set0_a;
CB[200]:=set1_b;
CB[201]:=set1_c;
CB[202]:=set1_d;
CB[203]:=set1_e;
CB[204]:=set1_h;
CB[205]:=set1_l;
CB[206]:=set1;
CB[207]:=set1_a;
CB[208]:=set2_b;
CB[209]:=set2_c;
CB[210]:=set2_d;
CB[211]:=set2_e;
CB[212]:=set2_h;
CB[213]:=set2_l;
CB[214]:=set2;
CB[215]:=set2_a;
CB[216]:=set3_b;
CB[217]:=set3_c;
CB[218]:=set3_d;
CB[219]:=set3_e;
CB[220]:=set3_h;
CB[221]:=set3_l;
CB[222]:=set3;
CB[223]:=set3_a;
CB[224]:=set4_b;
CB[225]:=set4_c;
CB[226]:=set4_d;
CB[227]:=set4_e;
CB[228]:=set4_h;
CB[229]:=set4_l;
CB[230]:=set4;
CB[231]:=set4_a;
CB[232]:=set5_b;
CB[233]:=set5_c;
CB[234]:=set5_d;
CB[235]:=set5_e;
CB[236]:=set5_h;
CB[237]:=set5_l;
CB[238]:=set5;
CB[239]:=set5_a;
CB[240]:=set6_b;
CB[241]:=set6_c;
CB[242]:=set6_d;
CB[243]:=set6_e;
CB[244]:=set6_h;
CB[245]:=set6_l;
CB[246]:=set6;
CB[247]:=set6_a;
CB[248]:=set7_b;
CB[249]:=set7_c;
CB[250]:=set7_d;
CB[251]:=set7_e;
CB[252]:=set7_h;
CB[253]:=set7_l;
CB[254]:=set7;
CB[255]:=set7_a;
end;
