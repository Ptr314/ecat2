var z80_std, Z80_IX, Z80_IY:Array[0..255] of procedure; {Jump-Table}

procedure nop;
Begin
inc(t_state,4);
end;

procedure ld_bc_XXXX;
Begin
bc.W:=peekw(pc.W);
inc(pc.W,2);
inc(t_state,10);
end;

procedure ld_mbc_a;
Begin
pokeb(bc.W,af.h);
inc(t_state,7);
end;

procedure inc_bc;
Begin
inc(bc.w);
inc(t_state,6);
end;

procedure inc_b;
Begin
af.l:=inc_f[bc.h] or (af.l and 1); 
inc(bc.h);
inc(t_state,4);
end;

procedure dec_b;
Begin
af.l:=dec_f[bc.h] or (af.l and 1); 
dec(bc.h);
inc(t_state,4);
end;

procedure ld_b_XX;
Begin
bc.h:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure rlca;
var btemp: Byte;
Begin
btemp:=af.l and 1;
af.l:=rlca_f[btemp][af.h] or (af.l and 196); 
af.h:=rlca_a[btemp][af.h];
inc(t_state,4);
end;

procedure ex_af_af;
var temp: word;
Begin
temp:=af.W;
af.W:=af2.W;
af2.W:=temp;
inc(t_state,4);
end;

procedure add_ix_bc;
Begin
add16(ix.W,bc.W);
inc(t_state,11);
end;

procedure add_iy_bc;
Begin
add16(iy.W,bc.W);
inc(t_state,11);
end;

procedure add_hl_bc;
Begin
add16(hl.W,bc.W);
inc(t_state,11);
end;

procedure ld_a_mbc;
Begin
af.h:=peekb(bc.W);
inc(t_state,7);
end;

procedure dec_bc;
Begin
dec(bc.W);
inc(t_state,6);
end;

procedure inc_c;
Begin
af.l:=inc_f[bc.l] or (af.l and 1); 
inc(bc.l);
inc(t_state,4);
end;

procedure dec_c;
Begin
af.l:=dec_f[bc.l] or (af.l and 1); 
dec(bc.l);
inc(t_state,4);
end;

procedure ld_c_XX;
Begin
bc.l:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure rrca;
var btemp: Byte;
Begin
btemp:=af.l and 1;
af.l:=rrca_f[btemp][af.h] or (af.l and 196); 
af.h:=rrca_a[btemp][af.h];
inc(t_state,4);
end;

procedure djnz_DIS;
Begin
dec(bc.h);
if bc.h>0 then
Begin
pc.W:=pc.w + shortint(peekb(pc.W))+1;
inc(t_state,13);
end
else
Begin
inc(pc.W);
inc(t_state,8);
end
end;

procedure ld_de_XXXX;
Begin
de.W:=peekw(pc.W);
inc(pc.W,2);
inc(t_state,10);
end;

procedure ld_mde_a;
Begin
pokeb(de.W,af.h);
inc(t_state,7);
end;

procedure inc_de;
Begin
inc(de.W);
inc(t_state,6);
end;

procedure inc_d;
Begin
af.l:=inc_f[de.h] or (af.l and 1); 
inc(de.h);
inc(t_state,4);
end;

procedure dec_d;
Begin
af.l:=dec_f[de.h] or (af.l and 1); 
dec(de.h);
inc(t_state,4);
end;

procedure ld_d_XX;
Begin
de.h:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure rla;
var btemp: Byte;
Begin
btemp:=af.l and 1;
af.l:=rla_f[btemp][af.h] or (af.l and 196); 
af.h:=rla_a[btemp][af.h];
inc(t_state,4);
end;

procedure jr_DIS;
Begin
pc.W:=pc.w + shortint(peekb(pc.W))+1;
inc(t_state,12);
end;

procedure add_ix_de;
Begin
add16(ix.W,de.W);
inc(t_state,11);
end;

procedure add_iy_de;
Begin
add16(iy.W,de.W);
inc(t_state,11);
end;

procedure add_hl_de;
Begin
add16(hl.W,de.W);
inc(t_state,11);
end;

procedure ld_a_mde;
Begin
af.h:=peekb(de.W);
inc(t_state,7);
end;

procedure dec_de;
Begin
dec(de.W);
inc(t_state,6);
end;

procedure inc_e;
Begin
af.l:=inc_f[de.l] or (af.l and 1); 
inc(de.l);
inc(t_state,4);
end;

procedure dec_e;
Begin
af.l:=dec_f[de.l] or (af.l and 1); 
dec(de.l);
inc(t_state,4);
end;

procedure ld_e_XX;
Begin
de.l:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure rra;
Begin
 if af.l and 1=0 then
 begin
 af.l:=rra_f[af.h] or (af.l and 196); 
 af.h:=rra_a[0][af.h];
 end
 else
 begin
  af.l:=rra_f[af.h] or (af.l and 196);
  af.h:=rra_a[1][af.h];
 end;
 inc(t_state,4);
end;

procedure jr_nz_DIS;
Begin
if af.l and 64=0 then
Begin
 pc.W:=pc.w + shortint(peekb(pc.W))+1;
 inc(t_state,12);
end
else
Begin
 inc(pc.W);
 inc(t_state,7);
end
end;

procedure ld_ix_XXXX;
Begin
ix.W:=peekw(pc.W);
inc(pc.W,2);
inc(t_state,10);
end;

procedure ld_iy_XXXX;
Begin
iy.W:=peekw(pc.W);
inc(pc.W,2);
inc(t_state,10);
end;

procedure ld_hl_XXXX;
Begin
hl.W:=peekw(pc.W);
inc(pc.W,2);
inc(t_state,10);
end;

procedure Z80ld_aXXXX_ix;
Begin
pokew(peekw(pc.W),ix.W);
inc(pc.W,2);
inc(t_state,16);
end;

procedure Z80ld_aXXXX_iy;
Begin
pokew(peekw(pc.W),iy.W);
inc(pc.W,2);
inc(t_state,16);
end;

procedure Z80ld_aXXXX_hl;
Begin
pokew(peekw(pc.W),hl.W);
inc(pc.W,2);
inc(t_state,16);
end;

procedure inc_ix;
Begin
inc(ix.W);
inc(t_state,6);
end;

procedure inc_iy;
Begin
        inc(iy.W);
inc(t_state,6);
end;

procedure inc_hl;
Begin
inc(hl.W);
inc(t_state,6);
end;

procedure inc_ixh;
Begin
af.l:=inc_f[ix.h] or (af.l and 1); 
inc(ix.h);
inc(t_state,4);
end;

procedure inc_iyh;
Begin
af.l:=inc_f[iy.h] or (af.l and 1); 
inc(iy.h);
inc(t_state,4);
end;

procedure inc_h;
Begin
af.l:=inc_f[hl.h] or (af.l and 1); 
inc(hl.h);
inc(t_state,4);
end;

procedure dec_ixh;
Begin
af.l:=dec_f[ix.h] or (af.l and 1); 
dec(ix.h);
inc(t_state,4);
end;

procedure dec_iyh;
Begin
af.l:=dec_f[iy.h] or (af.l and 1); 
dec(iy.h);
inc(t_state,4);
end;

procedure dec_h;
Begin
af.l:=dec_f[hl.h] or (af.l and 1); 
dec(hl.h);
inc(t_state,4);
end;

procedure ld_ixh_XX;
Begin
ix.h:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure ld_iyh_XX;
Begin
iy.h:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure ld_h_XX;
Begin
hl.h:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure daa;
var daa_select: Byte;
Begin
daa_select:=af.l and 19; 
if daa_select and 16>0 then 
Begin
af.l:=daa_f[daa_select-12][af.h];
af.h:=daa_a[daa_select-12][af.h];
end
else 
Begin
af.l:=daa_f[daa_select][af.h];
af.h:=daa_a[daa_select][af.h];
end;
inc(t_state,4);
end;

procedure jr_z_DIS;
Begin
if af.l and 64>0 then
Begin
pc.W:=pc.w + shortint(peekb(pc.W))+1;
inc(t_state,12);
end
else
Begin
inc(pc.W);
inc(t_state,7);
end
end;

procedure add_ix_ix;
Begin
add16(ix.W,ix.W);
inc(t_state,11);
end;

procedure add_iy_iy;
Begin
add16(iy.W,iy.W);
inc(t_state,11);
end;

procedure add_hl_hl;
Begin
add16(hl.W,hl.W);
inc(t_state,11);
end;

procedure Z80ld_ix_aXXXX;
Begin
ix.W:=peekw(peekw(pc.W));
inc(pc.W,2);
inc(t_state,16);
end;

procedure Z80ld_iy_aXXXX;
Begin
iy.W:=peekw(peekw(pc.W));
inc(pc.W,2);
inc(t_state,16);
end;

procedure Z80ld_hl_aXXXX;
Begin
hl.W:=peekw(peekw(pc.W));
inc(pc.W,2);
inc(t_state,16);
end;

procedure dec_ix;
Begin
dec(ix.W);
inc(t_state,6);
end;

procedure dec_iy;
Begin
dec(iy.W);
inc(t_state,6);
end;

procedure dec_hl;
Begin
dec(hl.W);
inc(t_state,6);
end;

procedure inc_ixl;
Begin
af.l:=inc_f[ix.l] or (af.l and 1); 
inc(ix.l);
inc(t_state,4);
end;

procedure inc_iyl;
Begin
af.l:=inc_f[iy.l] or (af.l and 1); 
inc(iy.l);
inc(t_state,4);
end;

procedure inc_l;
Begin
af.l:=inc_f[hl.l] or (af.l and 1); 
inc(hl.l);
inc(t_state,4);
end;

procedure dec_ixl;
Begin
af.l:=dec_f[ix.l] or (af.l and 1); 
dec(ix.l);
inc(t_state,4);
end;

procedure dec_iyl;
Begin
af.l:=dec_f[iy.l] or (af.l and 1); 
dec(iy.l);
inc(t_state,4);
end;

procedure dec_l;
Begin
af.l:=dec_f[hl.l] or (af.l and 1); 
dec(hl.l);
inc(t_state,4);
end;

procedure ld_ixl_XX;
Begin
ix.l:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure ld_iyl_XX;
Begin
iy.l:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure ld_l_XX;
Begin
hl.l:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure cpl;
Begin
af.h:=af.h xor 255;
af.l:=af.l or 18; 
copy_b53(af.h);
inc(t_state,4);
end;

procedure jr_nc_DIS;
Begin
if af.l and 1=0 then
Begin
 pc.W:=pc.w + shortint(peekb(pc.W))+1;
 inc(t_state,12);
end
else
Begin
 inc(pc.W);
 inc(t_state,7);
end
end;

procedure ld_sp_XXXX;
Begin
sp.W:=peekw(pc.W);
inc(pc.W,2);
inc(t_state,10);
end;

procedure ld_aXXXX_a;
Begin
pokeb(peekw(pc.W),af.h);
inc(pc.W,2);
inc(t_state,13);
end;

procedure inc_sp;
Begin
inc(sp.W);
inc(t_state,6);
end;

procedure inc_mix;
var btemp: Byte;
    dis:Shortint;
Begin
dis:=peekb(pc.W);
inc(pc.W);
btemp:=peekb(ix.W+dis);
af.l:=inc_f[btemp] or (af.l and 1); 
pokeb(ix.W+dis,btemp+1);
inc(t_state,19);
end;

procedure inc_miy;
var btemp: Byte;
    dis:shortint;
Begin

dis:=peekb(pc.W);
inc(pc.W);
btemp:=peekb(iy.W+dis);
af.l:=inc_f[btemp] or (af.l and 1); 
pokeb(iy.W+dis,btemp+1);
inc(t_state,19);
end;

procedure inc_mhl;
var btemp: Byte;
Begin
btemp:=peekb(hl.W);
af.l:=inc_f[btemp] or (af.l and 1); 
pokeb(hl.W,btemp+1);
inc(t_state,11);
end;

procedure dec_mix;
var btemp: Byte;
    dis: shortint;
Begin
dis:=peekb(pc.W);
inc(pc.W);
btemp:=peekb(ix.W+dis);
af.l:=dec_f[btemp] or (af.l and 1); 
pokeb(ix.W+dis,btemp-1);
inc(t_state,19);
end;

procedure dec_miy;
var btemp: Byte;
    dis: shortint;
Begin
dis:=peekb(pc.W);
inc(pc.W);
btemp:=peekb(iy.W+dis);
af.l:=dec_f[btemp] or (af.l and 1); 
pokeb(iy.W+dis,btemp-1);
inc(t_state,19);
end;

procedure dec_mhl;
var btemp: Byte;
Begin
btemp:=peekb(hl.W);
af.l:=dec_f[btemp] or (af.l and 1); 
pokeb(hl.W,btemp-1);
inc(t_state,11);
end;

procedure ld_mix_XX;
var dis: shortint;
Begin
dis:=peekb(pc.W);
inc(pc.W);
pokeb(ix.W+dis,peekb(pc.W));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_miy_XX;
var dis: shortint;
Begin
dis:=peekb(pc.W);
inc(pc.W);
pokeb(iy.W+dis,peekb(pc.W));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_mhl_XX;
Begin
pokeb(hl.W,peekb(pc.W));
inc(pc.W);
inc(t_state,10);
end;

procedure scf;
Begin
af.l:=af.l and 237; 
copy_b53(af.h);
af.l:=af.l Or 1;
inc(t_state,4);
end;

procedure jr_c_DIS;
Begin
if af.l and 1>0 then
Begin
pc.W:=pc.w + shortint(peekb(pc.W))+1;
inc(t_state,12);
end
else
Begin
inc(pc.W);
inc(t_state,7);
end
end;

procedure add_ix_sp;
Begin
add16(ix.W,sp.W);
inc(t_state,11);
end;

procedure add_iy_sp;
Begin
add16(iy.W,sp.W);
inc(t_state,11);
end;

procedure add_hl_sp;
Begin
add16(hl.W,sp.W);
inc(t_state,11);
end;

procedure ld_a_aXXXX;
Begin
af.h:=peekb(peekw(pc.W));
inc(pc.W,2);
inc(t_state,13);
end;

procedure dec_sp;
Begin
dec(sp.W);
inc(t_state,6);
end;

procedure Z80inc_a;
Begin
af.l:=inc_f[af.h] or (af.l and 1); 
inc(af.h);
inc(t_state,4);
end;

procedure Z80dec_a;
Begin
af.l:=dec_f[af.h] or (af.l and 1); 
dec(af.h);
inc(t_state,4);
end;

procedure ld_a_XX;
Begin
af.h:=peekb(pc.W);
inc(pc.W);
inc(t_state,7);
end;

procedure ccf;
Begin
af.l:=af.l xor 1;
af.l:=af.l And 253;
copy_b53(af.h);
inc(t_state,4);
end;

procedure ld_b_b;
Begin
bc.h:=bc.h;
inc(t_state,4);
end;

procedure ld_b_c;
Begin
bc.h:=bc.l;
inc(t_state,4);
end;

procedure ld_b_d;
Begin
bc.h:=de.h;
inc(t_state,4);
end;

procedure ld_b_e;
Begin
bc.h:=de.l;
inc(t_state,4);
end;

procedure ld_b_ixh;
Begin
bc.h:=ix.h;
inc(t_state,4);
end;

procedure ld_b_iyh;
Begin
bc.h:=iy.h;
inc(t_state,4);
end;

procedure ld_b_h;
Begin
bc.h:=hl.h;
inc(t_state,4);
end;

procedure ld_b_ixl;
Begin
bc.h:=ix.l;
inc(t_state,4);
end;

procedure ld_b_iyl;
Begin
bc.h:=iy.l;
inc(t_state,4);
end;

procedure ld_b_l;
Begin
bc.h:=hl.l;
inc(t_state,4);
end;

procedure ld_b_ix;
Begin
bc.h:=peekb(ix.W+ shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_b_iy;
Begin
bc.h:=peekb(iy.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_b_hl;
Begin
bc.h:=peekb(hl.W);
inc(t_state,7);
end;

procedure ld_b_a;
Begin
bc.h:=af.h;
inc(t_state,4);
end;

procedure ld_c_b;
Begin
bc.l:=bc.h;
inc(t_state,4);
end;

procedure ld_c_c;
Begin
bc.l:=bc.l;
inc(t_state,4);
end;

procedure ld_c_d;
Begin
bc.l:=de.h;
inc(t_state,4);
end;

procedure ld_c_e;
Begin
bc.l:=de.l;
inc(t_state,4);
end;

procedure ld_c_ixh;
Begin
bc.l:=ix.h;
inc(t_state,4);
end;

procedure ld_c_iyh;
Begin
bc.l:=iy.h;
inc(t_state,4);
end;

procedure ld_c_h;
Begin
bc.l:=hl.h;
inc(t_state,4);
end;

procedure ld_c_ixl;
Begin
bc.l:=ix.l;
inc(t_state,4);
end;

procedure ld_c_iyl;
Begin
bc.l:=iy.l;
inc(t_state,4);
end;

procedure ld_c_l;
Begin
bc.l:=hl.l;
inc(t_state,4);
end;

procedure ld_c_ix;
Begin
bc.l:=peekb(ix.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_c_iy;
Begin
bc.l:=peekb(iy.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_c_hl;
Begin
bc.l:=peekb(hl.W);
inc(t_state,7);
end;

procedure ld_c_a;
Begin
bc.l:=af.h;
inc(t_state,4);
end;

procedure ld_d_b;
Begin
de.h:=bc.h;
inc(t_state,4);
end;

procedure ld_d_c;
Begin
de.h:=bc.l;
inc(t_state,4);
end;

procedure ld_d_d;
Begin
de.h:=de.h;
inc(t_state,4);
end;

procedure ld_d_e;
Begin
de.h:=de.l;
inc(t_state,4);
end;

procedure ld_d_ixh;
Begin
de.h:=ix.h;
inc(t_state,4);
end;

procedure ld_d_iyh;
Begin
de.h:=iy.h;
inc(t_state,4);
end;

procedure ld_d_h;
Begin
de.h:=hl.h;
inc(t_state,4);
end;

procedure ld_d_ixl;
Begin
de.h:=ix.l;
inc(t_state,4);
end;

procedure ld_d_iyl;
Begin
de.h:=iy.l;
inc(t_state,4);
end;

procedure ld_d_l;
Begin
de.h:=hl.l;
inc(t_state,4);
end;

procedure ld_d_ix;
Begin
de.h:=peekb(ix.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_d_iy;
Begin
de.h:=peekb(iy.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_d_hl;
Begin
de.h:=peekb(hl.W);
inc(t_state,7);
end;

procedure ld_d_a;
Begin
de.h:=af.h;
inc(t_state,4);
end;

procedure ld_e_b;
Begin
de.l:=bc.h;
inc(t_state,4);
end;

procedure ld_e_c;
Begin
de.l:=bc.l;
inc(t_state,4);
end;

procedure ld_e_d;
Begin
de.l:=de.h;
inc(t_state,4);
end;

procedure ld_e_e;
Begin
de.l:=de.l;
inc(t_state,4);
end;

procedure ld_e_ixh;
Begin
de.l:=ix.h;
inc(t_state,4);
end;

procedure ld_e_iyh;
Begin
de.l:=iy.h;
inc(t_state,4);
end;

procedure ld_e_h;
Begin
de.l:=hl.h;
inc(t_state,4);
end;

procedure ld_e_ixl;
Begin
de.l:=ix.l;
inc(t_state,4);
end;

procedure ld_e_iyl;
Begin
de.l:=iy.l;
inc(t_state,4);
end;

procedure ld_e_l;
Begin
de.l:=hl.l;
inc(t_state,4);
end;

procedure ld_e_ix;
Begin
de.l:=peekb(ix.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_e_iy;
Begin
de.l:=peekb(iy.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_e_hl;
Begin
de.l:=peekb(hl.W);
inc(t_state,7);
end;

procedure ld_e_a;
Begin
de.l:=af.h;
inc(t_state,4);
end;

procedure ld_ixh_b;
Begin
ix.h:=bc.h;
inc(t_state,4);
end;

procedure ld_iyh_b;
Begin
iy.h:=bc.h;
inc(t_state,4);
end;

procedure ld_h_b;
Begin
hl.h:=bc.h;
inc(t_state,4);
end;

procedure ld_ixh_c;
Begin
ix.h:=bc.l;
inc(t_state,4);
end;

procedure ld_iyh_c;
Begin
iy.h:=bc.l;
inc(t_state,4);
end;

procedure ld_h_c;
Begin
hl.h:=bc.l;
inc(t_state,4);
end;

procedure ld_ixh_d;
Begin
ix.h:=de.h;
inc(t_state,4);
end;

procedure ld_iyh_d;
Begin
iy.h:=de.h;
inc(t_state,4);
end;

procedure ld_h_d;
Begin
hl.h:=de.h;
inc(t_state,4);
end;

procedure ld_ixh_e;
Begin
ix.h:=de.l;
inc(t_state,4);
end;

procedure ld_iyh_e;
Begin
iy.h:=de.l;
inc(t_state,4);
end;

procedure ld_h_e;
Begin
hl.h:=de.l;
inc(t_state,4);
end;

procedure ld_ixh_ixh;
Begin
ix.h:=ix.h;
inc(t_state,4);
end;

procedure ld_iyh_iyh;
Begin
iy.h:=iy.h;
inc(t_state,4);
end;

procedure ld_h_h;
Begin
hl.h:=hl.h;
inc(t_state,4);
end;

procedure ld_ixh_ixl;
Begin
ix.h:=ix.l;
inc(t_state,4);
end;

procedure ld_iyh_iyl;
Begin
iy.h:=iy.l;
inc(t_state,4);
end;

procedure ld_h_l;
Begin
hl.h:=hl.l;
inc(t_state,4);
end;

procedure ld_h_ix;
Begin
hl.h:=peekb(ix.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_h_iy;
Begin
hl.h:=peekb(iy.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_h_hl;
Begin
hl.h:=peekb(hl.W);
inc(t_state,7);
end;

procedure ld_ixh_a;
Begin
ix.h:=af.h;
inc(t_state,4);
end;

procedure ld_iyh_a;
Begin
iy.h:=af.h;
inc(t_state,4);
end;

procedure ld_h_a;
Begin
hl.h:=af.h;
inc(t_state,4);
end;

procedure ld_ixl_b;
Begin
ix.l:=bc.h;
inc(t_state,4);
end;

procedure ld_iyl_b;
Begin
iy.l:=bc.h;
inc(t_state,4);
end;

procedure ld_l_b;
Begin
hl.l:=bc.h;
inc(t_state,4);
end;

procedure ld_ixl_c;
Begin
ix.l:=bc.l;
inc(t_state,4);
end;

procedure ld_iyl_c;
Begin
iy.l:=bc.l;
inc(t_state,4);
end;

procedure ld_l_c;
Begin
hl.l:=bc.l;
inc(t_state,4);
end;

procedure ld_ixl_d;
Begin
ix.l:=de.h;
inc(t_state,4);
end;

procedure ld_iyl_d;
Begin
iy.l:=de.h;
inc(t_state,4);
end;

procedure ld_l_d;
Begin
hl.l:=de.h;
inc(t_state,4);
end;

procedure ld_ixl_e;
Begin
ix.l:=de.l;
inc(t_state,4);
end;

procedure ld_iyl_e;
Begin
iy.l:=de.l;
inc(t_state,4);
end;

procedure ld_l_e;
Begin
hl.l:=de.l;
inc(t_state,4);
end;

procedure ld_ixl_ixh;
Begin
ix.l:=ix.h;
inc(t_state,4);
end;

procedure ld_iyl_iyh;
Begin
iy.l:=iy.h;
inc(t_state,4);
end;

procedure ld_l_h;
Begin
hl.l:=hl.h;
inc(t_state,4);
end;

procedure ld_ixl_ixl;
Begin
ix.l:=ix.l;
inc(t_state,4);
end;

procedure ld_iyl_iyl;
Begin
iy.l:=iy.l;
inc(t_state,4);
end;

procedure ld_l_l;
Begin
hl.l:=hl.l;
inc(t_state,4);
end;

procedure ld_l_ix;
Begin
hl.l:=peekb(ix.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_l_iy;
Begin
hl.l:=peekb(iy.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_l_hl;
Begin
hl.l:=peekb(hl.W);
inc(t_state,7);
end;

procedure ld_ixl_a;
Begin
ix.l:=af.h;
inc(t_state,4);
end;

procedure ld_iyl_a;
Begin
iy.l:=af.h;
inc(t_state,4);
end;

procedure ld_l_a;
Begin
hl.l:=af.h;
inc(t_state,4);
end;

procedure ld_ix_b;
Begin
pokeb(ix.W+shortint(peekb(pc.W)),bc.h);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_iy_b;
Begin
pokeb(iy.W+shortint(peekb(pc.W)),bc.h);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_hl_b;
Begin
pokeb(hl.W,bc.h);
inc(t_state,7);
end;

procedure ld_ix_c;
Begin
pokeb(ix.W+shortint(peekb(pc.W)),bc.l);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_iy_c;
Begin
pokeb(iy.W+shortint(peekb(pc.W)),bc.l);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_hl_c;
Begin
pokeb(hl.W,bc.l);
inc(t_state,7);
end;

procedure ld_ix_d;
Begin
pokeb(ix.W+shortint(peekb(pc.W)),de.h);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_iy_d;
Begin
pokeb(iy.W+shortint(peekb(pc.W)),de.h);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_hl_d;
Begin
pokeb(hl.W,de.h);
inc(t_state,7);
end;

procedure ld_ix_e;
Begin
pokeb(ix.W+shortint(peekb(pc.W)),de.l);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_iy_e;
Begin
pokeb(iy.W+shortint(peekb(pc.W)),de.l);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_hl_e;
Begin
pokeb(hl.W,de.l);
inc(t_state,7);
end;

procedure ld_ix_h;
Begin
pokeb(ix.W+shortint(peekb(pc.W)),hl.h);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_iy_h;
Begin
pokeb(iy.W+shortint(peekb(pc.W)),hl.h);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_hl_h;
Begin
pokeb(hl.W,hl.h);
inc(t_state,7);
end;

procedure ld_ix_l;
Begin
pokeb(ix.W+shortint(peekb(pc.W)),hl.l);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_iy_l;
Begin
pokeb(iy.W+shortint(peekb(pc.W)),hl.l);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_hl_l;
Begin
pokeb(hl.W,hl.l);
inc(t_state,7);
end;

procedure Z80halt;
Begin
halt:=true;
inc(t_state,4);
end;

procedure ld_ix_a;
Begin
pokeb(ix.W+shortint(peekb(pc.W)),af.h);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_iy_a;
Begin
pokeb(iy.W+shortint(peekb(pc.W)),af.h);
inc(pc.W);
inc(t_state,15);
end;

procedure ld_hl_a;
Begin
pokeb(hl.W,af.h);
inc(t_state,7);
end;

procedure ld_a_b;
Begin
af.h:=bc.h;
inc(t_state,4);
end;

procedure ld_a_c;
Begin
af.h:=bc.l;
inc(t_state,4);
end;

procedure ld_a_d;
Begin
af.h:=de.h;
inc(t_state,4);
end;

procedure ld_a_e;
Begin
af.h:=de.l;
inc(t_state,4);
end;

procedure ld_a_ixh;
Begin
af.h:=ix.h;
inc(t_state,4);
end;

procedure ld_a_iyh;
Begin
af.h:=iy.h;
inc(t_state,4);
end;

procedure ld_a_h;
Begin
af.h:=hl.h;
inc(t_state,4);
end;

procedure ld_a_ixl;
Begin
af.h:=ix.l;
inc(t_state,4);
end;

procedure ld_a_iyl;
Begin
af.h:=iy.l;
inc(t_state,4);
end;

procedure ld_a_l;
Begin
af.h:=hl.l;
inc(t_state,4);
end;

procedure ld_a_ix;
Begin
af.h:=peekb(ix.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_a_iy;
Begin
af.h:=peekb(iy.W+shortint(peekb(pc.W)));
inc(pc.W);
inc(t_state,15);
end;

procedure ld_a_hl;
Begin
af.h:=peekb(hl.W);
inc(t_state,7);
end;

procedure ld_a_a;
Begin
af.h:=af.h;
inc(t_state,4);
end;

procedure add_a_b;
Begin
add8(af.h,bc.h);
inc(t_state,4);
end;

procedure add_a_c;
Begin
add8(af.h,bc.l);
inc(t_state,4);
end;

procedure add_a_d;
Begin
add8(af.h,de.h);
inc(t_state,4);
end;

procedure add_a_e;
Begin
add8(af.h,de.l);
inc(t_state,4);
end;

procedure add_a_ixh;
Begin
add8(af.h,ix.h);
inc(t_state,4);
end;

procedure add_a_iyh;
Begin
add8(af.h,iy.h);
inc(t_state,4);
end;

procedure add_a_h;
Begin
add8(af.h,hl.h);
inc(t_state,4);
end;

procedure add_a_ixl;
Begin
add8(af.h,ix.l);
inc(t_state,4);
end;

procedure add_a_iyl;
Begin
add8(af.h,iy.l);
inc(t_state,4);
end;

procedure add_a_l;
Begin
add8(af.h,hl.l);
inc(t_state,4);
end;

procedure add_a_ix;
Begin
add8(af.h,peekb(ix.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure add_a_iy;
Begin
add8(af.h,peekb(iy.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure add_a_hl;
Begin
add8(af.h,peekb(hl.W));
inc(t_state,7);
end;

procedure add_a_a;
Begin
add8(af.h,af.h);
inc(t_state,4);
end;

procedure adc_a_b;
Begin
adc8(af.h,bc.h);
inc(t_state,4);
end;

procedure adc_a_c;
Begin
adc8(af.h,bc.l);
inc(t_state,4);
end;

procedure adc_a_d;
Begin
adc8(af.h,de.h);
inc(t_state,4);
end;

procedure adc_a_e;
Begin
adc8(af.h,de.l);
inc(t_state,4);
end;

procedure adc_a_ixh;
Begin
adc8(af.h,ix.h);
inc(t_state,4);
end;

procedure adc_a_iyh;
Begin
adc8(af.h,iy.h);
inc(t_state,4);
end;

procedure adc_a_h;
Begin
adc8(af.h,hl.h);
inc(t_state,4);
end;

procedure adc_a_ixl;
Begin
adc8(af.h,ix.l);
inc(t_state,4);
end;

procedure adc_a_iyl;
Begin
adc8(af.h,iy.l);
inc(t_state,4);
end;

procedure adc_a_l;
Begin
adc8(af.h,hl.l);
inc(t_state,4);
end;

procedure adc_a_ix;
Begin
adc8(af.h,peekb(ix.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure adc_a_iy;
Begin
adc8(af.h,peekb(iy.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure adc_a_hl;
Begin
adc8(af.h,peekb(hl.W));
inc(t_state,7);
end;

procedure adc_a_a;
Begin
adc8(af.h,af.h);
inc(t_state,4);
end;

procedure sub_b;
Begin
sub8(af.h,bc.h);
inc(t_state,4);
end;

procedure sub_c;
Begin
sub8(af.h,bc.l);
inc(t_state,4);
end;

procedure sub_d;
Begin
sub8(af.h,de.h);
inc(t_state,4);
end;

procedure sub_e;
Begin
sub8(af.h,de.l);
inc(t_state,4);
end;

procedure sub_ixh;
Begin
sub8(af.h,ix.h);
inc(t_state,4);
end;

procedure sub_iyh;
Begin
sub8(af.h,iy.h);
inc(t_state,4);
end;

procedure sub_h;
Begin
sub8(af.h,hl.h);
inc(t_state,4);
end;

procedure sub_ixl;
Begin
sub8(af.h,ix.l);
inc(t_state,4);
end;

procedure sub_iyl;
Begin
sub8(af.h,iy.l);
inc(t_state,4);
end;

procedure sub_l;
Begin
sub8(af.h,hl.l);
inc(t_state,4);
end;

procedure sub_ix;
Begin
sub8(af.h,peekb(ix.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure sub_iy;
Begin
sub8(af.h,peekb(iy.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure sub_hl;
Begin
sub8(af.h,peekb(hl.W));
inc(t_state,7);
end;

procedure sub_a;
Begin
sub8(af.h,af.h);
inc(t_state,4);
end;

procedure sbc_a_b;
Begin
sbc8(af.h,bc.h);
inc(t_state,4);
end;

procedure sbc_a_c;
Begin
sbc8(af.h,bc.l);
inc(t_state,4);
end;

procedure sbc_a_d;
Begin
sbc8(af.h,de.h);
inc(t_state,4);
end;

procedure sbc_a_e;
Begin
sbc8(af.h,de.l);
inc(t_state,4);
end;

procedure sbc_a_ixh;
Begin
sbc8(af.h,ix.h);
inc(t_state,4);
end;

procedure sbc_a_iyh;
Begin
sbc8(af.h,iy.h);
inc(t_state,4);
end;

procedure sbc_a_h;
Begin
sbc8(af.h,hl.h);
inc(t_state,4);
end;

procedure sbc_a_ixl;
Begin
sbc8(af.h,ix.l);
inc(t_state,4);
end;

procedure sbc_a_iyl;
Begin
sbc8(af.h,iy.l);
inc(t_state,4);
end;

procedure sbc_a_l;
Begin
sbc8(af.h,hl.l);
inc(t_state,4);
end;

procedure sbc_a_ix;
Begin
sbc8(af.h,peekb(ix.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure sbc_a_iy;
Begin
sbc8(af.h,peekb(iy.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure sbc_a_hl;
Begin
sbc8(af.h,peekb(hl.W));
inc(t_state,7);
end;

procedure sbc_a_a;
Begin
sbc8(af.h,af.h);
inc(t_state,4);
end;

procedure and_b;
Begin
anda(bc.h);
inc(t_state,4);
end;

procedure and_c;
Begin
anda(bc.l);
inc(t_state,4);
end;

procedure and_d;
Begin
anda(de.h);
inc(t_state,4);
end;

procedure and_e;
Begin
anda(de.l);
inc(t_state,4);
end;

procedure and_ixh;
Begin
anda(ix.h);
inc(t_state,4);
end;

procedure and_iyh;
Begin
anda(iy.h);
inc(t_state,4);
end;

procedure and_h;
Begin
anda(hl.h);
inc(t_state,4);
end;

procedure and_ixl;
Begin
anda(ix.l);
inc(t_state,4);
end;

procedure and_iyl;
Begin
anda(iy.l);
inc(t_state,4);
end;

procedure and_l;
Begin
anda(hl.l);
inc(t_state,4);
end;

procedure and_ix;
Begin
anda(peekb(ix.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure and_iy;
Begin
anda(peekb(iy.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure and_hl;
Begin
anda(peekb(hl.W));
inc(t_state,7);
end;

procedure and_a;
Begin
anda(af.h);
inc(t_state,4);
end;

procedure xor_b;
Begin
xora(bc.h);
inc(t_state,4);
end;

procedure xor_c;
Begin
xora(bc.l);
inc(t_state,4);
end;

procedure xor_d;
Begin
xora(de.h);
inc(t_state,4);
end;

procedure xor_e;
Begin
xora(de.l);
inc(t_state,4);
end;

procedure xor_ixh;
Begin
xora(ix.h);
inc(t_state,4);
end;

procedure xor_iyh;
Begin
xora(iy.h);
inc(t_state,4);
end;

procedure xor_h;
Begin
xora(hl.h);
inc(t_state,4);
end;

procedure xor_ixl;
Begin
xora(ix.l);
inc(t_state,4);
end;

procedure xor_iyl;
Begin
xora(iy.l);
inc(t_state,4);
end;

procedure xor_l;
Begin
xora(hl.l);
inc(t_state,4);
end;

procedure xor_ix;
Begin
xora(peekb(ix.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure xor_iy;
Begin
xora(peekb(iy.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure xor_hl;
Begin
xora(peekb(hl.W));
inc(t_state,7);
end;

procedure xor_a;
Begin
xora(af.h);
inc(t_state,4);
end;

procedure or_b;
Begin
ora(bc.h);
inc(t_state,4);
end;

procedure or_c;
Begin
ora(bc.l);
inc(t_state,4);
end;

procedure or_d;
Begin
ora(de.h);
inc(t_state,4);
end;

procedure or_e;
Begin
ora(de.l);
inc(t_state,4);
end;

procedure or_ixh;
Begin
ora(ix.h);
inc(t_state,4);
end;

procedure or_iyh;
Begin
ora(iy.h);
inc(t_state,4);
end;

procedure or_h;
Begin
ora(hl.h);
inc(t_state,4);
end;

procedure or_ixl;
Begin
ora(ix.l);
inc(t_state,4);
end;

procedure or_iyl;
Begin
ora(iy.l);
inc(t_state,4);
end;

procedure or_l;
Begin
ora(hl.l);
inc(t_state,4);
end;

procedure or_ix;
Begin
ora(peekb(ix.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure or_iy;
Begin
ora(peekb(iy.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure or_hl;
Begin
ora(peekb(hl.W));
inc(t_state,7);
end;

procedure or_a;
Begin
ora(af.h);
inc(t_state,4);
end;

procedure cp_b;
Begin
cp_sub8(af.h,bc.h);
inc(t_state,4);
end;

procedure cp_c;
Begin
cp_sub8(af.h,bc.l);
inc(t_state,4);
end;

procedure cp_d;
Begin
cp_sub8(af.h,de.h);
inc(t_state,4);
end;

procedure cp_e;
Begin
cp_sub8(af.h,de.l);
inc(t_state,4);
end;

procedure cp_ixh;
Begin
cp_sub8(af.h,ix.h);
inc(t_state,4);
end;

procedure cp_iyh;
Begin
cp_sub8(af.h,iy.h);
inc(t_state,4);
end;

procedure cp_h;
Begin
cp_sub8(af.h,hl.h);
inc(t_state,4);
end;

procedure cp_ixl;
Begin
cp_sub8(af.h,ix.l);
inc(t_state,4);
end;

procedure cp_iyl;
Begin
cp_sub8(af.h,iy.l);
inc(t_state,4);
end;

procedure cp_l;
Begin
cp_sub8(af.h,hl.l);
inc(t_state,4);
end;

procedure cp_ix;
Begin
cp_sub8(af.h,peekb(ix.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure cp_iy;
Begin
cp_sub8(af.h,peekb(iy.W+shortint(peekb(pc.W))));
inc(pc.W);
inc(t_state,15);
end;

procedure cp_hl;
Begin
cp_sub8(af.h,peekb(hl.W));
inc(t_state,7);
end;

procedure cp_a_;
Begin
cp_sub8(af.h,af.h);
inc(t_state,4);
end;

procedure ret_nz;
Begin
if af.l and 64=0 then
 Begin
  pop(pc.W);
  inc(t_state,11);
 end else inc(t_state,5);
end;

procedure pop_bc;
Begin
pop(bc.W);
inc(t_state,10);
end;

procedure jp_nz_XXXX;
Begin
if af.l and 64=0 then
Begin
 pc.W:=peekw(pc.W);
 inc(t_state,10);
end
else
Begin
 inc(pc.W,2);
 inc(t_state,10);
end
end;

procedure jp_XXXX;
Begin
pc.W:=peekw(pc.W);
inc(t_state,10);
end;

procedure call_nz_XXXX;
Begin
if af.l and 64=0 then
Begin
 push(pc.W+2);
 pc.W:=peekw(pc.W);
 inc(t_state,17);
end
else
Begin
 inc(pc.W,2);
 inc(t_state,10);
end
end;

procedure push_bc;
Begin
 push(bc.W);
 inc(t_state,11);
end;

procedure add_a_XX;
Begin
add8(af.h,peekb(pc.W));
inc(pc.W);
inc(t_state,7);
end;

procedure rst_0;
Begin
push(pc.W);
pc.W:=0;
inc(t_state,11);
end;

procedure ret_z;
Begin
if af.l and 64>0 then
Begin
 pop(pc.W);
 inc(t_state,11);
end
else inc(t_state,5);
end;

procedure ret;
Begin
pop(pc.W);
inc(t_state,10);
end;

procedure jp_z_XXXX;
Begin
if af.l and 64>0 then
Begin
pc.W:=peekw(pc.W);
inc(t_state,10);
end
else
Begin
inc(pc.W,2);
inc(t_state,10); 
end
end;

procedure call_z_XXXX;
Begin
if af.l and 64>0 then
Begin
push(pc.W+2);
pc.W:=peekw(pc.W);
inc(t_state,17);
end
else
Begin
inc(pc.W,2);
inc(t_state,10);
end
end;

procedure call_XXXX;
Begin
push(pc.W+2);
pc.W:=peekw(pc.W);
inc(t_state,17);
end;

procedure adc_a_XX;
Begin
adc8(af.h,peekb(pc.W));
inc(pc.W);
inc(t_state,7);
end;

procedure rst_8;
Begin
push(pc.W);
pc.W:=8;
inc(t_state,11);
end;

procedure ret_nc;
Begin
if af.l and 1=0 then
Begin
pop(pc.W);
inc(t_state,11);
end
else inc(t_state,5);
end;

procedure pop_de;
Begin
pop(de.W);
inc(t_state,10);
end;

procedure jp_nc_XXXX;
Begin
if af.l and 1=0 then
Begin
pc.W:=peekw(pc.W);
inc(t_state,10);
end
else
Begin
inc(pc.W,2);
inc(t_state,10); 
end
end;

procedure out_XX_a;
Begin
outb(word(af.h shl 8) or peekb(pc.W),af.h);
inc(pc.W);
inc(t_state,11);
end;

procedure call_nc_XXXX;
Begin
if af.l and 1=0 then
Begin
push(pc.W+2);
pc.W:=peekw(pc.W);
inc(t_state,17);
end
else
Begin
inc(pc.W,2);
inc(t_state,10);
end
end;

procedure push_de;
Begin
push(de.W);
inc(t_state,11);
end;

procedure sub_XX;
Begin
sub8(af.h,peekb(pc.W));
inc(pc.W);
inc(t_state,7);
end;

procedure rst_16;
Begin
push(pc.W);
pc.W:=16;
inc(t_state,11);
end;

procedure ret_c;
Begin
if af.l and 1>0 then
Begin
pop(pc.W);
inc(t_state,11);
end
else inc(t_state,5);
end;

procedure exx;
var temp: word;
Begin
 {temp:=af.W;af.W:=af2.W;af2.W:=temp;}
 temp:=bc.W;bc.W:=bc2.W;bc2.W:=temp;
 temp:=de.W;de.W:=de2.W;de2.W:=temp;
 temp:=hl.W;hl.W:=hl2.W;hl2.W:=temp;
 inc(t_state,4);
end;

procedure jp_c_XXXX;
Begin
if af.l and 1>0 then
Begin
pc.W:=peekw(pc.W);
inc(t_state,10);
end
else
Begin
inc(pc.W,2);
inc(t_state,10); 
end
end;

procedure in_a_XX;
Begin
af.h:=inb(af.h shl 8+peekb(pc.W));
inc(pc.W);
inc(t_state,11);
end;

procedure call_c_XXXX;
Begin
if af.l and 1>0 then
Begin
push(pc.W+2);
pc.W:=peekw(pc.W);
inc(t_state,17);
end
else
Begin
inc(pc.W,2);
inc(t_state,10);
end
end;

procedure sbc_a_XX;
Begin
sbc8(af.h,peekb(pc.W));
inc(pc.W);
inc(t_state,7);
end;

procedure rst_24;
Begin
push(pc.W);
pc.W:=24;
inc(t_state,11);
end;

procedure ret_po;
Begin
if af.l and 4=0 then
Begin
pop(pc.W);
inc(t_state,11);
end
else inc(t_state,5);
end;

procedure pop_ix;
Begin
pop(ix.W);
inc(t_state,10);
end;

procedure pop_iy;
Begin
pop(iy.W);
inc(t_state,10);
end;

procedure pop_hl;
Begin
pop(hl.W);
inc(t_state,10);
end;

procedure jp_po_XXXX;
Begin
if af.l and 4=0 then
Begin
 pc.W:=peekw(pc.W);
 inc(t_state,10);
end
else
Begin
 inc(pc.W,2);
 inc(t_state,10);
end
end;

procedure ex_msp_ix;
var temp:Word;
Begin
temp:=peekw(sp.W);
pokew(sp.W,ix.W);
ix.W:=temp;
inc(t_state,19);
end;

procedure ex_msp_iy;
var temp:Word;
Begin
temp:=peekw(sp.W);
pokew(sp.W,iy.W);
iy.W:=temp;
inc(t_state,19);
end;

procedure ex_msp_hl;
var temp:Word;
Begin
temp:=peekw(sp.W);
pokew(sp.W,hl.W);
hl.W:=temp;
inc(t_state,4);
end;

procedure call_po_XXXX;
Begin
        if af.l and 4=0 then
Begin
push(pc.W+2);
pc.W:=peekw(pc.W);
inc(t_state,17);
end
else
Begin
inc(pc.W,2);
inc(t_state,10);
end
end;

procedure push_ix;
Begin
push(ix.W);
inc(t_state,11);
end;

procedure push_iy;
Begin
push(iy.W);
inc(t_state,11);
end;

procedure push_hl;
Begin
push(hl.W);
inc(t_state,11);
end;

procedure and_XX;
Begin
anda(peekb(pc.W));
inc(pc.W);
inc(t_state,7);
end;

procedure rst_32;
Begin
push(pc.W);
pc.W:=32;
inc(t_state,11);
end;

procedure ret_pe;
Begin
if af.l and 4>0 then
Begin
pop(pc.W);
inc(t_state,11);
end
else inc(t_state,5);
end;

procedure jp_ix;
Begin
pc.W:=ix.W;
inc(t_state,4);
end;

procedure jp_iy;
Begin
pc.W:=iy.W;
inc(t_state,4);
end;

procedure jp_hl;
Begin
pc.W:=hl.W;
inc(t_state,4);
end;

procedure jp_pe_XXXX;
Begin
if af.l and 4>0 then
Begin
pc.W:=peekw(pc.W);
inc(t_state,10);
end
else
Begin
inc(pc.W,2);
inc(t_state,10); 
end
end;

procedure ex_de_ix;
var temp: Word;
Begin
temp:=de.W;
de.W:=ix.W;
ix.W:=temp;
inc(t_state,4);
end;

procedure ex_de_iy;
var temp: word;
Begin
temp:=de.W;
de.W:=iy.W;
iy.W:=temp;
inc(t_state,4);
end;

procedure ex_de_hl;
var temp: word;
Begin
temp:=de.W;
de.W:=hl.W;
hl.W:=temp;
inc(t_state,4);
end;

procedure call_pe_XXXX;
Begin
if af.l and 4>0 then
Begin
push(pc.W+2);
pc.W:=peekw(pc.W);
inc(t_state,17);
end
else
Begin
inc(pc.W,2);
inc(t_state,10);
end
end;

procedure xor_XX;
Begin
xora(peekb(pc.W));
inc(pc.W);
inc(t_state,7);
end;

procedure rst_40;
Begin
push(pc.W);
pc.W:=40;
inc(t_state,11);
end;

procedure ret_p;
Begin
if af.l and 128=0 then
Begin
pop(pc.W);
inc(t_state,11);
end
else inc(t_state,5);
end;

procedure pop_af;
Begin
pop(af.W);
inc(t_state,10);
end;

procedure jp_p_XXXX;
Begin
if af.l and 128=0 then
Begin
pc.W:=peekw(pc.W);
inc(t_state,10);
end
else
Begin
inc(pc.W,2);
inc(t_state,10); 
end
end;

procedure di;
Begin
iff1:=0;
inc(t_state,4);
end;

procedure call_p_XXXX;
Begin
if af.l and 128=0 then
Begin
push(pc.W+2);
pc.W:=peekw(pc.W);
inc(t_state,17);
end
else
Begin
inc(pc.W,2);
inc(t_state,10);
end
end;

procedure push_af;
Begin
push(af.W);
inc(t_state,11);
end;

procedure or_XX;
Begin
ora(peekb(pc.W));
inc(pc.W);
inc(t_state,7);
end;

procedure rst_48;
Begin
push(pc.W);
pc.W:=48;
inc(t_state,11);
end;

procedure ret_m;
Begin
if af.l and 128>0 then
Begin
pop(pc.W);
inc(t_state,11);
end else inc(t_state,5);
end;

procedure ld_sp_ix;
Begin
sp.W:=ix.W;
inc(t_state,6);
end;

procedure ld_sp_iy;
Begin
sp.W:=iy.W;
inc(t_state,6);
end;

procedure ld_sp_hl;
Begin
sp.W:=hl.W;
inc(t_state,6);
end;

procedure jp_m_XXXX;
Begin
if af.l and 128>0 then
Begin
pc.W:=peekw(pc.W);
inc(t_state,10);
end
else
Begin
inc(pc.W,2);
inc(t_state,10); 
end
end;

procedure ei;
Begin
iff1:=1;
inc(t_state,4);
end;

procedure call_m_XXXX;
Begin
if af.l and 128>0 then
Begin
push(pc.W+2);
pc.W:=peekw(pc.W);
inc(t_state,17);
end
else
Begin
inc(pc.W,2);
inc(t_state,10);
end
end;

procedure cp_XX;
Begin
cp_sub8(af.h,peekb(pc.W));
inc(pc.W);
inc(t_state,7);
end;

procedure rst_56;
Begin
push(pc.W);
pc.W:=56;
inc(t_state,11);
end;

procedure IX_Pre;
var b:byte;
begin
inc(ir.l);
b:=peekb(pc.W);
inc(pc.W);
Z80_IX[b];
end;

procedure IY_Pre;
var b:byte;
begin
inc(ir.l);
b:=peekb(pc.W);
inc(pc.w);
Z80_IY[b];
end;

procedure ED_Pre;
var b:byte;
begin
        inc(ir.l);
b:=peekb(pc.W);
inc(pc.w);
ED[b];
end;

procedure  IX_CB_Pre;
var b:byte;
begin
CBdis:=peekb(pc.W);
inc(pc.w);
b:=peekb(pc.W);
inc(pc.w);
        addr:=ix.w+cbdis;
CB[b]; inc(t_state,8);
end;

procedure  IY_CB_Pre;
var b:byte;
begin
CBdis:=peekb(pc.W);
inc(pc.w);
b:=peekb(pc.W);
inc(pc.w);
        addr:=iy.w+cbdis;inc(t_state,8);
CB[b];
end;

procedure  CB_Pre;
var b:byte;
begin
        inc(ir.l);
b:=peekb(pc.W);
inc(pc.w);
        addr:=hl.w;
CB[b];
end;

procedure create_std;
begin
Z80_std[0]:=nop;
Z80_std[1]:=ld_bc_XXXX;
Z80_std[2]:=ld_mbc_a;
Z80_std[3]:=inc_bc;
Z80_std[4]:=inc_b;
Z80_std[5]:=dec_b;
Z80_std[6]:=ld_b_XX;
Z80_std[7]:=rlca;
Z80_std[8]:=ex_af_af;
Z80_std[9]:=add_hl_bc;
Z80_std[10]:=ld_a_mbc;
Z80_std[11]:=dec_bc;
Z80_std[12]:=inc_c;
Z80_std[13]:=dec_c;
Z80_std[14]:=ld_c_XX;
Z80_std[15]:=rrca;
Z80_std[16]:=djnz_DIS;
Z80_std[17]:=ld_de_XXXX;
Z80_std[18]:=ld_mde_a;
Z80_std[19]:=inc_de;
Z80_std[20]:=inc_d;
Z80_std[21]:=dec_d;
Z80_std[22]:=ld_d_XX;
Z80_std[23]:=rla;
Z80_std[24]:=jr_DIS;
Z80_std[25]:=add_hl_de;
Z80_std[26]:=ld_a_mde;
Z80_std[27]:=dec_de;
Z80_std[28]:=inc_e;
Z80_std[29]:=dec_e;
Z80_std[30]:=ld_e_XX;
Z80_std[31]:=rra;
Z80_std[32]:=jr_nz_DIS;
Z80_std[33]:=ld_hl_XXXX;
Z80_std[34]:=Z80ld_aXXXX_hl;
Z80_std[35]:=inc_hl;
Z80_std[36]:=inc_h;
Z80_std[37]:=dec_h;
Z80_std[38]:=ld_h_XX;
Z80_std[39]:=daa;
Z80_std[40]:=jr_z_DIS;
Z80_std[41]:=add_hl_hl;
Z80_std[42]:=Z80ld_hl_aXXXX;
Z80_std[43]:=dec_hl;
Z80_std[44]:=inc_l;
Z80_std[45]:=dec_l;
Z80_std[46]:=ld_l_XX;
Z80_std[47]:=cpl;
Z80_std[48]:=jr_nc_DIS;
Z80_std[49]:=ld_sp_XXXX;
Z80_std[50]:=ld_aXXXX_a;
Z80_std[51]:=inc_sp;
Z80_std[52]:=inc_mhl;
Z80_std[53]:=dec_mhl;
Z80_std[54]:=ld_mhl_XX;
Z80_std[55]:=scf;
Z80_std[56]:=jr_c_DIS;
Z80_std[57]:=add_hl_sp;
Z80_std[58]:=ld_a_aXXXX;
Z80_std[59]:=dec_sp;
Z80_std[60]:=Z80inc_a;
Z80_std[61]:=Z80dec_a;
Z80_std[62]:=ld_a_XX;
Z80_std[63]:=ccf;
Z80_std[64]:=ld_b_b;
Z80_std[65]:=ld_b_c;
Z80_std[66]:=ld_b_d;
Z80_std[67]:=ld_b_e;
Z80_std[68]:=ld_b_h;
Z80_std[69]:=ld_b_l;
Z80_std[70]:=ld_b_hl;
Z80_std[71]:=ld_b_a;
Z80_std[72]:=ld_c_b;
Z80_std[73]:=ld_c_c;
Z80_std[74]:=ld_c_d;
Z80_std[75]:=ld_c_e;
Z80_std[76]:=ld_c_h;
Z80_std[77]:=ld_c_l;
Z80_std[78]:=ld_c_hl;
Z80_std[79]:=ld_c_a;
Z80_std[80]:=ld_d_b;
Z80_std[81]:=ld_d_c;
Z80_std[82]:=ld_d_d;
Z80_std[83]:=ld_d_e;
Z80_std[84]:=ld_d_h;
Z80_std[85]:=ld_d_l;
Z80_std[86]:=ld_d_hl;
Z80_std[87]:=ld_d_a;
Z80_std[88]:=ld_e_b;
Z80_std[89]:=ld_e_c;
Z80_std[90]:=ld_e_d;
Z80_std[91]:=ld_e_e;
Z80_std[92]:=ld_e_h;
Z80_std[93]:=ld_e_l;
Z80_std[94]:=ld_e_hl;
Z80_std[95]:=ld_e_a;
Z80_std[96]:=ld_h_b;
Z80_std[97]:=ld_h_c;
Z80_std[98]:=ld_h_d;
Z80_std[99]:=ld_h_e;
Z80_std[100]:=ld_h_h;
Z80_std[101]:=ld_h_l;
Z80_std[102]:=ld_h_hl;
Z80_std[103]:=ld_h_a;
Z80_std[104]:=ld_l_b;
Z80_std[105]:=ld_l_c;
Z80_std[106]:=ld_l_d;
Z80_std[107]:=ld_l_e;
Z80_std[108]:=ld_l_h;
Z80_std[109]:=ld_l_l;
Z80_std[110]:=ld_l_hl;
Z80_std[111]:=ld_l_a;
Z80_std[112]:=ld_hl_b;
Z80_std[113]:=ld_hl_c;
Z80_std[114]:=ld_hl_d;
Z80_std[115]:=ld_hl_e;
Z80_std[116]:=ld_hl_h;
Z80_std[117]:=ld_hl_l;
Z80_std[118]:=Z80halt;
Z80_std[119]:=ld_hl_a;
Z80_std[120]:=ld_a_b;
Z80_std[121]:=ld_a_c;
Z80_std[122]:=ld_a_d;
Z80_std[123]:=ld_a_e;
Z80_std[124]:=ld_a_h;
Z80_std[125]:=ld_a_l;
Z80_std[126]:=ld_a_hl;
Z80_std[127]:=ld_a_a;
Z80_std[128]:=add_a_b;
Z80_std[129]:=add_a_c;
Z80_std[130]:=add_a_d;
Z80_std[131]:=add_a_e;
Z80_std[132]:=add_a_h;
Z80_std[133]:=add_a_l;
Z80_std[134]:=add_a_hl;
Z80_std[135]:=add_a_a;
Z80_std[136]:=adc_a_b;
Z80_std[137]:=adc_a_c;
Z80_std[138]:=adc_a_d;
Z80_std[139]:=adc_a_e;
Z80_std[140]:=adc_a_h;
Z80_std[141]:=adc_a_l;
Z80_std[142]:=adc_a_hl;
Z80_std[143]:=adc_a_a;
Z80_std[144]:=sub_b;
Z80_std[145]:=sub_c;
Z80_std[146]:=sub_d;
Z80_std[147]:=sub_e;
Z80_std[148]:=sub_h;
Z80_std[149]:=sub_l;
Z80_std[150]:=sub_hl;
Z80_std[151]:=sub_a;
Z80_std[152]:=sbc_a_b;
Z80_std[153]:=sbc_a_c;
Z80_std[154]:=sbc_a_d;
Z80_std[155]:=sbc_a_e;
Z80_std[156]:=sbc_a_h;
Z80_std[157]:=sbc_a_l;
Z80_std[158]:=sbc_a_hl;
Z80_std[159]:=sbc_a_a;
Z80_std[160]:=and_b;
Z80_std[161]:=and_c;
Z80_std[162]:=and_d;
Z80_std[163]:=and_e;
Z80_std[164]:=and_h;
Z80_std[165]:=and_l;
Z80_std[166]:=and_hl;
Z80_std[167]:=and_a;
Z80_std[168]:=xor_b;
Z80_std[169]:=xor_c;
Z80_std[170]:=xor_d;
Z80_std[171]:=xor_e;
Z80_std[172]:=xor_h;
Z80_std[173]:=xor_l;
Z80_std[174]:=xor_hl;
Z80_std[175]:=xor_a;
Z80_std[176]:=or_b;
Z80_std[177]:=or_c;
Z80_std[178]:=or_d;
Z80_std[179]:=or_e;
Z80_std[180]:=or_h;
Z80_std[181]:=or_l;
Z80_std[182]:=or_hl;
Z80_std[183]:=or_a;
Z80_std[184]:=cp_b;
Z80_std[185]:=cp_c;
Z80_std[186]:=cp_d;
Z80_std[187]:=cp_e;
Z80_std[188]:=cp_h;
Z80_std[189]:=cp_l;
Z80_std[190]:=cp_hl;
Z80_std[191]:=cp_a_;
Z80_std[192]:=ret_nz;
Z80_std[193]:=pop_bc;
Z80_std[194]:=jp_nz_XXXX;
Z80_std[195]:=jp_XXXX;
Z80_std[196]:=call_nz_XXXX;
Z80_std[197]:=push_bc;
Z80_std[198]:=add_a_XX;
Z80_std[199]:=rst_0;
Z80_std[200]:=ret_z;
Z80_std[201]:=ret;
Z80_std[202]:=jp_z_XXXX;
Z80_std[203]:=CB_Pre;
Z80_std[204]:=call_z_XXXX;
Z80_std[205]:=call_XXXX;
Z80_std[206]:=adc_a_XX;
Z80_std[207]:=rst_8;
Z80_std[208]:=ret_nc;
Z80_std[209]:=pop_de;
Z80_std[210]:=jp_nc_XXXX;
Z80_std[211]:=out_XX_a;
Z80_std[212]:=call_nc_XXXX;
Z80_std[213]:=push_de;
Z80_std[214]:=sub_XX;
Z80_std[215]:=rst_16;
Z80_std[216]:=ret_c;
Z80_std[217]:=exx;
Z80_std[218]:=jp_c_XXXX;
Z80_std[219]:=in_a_XX;
Z80_std[220]:=call_c_XXXX;
Z80_std[221]:=IX_Pre;
Z80_std[222]:=sbc_a_XX;
Z80_std[223]:=rst_24;
Z80_std[224]:=ret_po;
Z80_std[225]:=pop_hl;
Z80_std[226]:=jp_po_XXXX;
Z80_std[227]:=ex_msp_hl;
Z80_std[228]:=call_po_XXXX;
Z80_std[229]:=push_hl;
Z80_std[230]:=and_XX;
Z80_std[231]:=rst_32;
Z80_std[232]:=ret_pe;
Z80_std[233]:=jp_hl;
Z80_std[234]:=jp_pe_XXXX;
Z80_std[235]:=ex_de_hl;
Z80_std[236]:=call_pe_XXXX;
Z80_std[237]:=ED_Pre;
Z80_std[238]:=xor_XX;
Z80_std[239]:=rst_40;
Z80_std[240]:=ret_p;
Z80_std[241]:=pop_af;
Z80_std[242]:=jp_p_XXXX;
Z80_std[243]:=di;
Z80_std[244]:=call_p_XXXX;
Z80_std[245]:=push_af;
Z80_std[246]:=or_XX;
Z80_std[247]:=rst_48;
Z80_std[248]:=ret_m;
Z80_std[249]:=ld_sp_hl;
Z80_std[250]:=jp_m_XXXX;
Z80_std[251]:=ei;
Z80_std[252]:=call_m_XXXX;
Z80_std[253]:=IY_Pre;
Z80_std[254]:=cp_XX;
Z80_std[255]:=rst_56;

Z80_IX[0]:=nop;
Z80_IX[1]:=ld_bc_XXXX;
Z80_IX[2]:=ld_mbc_a;
Z80_IX[3]:=inc_bc;
Z80_IX[4]:=inc_b;
Z80_IX[5]:=dec_b;
Z80_IX[6]:=ld_b_XX;
Z80_IX[7]:=rlca;
Z80_IX[8]:=ex_af_af;
Z80_IX[9]:=add_ix_bc;
Z80_IX[10]:=ld_a_mbc;
Z80_IX[11]:=dec_bc;
Z80_IX[12]:=inc_c;
Z80_IX[13]:=dec_c;
Z80_IX[14]:=ld_c_XX;
Z80_IX[15]:=rrca;
Z80_IX[16]:=djnz_DIS;
Z80_IX[17]:=ld_de_XXXX;
Z80_IX[18]:=ld_mde_a;
Z80_IX[19]:=inc_de;
Z80_IX[20]:=inc_d;
Z80_IX[21]:=dec_d;
Z80_IX[22]:=ld_d_XX;
Z80_IX[23]:=rla;
Z80_IX[24]:=jr_DIS;
Z80_IX[25]:=add_ix_de;
Z80_IX[26]:=ld_a_mde;
Z80_IX[27]:=dec_de;
Z80_IX[28]:=inc_e;
Z80_IX[29]:=dec_e;
Z80_IX[30]:=ld_e_XX;
Z80_IX[31]:=rra;
Z80_IX[32]:=jr_nz_DIS;
Z80_IX[33]:=ld_ix_XXXX;
Z80_IX[34]:=Z80ld_aXXXX_ix;
Z80_IX[35]:=inc_ix;
Z80_IX[36]:=inc_ixh;
Z80_IX[37]:=dec_ixh;
Z80_IX[38]:=ld_ixh_XX;
Z80_IX[39]:=daa;
Z80_IX[40]:=jr_z_DIS;
Z80_IX[41]:=add_ix_ix;
Z80_IX[42]:=Z80ld_ix_aXXXX;
Z80_IX[43]:=dec_ix;
Z80_IX[44]:=inc_ixl;
Z80_IX[45]:=dec_ixl;
Z80_IX[46]:=ld_ixl_XX;
Z80_IX[47]:=cpl;
Z80_IX[48]:=jr_nc_DIS;
Z80_IX[49]:=ld_sp_XXXX;
Z80_IX[50]:=ld_aXXXX_a;
Z80_IX[51]:=inc_sp;
Z80_IX[52]:=inc_mix;
Z80_IX[53]:=dec_mix;
Z80_IX[54]:=ld_mix_XX;
Z80_IX[55]:=scf;
Z80_IX[56]:=jr_c_DIS;
Z80_IX[57]:=add_ix_sp;
Z80_IX[58]:=ld_a_aXXXX;
Z80_IX[59]:=dec_sp;
Z80_IX[60]:=Z80inc_a;
Z80_IX[61]:=Z80dec_a;
Z80_IX[62]:=ld_a_XX;
Z80_IX[63]:=ccf;
Z80_IX[64]:=ld_b_b;
Z80_IX[65]:=ld_b_c;
Z80_IX[66]:=ld_b_d;
Z80_IX[67]:=ld_b_e;
Z80_IX[68]:=ld_b_ixh;
Z80_IX[69]:=ld_b_ixl;
Z80_IX[70]:=ld_b_ix;
Z80_IX[71]:=ld_b_a;
Z80_IX[72]:=ld_c_b;
Z80_IX[73]:=ld_c_c;
Z80_IX[74]:=ld_c_d;
Z80_IX[75]:=ld_c_e;
Z80_IX[76]:=ld_c_ixh;
Z80_IX[77]:=ld_c_ixl;
Z80_IX[78]:=ld_c_ix;
Z80_IX[79]:=ld_c_a;
Z80_IX[80]:=ld_d_b;
Z80_IX[81]:=ld_d_c;
Z80_IX[82]:=ld_d_d;
Z80_IX[83]:=ld_d_e;
Z80_IX[84]:=ld_d_ixh;
Z80_IX[85]:=ld_d_ixl;
Z80_IX[86]:=ld_d_ix;
Z80_IX[87]:=ld_d_a;
Z80_IX[88]:=ld_e_b;
Z80_IX[89]:=ld_e_c;
Z80_IX[90]:=ld_e_d;
Z80_IX[91]:=ld_e_e;
Z80_IX[92]:=ld_e_ixh;
Z80_IX[93]:=ld_e_ixl;
Z80_IX[94]:=ld_e_ix;
Z80_IX[95]:=ld_e_a;
Z80_IX[96]:=ld_ixh_b;
Z80_IX[97]:=ld_ixh_c;
Z80_IX[98]:=ld_ixh_d;
Z80_IX[99]:=ld_ixh_e;
Z80_IX[100]:=ld_ixh_ixh;
Z80_IX[101]:=ld_ixh_ixl;
Z80_IX[102]:=ld_h_ix;
Z80_IX[103]:=ld_ixh_a;
Z80_IX[104]:=ld_ixl_b;
Z80_IX[105]:=ld_ixl_c;
Z80_IX[106]:=ld_ixl_d;
Z80_IX[107]:=ld_ixl_e;
Z80_IX[108]:=ld_ixl_ixh;
Z80_IX[109]:=ld_ixl_ixl;
Z80_IX[110]:=ld_l_ix;
Z80_IX[111]:=ld_ixl_a;
Z80_IX[112]:=ld_ix_b;
Z80_IX[113]:=ld_ix_c;
Z80_IX[114]:=ld_ix_d;
Z80_IX[115]:=ld_ix_e;
Z80_IX[116]:=ld_ix_h;
Z80_IX[117]:=ld_ix_l;
Z80_IX[118]:=Z80halt;
Z80_IX[119]:=ld_ix_a;
Z80_IX[120]:=ld_a_b;
Z80_IX[121]:=ld_a_c;
Z80_IX[122]:=ld_a_d;
Z80_IX[123]:=ld_a_e;
Z80_IX[124]:=ld_a_ixh;
Z80_IX[125]:=ld_a_ixl;
Z80_IX[126]:=ld_a_ix;
Z80_IX[127]:=ld_a_a;
Z80_IX[128]:=add_a_b;
Z80_IX[129]:=add_a_c;
Z80_IX[130]:=add_a_d;
Z80_IX[131]:=add_a_e;
Z80_IX[132]:=add_a_ixh;
Z80_IX[133]:=add_a_ixl;
Z80_IX[134]:=add_a_ix;
Z80_IX[135]:=add_a_a;
Z80_IX[136]:=adc_a_b;
Z80_IX[137]:=adc_a_c;
Z80_IX[138]:=adc_a_d;
Z80_IX[139]:=adc_a_e;
Z80_IX[140]:=adc_a_ixh;
Z80_IX[141]:=adc_a_ixl;
Z80_IX[142]:=adc_a_ix;
Z80_IX[143]:=adc_a_a;
Z80_IX[144]:=sub_b;
Z80_IX[145]:=sub_c;
Z80_IX[146]:=sub_d;
Z80_IX[147]:=sub_e;
Z80_IX[148]:=sub_ixh;
Z80_IX[149]:=sub_ixl;
Z80_IX[150]:=sub_ix;
Z80_IX[151]:=sub_a;
Z80_IX[152]:=sbc_a_b;
Z80_IX[153]:=sbc_a_c;
Z80_IX[154]:=sbc_a_d;
Z80_IX[155]:=sbc_a_e;
Z80_IX[156]:=sbc_a_ixh;
Z80_IX[157]:=sbc_a_ixl;
Z80_IX[158]:=sbc_a_ix;
Z80_IX[159]:=sbc_a_a;
Z80_IX[160]:=and_b;
Z80_IX[161]:=and_c;
Z80_IX[162]:=and_d;
Z80_IX[163]:=and_e;
Z80_IX[164]:=and_ixh;
Z80_IX[165]:=and_ixl;
Z80_IX[166]:=and_ix;
Z80_IX[167]:=and_a;
Z80_IX[168]:=xor_b;
Z80_IX[169]:=xor_c;
Z80_IX[170]:=xor_d;
Z80_IX[171]:=xor_e;
Z80_IX[172]:=xor_ixh;
Z80_IX[173]:=xor_ixl;
Z80_IX[174]:=xor_ix;
Z80_IX[175]:=xor_a;
Z80_IX[176]:=or_b;
Z80_IX[177]:=or_c;
Z80_IX[178]:=or_d;
Z80_IX[179]:=or_e;
Z80_IX[180]:=or_ixh;
Z80_IX[181]:=or_ixl;
Z80_IX[182]:=or_ix;
Z80_IX[183]:=or_a;
Z80_IX[184]:=cp_b;
Z80_IX[185]:=cp_c;
Z80_IX[186]:=cp_d;
Z80_IX[187]:=cp_e;
Z80_IX[188]:=cp_ixh;
Z80_IX[189]:=cp_ixl;
Z80_IX[190]:=cp_ix;
Z80_IX[191]:=cp_a_;
Z80_IX[192]:=ret_nz;
Z80_IX[193]:=pop_bc;
Z80_IX[194]:=jp_nz_XXXX;
Z80_IX[195]:=jp_XXXX;
Z80_IX[196]:=call_nz_XXXX;
Z80_IX[197]:=push_bc;
Z80_IX[198]:=add_a_XX;
Z80_IX[199]:=rst_0;
Z80_IX[200]:=ret_z;
Z80_IX[201]:=ret;
Z80_IX[202]:=jp_z_XXXX;
Z80_IX[203]:=ix_CB_pre;
Z80_IX[204]:=call_z_XXXX;
Z80_IX[205]:=call_XXXX;
Z80_IX[206]:=adc_a_XX;
Z80_IX[207]:=rst_8;
Z80_IX[208]:=ret_nc;
Z80_IX[209]:=pop_de;
Z80_IX[210]:=jp_nc_XXXX;
Z80_IX[211]:=out_XX_a;
Z80_IX[212]:=call_nc_XXXX;
Z80_IX[213]:=push_de;
Z80_IX[214]:=sub_XX;
Z80_IX[215]:=rst_16;
Z80_IX[216]:=ret_c;
Z80_IX[217]:=exx;
Z80_IX[218]:=jp_c_XXXX;
Z80_IX[219]:=in_a_XX;
Z80_IX[220]:=call_c_XXXX;
Z80_IX[221]:=IX_Pre;
Z80_IX[222]:=sbc_a_XX;
Z80_IX[223]:=rst_24;
Z80_IX[224]:=ret_po;
Z80_IX[225]:=pop_ix;
Z80_IX[226]:=jp_po_XXXX;
Z80_IX[227]:=ex_msp_ix;
Z80_IX[228]:=call_po_XXXX;
Z80_IX[229]:=push_ix;
Z80_IX[230]:=and_XX;
Z80_IX[231]:=rst_32;
Z80_IX[232]:=ret_pe;
Z80_IX[233]:=jp_ix;
Z80_IX[234]:=jp_pe_XXXX;
Z80_IX[235]:=ex_de_ix;
Z80_IX[236]:=call_pe_XXXX;
Z80_IX[237]:=ED_Pre;
Z80_IX[238]:=xor_XX;
Z80_IX[239]:=rst_40;
Z80_IX[240]:=ret_p;
Z80_IX[241]:=pop_af;
Z80_IX[242]:=jp_p_XXXX;
Z80_IX[243]:=di;
Z80_IX[244]:=call_p_XXXX;
Z80_IX[245]:=push_af;
Z80_IX[246]:=or_XX;
Z80_IX[247]:=rst_48;
Z80_IX[248]:=ret_m;
Z80_IX[249]:=ld_sp_ix;
Z80_IX[250]:=jp_m_XXXX;
Z80_IX[251]:=ei;
Z80_IX[252]:=call_m_XXXX;
Z80_IX[253]:=IY_Pre;
Z80_IX[254]:=cp_XX;
Z80_IX[255]:=rst_56;

Z80_IY[0]:=nop;
Z80_IY[1]:=ld_bc_XXXX;
Z80_IY[2]:=ld_mbc_a;
Z80_IY[3]:=inc_bc;
Z80_IY[4]:=inc_b;
Z80_IY[5]:=dec_b;
Z80_IY[6]:=ld_b_XX;
Z80_IY[7]:=rlca;
Z80_IY[8]:=ex_af_af;
Z80_IY[9]:=add_iy_bc;
Z80_IY[10]:=ld_a_mbc;
Z80_IY[11]:=dec_bc;
Z80_IY[12]:=inc_c;
Z80_IY[13]:=dec_c;
Z80_IY[14]:=ld_c_XX;
Z80_IY[15]:=rrca;
Z80_IY[16]:=djnz_DIS;
Z80_IY[17]:=ld_de_XXXX;
Z80_IY[18]:=ld_mde_a;
Z80_IY[19]:=inc_de;
Z80_IY[20]:=inc_d;
Z80_IY[21]:=dec_d;
Z80_IY[22]:=ld_d_XX;
Z80_IY[23]:=rla;
Z80_IY[24]:=jr_DIS;
Z80_IY[25]:=add_iy_de;
Z80_IY[26]:=ld_a_mde;
Z80_IY[27]:=dec_de;
Z80_IY[28]:=inc_e;
Z80_IY[29]:=dec_e;
Z80_IY[30]:=ld_e_XX;
Z80_IY[31]:=rra;
Z80_IY[32]:=jr_nz_DIS;
Z80_IY[33]:=ld_iy_XXXX;
Z80_IY[34]:=Z80ld_aXXXX_iy;
Z80_IY[35]:=inc_iy;
Z80_IY[36]:=inc_iyh;
Z80_IY[37]:=dec_iyh;
Z80_IY[38]:=ld_iyh_XX;
Z80_IY[39]:=daa;
Z80_IY[40]:=jr_z_DIS;
Z80_IY[41]:=add_iy_iy;
Z80_IY[42]:=Z80ld_iy_aXXXX;
Z80_IY[43]:=dec_iy;
Z80_IY[44]:=inc_iyl;
Z80_IY[45]:=dec_iyl;
Z80_IY[46]:=ld_iyl_XX;
Z80_IY[47]:=cpl;
Z80_IY[48]:=jr_nc_DIS;
Z80_IY[49]:=ld_sp_XXXX;
Z80_IY[50]:=ld_aXXXX_a;
Z80_IY[51]:=inc_sp;
Z80_IY[52]:=inc_miy;
Z80_IY[53]:=dec_miy;
Z80_IY[54]:=ld_miy_XX;
Z80_IY[55]:=scf;
Z80_IY[56]:=jr_c_DIS;
Z80_IY[57]:=add_iy_sp;
Z80_IY[58]:=ld_a_aXXXX;
Z80_IY[59]:=dec_sp;
Z80_IY[60]:=Z80inc_a;
Z80_IY[61]:=Z80dec_a;
Z80_IY[62]:=ld_a_XX;
Z80_IY[63]:=ccf;
Z80_IY[64]:=ld_b_b;
Z80_IY[65]:=ld_b_c;
Z80_IY[66]:=ld_b_d;
Z80_IY[67]:=ld_b_e;
Z80_IY[68]:=ld_b_iyh;
Z80_IY[69]:=ld_b_iyl;
Z80_IY[70]:=ld_b_iy;
Z80_IY[71]:=ld_b_a;
Z80_IY[72]:=ld_c_b;
Z80_IY[73]:=ld_c_c;
Z80_IY[74]:=ld_c_d;
Z80_IY[75]:=ld_c_e;
Z80_IY[76]:=ld_c_iyh;
Z80_IY[77]:=ld_c_iyl;
Z80_IY[78]:=ld_c_iy;
Z80_IY[79]:=ld_c_a;
Z80_IY[80]:=ld_d_b;
Z80_IY[81]:=ld_d_c;
Z80_IY[82]:=ld_d_d;
Z80_IY[83]:=ld_d_e;
Z80_IY[84]:=ld_d_iyh;
Z80_IY[85]:=ld_d_iyl;
Z80_IY[86]:=ld_d_iy;
Z80_IY[87]:=ld_d_a;
Z80_IY[88]:=ld_e_b;
Z80_IY[89]:=ld_e_c;
Z80_IY[90]:=ld_e_d;
Z80_IY[91]:=ld_e_e;
Z80_IY[92]:=ld_e_iyh;
Z80_IY[93]:=ld_e_iyl;
Z80_IY[94]:=ld_e_iy;
Z80_IY[95]:=ld_e_a;
Z80_IY[96]:=ld_iyh_b;
Z80_IY[97]:=ld_iyh_c;
Z80_IY[98]:=ld_iyh_d;
Z80_IY[99]:=ld_iyh_e;
Z80_IY[100]:=ld_iyh_iyh;
Z80_IY[101]:=ld_iyh_iyl;
Z80_IY[102]:=ld_h_iy;
Z80_IY[103]:=ld_iyh_a;
Z80_IY[104]:=ld_iyl_b;
Z80_IY[105]:=ld_iyl_c;
Z80_IY[106]:=ld_iyl_d;
Z80_IY[107]:=ld_iyl_e;
Z80_IY[108]:=ld_iyl_iyh;
Z80_IY[109]:=ld_iyl_iyl;
Z80_IY[110]:=ld_l_iy;
Z80_IY[111]:=ld_iyl_a;
Z80_IY[112]:=ld_iy_b;
Z80_IY[113]:=ld_iy_c;
Z80_IY[114]:=ld_iy_d;
Z80_IY[115]:=ld_iy_e;
Z80_IY[116]:=ld_iy_h;
Z80_IY[117]:=ld_iy_l;
Z80_IY[118]:=Z80halt;
Z80_IY[119]:=ld_iy_a;
Z80_IY[120]:=ld_a_b;
Z80_IY[121]:=ld_a_c;
Z80_IY[122]:=ld_a_d;
Z80_IY[123]:=ld_a_e;
Z80_IY[124]:=ld_a_iyh;
Z80_IY[125]:=ld_a_iyl;
Z80_IY[126]:=ld_a_iy;
Z80_IY[127]:=ld_a_a;
Z80_IY[128]:=add_a_b;
Z80_IY[129]:=add_a_c;
Z80_IY[130]:=add_a_d;
Z80_IY[131]:=add_a_e;
Z80_IY[132]:=add_a_iyh;
Z80_IY[133]:=add_a_iyl;
Z80_IY[134]:=add_a_iy;
Z80_IY[135]:=add_a_a;
Z80_IY[136]:=adc_a_b;
Z80_IY[137]:=adc_a_c;
Z80_IY[138]:=adc_a_d;
Z80_IY[139]:=adc_a_e;
Z80_IY[140]:=adc_a_iyh;
Z80_IY[141]:=adc_a_iyl;
Z80_IY[142]:=adc_a_iy;
Z80_IY[143]:=adc_a_a;
Z80_IY[144]:=sub_b;
Z80_IY[145]:=sub_c;
Z80_IY[146]:=sub_d;
Z80_IY[147]:=sub_e;
Z80_IY[148]:=sub_iyh;
Z80_IY[149]:=sub_iyl;
Z80_IY[150]:=sub_iy;
Z80_IY[151]:=sub_a;
Z80_IY[152]:=sbc_a_b;
Z80_IY[153]:=sbc_a_c;
Z80_IY[154]:=sbc_a_d;
Z80_IY[155]:=sbc_a_e;
Z80_IY[156]:=sbc_a_iyh;
Z80_IY[157]:=sbc_a_iyl;
Z80_IY[158]:=sbc_a_iy;
Z80_IY[159]:=sbc_a_a;
Z80_IY[160]:=and_b;
Z80_IY[161]:=and_c;
Z80_IY[162]:=and_d;
Z80_IY[163]:=and_e;
Z80_IY[164]:=and_iyh;
Z80_IY[165]:=and_iyl;
Z80_IY[166]:=and_iy;
Z80_IY[167]:=and_a;
Z80_IY[168]:=xor_b;
Z80_IY[169]:=xor_c;
Z80_IY[170]:=xor_d;
Z80_IY[171]:=xor_e;
Z80_IY[172]:=xor_iyh;
Z80_IY[173]:=xor_iyl;
Z80_IY[174]:=xor_iy;
Z80_IY[175]:=xor_a;
Z80_IY[176]:=or_b;
Z80_IY[177]:=or_c;
Z80_IY[178]:=or_d;
Z80_IY[179]:=or_e;
Z80_IY[180]:=or_iyh;
Z80_IY[181]:=or_iyl;
Z80_IY[182]:=or_iy;
Z80_IY[183]:=or_a;
Z80_IY[184]:=cp_b;
Z80_IY[185]:=cp_c;
Z80_IY[186]:=cp_d;
Z80_IY[187]:=cp_e;
Z80_IY[188]:=cp_iyh;
Z80_IY[189]:=cp_iyl;
Z80_IY[190]:=cp_iy;
Z80_IY[191]:=cp_a_;
Z80_IY[192]:=ret_nz;
Z80_IY[193]:=pop_bc;
Z80_IY[194]:=jp_nz_XXXX;
Z80_IY[195]:=jp_XXXX;
Z80_IY[196]:=call_nz_XXXX;
Z80_IY[197]:=push_bc;
Z80_IY[198]:=add_a_XX;
Z80_IY[199]:=rst_0;
Z80_IY[200]:=ret_z;
Z80_IY[201]:=ret;
Z80_IY[202]:=jp_z_XXXX;
Z80_IY[203]:=IY_CB_Pre;
Z80_IY[204]:=call_z_XXXX;
Z80_IY[205]:=call_XXXX;
Z80_IY[206]:=adc_a_XX;
Z80_IY[207]:=rst_8;
Z80_IY[208]:=ret_nc;
Z80_IY[209]:=pop_de;
Z80_IY[210]:=jp_nc_XXXX;
Z80_IY[211]:=out_XX_a;
Z80_IY[212]:=call_nc_XXXX;
Z80_IY[213]:=push_de;
Z80_IY[214]:=sub_XX;
Z80_IY[215]:=rst_16;
Z80_IY[216]:=ret_c;
Z80_IY[217]:=exx;
Z80_IY[218]:=jp_c_XXXX;
Z80_IY[219]:=in_a_XX;
Z80_IY[220]:=call_c_XXXX;
Z80_IY[221]:=IX_Pre;
Z80_IY[222]:=sbc_a_XX;
Z80_IY[223]:=rst_24;
Z80_IY[224]:=ret_po;
Z80_IY[225]:=pop_iy;
Z80_IY[226]:=jp_po_XXXX;
Z80_IY[227]:=ex_msp_iy;
Z80_IY[228]:=call_po_XXXX;
Z80_IY[229]:=push_iy;
Z80_IY[230]:=and_XX;
Z80_IY[231]:=rst_32;
Z80_IY[232]:=ret_pe;
Z80_IY[233]:=jp_iy;
Z80_IY[234]:=jp_pe_XXXX;
Z80_IY[235]:=ex_de_iy;
Z80_IY[236]:=call_pe_XXXX;
Z80_IY[237]:=ED_Pre;
Z80_IY[238]:=xor_XX;
Z80_IY[239]:=rst_40;
Z80_IY[240]:=ret_p;
Z80_IY[241]:=pop_af;
Z80_IY[242]:=jp_p_XXXX;
Z80_IY[243]:=di;
Z80_IY[244]:=call_p_XXXX;
Z80_IY[245]:=push_af;
Z80_IY[246]:=or_XX;
Z80_IY[247]:=rst_48;
Z80_IY[248]:=ret_m;
Z80_IY[249]:=ld_sp_iy;
Z80_IY[250]:=jp_m_XXXX;
Z80_IY[251]:=ei;
Z80_IY[252]:=call_m_XXXX;
Z80_IY[253]:=IY_Pre;
Z80_IY[254]:=cp_XX;
Z80_IY[255]:=rst_56;
end;
