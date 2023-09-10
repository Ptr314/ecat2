unit DebugZ80Wnd;
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
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, Buttons, ExtCtrls,
	Core, modZ80, Utils, Emulator, DebugWnd, DAsm;

type
  TDebugZ80 = class(TDebugWindow)
		Panel1: TPanel;
    Label1: TLabel;
    LabelPC: TLabel;
    LabelSP: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabelA: TLabel;
    Label7: TLabel;
		LabelB: TLabel;
		Label9: TLabel;
    LabelC: TLabel;
    LabelD: TLabel;
    Label12: TLabel;
		Label15: TLabel;
		LabelL: TLabel;
    LabelH: TLabel;
		Label18: TLabel;
    Label19: TLabel;
    LabelE: TLabel;
    Label21: TLabel;
    LabelBC: TLabel;
		LabelDE: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    LabelHL: TLabel;
    LabelF: TLabel;
    Label14: TLabel;
    Label33: TLabel;
    LabelFS: TLabel;
    Label35: TLabel;
    LabelFZ: TLabel;
    LabelFH: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    LabelFP: TLabel;
    LabelFC: TLabel;
    Label42: TLabel;
    Panel2: TPanel;
		ScrollBar: TScrollBar;
    ASMPanel: TPaintBox;
    SeekTimer: TTimer;
    SeekBtn: TSpeedButton;
    StepInto: TSpeedButton;
    RunTo: TSpeedButton;
		SpeedButton3: TSpeedButton;
		Panel3: TPanel;
    NewAddrEdit: TEdit;
    NewAddrBtn: TSpeedButton;
		SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    StepOver: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    LabelIX: TLabel;
    Label6: TLabel;
    LabelIY: TLabel;
    Label10: TLabel;
    LabelAF_: TLabel;
    Label13: TLabel;
    LabelBC_: TLabel;
    Label17: TLabel;
    LabelDE_: TLabel;
    Label22: TLabel;
    LabelHL_: TLabel;
    LabelF5: TLabel;
    Label27: TLabel;
    LabelF3: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    LabelFN: TLabel;
    Label32: TLabel;
    LabelIFF1: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    LabelIFF2: TLabel;
    Label41: TLabel;
    LabelR: TLabel;
    Label44: TLabel;
    LabelI: TLabel;
    Label46: TLabel;
    LabelIM: TLabel;
		procedure BitBtn1Click(Sender: TObject);
		procedure ASMPanelPaint(Sender: TObject);
		procedure FormActivate(Sender: TObject);
		procedure SeekTimerTimer(Sender: TObject);
		procedure SeekBtnClick(Sender: TObject);
		procedure SpeedButton4Click(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure NewAddrBtnClick(Sender: TObject);
		procedure ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode;
			var ScrollPos: Integer);
		procedure NewAddrEditKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton3Click(Sender: TObject);
		procedure StartClick(Sender: TObject);
    procedure StepIntoClick(Sender: TObject);
    procedure LabelPCDblClick(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure LabelAClick(Sender: TObject);
    procedure LabelCClick(Sender: TObject);
    procedure ASMPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StepOverClick(Sender: TObject);
    procedure RunToClick(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButton1Click(Sender: TObject);
    procedure LabelPCMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LabelBCMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LabelDEMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LabelHLMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LabelFClick(Sender: TObject);
    procedure LabelBClick(Sender: TObject);
    procedure LabelDClick(Sender: TObject);
    procedure LabelEClick(Sender: TObject);
    procedure LabelHClick(Sender: TObject);
    procedure LabelLClick(Sender: TObject);
	private
		{ Private declarations }
		InstrData:array [0..65535] of T8BitInstrRec; //Адреса дизассемблированных инструкций
		StartAddr:Integer; //Адрес, с которого начинать дизассемблирование
		StartLine:Integer; //Номер строки в InstrAddresses, соответствующей первой строке
		LinesCount: Integer; //Сколько строк содержится в InstrAddresses
		WindowLen:Integer; //Сколько строк помещается в окне
		WindowLineHeight:Integer; //Высота строки на экране
		WindowLinePadding:Integer; //Отступы внутри строки для формирования промежутков
		PrevContext:TZ80Context; //Для отслеживания изменения значений;
		Stopped: Boolean;
		FDisAsm: TDisAsm;
		procedure ChangeReg8(Name: String; var Reg:Byte);
	public
		{ Public declarations }
		CPU: TZ80;
		MM: TMemoryMapper;
		DM: TDeviceManager;
		procedure UpdateLabels(fromTimer:Boolean);
		procedure DecodeInstrForward;
		procedure DecodeInstrBackward(Count:Integer);
		procedure GoToAddr(Addr: Integer);
		procedure UpdateView; override;
	end;

var
	DebugZ80: TDebugZ80;

implementation

{$R *.dfm}

procedure TDebugZ80.BitBtn1Click(Sender: TObject);
begin
 Close;
end;


procedure TDebugZ80.UpdateLabels;
	procedure SetLabelColor(L:TLabel; Value, PrevValue: Integer);
	var NewColor:TColor;
	begin
		if Value=PrevValue then NewColor:=clBlack
		else NewColor:=clRed;
		L.Font.Color:=NewColor;
	end;
begin
	CPU.UpdateContext;	
	with CPU.Context do begin
		SetLabelColor(LabelPC, PC, PrevContext.PC);
		LabelPC.Caption:=Format('%.4x', [PC AND $FFFF]);
		SetLabelColor(LabelSP, SP, PrevContext.SP);
		LabelSP.Caption:=Format('%.4x', [SP AND $FFFF]);

		SetLabelColor(LabelIX, IX, PrevContext.IX);
		LabelIX.Caption:=Format('%.4x', [IX AND $FFFF]);
		SetLabelColor(LabelIY, IY, PrevContext.IY);
		LabelIY.Caption:=Format('%.4x', [IY AND $FFFF]);

		SetLabelColor(LabelA, A, PrevContext.A);
		LabelA.Caption:=Format('%.2x', [A AND $FF]);
		SetLabelColor(LabelF, F, PrevContext.F);
		LabelF.Caption:=Format('%.2x', [F AND $FF]);

		SetLabelColor(LabelB, B, PrevContext.B);
		LabelB.Caption:=Format('%.2x', [B AND $FF]);
		SetLabelColor(LabelC, C, PrevContext.C);
		LabelC.Caption:=Format('%.2x', [C AND $FF]);
		SetLabelColor(LabelD, D, PrevContext.D);
		LabelD.Caption:=Format('%.2x', [D AND $FF]);
		SetLabelColor(LabelE, E, PrevContext.E);
		LabelE.Caption:=Format('%.2x', [E AND $FF]);
		SetLabelColor(LabelH, H, PrevContext.H);
		LabelH.Caption:=Format('%.2x', [H AND $FF]);
		SetLabelColor(LabelL, L, PrevContext.L);
		LabelL.Caption:=Format('%.2x', [L AND $FF]);

		SetLabelColor(LabelBC, BC, PrevContext.BC);
		LabelBC.Caption:=Format('%.4x', [BC AND $FFFF]);
		SetLabelColor(LabelDE, DE, PrevContext.DE);
		LabelDE.Caption:=Format('%.4x', [DE AND $FFFF]);
		SetLabelColor(LabelHL, HL, PrevContext.HL);
		LabelHL.Caption:=Format('%.4x', [HL AND $FFFF]);

		SetLabelColor(LabelBC_, BC_, PrevContext.BC_);
		LabelBC_.Caption:=Format('%.4x', [BC_ AND $FFFF]);
		SetLabelColor(LabelDE_, DE_, PrevContext.DE_);
		LabelDE_.Caption:=Format('%.4x', [DE_ AND $FFFF]);
		SetLabelColor(LabelHL_, HL_, PrevContext.HL_);
		LabelHL_.Caption:=Format('%.4x', [HL_ AND $FFFF]);

		SetLabelColor(LabelFC, F AND F_CARRY, PrevContext.F AND F_CARRY);
		LabelFC.Caption:=Format('%d', [F AND F_CARRY]);
		SetLabelColor(LabelFN, F AND F_NEGATIVE, PrevContext.F AND F_NEGATIVE);
		LabelFN.Caption:=Format('%d', [(F AND F_NEGATIVE) shr 1]);
		SetLabelColor(LabelFP, F AND F_PARITY, PrevContext.F AND F_PARITY);
		LabelFP.Caption:=Format('%d', [(F AND F_PARITY) shr 2]);
		SetLabelColor(LabelF3, F AND F_3, PrevContext.F AND F_3);
		LabelF3.Caption:=Format('%d', [(F AND F_3) shr 3]);
		SetLabelColor(LabelFH, F AND F_HALF_CARRY, PrevContext.F AND F_HALF_CARRY);
		LabelFH.Caption:=Format('%d', [(F AND F_HALF_CARRY) shr 4]);
		SetLabelColor(LabelF5, F AND F_5, PrevContext.F AND F_5);
		LabelF5.Caption:=Format('%d', [(F AND F_5) shr 5]);
		SetLabelColor(LabelFZ, F AND F_ZERO, PrevContext.F AND F_ZERO);
		LabelFZ.Caption:=Format('%d', [(F AND F_ZERO) shr 6]);
		SetLabelColor(LabelFS, F AND F_SIGN, PrevContext.F AND F_SIGN);
		LabelFS.Caption:=Format('%d', [(F AND F_SIGN) shr 7]);

		SetLabelColor(LabelR, R, PrevContext.R);
		LabelR.Caption:=Format('%.2x', [R AND $FF]);
		SetLabelColor(LabelI, I, PrevContext.I);
		LabelI.Caption:=Format('%.2x', [I AND $FF]);

		SetLabelColor(LabelIFF1, IFF1, PrevContext.IFF1);
		LabelIFF1.Caption:=Format('%d', [IFF1 AND $1]);
		SetLabelColor(LabelIFF2, IFF2, PrevContext.IFF2);
		LabelIFF2.Caption:=Format('%d', [IFF2 AND $1]);

		SetLabelColor(LabelIM, IM, PrevContext.IM);
		LabelIM.Caption:=Format('%d', [IM AND $3]);

	end;
	if not (fromTimer and Stopped) then PrevContext:=CPU.Context;
end;

procedure TDebugZ80.FormActivate(Sender: TObject);
begin
	SeekTimer.Enabled:=SeekBtn.Down;
	if CPU.DebugMode=DEBUG_STOPPED then SpeedButton3Click(Sender);
end;

procedure TDebugZ80.SeekTimerTimer(Sender: TObject);
begin
	UpdateLabels(TRUE);
	if CPU.DebugMode = DEBUG_STOPPED then begin
		SeekTimer.Enabled:=FALSE;
		SeekBtn.Down:=FALSE;
		Stopped:=TRUE;
		CPU.UpdateContext;
		LinesCount:=0;
		GoToAddr(CPU.Context.PC);
		DebugWindowsManager.UpdateViews;
	end;
end;

procedure TDebugZ80.SeekBtnClick(Sender: TObject);
begin
	SeekTimer.Enabled:=SeekBtn.Down;
end;

procedure TDebugZ80.SpeedButton4Click(Sender: TObject);
begin
	SeekTimer.Enabled:=FALSE;
	Close;
end;

procedure TDebugZ80.FormCreate(Sender: TObject);
begin
	CPU:=TZ80(FDevice);
	MM := TMemoryMapper(FE.DM.GetDeviceByName('mapper'));
	DM := FE.DM;
	WindowLineHeight:=17;
	WindowLinePadding:=1;
	StartLine:=0;
	StartAddr:=$F800;
	LinesCount:=0;
	Stopped:=FALSE;
	WindowLen:=ASMPanel.Height div WindowLineHeight;
	ScrollBar.Position:=StartAddr;

  FDisAsm := TDisAsm.Create(ExtractFilePath(ParamStr(0))+'Data/z80.dis');
end;

procedure TDebugZ80.ASMPanelPaint(Sender: TObject);
var i, j, Address:Integer;
		Bytes, AddrStr:String;
		LinesColor, BreakColor, CurrentColor:Integer;
		LT, LB, L, W: Integer;
begin
	CPU.UpdateContext;
	LinesColor:=RGB(50,50,50);
	BreakColor:=RGB(128,0,0);
	CurrentColor:=RGB(0,0,128);
	for i:=0 to WindowLen-1 do begin
		if StartLine+i>=LinesCount then DecodeInstrForward;
		Address:=InstrData[StartLine+i].Address;

		AddrStr:=Format('%.4x',[Address]);
		Bytes:='';//Format('%.2x',[Code]);
		for j:=0 to InstrData[StartLine+i].Len-1 do Bytes:=Bytes+Format('%.2x',[MM.Read(Address+j)])+' ';

		LT:=i*WindowLineHeight+WindowLinePadding;
		LB:=(i+1)*WindowLineHeight-WindowLinePadding;

		AsmPanel.Canvas.Brush.Color:=LinesColor;

		AsmPanel.Canvas.FillRect(Rect(WindowLinePadding, LT, 20-WindowLinePadding, LB));
		if CPU.CheckBreakPoint(Address) then begin
			AsmPanel.Canvas.Font.Color:=RGB(255, 0, 0);
			AsmPanel.Canvas.TextOut(6, i*WindowLineHeight+1, #164);
		end;

		if Address = CPU.Context.PC then
			AsmPanel.Canvas.Brush.Color:=CurrentColor
		else
		if CPU.CheckBreakPoint(Address) then
			AsmPanel.Canvas.Brush.Color:=BreakColor
		else
			AsmPanel.Canvas.Brush.Color:=LinesColor;

		L := 20; W:=40;
		AsmPanel.Canvas.FillRect(Rect(L+WindowLinePadding, LT, L+W-WindowLinePadding, LB));
		AsmPanel.Canvas.Font.Color:=RGB(255, 100, 100);
		AsmPanel.Canvas.TextOut(L+5, i*WindowLineHeight+1, AddrStr);
		Inc(L, W); W := 90;
		AsmPanel.Canvas.FillRect(Rect(L+WindowLinePadding, LT, L+W-WindowLinePadding, LB));
		AsmPanel.Canvas.Font.Color:=RGB(210, 210, 210);
		AsmPanel.Canvas.TextOut(L+5, i*WindowLineHeight+1, Bytes);
		Inc(L, W); W := 40;
		AsmPanel.Canvas.FillRect(Rect(L+WindowLinePadding, LT, L+W-WindowLinePadding, LB));
		Inc(L, W); W := 180;
		AsmPanel.Canvas.FillRect(Rect(L+WindowLinePadding, LT, L+W-WindowLinePadding, LB));
		if InstrData[StartLine+i].IsTrue then
			AsmPanel.Canvas.Font.Color:=RGB(0, 255, 255)
		else
			AsmPanel.Canvas.Font.Color:=RGB(255, 128, 128);
		AsmPanel.Canvas.TextOut(L+5, i*WindowLineHeight+1, InstrData[StartLine+i].Txt);
	end;
end;

procedure TDebugZ80.DecodeInstrForward;
var NewAddr:Integer;
		Bytes: array [0..3] of Byte;
		i, NewLen:Integer;
		S: String;
begin
	if LinesCount=0 then
		NewAddr:=StartAddr
	else
		NewAddr:=InstrData[LinesCount-1].Address+InstrData[LinesCount-1].Len;
  //Читаем в буфер байты
	for i:=0 to 3 do
		Bytes[i] := MM.Read(NewAddr+i);
	NewLen := FDisAsm.Disassemble(@Bytes, NewAddr, 4, S);
	if NewLen>0 then begin
		InstrData[LinesCount].Code:=Bytes[0];
		InstrData[LinesCount].Address:=NewAddr;
		InstrData[LinesCount].IsTrue:=TRUE;
		InstrData[LinesCount].Len:=NewLen;
		InstrData[LinesCount].Txt := S;
		Inc(LinesCount);
	end;
end;

procedure TDebugZ80.DecodeInstrBackward(Count:Integer);
{var NewAddr:Integer;
		i:Integer;}
begin
	{
	for i:=LinesCount-1 downto 0 do InstrData[i+Count]:=InstrData[i+Count-1];
	for i:=Count-1 downto 0 do begin
		NewAddr:=InstrData[i+1].Address-1;
		while I8080LENGTHS[MM.Read(NewAddr)]>InstrData[i+1].Address-NewAddr do Dec(NewAddr);
		InstrData[i].Address:=NewAddr;
		InstrData[i].Code:=MM.Read(NewAddr);
		InstrData[i].IsTrue:=FALSE;
	end;
	Inc(LinesCount, Count);
	}
end;


procedure TDebugZ80.NewAddrBtnClick(Sender: TObject);
begin
	LinesCount:=0;
	GoToAddr(ParseNumericValue('$'+NewAddrEdit.Text));
end;

procedure TDebugZ80.GoToAddr(Addr: Integer);
var i, N:Integer;
begin
	if (LinesCount=0) or (Addr < InstrData[0].Address) or (Addr > InstrData[LinesCount-1].Address) then begin
		StartAddr:=Addr;
		LinesCount:=0;
		StartLine:=0;
	end else begin
		N:=-1;
		for i:=0 to LinesCount-1 do
			if InstrData[i].Address = Addr then N:=i;
		if N>=0 then begin
		 if N < StartLine then StartLine := N;
		 if N > StartLine + WindowLen then StartLine := N;
		end else begin
			StartAddr:=Addr;
			LinesCount:=0;
			StartLine:=0;
		end;
	end;
	ASMPAnel.Invalidate;
	ScrollBar.Position:=Addr;
end;

procedure TDebugZ80.ScrollBarScroll(Sender: TObject;
	ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
	case ScrollCode of
		scLineUp:begin
								if StartLine>0 then
									Dec(StartLine)
								else
									DecodeInstrBackward(1);
								ASMPanel.Repaint;
								ScrollPos:=InstrData[StartLine].Address;
							 end;
		scLineDown:begin
								Inc(StartLine);
								ASMPanel.Repaint;
								ScrollPos:=InstrData[StartLine].Address;
							 end;
		scPageUp:begin
								if StartLine>=WindowLen then
									Dec(StartLine, WindowLen)
								else begin
									DecodeInstrBackward(WindowLen-StartLine);
									StartLine:=0;
								end;
								ASMPanel.Repaint;
								ScrollPos:=InstrData[StartLine].Address;
							 end;
		scPageDown:begin
								Inc(StartLine, WindowLen);
								ASMPanel.Repaint;
								ScrollPos:=InstrData[StartLine].Address;
							 end;
		scPosition:begin
									StartAddr:=ScrollPos;
									LinesCount:=0;
									StartLine:=0;
									ASMPAnel.Repaint;
								end;
		scTrack:;
		scTop:;
		scBottom:;
		scEndScroll:;
	end;

end;

procedure TDebugZ80.NewAddrEditKeyPress(Sender: TObject; var Key: Char);
begin
	if Key=#13 then NewAddrBtn.Click;
end;

procedure TDebugZ80.SpeedButton3Click(Sender: TObject);
begin
	CPU.DebugMode:=DEBUG_STOPPED;
	Stopped:=TRUE;
	GoToAddr(CPU.Context.PC);
	//SeekBtn.Down:=FALSE;
	SeekTimer.Enabled:=FALSE;
	UpdateLabels(FALSE);
	DebugWindowsManager.UpdateViews;
end;

procedure TDebugZ80.StartClick(Sender: TObject);
begin
	CPU.DebugMode:=DEBUG_OFF;
	Stopped:=FALSE;
	SeekTimer.Enabled:=SeekBtn.Down;
end;

procedure TDebugZ80.StepIntoClick(Sender: TObject);
begin
	if Stopped then begin
		CPU.DebugMode:=DEBUG_STEP;
		repeat until CPU.DebugMode<>DEBUG_STEP;
		UpdateLabels(FALSE);
		GoToAddr(CPU.Context.PC);
		DebugWindowsManager.UpdateViews;
	end
end;

procedure TDebugZ80.LabelPCDblClick(Sender: TObject);
var S:String;
begin
	S:=IntToHex(CPU.Context.PC, 4);
	if InputQuery('Изменение регистра', 'PC', S) then begin
		CPU.FContext.PC:=ParseNumericValue('$'+S);
		regPC := CPU.FContext.PC; //Временно
		UpdateLabels(FALSE);
		GoToAddr(CPU.Context.PC);
	end;
end;

procedure TDebugZ80.SpeedButton5Click(Sender: TObject);
{var s:string;
		M:TRAM;
		C, d1, d2: Byte;}
begin
{	M:=TRAM(DM.GetDeviceByName('ram0'));
	if InputQuery('Команда', 'Код', S) then
		C:=ParseNumericValue('$'+S);
	if InputQuery('Команда', 'd1', S) then
		d1:=ParseNumericValue('$'+S);
	if InputQuery('Команда', 'd2', S) then
		d2:=ParseNumericValue('$'+S);
	M[0]:=C;
	M[1]:=d1;
	M[2]:=d2;
	CPU.FContext.PC:=0;
	GoToAddr(0);}
end;

procedure TDebugZ80.LabelAClick(Sender: TObject);
begin
	ChangeReg8('A', CPU.FContext.A);
end;

procedure TDebugZ80.LabelCClick(Sender: TObject);
begin
	ChangeReg8('C', CPU.FContext.C);
end;

procedure TDebugZ80.ASMPanelMouseUp(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
var	N, Address:Integer;
begin
	if (X<20) then begin
		N:=Y div WindowLineHeight;
		Address := InstrData[StartLine + N].Address;
		if not CPU.CheckBreakPoint(Address) then
			CPU.AddBreakPoint(Address)
		else
			CPU.RemoveBreakPoint(Address);
		ASMPanel.Repaint;
		//ShowMessage(Format('%.4x',[]));
	end;
end;

procedure TDebugZ80.StepOverClick(Sender: TObject);
var Code: Byte;
		Size, Address: Integer;
begin
	if Stopped then begin
		Code := MM.Read(CPU.Context.PC);
		if (Code=$CD) then begin
			Size := 3; //I8080LENGTHS[Code];
			Address := CPU.Context.PC + Size;
			CPU.AddBreakPoint(Address);
			CPU.DebugMode:=DEBUG_BRAKES;
			repeat until CPU.DebugMode<>DEBUG_BRAKES;
			CPU.RemoveBreakPoint(Address);
		end else begin
			CPU.DebugMode:=DEBUG_STEP;
			repeat until CPU.DebugMode<>DEBUG_STEP;
		end;
		UpdateLabels(FALSE);
		GoToAddr(CPU.Context.PC);
		DebugWindowsManager.UpdateViews;
	end
end;

procedure TDebugZ80.RunToClick(Sender: TObject);
begin
	CPU.DebugMode:=DEBUG_BRAKES;
	SeekBtn.Down := TRUE;
	SeekTimer.Enabled:=TRUE;
end;

procedure TDebugZ80.SpeedButton8Click(Sender: TObject);
begin
	CPU.AddBreakPoint(ParseNumericValue('$'+NewAddrEdit.Text));
	ASMPanel.Repaint;
end;

procedure TDebugZ80.SpeedButton9Click(Sender: TObject);
begin
	CPU.RemoveBreakPoint(ParseNumericValue('$'+NewAddrEdit.Text));
	ASMPanel.Repaint;
end;

procedure TDebugZ80.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	case Key of
		VK_F7: StepIntoClick(Sender); 
		VK_F8: StepOverClick(Sender);
		VK_F9: RunToClick(Sender);
	end;
end;

procedure TDebugZ80.SpeedButton1Click(Sender: TObject);
begin
	CPU.ClearBreakPoints;
	ASMPanel.Invalidate;
end;

procedure TDebugZ80.LabelPCMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	if Button = mbRight then
		GoToAddr(CPU.Context.PC);
end;

procedure TDebugZ80.LabelBCMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	if Button = mbRight then
		GoToAddr(CPU.Context.BC);
end;

procedure TDebugZ80.LabelDEMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	if Button = mbRight then
		GoToAddr(CPU.Context.DE);
end;

procedure TDebugZ80.LabelHLMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	if Button = mbRight then
		GoToAddr(CPU.Context.HL);
end;

procedure TDebugZ80.ChangeReg8(Name: String; var Reg:Byte);
var S:String;
begin
	S:=IntToHex(Reg, 2);
	if InputQuery('Изменение регистра', Name, S) then begin
		Reg:=ParseNumericValue('$'+S);
		setF(CPU.FContext.F);
		UpdateLabels(FALSE);
	end;
end;

procedure TDebugZ80.LabelFClick(Sender: TObject);
begin
	ChangeReg8('F', CPU.FContext.F);
	UpdateLabels(FALSE);
end;

procedure TDebugZ80.LabelBClick(Sender: TObject);
begin
	ChangeReg8('B', CPU.FContext.B);
end;

procedure TDebugZ80.LabelDClick(Sender: TObject);
begin
	ChangeReg8('D', CPU.FContext.D);
end;

procedure TDebugZ80.LabelEClick(Sender: TObject);
begin
	ChangeReg8('E', CPU.FContext.E);
end;

procedure TDebugZ80.LabelHClick(Sender: TObject);
begin
	ChangeReg8('H', CPU.FContext.H);
end;

procedure TDebugZ80.LabelLClick(Sender: TObject);
begin
	ChangeReg8('L', CPU.FContext.L);
end;

procedure TDebugZ80.UpdateView;
begin
	UpdateLabels(TRUE);
end;

function CreateZ80DebugWnd(AOwner: TComponent; E:TEmulator; Device:TComputerDevice):TDebugWindow;
begin
	Result := TDebugZ80.CreateDebug(AOwner, E, Device);
end;

begin
	DebugWindowsManager.RegisterDebugWindow('z80r', @CreateZ80DebugWnd);
end.
