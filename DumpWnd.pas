unit DumpWnd;
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

{$RANGECHECKS OFF}
interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, ExtCtrls, StdCtrls, Buttons,
	Emulator, Core, Utils, DebugWnd;

type
  TDumpWindow = class(TDebugWindow)
    Panel1: TPanel;
    Panel2: TPanel;
    DumpBox: TPaintBox;
    AddrEdit: TEdit;
    GoBtn: TSpeedButton;
    Panel3: TPanel;
		ScrollBar: TScrollBar;
    SpeedButton1: TSpeedButton;
		procedure GoBtnClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure DumpBoxPaint(Sender: TObject);
		procedure FormActivate(Sender: TObject);
		procedure AddrEditKeyPress(Sender: TObject; var Key: Char);
		procedure ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode;
			var ScrollPos: Integer);
    procedure SpeedButton1Click(Sender: TObject);
	private
		{ Private declarations }
		PrevBuffer1:PStorage;
		PrevBuffer2:PStorage;
		MemoryBuffer:PStorage;
		StartAddr: Cardinal;
		WindowLineHeight:Integer;
		CharMap: String;
	public
		{ Public declarations }
		procedure UpdateView; override;
	end;

var
  DumpWindow: TDumpWindow;

implementation

{$R *.dfm}

function CreateDumpWnd(AOwner: TComponent; E:TEmulator; Device:TComputerDevice):TDebugWindow;
begin
	Result := TDumpWindow.CreateDebug(AOwner, E, Device);
end;

procedure TDumpWindow.GoBtnClick(Sender: TObject);
begin
	StartAddr:=ParseNumericValue('$'+AddrEdit.Text);
	DumpBox.Invalidate;
end;

procedure TDumpWindow.FormCreate(Sender: TObject);
var 
	F: TextFile;
	S: string;
begin
	StartAddr:=0;
	WindowLineHeight:=17;
	CharMap:='';
	if FE.SD.SystemCharMap<>'' then begin
		//AssignFile(F, FE.SD.SystemPath + FE.SD.SystemCharMap+'.chr');
		AssignFile(F, ExtractFilePath(ParamStr(0)) +'Data/' + FE.SD.SystemCharMap+'.chr');
		Reset(F);
		while not EOF(F) do begin
			Readln(F, S);
			CharMap:=CharMap + S;
		end;
		CloseFile(F);
	end;
	MemoryBuffer:=TMemory(FDevice).Buffer;
	ScrollBar.Max:=TMemory(FDevice).Size;
	GetMem(PrevBuffer1, 65536);
	GetMem(PrevBuffer2, 65536);
	Move(MemoryBuffer^, PrevBuffer1^, TMemory(FDevice).Size);
	Move(MemoryBuffer^, PrevBuffer2^, TMemory(FDevice).Size);
end;

procedure TDumpWindow.DumpBoxPaint(Sender: TObject);
var LinesCount, i, j, D:Integer;
		AddrStr, DataStr:String;
		Address: Cardinal;
begin
	LinesCount:=DumpBox.Height div WindowLineHeight;
	DumpBox.Canvas.Brush.Color:=RGB(0, 0, 0);
	for i:=0 to LinesCount-1 do begin
		Address:=StartAddr + Cardinal(i)*16;
		if Address<TMemory(FDevice).Size then begin
			AddrStr:=Format('%.4x :',[Address]);
			DumpBox.Canvas.Font.Color:=RGB(255, 255, 255);
			DumpBox.Canvas.TextOut(0, i*WindowLineHeight, AddrStr);
			for j:=0 to 15 do begin
				Address := StartAddr + Cardinal(i)*16 + Cardinal(j);
				if Address<TMemory(FDevice).Size then begin
					D:=MemoryBuffer^[Address];
					if D=PrevBuffer1^[Address] then
						DumpBox.Canvas.Font.Color:=RGB(255, 255, 255)
					else
						DumpBox.Canvas.Font.Color:=RGB(255, 0, 0);
					DataStr:=Format('%.2x',[D]);
					DumpBox.Canvas.TextOut(50 + j*20, i*WindowLineHeight, DataStr);
					DumpBox.Canvas.TextOut(400 + j*8, i*WindowLineHeight, CharMap[D+1]);
				end;
			end;
		end;
	end;
end;

procedure TDumpWindow.FormActivate(Sender: TObject);
begin
	AddrEdit.Text:=Format('%.4x',[StartAddr]);
end;

procedure TDumpWindow.AddrEditKeyPress(Sender: TObject; var Key: Char);
begin
	if Key=#13 then GoBtn.Click;
end;

procedure TDumpWindow.ScrollBarScroll(Sender: TObject;
	ScrollCode: TScrollCode; var ScrollPos: Integer);
var LinesCount, PageSize:Integer;
begin
	LinesCount:=DumpBox.Height div WindowLineHeight;
	PageSize := LinesCount * 16;
	case ScrollCode of
		scLineUp:begin
								if StartAddr > 16 then begin
									Dec(StartAddr, 16);
									DumpBox.Invalidate;
									ScrollPos:=StartAddr;
								end;
							 end;
		scLineDown:begin
								if StartAddr < TMemory(FDevice).Size-16 then begin
									Inc(StartAddr, 16);
									DumpBox.Invalidate;
									ScrollPos:=StartAddr;
								end;
							 end;
		scPageUp:begin
								if StartAddr > Cardinal(PageSize) then begin
									Dec(StartAddr, PageSize);
									DumpBox.Invalidate;
									ScrollPos:=StartAddr;
								end;
							 end;
		scPageDown:begin
								if StartAddr < TMemory(FDevice).Size - Cardinal(PageSize) then begin
									Inc(StartAddr, PageSize);
									DumpBox.Invalidate;
									ScrollPos:=StartAddr;
								end;
							 end;
		scPosition:begin
									StartAddr:=ScrollPos div 16 * 16;
									DumpBox.Invalidate;
								end;
		scTrack:;
		scTop:;
		scBottom:;
		scEndScroll:;
	end;

end;

procedure TDumpWindow.SpeedButton1Click(Sender: TObject);
begin
	UpdateView;
end;

procedure TDumpWindow.UpdateView;
begin
	DumpBox.Invalidate;
	Move(PrevBuffer2^, PrevBuffer1^, TMemory(FDevice).Size);
	Move(MemoryBuffer^, PrevBuffer2^, TMemory(FDevice).Size);
end;


begin
	DebugWindowsManager.RegisterDebugWindow('ram', @CreateDumpWnd);
	DebugWindowsManager.RegisterDebugWindow('rom', @CreateDumpWnd);
end.
