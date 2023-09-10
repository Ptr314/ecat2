unit main;
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
	Dialogs, StdCtrls, StrUtils, Menus, ImgList, ExtDlgs, ExtCtrls, ComCtrls,
	Buttons,
	CpuUsage, DX,
	Emulator, Core, DebugWnd, i8080, Debug8080Wnd, ScanKbd, i8255, i8253,
	i8255Debug, DumpWnd, Files, FDD, Utils, ChooseConfig, Tape, z80, modZ80,
	TapeControlWnd, PortDebug, DebugZ80Wnd, FDC, Config, mos6502, wd1793,
	Debug6502Wnd, AgatDisplay, AgatFDC, i8257Debug;

type
	TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    Timer_GDI: TTimer;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuDevices: TMenuItem;
    N3: TMenuItem;
    MenuFileOpen: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    OpenDialog: TOpenDialog;
    ToolBar: TPanel;
    SpeedButton1: TSpeedButton;
    DebugBtn: TSpeedButton;
    RstWarmBtn: TSpeedButton;
    StatusBar: TStatusBar;
    Timer_Status: TTimer;
    N1: TMenuItem;
    N2: TMenuItem;
    N1001: TMenuItem;
    N1002: TMenuItem;
    N4: TMenuItem;
    N1003: TMenuItem;
    N2001: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    FileDialog: TOpenDialog;
    N14: TMenuItem;
    SpeedButton4: TSpeedButton;
    RstHardBtn: TSpeedButton;
    SpeedButton6: TSpeedButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    SavePictureDialog: TSavePictureDialog;
		Btn_fdd0: TSpeedButton;
		FDDImages: TImageList;
    SpeedButton7: TSpeedButton;
    Btn_fdd1: TSpeedButton;
    SpeedButton9: TSpeedButton;
    Bevel3: TBevel;
    FDDPopup: TPopupMenu;
		FDD_Popup_Image: TMenuItem;
    N4561: TMenuItem;
    FDD_Popup_Load: TMenuItem;
    FDD_Popup_Unload: TMenuItem;
		FDD_Popup_Save: TMenuItem;
		FDD_Popup_Protect: TMenuItem;
    FileSaveDialog: TSaveDialog;
    SpeedButton2: TSpeedButton;
    Bevel4: TBevel;
    Timer_FDD: TTimer;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
		procedure PaintBox1Paint(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure Button1Click(Sender: TObject);
		procedure Timer_GDITimer(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure FormKeyUp(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure MenuFileOpenClick(Sender: TObject);
		procedure Timer_StatusTimer(Sender: TObject);
		procedure N1001Click(Sender: TObject);
		procedure N1002Click(Sender: TObject);
		procedure N1003Click(Sender: TObject);
		procedure N2001Click(Sender: TObject);
		procedure N13Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure Btn_fdd0Click(Sender: TObject);
    procedure Btn_fdd1Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure FDD_Popup_LoadClick(Sender: TObject);
    procedure FDD_Popup_UnloadClick(Sender: TObject);
    procedure FDD_Popup_SaveClick(Sender: TObject);
    procedure FDD_Popup_ProtectClick(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Timer_FDDTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
	private
		{ Private declarations }
		//function ParseXML(FileName:String):String;
		//procedure ParseNode(Node:TXmlNode; Indent:string);
		//function GetAttributes(Node:TXmlNode):String;
		PrevTime: TDateTime;
		ScreenRatio:Extended;
		ScreenScale:Cardinal;
		FDD_id : String;
		FCPUQuery: TPDHQuery;
		FCPUCounter: TCounter;
		FFDC: TFDC;
		FFDD0, FFDD1: TCommonFDD;
		FFDDImage: array [0..1] of Cardinal;
		Video_Enable: Boolean;
		FFPS, FMaxFPS: Cardinal;
		HighPriority: Boolean;
		UseDI: Boolean;
		PrevScreenX, PrevScreenY: Cardinal;
		procedure CreateDevicesMenu;
		procedure SetFDDImages;
		procedure DevicesMenuClick(Sender: TObject);
		procedure	SetScreenSize(Ratio:Extended; Scale:Cardinal);
		procedure FDD_Load(Id: String);
		procedure FDD_Popup(Id: String; Btn:TSpeedButton);
		procedure CMDialogKey( Var msg: TCMDialogKey );	message CM_DIALOGKEY;
		procedure RepaintScreen(Forced:Boolean);
		procedure IdleRepaint(Sender: TObject; var Done: Boolean);
	public
		{ Public declarations }
		E: TEmulator;
  end;

var
  Form1: TForm1;

implementation

uses disasm, About;

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
var	CPUIndex:Integer;
begin
	CPUIndex := E.DM.GetDeviceIndex('cpu');
	if DebugWindowsManager.HasDebugWindow(E.DM[CPUIndex].DeviceType) then
		DebugWindowsManager.OpenDebugWindow(TComponent(Sender), E, CPUIndex);
end;

procedure TForm1.FormCreate(Sender: TObject);
var FileToLoad: String;
		ExePath:String;
begin
	//Функции привязаны к языку системы
	//Поэтому, если это не русский или английский
	//замер отключается
	//Вообще, странно. Надо подобрать другую библиотеку.
	try
		FCPUQuery :=TPDHQuery.Create;
		FCPUCounter:=TCounter.Create(FCPUQuery, -1);
	except
		FCPUQuery := nil;
	end;

	ExePath := ExtractFilePath(Application.ExeName);

	E:= TEmulator.Create(ExePath + 'Computers\', ExePath + 'ecat.ini');

	FileToLoad := E.ReadSetup('Startup', 'default', '');
	if (FileToLoad='') or (not FileExists(E.WorkPath + FileToLoad)) then
		FileToLoad := E.WorkPath + 'Orion-128\orion-128.cfg'
	else
		FileToLoad := E.WorkPath + FileToLoad;

	UseDI := E.ReadSetup('Core', 'DirectInput', '1') <> '0';

	E.LoadConfig(FileToLoad);
	E.Start(UseDI, Handle);
	SetScreenSize(E.SD.ScreenRatio, E.SD.ScreenScale);


	//Timer_GDI.Enabled := true;

	FillChar(FFDDImage, SizeOf(FFDDImage), $FF);

	CreateDevicesMenu;

	FMaxFPS := StrToInt(E.ReadSetup('Video', 'max_fps', '100'));
	HighPriority := E.ReadSetup('Video', 'high_priority', '1') <> '0';

	Application.OnIdle:= IdleRepaint;
	Video_Enable := TRUE;
	FFPS := 0;

	Caption := 'eCat / '+E.SD.SystemName+' ('+E.SD.SystemVersion+')';

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
	RepaintScreen(True);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	Video_Enable := FALSE;
	E.Stop;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
	E.Reset(FALSE);
end;

procedure TForm1.Timer_GDITimer(Sender: TObject);
begin
	//PaintBox1Paint(Sender);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	if not UseDI then E.KeyDown(Key);
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	if not UseDI then E.KeyUp(Key);
end;

procedure TForm1.DevicesMenuClick(Sender: TObject);
begin
  with Sender as TMenuItem do
	begin
		DebugWindowsManager.OpenDebugWindow(TComponent(Sender), E, Tag);
	end;
end;

procedure TForm1.CreateDevicesMenu;
var Item:TMenuItem;
		i:Integer;
		CPUIndex:Integer;
begin
	for i:=MenuDevices.Count-1 downto 0 do begin
		Item:=MenuDevices.Items[i];
		MenuDevices.Remove(Item);
		Item.Free;
	end;

	for i:=0 to E.DM.DevicesCount-1 do begin
		Item := TMenuItem.Create(MainMenu);
		Item.Caption := E.DM[i].DeviceName + ' : ' + E.DM[i].DeviceType;
		Item.Tag := i;
		Item.OnClick := DevicesMenuClick;
		Item.Enabled:=DebugWindowsManager.HasDebugWindow(E.DM[i].DeviceType);
		MenuDevices.Add(Item);
	end;

	SpeedButton4.Enabled:=E.SD.AllowedFiles <> '';

	try
		CPUIndex := E.DM.GetDeviceIndex('cpu');
		DebugBtn.Enabled := DebugWindowsManager.HasDebugWindow(E.DM[CPUIndex].DeviceType);
	except
		DebugBtn.Enabled := False;
	end;

	FFDC :=  E.DM.GetDeviceByName('fdc', false) as TFDC;
	FFDD0 := E.DM.GetDeviceByName('fdd0', false) as TCommonFDD;
	FFDD1 := E.DM.GetDeviceByName('fdd1', false) as TCommonFDD;
	SetFDDImages;
	Timer_FDD.Enabled := Assigned(FFDD0);

	//Btn_fdd0.Enabled := Assigned(FFDD0);
	//SpeedButton7.Enabled := Assigned(FFDD0);
	//Btn_fdd1.Enabled := Assigned(FFDD1);
	//SpeedButton9.Enabled := Assigned(FFDD1);
end;

procedure TForm1.MenuFileOpenClick(Sender: TObject);
var NewName: String;
begin
	ChooseConfigDlg.WorkPath := E.WorkPath;
	ChooseConfigDlg.CurrentFile := E.SD.SystemFile;
	if ChooseConfigDlg.ShowModal=mrOK then begin
		if ChooseConfigDlg.DefBox.Checked then begin
			if AnsiStartsStr(E.WorkPath, ChooseConfigDlg.SelectedFile) then
				NewName := RightStr(ChooseConfigDlg.SelectedFile, Length(ChooseConfigDlg.SelectedFile) - Length(E.WorkPath))
			else
				NewName := ChooseConfigDlg.SelectedFile;
			E.WriteSetup('Startup', 'default', NewName);
		end;
		if ChooseConfigDlg.SelectedFile <> E.SD.SystemFile then begin
			Video_Enable := False;
			DebugWindowsManager.Clear;
			E.LoadConfig(ChooseConfigDlg.SelectedFile);
			if E.Loaded then begin
				E.Start(UseDI, Handle);
				SetScreenSize(E.SD.ScreenRatio, E.SD.ScreenScale);
				CreateDevicesMenu;
				Caption := 'eCat / '+E.SD.SystemName+' ('+E.SD.SystemVersion+')';
			end;
			Video_Enable := E.Loaded;
		end;
	end;
end;

procedure TForm1.Timer_StatusTimer(Sender: TObject);
var	T: TdateTime;
		ED: TComputerDevice;
begin
	if not E.Loaded then exit;
	T:=(GetTime-PrevTime)*24*60*60;
	if T<>0 then begin
		StatusBar.Panels[1].Text:=IntToStr(Round(E.ClockCounter*(1/T)))+' Hz';
		if Assigned(FCPUQuery) then begin
			FCPUQuery.Refresh;
			StatusBar.Panels[0].Text:='CPU: '+IntToStr(Round(FCPUCounter.Value))+'%';
		end;
		E.ClockCounter:=0;
		PrevTime:=GetTime;
		StatusBar.Panels[2].Text:=IntToStr(Round(FFPS*1000/Timer_Status.Interval)) + ' FPS';
		FFPS := 0;

		if (E.MM.CacheHit + E.MM.CacheMiss) > 0 then
			StatusBar.Panels[3].Text:=Format('Cache hit: %.2f%%', [E.MM.CacheHit / (E.MM.CacheHit + E.MM.CacheMiss) * 100])
		else
			StatusBar.Panels[3].Text:='Stopped';
		E.MM.CacheHit := 0;
		E.MM.CacheMiss := 0;

		if E.DM.ErrorDevice <> nil then begin
			ED := E.DM.ErrorDevice; //Надо сначала запомнить,
			E.DM.ErrorClear; 				//а потом сразу очистить
			MessageDlg( 'Инструкция по адресу '+IntToHex(E.CPU_PC,8)+
									' вызвала ошибку '''+E.DM.ErrorMsg+''' в устройстве '+
									ED.Name+':'+ED.DType+'.',
									mtError, [mbOk], 0);
		end;
	end;
end;

procedure	TForm1.SetScreenSize(Ratio:Extended; Scale:Cardinal);
begin
	ScreenRatio := Ratio;
	ScreenScale := Scale;
	Width := E.ScreenX * Scale + Cardinal(GetSystemMetrics(SM_CXFIXEDFRAME)*2);

	Height := Round(E.ScreenY * Scale * Ratio) + ToolBar.Height + StatusBar.Height +
		GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CYMENU) +
		GetSystemMetrics(SM_CYFIXEDFRAME)*2;

	PaintBox1.Left := (Cardinal(Width) - E.ScreenX * Scale - Cardinal(GetSystemMetrics(SM_CXFIXEDFRAME)*2)) div 2;

	PaintBox1.Width:=E.ScreenX*ScreenScale;
	PaintBox1.Height:=Round(E.ScreenY*ScreenScale*ScreenRatio);

	N1001.Checked:=(Ratio=1) and (Scale=1);
	N1002.Checked:=(Ratio=1) and (Scale=2);
	N1003.Checked:=(Ratio=E.SD.ScreenRatio) and (Scale=1);
	N2001.Checked:=(Ratio=E.SD.ScreenRatio) and (Scale=2);

	PrevScreenX := E.ScreenX;
	PrevScreenY := E.ScreenY;
end;

procedure TForm1.N1001Click(Sender: TObject);
begin
	SetScreenSize(1, 1);
end;

procedure TForm1.N1002Click(Sender: TObject);
begin
	SetScreenSize(1, 2);
end;

procedure TForm1.N1003Click(Sender: TObject);
begin
	SetScreenSize(E.SD.ScreenRatio, 1);
end;

procedure TForm1.N2001Click(Sender: TObject);
begin
	SetScreenSize(E.SD.ScreenRatio, 2);
end;

procedure TForm1.N13Click(Sender: TObject);
begin
	DisAsmWnd.ShowModal;
end;

procedure TForm1.N9Click(Sender: TObject);
begin
	E.Reset(TRUE);
end;

procedure TForm1.N14Click(Sender: TObject);
begin
	//if FileDialog.InitialDir = '' then
	//	FileDialog.InitialDir := E.SD.SoftwarePath;
	if E.SD.AllowedFiles<>'' then begin
		FileDialog.Filter := E.SD.AllowedFiles;
		if FileDialog.Execute then begin
			HandleExternalFile(E, FileDialog.FileName);
		end;
	end;
end;

procedure TForm1.N5Click(Sender: TObject);
begin
	Close;
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
var BitMap : TBitMap;
begin
	BitMap := TBitMap.create;
	BitMap.Assign(E.GetScreen(True));

	SavePictureDialog.DefaultExt := GraphicExtension(TBitmap);
	SavePictureDialog.Filter := GraphicFilter(TBitmap);
	if SavePictureDialog.Execute then	BitMap.SaveToFile(SavePictureDialog.FileName);
	
	BitMap.Free;  
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
	if Assigned(FFDD0) then FDD_Popup('fdd0', Btn_fdd0);
end;

procedure TForm1.Btn_fdd0Click(Sender: TObject);
begin
	if Assigned(FFDD0) then FDD_Load('fdd0');
end;

procedure TForm1.Btn_fdd1Click(Sender: TObject);
begin
	if Assigned(FFDD1) then FDD_Load('fdd1');
end;

procedure TForm1.SetFDDImages;
	procedure SetFDDImage(FDC: TFDC; FDD:TCommonFDD; BTN: TSpeedButton; SelectedDrive:Cardinal; var PrevImage:Cardinal);
	var G: Cardinal;
			Image: TBitmap;
	begin
		if Assigned(FDD) then begin
			if not FDD.IsLoaded then G := 0
			else
			if Assigned(FDC) and FDC.IsBusy and (FDC.SelectedDrive=SelectedDrive) then G:=3
			else
			if FDD.IsProtected then G := 2
			else G := 1;
		end else
			G:=0;

		if G<>PrevImage then begin
			Image := TBitmap.Create;
			FDDImages.GetBitmap(G, Image);
			BTN.Glyph.Assign(Image);
			Image.Free;
			PrevImage := G;
		end;
	end;
begin
	SetFDDImage(FFDC, FFDD0, Btn_fdd0, 0, FFDDImage[0]);
	SetFDDImage(FFDC, FFDD1, Btn_fdd1, 1, FFDDImage[1]);
end;

procedure TForm1.FDD_Load(Id: String);
var FDD: TCommonFDD;
begin
	if Id<>'' then
		FDD := E.DM.GetDeviceByName(Id) as TCommonFDD
	else
		FDD := E.DM.GetDeviceByName(FDD_id) as TCommonFDD;
	FileDialog.Filter := FDD.Files;
	if FileDialog.Execute then begin
			FDD.LoadImage(FileDialog.FileName);
			SetFDDImages;
	end;
end;

procedure TForm1.FDD_Popup(Id: String; Btn:TSpeedButton);
var P:TPoint;
		FDD: TCommonFDD;
begin
	FDD := E.DM.GetDeviceByName(Id) as TCommonFDD;
	P:=Btn.ClientToScreen(Point(0, Btn.Height));
	FDD_id := Id;
	if FDD.FileName<>'' then
		FDD_Popup_Image.Caption := FDD.FileName
	else
		FDD_Popup_Image.Caption := 'Файл не загружен';

	FDD_Popup_Protect.Checked := FDD.IsProtected and FDD.IsLoaded;

	FDD_Popup_Protect.Enabled := FDD.IsLoaded; 
	FDD_Popup_Unload.Enabled := FDD.IsLoaded;
	FDD_Popup_Save.Enabled := FDD.IsLoaded;

	FDDPopup.Popup(P.X, P.Y);
end;

procedure TForm1.SpeedButton9Click(Sender: TObject);
begin
	if Assigned(FFDD1) then FDD_Popup('fdd1', Btn_fdd1);
end;

procedure TForm1.FDD_Popup_LoadClick(Sender: TObject);
begin
	FDD_Load('');
end;

procedure TForm1.FDD_Popup_UnloadClick(Sender: TObject);
var FDD: TCommonFDD;
begin
	FDD := E.DM.GetDeviceByName(FDD_id) as TCommonFDD;
	FDD.UnLoad;
	SetFDDImages;
end;

procedure TForm1.FDD_Popup_SaveClick(Sender: TObject);
var FDD: TCommonFDD;
		S: array [0..20] of String;
begin
	FDD := E.DM.GetDeviceByName(FDD_id) as TCommonFDD;
	FileSaveDialog.Filter := FDD.Files;
	Explode(S, '|', FDD.Files);
	Explode(S, ';', S[1]);
	Explode(S, '.', S[0]);
	FileSaveDialog.DefaultExt := S[1];
	if FileSaveDialog.Execute then begin
			FDD.SaveImage(FileSaveDialog.FileName);
			SetFDDImages;
	end;
end;

procedure TForm1.FDD_Popup_ProtectClick(Sender: TObject);
var FDD: TCommonFDD;
begin
	FDD := E.DM.GetDeviceByName(FDD_id) as TCommonFDD;
	FDD.ChangeProtection;
	SetFDDImages;
end;

procedure TForm1.CMDialogKey(var msg: TCMDialogKey);
begin
    if msg.Charcode <> VK_TAB then
        inherited;
end;

procedure TForm1.N7Click(Sender: TObject);
begin
	AboutDlg.ShowModal;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
	if Assigned(FCPUQuery) then begin
		FCPUCounter.Free;
		FCPUQuery.Free;
	end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
var	TapeIndex:Integer;
begin
	TapeIndex := E.DM.GetDeviceIndex('tape');
	if DebugWindowsManager.HasDebugWindow(E.DM[TapeIndex].DeviceType) then
		DebugWindowsManager.OpenDebugWindow(TComponent(Sender), E, TapeIndex);
end;

procedure TForm1.Timer_FDDTimer(Sender: TObject);
begin
	if E.Loaded then SetFDDImages;
end;

procedure TForm1.IdleRepaint(Sender: TObject; var Done: Boolean);
var dT: TDateTime;
		dF: Extended;
begin
	dT := (GetTime-PrevTime)*24*60*60;
	dF := FFPS / FMaxFPS;

	if dF < dT then begin
		if Video_Enable then RepaintScreen(False);
		Inc(FFPS);
		Done := FALSE
	end else
		Done := not HighPriority;
end;

procedure TForm1.RepaintScreen(Forced:Boolean);
var Bitmap: TBitmap;
begin
	//Экран перерисовывется в двух случаях - когда это надо обязательно
	//или на нем произошли изменения
	Bitmap := E.GetScreen(Forced);
	if Forced or Assigned(Bitmap) then begin
		if (E.ScreenX<>PrevScreenX) or (E.ScreenY<>PrevScreenY) then
			SetScreenSize(ScreenRatio, ScreenScale);
		PaintBox1.Canvas.StretchDraw(Rect(0, 0, PaintBox1.Width, PaintBox1.Height), Bitmap);
	end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
	if Assigned(E) then E.HaveFocus := TRUE;
end;

procedure TForm1.FormDeactivate(Sender: TObject);
begin
	if Assigned(E) then E.HaveFocus := FALSE;
end;

end.
