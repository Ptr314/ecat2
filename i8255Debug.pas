unit i8255Debug;
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
	Emulator, utils, DebugWnd, core, i8255;

type
  TI8255DebugWnd = class(TDebugWindow)
    ABin: TLabel;
    Label1: TLabel;
    AHex: TLabel;
    Label3: TLabel;
    BBin: TLabel;
    BHex: TLabel;
    Label6: TLabel;
    CHBin: TLabel;
    CHex: TLabel;
    Label9: TLabel;
    DBin: TLabel;
    DHex: TLabel;
    ADir: TLabel;
    BDir: TLabel;
    CHDir: TLabel;
    CLDir: TLabel;
    Timer: TTimer;
    CLBin: TLabel;
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
		{ Private declarations }
		PrevRegs:array[0..3] of Byte;
	public
		{ Public declarations }
		procedure UpdateView; override;
	end;

var
	I8255DebugWnd: TI8255DebugWnd;

implementation

{$R *.dfm}

function Create8255DebugWnd(AOwner: TComponent; E:TEmulator; Device:TComputerDevice):TDebugWindow;
begin
	Result := TI8255DebugWnd.CreateDebug(AOwner, E, Device);
end;

procedure TI8255DebugWnd.TimerTimer(Sender: TObject);
var i:Integer;
		S:String;
		Mode: Byte;
begin
	ABin.Caption := IntToBin(T8255(FDevice).FRegs[0], 8);
	AHex.Caption := IntToHex(T8255(FDevice).FRegs[0], 2);
	BBin.Caption := IntToBin(T8255(FDevice).FRegs[1], 8);
	BHex.Caption := IntToHex(T8255(FDevice).FRegs[1], 2);
	S := IntToBin(T8255(FDevice).FRegs[2], 8);
	CHBin.Caption := Copy(S, 1, 4);
	CLBin.Caption := Copy(S, 5, 4);
	CHex.Caption := IntToHex(T8255(FDevice).FRegs[2], 2);
	DBin.Caption := IntToBin(T8255(FDevice).FRegs[3], 8);
	DHex.Caption := IntToHex(T8255(FDevice).FRegs[3], 2);
	Mode := T8255(FDevice).FRegs[3];
	if Mode and $10 > 0 then
		ADir.Caption := 'Ввод' else ADir.Caption := 'Вывод';
	if Mode and $02 > 0 then
		BDir.Caption := 'Ввод' else BDir.Caption := 'Вывод';
	if Mode and $08 > 0 then
		CHDir.Caption := 'Ввод' else CHDir.Caption := 'Вывод';
	if Mode and $01 > 0 then
		CLDir.Caption := 'Ввод' else CLDir.Caption := 'Вывод';
	for i:=0 to 3 do	PrevRegs[i]:=T8255(FDevice).FRegs[i];
end;

procedure TI8255DebugWnd.FormShow(Sender: TObject);
begin
	Timer.Enabled := True;
end;

procedure TI8255DebugWnd.FormHide(Sender: TObject);
begin
	Timer.Enabled := False;
end;

procedure TI8255DebugWnd.UpdateView;
begin
	TimerTimer(Self);
end;

begin
	DebugWindowsManager.RegisterDebugWindow('i8255', @Create8255DebugWnd);
end.
