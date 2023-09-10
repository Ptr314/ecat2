unit TapeControlWnd;
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
	Dialogs, StdCtrls, ExtCtrls,
	Emulator, utils, DebugWnd, core, Tape, Files,
	Buttons, ImgList;

type
  TTapeWnd = class(TDebugWindow)
    FileLabel: TLabel;
    Timer: TTimer;
    BtnOpen: TSpeedButton;
    BtnPlay: TSpeedButton;
    BtnMute: TSpeedButton;
		OpenDialog: TOpenDialog;
		TimeLabel: TLabel;
    ImageList1: TImageList;
		procedure TimerTimer(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure FormHide(Sender: TObject);
		procedure BtnOpenClick(Sender: TObject);
    procedure BtnPlayClick(Sender: TObject);
    procedure BtnMuteClick(Sender: TObject);
	private
		{ Private declarations }
		procedure UpdateTime;
	public
		{ Public declarations }
		procedure UpdateView; override;
	end;

var
	TapeWnd: TTapeWnd;

implementation

{$R *.dfm}

function CreateTapeWnd(AOwner: TComponent; E:TEmulator; Device:TComputerDevice):TDebugWindow;
begin
	Result := TTapeWnd.CreateDebug(AOwner, E, Device);
end;

procedure TTapeWnd.TimerTimer(Sender: TObject);
var Image: TBitmap;
begin
	UpdateTime;
	if not TTapeRecorder(FDevice).Busy then begin
		Timer.Enabled := FALSE;
		Image := TBitmap.Create;
		ImageList1.GetBitmap(0, Image);
		BtnPlay.Glyph.Assign(Image);
		Image.Free;
	end;
	//Bin.Caption := IntToBin(TPort(FDevice).Value[0], 8);
	//Hex.Caption := IntToHex(TPort(FDevice).Value[0] and $FF, 2);
end;

procedure TTapeWnd.FormShow(Sender: TObject);
begin
	//Timer.Enabled := True;
end;

procedure TTapeWnd.FormHide(Sender: TObject);
begin
	//Timer.Enabled := False;
end;

procedure TTapeWnd.BtnOpenClick(Sender: TObject);
var FileName, Ext, Fmt: String;
begin
	OpenDialog.Filter := FE.SD.AllowedFiles;
	if OpenDialog.Execute then begin
		FileName := OpenDialog.FileName;
		FileLabel.Caption := ExtractFileName(FileName);
		Ext := ExtractFileExt(FileName);
		Ext := Copy(Ext, 2, Length(Ext)-1);
		Fmt := FE.ReadSetup('TapeFiles', Ext, '');
		if Fmt='' then
			MessageDlg('Данный формат пока не поддерживается!', mtError, [mbOK], 0)
		else begin
			TTapeRecorder(FDevice).LoadFile(Fmt, FileName);
			UpdateTime;
			BtnPlay.Enabled := TRUE;
		end;
	end;
end;

procedure TTapeWnd.BtnPlayClick(Sender: TObject);
var Image: TBitmap;
begin
	Image := TBitmap.Create;
	if TTapeRecorder(FDevice).Busy then begin
		ImageList1.GetBitmap(0, Image);
		BtnPlay.Glyph.Assign(Image);
		TTapeRecorder(FDevice).StopTape;
	end else begin
		ImageList1.GetBitmap(1, Image);
		BtnPlay.Glyph.Assign(Image);
		TTapeRecorder(FDevice).StartRead;
	end;
	Timer.Enabled := TTapeRecorder(FDevice).Busy;
	Image.Free;
	UpdateTime;
end;

procedure TTapeWnd.BtnMuteClick(Sender: TObject);
var Image: TBitmap;
begin
	Image := TBitmap.Create;
	if TTapeRecorder(FDevice).Mute then begin
		ImageList1.GetBitmap(3, Image);
	end else begin
		ImageList1.GetBitmap(2, Image);
	end;
	TTapeRecorder(FDevice).Mute := not TTapeRecorder(FDevice).Mute;
	BtnMute.Glyph.Assign(Image);
	BtnMute.NumGlyphs := 2;
	Image.Free;
end;

procedure TTapeWnd.UpdateTime;
begin
	if TTapeRecorder(FDevice).Busy then begin
		TimeLabel.Caption :=  FormatTime(TTapeRecorder(FDevice).CurrentSeconds) +
													'/' +
													FormatTime(TTapeRecorder(FDevice).TotalSeconds);
	end else begin
		TimeLabel.Caption := FormatTime(TTapeRecorder(FDevice).TotalSeconds);
	end;
end;

procedure TTapeWnd.UpdateView;
begin
	{Здесь ничего делать не надо}
end;

begin
	DebugWindowsManager.RegisterDebugWindow('taperecorder', @CreateTapeWnd);
end.
