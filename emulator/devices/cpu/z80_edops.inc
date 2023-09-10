{ $define old_in}
var ed:Array[0..255] of procedure; {Jump_Table}

procedure in_b_c; (* in b,(c) ALL in reg,(c) UNTESTED FLAGS *)
begin
	bc.h:=inb(bc.w);                         (* SZ-H-PNC *)
{$ifdef OLD_IN}
	af.l:=(bc.h and $A8) or (af.l and 1) or (parity[bc.h]); (* 10101000 *)
	if bc.h>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
{$else}
	af.l:=in_table[bc.h] or (af.l and 1);
{$endif}
	inc(t_state,12);
end;

procedure out_c_b; (* out(c),b *)
begin
	outb(bc.w,bc.h);
	inc(t_state,12);
end;

procedure sbc_hl_bc; (* sbc hl,bc *)
begin
	sbc16(hl.W,bc.W);
	inc(t_state,15);
end;

procedure ld_aXXXX_bc; (* ld(XXXX),bc *)
begin
	pokew(peekw(pc.W),bc.W);
	inc(pc.W,2);
	inc(t_state,20);
end;

procedure neg; (* neg *)
begin
	sub8(0,af.h);
	inc(t_state,8);
end;

procedure retn; (* retn *)
begin
	iff1:=iff2;
	pop(pc.W);
	inc(t_state,14);
end;

procedure im_0; (* im 0 *)
begin
	im:=0;
	inc(t_state,8);
end;

procedure ld_i_a; (* ld i,a *)
begin
	ir.h:=af.h;
	inc(t_state,9);
end;

procedure in_c_c; (* in c,(c) *)
begin
	bc.l:=inb(bc.w);                         (* SZ-H-PNC *)
{$ifdef OLD_IN}
	af.l:=(bc.l and $A8) or (af.l and 1) or (parity[bc.l]); (* 10101000 *)
	if bc.l>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
{$else}
	af.l:=in_table[bc.l] or (af.l and 1);
{$endif}
	inc(t_state,12);
end;

procedure out_c_c; (* out(c),c *)
begin
	outb(bc.w,bc.l);
	inc(t_state,12);
end;

procedure adc_hl_bc; (* adc hl,bc *)
begin
	adc16(hl.W,bc.W);
	inc(t_state,15);
end;

procedure ld_bc_aXXXX; (* ld bc,(XXXX) *)
begin
	bc.W:=peekw(peekw(pc.W));
	inc(pc.W,2);
	inc(t_state,20);
end;

procedure reti; (* reti *)
begin
	pop(pc.W);
	inc(t_state,14);
end;

procedure ld_r_a; (* ld r,a *)
begin
	ir.l:=af.h and 127;
	bit7_r:=af.h and 128;
	inc(t_state,9);
end;

procedure in_d_c; (* in d,(c) *)
begin
	de.h:=inb(bc.w);                         (* SZ-H-PNC *)
{$ifdef OLD_IN}
	af.l:=(de.h and $A8) or (af.l and 1) or (parity[de.h]); (* 10101000 *)
	if de.h>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
{$else}
	af.l:=in_table[de.h] or (af.l and 1);
{$endif}
	inc(t_state,12);
end;

procedure out_c_d; (* out(c),d *)
begin
	outb(bc.w,de.h);
	inc(t_state,12);
end;

procedure sbc_hl_de; (* sbc hl,de *)
begin
	sbc16(hl.W,de.W);
	inc(t_state,15);
end;

procedure ld_aXXXX_de; (* ld(XXXX),de *)
begin
	pokew(peekw(pc.W),de.W);
	inc(pc.W,2);
	inc(t_state,20);
end;

procedure im_1; (* im 1 *)
begin
	im:=1;
	inc(t_state,8);
end;

procedure ld_a_i; (* ld a,i UNTESTED *)
begin
	af.h:=ir.h;                   (* SZ-H-PNC *)
	af.l:=(af.h and $A8) or (af.l and 1); (* 10101000 *)
	if af.h>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
	if iff2>0 then af.l:=af.l or 4   (* set Pf *) else af.l:=af.l and 251 (* reset Pf *);
	inc(t_state,9);
end;

procedure in_e_c; (* in e,(c) *)
begin
	de.l:=inb(bc.w);                         (* SZ-H-PNC *)
{$ifdef OLD_IN}
	af.l:=(de.l and $A8) or (af.l and 1) or (parity[de.l]); (* 10101000 *)
	if(de.l)>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
{$else}
	af.l:=in_table[de.l] or (af.l and 1);
{$endif}
	inc(t_state,12);
end;

procedure out_c_e; (* out(c),e *)
begin
	outb(bc.w,de.l);
	inc(t_state,12);
end;

procedure adc_hl_de; (* adc hl,de *)
begin
	adc16(hl.W,de.W);
	inc(t_state,15);
end;

procedure ld_de_aXXXX; (* ld de,(XXXX) *)
begin
	de.W:=peekw(peekw(pc.W));
	inc(pc.W,2);
	inc(t_state,20);
end;

procedure im_2; (* im 2 *)
begin
	im:=2;
	inc(t_state,8);
end;

procedure ld_a_r; (* ld a,r extra flags untested *)
begin
	af.h:=bit7_r or (ir.l and 127);      (* SZ-H-PNC *)
	af.l:=(af.h and $A8) or (af.l and 1); (* 10101000 *)
	if(af.h)>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
	if(iff2)>0 then af.l:=af.l or 4   (* set Pf *) else af.l:=af.l and 251 (* reset Pf *);
	inc(t_state,9);
end;

procedure in_h_c; (* in h,(c) *)
begin
	hl.h:=inb(bc.w);                         (* SZ-H-PNC *)
{$ifdef OLD_IN}
	af.l:=(hl.h and $A8) or (af.l and 1) or (parity[hl.h]); (* 10101000 *)
	if(hl.h)>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
{$else}
	af.l:=in_table[hl.h] or (af.l and 1);
{$endif}
	inc(t_state,12);
end;

procedure out_c_h; (* out(c),h *)
begin
	outb(bc.w,hl.h);
	inc(t_state,12);
end;

procedure sbc_hl_hl; (* sbc hl,hl *)
begin
	sbc16(hl.W,hl.W);
	inc(t_state,15);
end;

procedure ld_aXXXX_hl; (* ld(XXXX),hl *)
begin
	pokew(peekw(pc.W),hl.W);
	inc(pc.W,2);
	inc(t_state,20);
end;

procedure rrd; (* rrd INCOMPLETE *)
var c_hl:byte;
begin
	c_hl:=peekb(hl.W);
	pokeb(hl.W,(c_hl shr 4) or (af.h shl 4));
	af.h:=(c_hl and $0F) or (af.h and $F0);

	af.l:=(af.h and 190) or (af.l and 1); (* Keep Cf and Set Zf to 0 *)
	if af.h=0 then af.l:=af.l or 64  (* set Zf *); (* And the Sign flag is used *)
	inc(t_state,18);
end;

procedure in_l_c; (* in l,(c) *)
begin
	hl.l:=inb(bc.w);                         (* SZ-H-PNC *)
{$ifdef OLD_IN}
	af.l:=(hl.l and $A8) or (af.l and 1) or (parity[hl.l]); (* 10101000 *)
	if(hl.l)>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
{$else}
	af.l:=in_table[hl.l] or (af.l and 1);
{$endif}
	inc(t_state,12);
end;

procedure out_c_l; (* out(c),l *)
begin
	outb(bc.w,hl.l);
	inc(t_state,12);
end;

procedure adc_hl_hl; (* adc hl,hl *)
begin
	adc16(hl.W,hl.W);
	inc(t_state,15);
end;

procedure ld_hl_aXXXX; (* ld hl,(XXXX) *)
begin
	hl.W:=peekw(peekw(pc.W));
	inc(pc.W,2);
	inc(t_state,20);
end;

procedure rld; (* rld INCOMPLETE *)
var c_hl:byte;
begin
	c_hl:=peekb(hl.W);
	pokeb(hl.W,(c_hl shl 4) or (af.h and $0F));
	af.h:=(c_hl shr 4) or (af.h and $F0);

	af.l:=(af.h and 190) or (af.l and 1); (* Keep Cf and Set Zf to 0 *)
	if af.h=0 then af.l:=af.l or 64  (* set Zf *); (* And the Sign flag is used *)
	inc(t_state,18);
end;

procedure in_f_c; (* in f,(c) *)
begin
	af.l:=inb(bc.w);
{$ifdef OLD_IN}
	if(af.l)>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);        (* SZ-H-PNC *)
	af.l:=(af.l and $E9) or (parity[af.l]); (* 11101001 *)
{$else}
	af.l:=in_table[af.l] or (af.l and 1);
{$endif}
	inc(t_state,12);
end;

procedure out_c_0; (* out(c),0 *)
begin
	outb(bc.w,0);
	inc(t_state,12);
end;

procedure sbc_hl_sp; (* sbc hl,sp *)
begin
	sbc16(hl.W,sp.W);
	inc(t_state,15);
end;

procedure ld_aXXXX_sp; (* ld(XXXX),sp *)
begin
	pokew(peekw(pc.W),sp.W);
	inc(pc.W,2);
	inc(t_state,20);
end;

procedure in_a_c; (* in a,(c) *)
begin
	af.h:=inb(bc.w);                         (* SZ-H-PNC *)
{$ifdef OLD_IN}
	af.l:=(af.h and $A8) or (af.l and 1) or (parity[af.h]); (* 10101000 *)
	if(af.h)>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64  (* set Zf *);
{$else}
	af.l:=in_table[af.h] or (af.l and 1);
{$endif}
	inc(t_state,12);
end;

procedure out_c_a; (* out(c),a *)
begin
	outb(bc.w,af.h);
	inc(t_state,12);
end;

procedure adc_hl_sp; (* adc hl,sp *)
begin
	adc16(hl.W,sp.W);
	inc(t_state,15);
end;

procedure ld_sp_aXXXX; (* ld sp,(XXXX) *)
begin
	sp.W:=peekw(peekw(pc.W));
	inc(pc.W,2);
	inc(t_state,20);
end;

procedure ldi; (* ldi *)
begin
	pokeb(de.W,peekb(hl.W));
	inc(de.W);
	inc(hl.W);
	dec(bc.W);
	af.l:=af.l or 4   (* set Pf *);
	if bc.W=0 then
		af.l:=af.l and 233 (* reset Nf,Hf,Pf *)
	else
		af.l:=af.l and 237; (* reset Nf,Hf *)
	inc(t_state,16);
end;

procedure cpi; (* cpi UNTESTED *)
var btemp:byte;
begin
	btemp:=af.l and 1;
	cp_sub8(peekb(hl.W),af.h);(* Keep Cf *)
	af.l:=(af.l and 254) or btemp;
	inc(hl.W);
	dec(bc.W);
	if bc.W=0 then af.l:=af.l and 251 (* reset Pf *) else af.l:=af.l or 4   (* set Pf *);
	inc(t_state,16);
end;

procedure ini; (* ini UNTESTED *)
begin
	pokeb(hl.W,inb(bc.w));
	inc(hl.W);
	dec(bc.h);
	if bc.h=0 then af.l:=af.l or 64  (* set Zf *) else af.l:=af.l and 191 (* reset Zf *);
	 af.l:=af.l or 2   (* set Nf *);
	inc(t_state,16);
end;

procedure outi; (* outi UNTESTED *)
begin
	dec(bc.h); (* Pre-decremented according to some *)
	outb(bc.w,peekb(hl.W));
	inc(hl.W);
	if bc.h=0 then af.l:=af.l or 64  (* set Zf *) else af.l:=af.l and 191 (* reset Zf *);
	 af.l:=af.l or 2   (* set Nf *);
	inc(t_state,16);
end;

procedure ldd; (* ldd *)
begin
	pokeb(de.W,peekb(hl.W));
	dec(de.W);
	dec(hl.W);
	dec(bc.W);
	af.l:=af.l or 4   (* set Pf *);
	if bc.W=0 then
		af.l:=af.l and 233 (* reset Nf,Hf,Pf *)
        else
		af.l:=af.l and 237; (* reset Nf,Hf *)
	inc(t_state,16);
end;

procedure cpd; (* cpd UNTESTED *)
var btemp:byte;
begin
	btemp:=af.l and 1;
	cp_sub8(peekb(hl.W),af.h);(* Keep Cf *)
	af.l:=(af.l and 254) or btemp;
	dec(hl.W);
	dec(bc.W);
	if bc.W=0 then
		af.l:=af.l and 251 (* reset Pf *) else
                af.l:=af.l or 4   (* set Pf *);
	inc(t_state,16);
end;

procedure ind; (* ind UNTESTED *)
begin
	pokeb(hl.W,inb(bc.w));
	dec(hl.W);
	dec(bc.h);
	if bc.h=0 then af.l:=af.l or 64  (* set Zf *) else af.l:=af.l and 191 (* reset Zf *);
	 af.l:=af.l or 2   (* set Nf *);
	inc(t_state,16);
end;

procedure outd; (* outd UNTESTED *)
begin
	dec(bc.h); (* Pre-decremented according to some *)
	outb(bc.w,peekb(hl.W));
	dec(hl.W);
	if bc.h=0 then af.l:=af.l or 64  (* set Zf *) else af.l:=af.l and 191 (* reset Zf *);
	 af.l:=af.l or 2   (* set Nf *);
	inc(t_state,16);
end;

procedure ldir; (*ldir *)
begin
	pokeb(de.W,peekb(hl.W));
	inc(de.W);
	inc(hl.W);
	dec(bc.W);
	af.l:=af.l or 4   (* set Pf *);
	if bc.W=0 then
	begin
		af.l:=af.l and 233; (* reset Nf,Hf,Pf *)
		inc(t_state,16);
	end
	else
	begin
		af.l:=af.l and 237; (* reset Nf,Hf *)
		inc(t_state,21);
		dec(pc.W,2);
	end;
end;

procedure cpir; (* cpir UNTESTED *)
var btemp:byte;
begin
	btemp:=af.l and 1;
	cp_sub8(peekb(hl.W),af.h);(* Keep Cf *)
	af.l:=(af.l and 254) or btemp;
	inc(hl.W);
	dec(bc.W);
	if bc.W=0 then
	begin
		af.l:=af.l and 251 (* reset Pf *);
		inc(t_state,16); (* Hmmm *)
		exit; (* Hmmm *)
	end
	else af.l:=af.l or 4   (* set Pf *);
	if af.l and 64>0 then (* Zf:=1 *)
		inc(t_state,16)
	else
        begin
		inc(t_state,21);
		dec(pc.W,2);
	end;
end;

procedure inir; (* inir UNTESTED *)
begin
	pokeb(hl.W,inb(bc.w));
	inc(hl.W);
	 af.l:=af.l or 2   (* set Nf *);
	dec(bc.h);
	if bc.h=0 then
	begin
		af.l:=af.l or 64  (* set Zf *);
		inc(t_state,16);
	end
	else
	begin
		af.l:=af.l and 191 (* reset Zf *);
		inc(t_state,21);
		dec(pc.W,2);
	end;
end;

procedure otir; (* otir UNTESTED *)
begin
	dec(bc.h); (* Pre-decremented according to some *)
	outb(bc.w,peekb(hl.W));
	inc(hl.W);
	 af.l:=af.l or 2   (* set Nf *);
	if bc.h=0 then
	begin
		af.l:=af.l or 64  (* set Zf *);
		inc(t_state,16);
	end
	else
	begin
		af.l:=af.l and 191 (* reset Zf *);
		inc(t_state,21);
		dec(pc.W,2);
	end;
end;

procedure lddr; (* lddr *)
begin
	pokeb(de.W,peekb(hl.W));
	dec(de.W);
	dec(hl.W);
	dec(bc.W);
	af.l:=af.l or 4   (* set Pf *);
	if bc.W=0 then
	begin
		af.l:=af.l and 233; (* reset Nf,Hf,Pf *)
		inc(t_state,16);
	end
	else
	begin
		af.l:=af.l and 237; (* reset Nf,Hf *)
		inc(t_state,21);
		dec(pc.W,2);
	end;
end;

procedure cpdr; (* cpdr UNTESTED *)
var btemp:byte;
begin
	btemp:=af.l and 1;
	cp_sub8(peekb(hl.W),af.h);(* Keep Cf *)
	af.l:=(af.l and 254) or btemp;
	dec(hl.W);
	dec(bc.W);
	if bc.W=0 then
	begin
		af.l:=af.l and 251 (* reset Pf *);
		inc(t_state,16);
		exit;
	end
	else
		af.l:=af.l or 4   (* set Pf *);

	if(af.l and 64)>0 then  (* Zf:=1 *)
		inc(t_state,16)
	else
	begin
		inc(t_state,21);
		dec(pc.W,2);
	end;
end;

procedure indr; (* indr UNTESTED *)
begin
	pokeb(hl.W,inb(bc.w));
	dec(hl.W);
	 af.l:=af.l or 2   (* set Nf *);
	dec(bc.h);
	if bc.h=0 then
	begin
		af.l:=af.l or 64  (* set Zf *);
		inc(t_state,16);
	end
	else
	begin
		af.l:=af.l and 191 (* reset Zf *);
		inc(t_state,21);
		dec(pc.W,2);
	end;
end;

procedure otdr; (* otdr UNTESTED *)
begin
	dec(bc.h); (* Pre-decremented according to some *)
	outb(bc.w,peekb(hl.W));
	dec(hl.W);
	 af.l:=af.l or 2   (* set Nf *);
	if bc.h=0 then
	begin
		af.l:=af.l or 64  (* set Zf *);
		inc(t_state,16);
	end
	else
	begin
		af.l:=af.l and 191 (* reset Zf *);
		inc(t_state,21);
		dec(pc.W,2);
	end;
end;

procedure Ill_ED;
begin
inc(t_state,8);
end;

procedure createED;
begin
ED[0]:=Ill_ED;
ED[1]:=Ill_ED;
ED[2]:=Ill_ED;
ED[3]:=Ill_ED;
ED[4]:=Ill_ED;
ED[5]:=Ill_ED;
ED[6]:=Ill_ED;
ED[7]:=Ill_ED;
ED[8]:=Ill_ED;
ED[9]:=Ill_ED;
ED[10]:=Ill_ED;
ED[11]:=Ill_ED;
ED[12]:=Ill_ED;
ED[13]:=Ill_ED;
ED[14]:=Ill_ED;
ED[15]:=Ill_ED;
ED[16]:=Ill_ED;
ED[17]:=Ill_ED;
ED[18]:=Ill_ED;
ED[19]:=Ill_ED;
ED[20]:=Ill_ED;
ED[21]:=Ill_ED;
ED[22]:=Ill_ED;
ED[23]:=Ill_ED;
ED[24]:=Ill_ED;
ED[25]:=Ill_ED;
ED[26]:=Ill_ED;
ED[27]:=Ill_ED;
ED[28]:=Ill_ED;
ED[29]:=Ill_ED;
ED[30]:=Ill_ED;
ED[31]:=Ill_ED;
ED[32]:=Ill_ED;
ED[33]:=Ill_ED;
ED[34]:=Ill_ED;
ED[35]:=Ill_ED;
ED[36]:=Ill_ED;
ED[37]:=Ill_ED;
ED[38]:=Ill_ED;
ED[39]:=Ill_ED;
ED[40]:=Ill_ED;
ED[41]:=Ill_ED;
ED[42]:=Ill_ED;
ED[43]:=Ill_ED;
ED[44]:=Ill_ED;
ED[45]:=Ill_ED;
ED[46]:=Ill_ED;
ED[47]:=Ill_ED;
ED[48]:=Ill_ED;
ED[49]:=Ill_ED;
ED[50]:=Ill_ED;
ED[51]:=Ill_ED;
ED[52]:=Ill_ED;
ED[53]:=Ill_ED;
ED[54]:=Ill_ED;
ED[55]:=Ill_ED;
ED[56]:=Ill_ED;
ED[57]:=Ill_ED;
ED[58]:=Ill_ED;
ED[59]:=Ill_ED;
ED[60]:=Ill_ED;
ED[61]:=Ill_ED;
ED[62]:=Ill_ED;
ED[63]:=Ill_ED;
ED[64]:=in_b_c;
ED[65]:=out_c_b;
ED[66]:=sbc_hl_bc;
ED[67]:=ld_aXXXX_bc;
ED[68]:=neg;
ED[69]:=retn;
ED[70]:=im_0;
ED[71]:=ld_i_a;
ED[72]:=in_c_c;
ED[73]:=out_c_c;
ED[74]:=adc_hl_bc;
ED[75]:=ld_bc_aXXXX;
ED[76]:=Ill_ED;
ED[77]:=reti;
ED[78]:=Ill_ED;
ED[79]:=ld_r_a;
ED[80]:=in_d_c;
ED[81]:=out_c_d;
ED[82]:=sbc_hl_de;
ED[83]:=ld_aXXXX_de;
ED[84]:=Ill_ED;
ED[85]:=Ill_ED;
ED[86]:=im_1;
ED[87]:=ld_a_i;
ED[88]:=in_e_c;
ED[89]:=out_c_e;
ED[90]:=adc_hl_de;
ED[91]:=ld_de_aXXXX;
ED[92]:=Ill_ED;
ED[93]:=Ill_ED;
ED[94]:=im_2;
ED[95]:=ld_a_r;
ED[96]:=in_h_c;
ED[97]:=out_c_h;
ED[98]:=sbc_hl_hl;
ED[99]:=ld_aXXXX_hl;
ED[100]:=Ill_ED;
ED[101]:=Ill_ED;
ED[102]:=Ill_ED;
ED[103]:=rrd;
ED[104]:=in_l_c;
ED[105]:=out_c_l;
ED[106]:=adc_hl_hl;
ED[107]:=ld_hl_aXXXX;
ED[108]:=Ill_ED;
ED[109]:=Ill_ED;
ED[110]:=Ill_ED;
ED[111]:=rld;
ED[112]:=in_f_c;
ED[113]:=out_c_0;
ED[114]:=sbc_hl_sp;
ED[115]:=ld_aXXXX_sp;
ED[116]:=Ill_ED;
ED[117]:=Ill_ED;
ED[118]:=Ill_ED;
ED[119]:=Ill_ED;
ED[120]:=in_a_c;
ED[121]:=out_c_a;
ED[122]:=adc_hl_sp;
ED[123]:=ld_sp_aXXXX;
ED[124]:=Ill_ED;
ED[125]:=Ill_ED;
ED[126]:=Ill_ED;
ED[127]:=Ill_ED;
ED[128]:=Ill_ED;
ED[129]:=Ill_ED;
ED[130]:=Ill_ED;
ED[131]:=Ill_ED;
ED[132]:=Ill_ED;
ED[133]:=Ill_ED;
ED[134]:=Ill_ED;
ED[135]:=Ill_ED;
ED[136]:=Ill_ED;
ED[137]:=Ill_ED;
ED[138]:=Ill_ED;
ED[139]:=Ill_ED;
ED[140]:=Ill_ED;
ED[141]:=Ill_ED;
ED[142]:=Ill_ED;
ED[143]:=Ill_ED;
ED[144]:=Ill_ED;
ED[145]:=Ill_ED;
ED[146]:=Ill_ED;
ED[147]:=Ill_ED;
ED[148]:=Ill_ED;
ED[149]:=Ill_ED;
ED[150]:=Ill_ED;
ED[151]:=Ill_ED;
ED[152]:=Ill_ED;
ED[153]:=Ill_ED;
ED[154]:=Ill_ED;
ED[155]:=Ill_ED;
ED[156]:=Ill_ED;
ED[157]:=Ill_ED;
ED[158]:=Ill_ED;
ED[159]:=Ill_ED;
ED[160]:=ldi;
ED[161]:=cpi;
ED[162]:=ini;
ED[163]:=outi;
ED[164]:=Ill_ED;
ED[165]:=Ill_ED;
ED[166]:=Ill_ED;
ED[167]:=Ill_ED;
ED[168]:=ldd;
ED[169]:=cpd;
ED[170]:=ind;
ED[171]:=outd;
ED[172]:=Ill_ED;
ED[173]:=Ill_ED;
ED[174]:=Ill_ED;
ED[175]:=Ill_ED;
ED[176]:=ldir;
ED[177]:=cpir;
ED[178]:=inir;
ED[179]:=otir;
ED[180]:=Ill_ED;
ED[181]:=Ill_ED;
ED[182]:=Ill_ED;
ED[183]:=Ill_ED;
ED[184]:=lddr;
ED[185]:=cpdr;
ED[186]:=indr;
ED[187]:=otdr;
ED[188]:=Ill_ED;
ED[189]:=Ill_ED;
ED[190]:=Ill_ED;
ED[191]:=Ill_ED;
ED[192]:=Ill_ED;
ED[193]:=Ill_ED;
ED[194]:=Ill_ED;
ED[195]:=Ill_ED;
ED[196]:=Ill_ED;
ED[197]:=Ill_ED;
ED[198]:=Ill_ED;
ED[199]:=Ill_ED;
ED[200]:=Ill_ED;
ED[201]:=Ill_ED;
ED[202]:=Ill_ED;
ED[203]:=Ill_ED;
ED[204]:=Ill_ED;
ED[205]:=Ill_ED;
ED[206]:=Ill_ED;
ED[207]:=Ill_ED;
ED[208]:=Ill_ED;
ED[209]:=Ill_ED;
ED[210]:=Ill_ED;
ED[211]:=Ill_ED;
ED[212]:=Ill_ED;
ED[213]:=Ill_ED;
ED[214]:=Ill_ED;
ED[215]:=Ill_ED;
ED[216]:=Ill_ED;
ED[217]:=Ill_ED;
ED[218]:=Ill_ED;
ED[219]:=Ill_ED;
ED[220]:=Ill_ED;
ED[221]:=Ill_ED;
ED[222]:=Ill_ED;
ED[223]:=Ill_ED;
ED[224]:=Ill_ED;
ED[225]:=Ill_ED;
ED[226]:=Ill_ED;
ED[227]:=Ill_ED;
ED[228]:=Ill_ED;
ED[229]:=Ill_ED;
ED[230]:=Ill_ED;
ED[231]:=Ill_ED;
ED[232]:=Ill_ED;
ED[233]:=Ill_ED;
ED[234]:=Ill_ED;
ED[235]:=Ill_ED;
ED[236]:=Ill_ED;
ED[237]:=Ill_ED;
ED[238]:=Ill_ED;
ED[239]:=Ill_ED;
ED[240]:=Ill_ED;
ED[241]:=Ill_ED;
ED[242]:=Ill_ED;
ED[243]:=Ill_ED;
ED[244]:=Ill_ED;
ED[245]:=Ill_ED;
ED[246]:=Ill_ED;
ED[247]:=Ill_ED;
ED[248]:=Ill_ED;
ED[249]:=Ill_ED;
ED[250]:=Ill_ED;
ED[251]:=Ill_ED;
ED[252]:=Ill_ED;
ED[253]:=Ill_ED;
ED[254]:=Ill_ED;
ED[255]:=Ill_ED;
end;
