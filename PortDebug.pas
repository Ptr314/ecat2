unit PortDebug;
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
  TPortDebugWnd = class(TDebugWindow)
    Bin: TLabel;
    Hex: TLabel;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure BinClick(Sender: TObject);
	private
		{ Private declarations }
		//PrevRegs:array[0..3] of Byte;
	public
		{ Public declarations }
		procedure UpdateView; override;
	end;

var
	PortDebugWnd: TPortDebugWnd;

implementation

{$R *.dfm}

function CreatePortDebugWnd(AOwner: TComponent; E:TEmulator; Device:TComputerDevice):TDebugWindow;
begin
	Result := TPortDebugWnd.CreateDebug(AOwner, E, Device);
end;

procedure TPortDebugWnd.TimerTimer(Sender: TObject);
begin
	Bin.Caption := IntToBin(TPort(FDevice).Value[0], 8);
	Hex.Caption := IntToHex(TPort(FDevice).Value[0] and $FF, 2);
end;

procedure TPortDebugWnd.FormShow(Sender: TObject);
begin
	Timer.Enabled := True;
end;

procedure TPortDebugWnd.FormHide(Sender: TObject);
begin
	Timer.Enabled := False;
end;

procedure TPortDebugWnd.BinClick(Sender: TObject);
var S:String;
begin
	S:=IntToHex(TPort(FDevice).Value[0] and $FF, 2);
	if InputQuery('Изменение значения', Name, S) then begin
		if FDevice is TPortAddress then
			TPortAddress(FDevice).Value[ParseNumericValue('$'+S)]:=0
		else
			TPort(FDevice).Value[0]:=ParseNumericValue('$'+S)
	end;
end;

procedure TPortDebugWnd.UpdateView;
begin
	TimerTimer(Self);
end;

begin
	DebugWindowsManager.RegisterDebugWindow('port', @CreatePortDebugWnd);
	DebugWindowsManager.RegisterDebugWindow('port-address', @CreatePortDebugWnd);
end.
