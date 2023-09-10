unit disasm;
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
	Dialogs, StdCtrls, Buttons, Mask, ExtCtrls,
	disasmData, utils, ComCtrls, Menus, StdActns, ActnList;

type
  TDisAsmWnd = class(TForm)
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    labelFile: TLabel;
    Panel4: TPanel;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    boxProcessor: TComboBox;
    editBase: TMaskEdit;
    Label4: TLabel;
    Label1: TLabel;
    editOffset: TMaskEdit;
    editLength: TMaskEdit;
    Label3: TLabel;
    btnStart: TBitBtn;
    editComment: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    checkAddresses: TCheckBox;
    Label7: TLabel;
    checkCodes: TCheckBox;
    btnSave: TBitBtn;
    btnCopy: TBitBtn;
    memoResult: TRichEdit;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    ActionList1: TActionList;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    SaveDialog: TSaveDialog;
    BitBtn2: TBitBtn;
    ProgressBar: TProgressBar;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
  private
		{ Private declarations }
		isLoaded: Boolean;
		sourceFile: String;
		sourceName: String;
	public
    { Public declarations }
  end;

var
  DisAsmWnd: TDisAsmWnd;

implementation

{$R *.dfm}

procedure TDisAsmWnd.BitBtn1Click(Sender: TObject);
var Ext: String;
		Offset, Base, Len, Size, P: Integer;
		Buffer: array [0..255] of Byte;
	//procedure ReadHeader(FName: String; FBytes: Integer; var Buffer:array of Byte);
	//var fh: Integer;
	//begin
	//	fh := FileOpen(FName, fmOpenRead);
	//	FileRead(fh, Buffer, fBytes);
	//	FileClose(fh);
	//end;
	function GetSize(FName: String):Integer;
	var fh: Integer;
	begin
		fh := FileOpen(FName, fmOpenRead);
		Result := FileSeek(fh,0,2);
		FileClose(fh);
	end;
begin
	if (OpenDialog.Execute) then begin
		isLoaded := TRUE;
		sourceFile := OpenDialog.FileName;
		labelFile.Caption := sourceFile;
		memoResult.Lines.Clear;
		Ext := AnsiLowerCase(ExtractFileExt(sourceFile));
		sourceName := ExtractFileExt(sourceFile);
		if (Ext='.bru') or (Ext='.ord') then begin
			ReadHeader(sourceFile, 16, Buffer);
			Offset := 16;
			Base := Buffer[8]+Buffer[9]*256;
			Len :=Buffer[10]+Buffer[11]*256;
		end else
		if Ext='.rko' then begin
			ReadHeader(sourceFile, 256, Buffer);
			P := 0;
			while (Buffer[P]<>$E6) and (P<256) do Inc(P);
			Inc(P, 5);
			Offset := P+16;
			Base := Buffer[P+8]+Buffer[P+9]*256;
			Len :=Buffer[P+10]+Buffer[P+11]*256;
		end else
		if (Ext='.gam') or (Ext='.pki') or (Ext='.rk') or (Ext='.rkr') or (Ext='.rks') or (Ext='.rka') then begin
			ReadHeader(sourceFile, 16, Buffer);
			if (Ext='.gam') or (Ext='.pki') then P:=1 else P:=0;
			Offset := P+4;
			Base := Buffer[P]*256+Buffer[P+1];
			Len :=Buffer[P+2]*256+Buffer[P+3];
		end else
		if Ext='.hex' then begin
			MessageDlg('Данный формат пока не поддерживается!', mtError, [mbOK], 0);
			Exit;
		end else begin
			Offset := 0;
			Base := 0;
			Len := GetSize(sourceFile);
		end;
		editOffset.Text := '$'+IntToHex(Offset, 4);
		editBase.Text := '$'+IntToHex(Base, 4);
		editLength.Text := '$'+IntToHex(Len, 4);

		Size := GetSize(sourceFile);
		if Offset + Len > Size then
			MessageDlg('Размер файла не соответствует параметрам заголовка!', mtError, [mbOK], 0);
		btnStart.Enabled := True;
		ProgressBar.Position := 0;
	end;
end;

procedure TDisAsmWnd.FormCreate(Sender: TObject);
begin
	isLoaded := FALSE;
end;

procedure TDisAsmWnd.btnStartClick(Sender: TObject);
var Proccesor: String;
		Buffer: PdisasmBuffer;
		fh, Size: Integer;
begin
	Proccesor := boxProcessor.Items[boxProcessor.ItemIndex];
	memoResult.Lines.Clear;
	Size := ParseNumericValue(editLength.Text);
	GetMem(Buffer, Size);

	fh := FileOpen(sourceFile, fmOpenRead);
	FileSeek(fh, ParseNumericValue(editOffset.Text),0);
	FileRead(fh, Buffer^, Size);
	FileClose(fh);
	if Proccesor='i8080' then
		DisAsm8080(Buffer, ParseNumericValue(editBase.Text), Size, checkAddresses.Checked, checkCodes.Checked, memoResult.Lines, ProgressBar)
	else
			MessageDlg('Данный вид процессора пока не поддерживается!', mtError, [mbOK], 0);
	btnSave.Enabled := True;
	btnCopy.Enabled := True;
end;

procedure TDisAsmWnd.btnSaveClick(Sender: TObject);
var Ext, Name:String;
begin
	if SaveDialog.Execute then begin

		if ExtractFileExt(SaveDialog.FileName)='' then
			if SaveDialog.FilterIndex=1 then Ext := '.txt'
			else
			if SaveDialog.FilterIndex=2 then Ext := '.asm'
			else
				Ext := ''
		else
			Ext := '';
		Name := SaveDialog.FileName+Ext;
		if (not FileExists(Name)) or (MessageDlg('Файл уже существует, перезаписать?', mtWarning, [mbYes, mbNo], 0)=mrYes) then
			memoResult.Lines.SaveToFile(Name);
	end;
end;

procedure TDisAsmWnd.btnCopyClick(Sender: TObject);
begin
	memoResult.SelectAll;
	memoResult.CopyToClipboard;
end;

end.
