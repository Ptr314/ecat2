{$ifdef use_assembler}
{ Erstaunlicherweise muessen die Register gesichert werden, ansonsten
  funktioniert die Emulation nicht ?? }
procedure add16(var first:Word;second:Word);
var f:Word;                 
begin
 f:=first;
 asm
        clc
        mov    ax,second
        add	f,ax
	lahf
	mov	al,af.l
	and	ax,1FCh
	or	al,ah
	mov	af.l,al
 end;
 first:=F;
end;

procedure adc16(first,second:Word);assembler;
asm
        clc
        mov     ax,first
        mov     hl.w, ax

        mov     bx,second
        mov	ah,af.l
        ror	ah,1
	adc	hl.w,bx
        lahf
	jo	@s
	and	ah,not 4
	jmp @ende
@s:	or	ah,4
@ende:
	and	ah,not 2
	mov	af.l,ah
end;

procedure sbc16(first,second:Word);assembler;
asm
        clc
        mov     ax,first
        mov     hl.w, ax

	mov	bx,second
        mov	ah,af.l
        ror	ah,1
	sbb	hl.w,bx

        lahf
	jo	@s
	and	ah,not 4
	jmp @ende
@s:	or	ah,4
@ende:

	or	ah,2
	mov	af.l,ah
end;

procedure add8(AHigh,Pls:Byte);assembler;
asm
        clc
        mov     ah,AHigh
        mov     af.h, ah

	mov	al,pls

        add	af.h,al

        lahf
	jo	@s
	and	ah,not 4
	jmp @ende
@s:	or	ah,4
@ende:

	and	ah,not 2	{N:=0}
	mov	af.l,ah
end;

procedure sub8(AHigh,Pls:Byte);assembler;
asm
        clc
        mov     ah,AHigh
        mov     af.h, ah

        mov	al,Pls;
        sub	af.h,al

 	lahf
	jo	@s
	and	ah,not 4
	jmp @ende
@s:	or	ah,4
@ende:

        or	ah,2	{N:=1}
        mov	af.l,ah
end;

procedure adc8(ALo,Pls:Byte);assembler;
asm
        clc
        mov     ah,ALO
        mov     af.h, ah

        mov	al,pls

        mov	ah,af.l
        ror	ah,1

	adc	af.h,al

        lahf
	jo	@s
	and	ah,not 4
	jmp @ende
@s:	or	ah,4
@ende:

	and	ah,not 2
	mov	af.l,ah
end;

procedure sbc8(ALo,Mns:Byte);assembler;
asm
        clc
        mov     ah,ALO
        mov     af.h, ah

        mov     al,mns
        mov	ah,af.l
        ror	ah,1

	sbb	af.h,al

        lahf
	jo	@s
	and	ah,not 4
	jmp @ende
@s:	or	ah,4
@ende:

	or	ah,2
	mov	af.l,ah
end;

procedure cp_sub8(ALow,Mns:Byte);assembler;
asm
        clc
        mov     ah,ALow
        mov     al,Mns
        cmp     ah, al

        lahf
	jo	@s
	and	ah,not 4
	jmp @ende
@s:	or	ah,4
@ende:

	or	ah,2
	mov	af.l,ah
end;

procedure anda(bval:Byte);assembler;
asm
        clc
 	mov	al,bval
      	and	af.h,al
	lahf
	and	ah,not 2	{N auf 0}
	or	ah,10h		{H auf 1}
	mov	af.l,ah
end;

procedure ora(bval:byte);assembler;
asm
        clc
	mov	al,bval
        or	af.h,al
	lahf
	and	ah,not 12h	{H und N auf 0}
	mov	af.l,ah
end;

procedure xora(bval:byte);assembler;
asm
        clc
        mov     al,bval
        xor	af.h,al
	lahf
	and	ah,not 12h	{H und N auf 0}
	mov	af.l,ah
end;

procedure copy_b53(btemp:byte);assembler;
asm
 mov al,btemp
 and al,40
 and af.l,215
 or af.l,al
end;

{$else}

procedure add16(Var first:Word;second:Word);
begin
	qtemp.Q:=longint(first)+longint(second);
	//first:=qtemp.w1;
	af.l:=(af.l and $C4) OR (qtemp.b2 and $38);
	if qtemp.b3=0 then af.l:=af.l and 254 (* reset Cf *) else
				af.l:=af.l or 1;(* set Cf *)
	{H like modZ80}
	if (((first And $FFF) + (second And $FFF)) And $1000) <> 0 then
		af.l := af.l or $10
	else
		af.l := af.l and $EF;
	first:=qtemp.w1;
	{}
end;

procedure adc16(first,second:Word);
begin
	qtemp.Q:=longint(first)+longint(second)+(af.l and 1);
	af.l:=(qtemp.b2 and $B8);
	if qtemp.b3=0 then af.l:=af.l and 254 (* reset Cf *) else af.l:=af.l or 1;(* set Cf *)
	if qtemp.w1>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64;(* set Zf *)
	if ((first XOR qtemp.w1) SHR 15>0) and
           ((first XOR second) SHR 15=0) then af.l:=af.l or 4 (* set Pf *) else
            af.l:=af.l and 251;(* reset Pf *)
	hl.W:=qtemp.w1;
end;

procedure sbc16(first,second:Word);
begin
	qtemp.Q:=longint(first)-longint(second)-(af.l and 1);
	af.l:=(qtemp.b2 and $B8) OR 2;
	if qtemp.b4=0 then af.l:=af.l and 254 (* reset Cf *) else af.l:=af.l or 1;(* set Cf *)
	if qtemp.w1>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64;(* set Zf *)
	if ((first XOR qtemp.w1) SHR 15>0) and
           ((second XOR qtemp.w1) SHR 15=0) then af.l:=af.l or 4 (* set Pf *) else
         af.l:=af.l and 251 ;(* reset Pf *)
	hl.W:=qtemp.w1;
end;

procedure add8(Lo,Pls:Byte);
begin
	ptemp.W:=Lo+Pls;
	if ptemp.h=0 then
	begin
		ptemp.h:=ptemp.l;
                ptemp.l:=ptemp.l and 254; (* reset Cf *)
	end
	else
	begin
		ptemp.h:=ptemp.l;
                ptemp.l:=ptemp.l or 1;(* set Cf *)
	end;
        ptemp.l:=ptemp.l and 253;(* reset Nf *)
	if ptemp.h>0 then
         ptemp.l:=ptemp.l and 191 (* reset Zf *)
        else
         ptemp.l:=ptemp.l or 64;(* set Zf *)
	if ((Lo XOR Pls XOR ptemp.h) and 16>0) then
        ptemp.l:=ptemp.l or 16 (* set Hf *)
        else
        ptemp.l:=ptemp.l and 239;(* reset Hf *)
	if ((Lo XOR ptemp.h) SHR 7>0) and  ((Lo XOR Pls) SHR 7=0) then
        ptemp.l:=ptemp.l or 4 (* set Pf *)
        else
        ptemp.l:=ptemp.l and 251;(* reset Pf *)
	af.W:=ptemp.W;
end;

procedure sub8(Lo,Mns:Byte);
begin
	ptemp.W:=Lo-Mns;
	if ptemp.h=0 then
	begin
		ptemp.h:=ptemp.l;
                ptemp.l:=ptemp.l and 254; (* reset Cf *)
	end
	else
	begin
		ptemp.h:=ptemp.l;
                ptemp.l:=ptemp.l or 1;(* set Cf *)
	end;
        ptemp.l:=ptemp.l or 2; (* set Nf *)
	if ptemp.h>0 then
         ptemp.l:=ptemp.l and 191 (* reset Zf *)
        else
         ptemp.l:=ptemp.l or 64;(* set Zf *)
	if (Lo XOR Mns XOR ptemp.h) and 16>0 then
        ptemp.l:=ptemp.l or 16 (* set Hf *)
        else
        ptemp.l:=ptemp.l and 239;(* reset Hf *)
	if ((Lo XOR ptemp.h) SHR 7>0) and ((Mns XOR ptemp.h) SHR 7=0)
        then ptemp.l:=ptemp.l or 4 (* set Pf *)
        else ptemp.l:=ptemp.l and 251;(* reset Pf *)
	af.W:=ptemp.W;
end;

procedure adc8(Lo,Pls:Byte);
begin
	ptemp.W:=Lo+Pls+(af.l and 1);
	if ptemp.h=0 then
	begin
		ptemp.h:=ptemp.l;
                ptemp.l:=ptemp.l and 254; (* reset Cf *)
	end
	else
	begin
		ptemp.h:=ptemp.l;
                ptemp.l:=ptemp.l or 1;(* set Cf *)
	end;
        ptemp.l:=ptemp.l and 253;(* reset Nf *)
	if ptemp.h>0 then
        ptemp.l:=ptemp.l and 191(* reset Zf *)
        else
        ptemp.l:=ptemp.l or 64;(* set Zf *)
	if (Lo XOR Pls XOR ptemp.h) and 16>0 then
        ptemp.l:=ptemp.l or 16 (* set Hf *)
        else
        ptemp.l:=ptemp.l and 239;(* reset Hf *)
	if ((Lo XOR ptemp.h) SHR 7>0) and ((Lo XOR Pls) SHR 7=0) then
         ptemp.l:=ptemp.l or 4 (* set Pf *)
        else ptemp.l:=ptemp.l and 251;(* reset Pf *)
	af.W:=ptemp.W;
end;

procedure sbc8(Lo,Mns:Byte);
begin
	ptemp.W:=Lo-Mns-(af.l and 1);
	if ptemp.h=0 then
	begin
		ptemp.h:=ptemp.l;
                ptemp.l:=ptemp.l and 254; (* reset Cf *)
	end
	else
	begin
		ptemp.h:=ptemp.l;
                ptemp.l:=ptemp.l or 1;(* set Cf *)
	end;
        ptemp.l:=ptemp.l or 2; (* set Nf *)
	if ptemp.h>0 then
        ptemp.l:=ptemp.l and 191 (* reset Zf *)
        else
        ptemp.l:=ptemp.l or 64;(* set Zf *)
	if (Lo XOR Mns XOR ptemp.h) and 16>0 then
        ptemp.l:=ptemp.l or 16 (* set Hf *)
        else
        ptemp.l:=ptemp.l and 239;(* reset Hf *)
	if ((Lo XOR ptemp.h) SHR 7>0)  and ((Mns XOR ptemp.h) SHR 7=0)
        then
         ptemp.l:=ptemp.l or 4 (* set Pf *)
        else ptemp.l:=ptemp.l and 251;(* reset Pf *)
	af.W:=ptemp.W;
end;

procedure cp_sub8(Lo,Mns:Byte);
begin
	ptemp.W:=Lo-Mns;
	af.l:=(Mns and 40) OR (ptemp.l and 215) OR 2;
	if ptemp.l>0 then af.l:=af.l and 191 (* reset Zf *) else af.l:=af.l or 64;(* set Zf *)
	if ptemp.h=0 then af.l:=af.l and 254 (* reset Cf *) else af.l:=af.l or 1;(* set Cf *)
	if (Lo XOR Mns XOR ptemp.l) and 16>0 then
        af.l:=af.l or 16 (* set Hf *)
        else
        af.l:=af.l and 239;(* reset Hf *)

	if ((Lo XOR ptemp.l) SHR 7>0) and ((Mns XOR ptemp.l) SHR 7=0) then
        af.l:=af.l or 4 (* set Pf *) else
         af.l:=af.l and 251 ;(* reset Pf *)
end;

procedure anda(bval:Byte);
begin
 af.h:=af.h and bval;
 af.l:=16 or (af.h and 232) or parity[af.h];
 if af.h=0 then af.l:=af.l or 64 else af.l:=af.l and 191;
end;

procedure ora(bval:byte);
begin
 af.h:=af.h or bval;
 af.l:=(af.h and 232) or parity[af.h];
 if af.h=0 then af.l:=af.l or 64 else af.l:=af.l and 191;
end;

procedure xora(bval:byte);
begin
 af.h:=af.h xor bval;
 af.l:=(af.h and 232) or parity[af.h];
 if af.h=0 then af.l:=af.l or 64 else af.l:=af.l and 191;
end;

procedure copy_b53(btemp:Word);
Begin
 af.l:=(af.l and 215) or (btemp and 40);
end;

{$endif}

procedure pop(var wpval:Word);
Begin
 wpval:=peekw(sp.W);
 inc(sp.W,2);
end;

procedure push(wpval:Word);
Begin
 dec(sp.W,2);
 pokew(sp.W,wpval);
end;
