unit Debug6502Wnd;
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
	Core, mos6502, Utils, Emulator, DebugWnd, DAsm;

type
  TDebug6502 = class(TDebugWindow)
		Panel1: TPanel;
    Label1: TLabel;
    LabelPC: TLabel;
    Label5: TLabel;
    LabelA: TLabel;
    Label7: TLabel;
    LabelS: TLabel;
		Label9: TLabel;
    LabelP: TLabel;
    LabelY: TLabel;
    Label12: TLabel;
    LabelX: TLabel;
    Label14: TLabel;
    Label33: TLabel;
    LabelFN: TLabel;
    Label35: TLabel;
    LabelFV: TLabel;
    LabelFB: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    LabelFI: TLabel;
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
    LabelF5: TLabel;
    Label27: TLabel;
    LabelFD: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    LabelFZ: TLabel;
    Label32: TLabel;
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
    procedure LabelPClick(Sender: TObject);
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
    procedure LabelXClick(Sender: TObject);
    procedure LabelSClick(Sender: TObject);
    procedure LabelYClick(Sender: TObject);
	private
		{ Private declarations }
		InstrData:array [0..65535] of T8BitInstrRec; //Адреса дизассемблированных инструкций
		StartAddr:Integer; //Адрес, с которого начинать дизассемблирование
		StartLine:Integer; //Номер строки в InstrAddresses, соответствующей первой строке
		LinesCount: Integer; //Сколько строк содержится в InstrAddresses
		WindowLen:Integer; //Сколько строк помещается в окне
		WindowLineHeight:Integer; //Высота строки на экране
		WindowLinePadding:Integer; //Отступы внутри строки для формирования промежутков
		PrevContext:T6502Context; //Для отслеживания изменения значений;
		Stopped: Boolean;
		FDisAsm: TDisAsm;
		procedure ChangeReg8(Name: String; var Reg:Byte);
	public
		{ Public declarations }
		CPU: T6502;
		MM: TMemoryMapper;
		DM: TDeviceManager;
		procedure UpdateLabels(fromTimer:Boolean);
		procedure DecodeInstrForward;
		procedure DecodeInstrBackward(Count:Integer);
		procedure GoToAddr(Addr: Integer);
		procedure UpdateView; override;
	end;

var
	Debug6502: TDebug6502;

implementation

{$R *.dfm}

procedure TDebug6502.BitBtn1Click(Sender: TObject);
begin
 Close;
end;

procedure TDebug6502.UpdateLabels;
	procedure SetLabelColor(L:TLabel; Value, PrevValue: Integer);
	var NewColor:TColor;
	begin
		if Value=PrevValue then NewColor:=clBlack
		else NewColor:=clRed;
		L.Font.Color:=NewColor;
	end;
begin
	with CPU.Context do begin
		SetLabelColor(LabelPC, PC, PrevContext.PC);
		LabelPC.Caption:=Format('%.4x', [PC AND $FFFF]);
		SetLabelColor(LabelS, S, PrevContext.S);
		LabelS.Caption:=Format('%.2x', [S AND $FF]);

		SetLabelColor(LabelA, A, PrevContext.A);
		LabelA.Caption:=Format('%.2x', [A AND $FF]);
		SetLabelColor(LabelP, P, PrevContext.P);
		LabelP.Caption:=Format('%.2x', [P AND $FF]);

		SetLabelColor(LabelX, X, PrevContext.X);
		LabelX.Caption:=Format('%.2x', [X AND $FF]);
		SetLabelColor(LabelY, Y, PrevContext.Y);
		LabelY.Caption:=Format('%.2x', [Y AND $FF]);
		
		SetLabelColor(LabelFN, P AND F_N, PrevContext.P AND F_N);
		LabelFN.Caption:=Format('%d', [(P AND F_N) shr 7]);
		SetLabelColor(LabelFV, P AND F_V, PrevContext.P AND F_V);
		LabelFV.Caption:=Format('%d', [(P AND F_V) shr 6]);
		SetLabelColor(LabelF5, P AND F_5, PrevContext.P AND F_5);
		LabelF5.Caption:=Format('%d', [(P AND F_5) shr 5]);
		SetLabelColor(LabelFB, P AND F_B, PrevContext.P AND F_B);
		LabelFB.Caption:=Format('%d', [(P AND F_B) shr 4]);
		SetLabelColor(LabelFD, P AND F_D, PrevContext.P AND F_D);
		LabelFD.Caption:=Format('%d', [(P AND F_D) shr 3]);
		SetLabelColor(LabelFI, P AND F_I, PrevContext.P AND F_I);
		LabelFI.Caption:=Format('%d', [(P AND F_I) shr 2]);
		SetLabelColor(LabelFZ, P AND F_Z, PrevContext.P AND F_Z);
		LabelFZ.Caption:=Format('%d', [(P AND F_Z) shr 1]);
		SetLabelColor(LabelFC, P AND F_C, PrevContext.P AND F_C);
		LabelFC.Caption:=Format('%d', [P AND F_C]);

	end;
	if not (fromTimer and Stopped) then PrevContext:=CPU.Context;
end;

procedure TDebug6502.FormActivate(Sender: TObject);
begin
	SeekTimer.Enabled:=SeekBtn.Down;
	if CPU.DebugMode=DEBUG_STOPPED then SpeedButton3Click(Sender);
end;

procedure TDebug6502.SeekTimerTimer(Sender: TObject);
begin
	UpdateLabels(TRUE);
	if CPU.DebugMode = DEBUG_STOPPED then begin
		SeekTimer.Enabled:=FALSE;
		SeekBtn.Down:=FALSE;
		Stopped:=TRUE;
		LinesCount:=0;
		GoToAddr(CPU.Context.PC);
		DebugWindowsManager.UpdateViews;
	end;
end;

procedure TDebug6502.SeekBtnClick(Sender: TObject);
begin
	SeekTimer.Enabled:=SeekBtn.Down;
end;

procedure TDebug6502.SpeedButton4Click(Sender: TObject);
begin
	SeekTimer.Enabled:=FALSE;
	Close;
end;

procedure TDebug6502.FormCreate(Sender: TObject);
begin
	CPU:=T6502(FDevice);
	MM := TMemoryMapper(FE.DM.GetDeviceByName('mapper'));
	DM := FE.DM;
	WindowLineHeight:=17;
	WindowLinePadding:=1;
	StartLine:=0;
	StartAddr:=$0000;
	LinesCount:=0;
	Stopped:=FALSE;
	WindowLen:=ASMPanel.Height div WindowLineHeight;
	ScrollBar.Position:=StartAddr;

  FDisAsm := TDisAsm.Create(ExtractFilePath(ParamStr(0))+'Data/6502.dis');
end;

procedure TDebug6502.ASMPanelPaint(Sender: TObject);
var i, j, Address:Integer;
		Bytes, AddrStr:String;
		LinesColor, BreakColor, CurrentColor:Integer;
		LT, LB, L, W: Integer;
begin
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

procedure TDebug6502.DecodeInstrForward;
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

procedure TDebug6502.DecodeInstrBackward(Count:Integer);
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


procedure TDebug6502.NewAddrBtnClick(Sender: TObject);
begin
	LinesCount:=0;
	GoToAddr(ParseNumericValue('$'+NewAddrEdit.Text));
end;

procedure TDebug6502.GoToAddr(Addr: Integer);
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

procedure TDebug6502.ScrollBarScroll(Sender: TObject;
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

procedure TDebug6502.NewAddrEditKeyPress(Sender: TObject; var Key: Char);
begin
	if Key=#13 then NewAddrBtn.Click;
end;

procedure TDebug6502.SpeedButton3Click(Sender: TObject);
begin
	CPU.DebugMode:=DEBUG_STOPPED;
	Stopped:=TRUE;
	GoToAddr(CPU.Context.PC);
	//SeekBtn.Down:=FALSE;
	SeekTimer.Enabled:=FALSE;
	UpdateLabels(FALSE);
	DebugWindowsManager.UpdateViews;
end;

procedure TDebug6502.StartClick(Sender: TObject);
begin
	CPU.DebugMode:=DEBUG_OFF;
	Stopped:=FALSE;
	SeekTimer.Enabled:=SeekBtn.Down;
end;

procedure TDebug6502.StepIntoClick(Sender: TObject);
begin
	if Stopped then begin
		CPU.DebugMode:=DEBUG_STEP;
		repeat until CPU.DebugMode<>DEBUG_STEP;
		UpdateLabels(FALSE);
		GoToAddr(CPU.Context.PC);
		DebugWindowsManager.UpdateViews;
	end
end;

procedure TDebug6502.LabelPCDblClick(Sender: TObject);
var S:String;
begin
	S:=IntToHex(CPU.Context.PC, 4);
	if InputQuery('Изменение регистра', 'PC', S) then begin
		CPU.FContext.PC:=ParseNumericValue('$'+S);
		UpdateLabels(FALSE);
		GoToAddr(CPU.Context.PC);
	end;
end;

procedure TDebug6502.SpeedButton5Click(Sender: TObject);
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

procedure TDebug6502.LabelAClick(Sender: TObject);
begin
	ChangeReg8('A', CPU.FContext.A);
end;

procedure TDebug6502.LabelPClick(Sender: TObject);
begin
	ChangeReg8('P', CPU.FContext.P);
end;

procedure TDebug6502.ASMPanelMouseUp(Sender: TObject; Button: TMouseButton;
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

procedure TDebug6502.StepOverClick(Sender: TObject);
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

procedure TDebug6502.RunToClick(Sender: TObject);
begin
	CPU.DebugMode:=DEBUG_BRAKES;
	SeekBtn.Down := TRUE;
	SeekTimer.Enabled:=TRUE;
end;

procedure TDebug6502.SpeedButton8Click(Sender: TObject);
begin
	CPU.AddBreakPoint(ParseNumericValue('$'+NewAddrEdit.Text));
	ASMPanel.Repaint;
end;

procedure TDebug6502.SpeedButton9Click(Sender: TObject);
begin
	CPU.RemoveBreakPoint(ParseNumericValue('$'+NewAddrEdit.Text));
	ASMPanel.Repaint;
end;

procedure TDebug6502.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	case Key of
		VK_F7: StepIntoClick(Sender); 
		VK_F8: StepOverClick(Sender);
		VK_F9: RunToClick(Sender);
	end;
end;

procedure TDebug6502.SpeedButton1Click(Sender: TObject);
begin
	CPU.ClearBreakPoints;
	ASMPanel.Invalidate;
end;

procedure TDebug6502.LabelPCMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	if Button = mbRight then
		GoToAddr(CPU.Context.PC);
end;

procedure TDebug6502.ChangeReg8(Name: String; var Reg:Byte);
var S:String;
begin
	S:=IntToHex(Reg, 2);
	if InputQuery('Изменение регистра', Name, S) then begin
		Reg:=ParseNumericValue('$'+S);
		UpdateLabels(FALSE);
	end;
end;

procedure TDebug6502.LabelXClick(Sender: TObject);
begin
	ChangeReg8('X', CPU.FContext.X);
end;


procedure TDebug6502.LabelSClick(Sender: TObject);
begin
	ChangeReg8('S', CPU.FContext.S);
end;

procedure TDebug6502.LabelYClick(Sender: TObject);
begin
	ChangeReg8('Y', CPU.FContext.Y);
end;

procedure TDebug6502.UpdateView;
begin
	UpdateLabels(TRUE);
end;


function Create6502DebugWnd(AOwner: TComponent; E:TEmulator; Device:TComputerDevice):TDebugWindow;
begin
	Result := TDebug6502.CreateDebug(AOwner, E, Device);
end;

begin
	DebugWindowsManager.RegisterDebugWindow('6502', @Create6502DebugWnd);
end.
