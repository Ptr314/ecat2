unit i8257Debug;
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
	Emulator, utils, DebugWnd, core, i8257;

type
  TI8257DebugWnd = class(TDebugWindow)
    Md: TLabel;
    A0: TLabel;
    Timer: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    A1: TLabel;
    Label4: TLabel;
    A2: TLabel;
    Label6: TLabel;
    A3: TLabel;
    C0: TLabel;
    C1: TLabel;
    C2: TLabel;
    C3: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    St: TLabel;
    E0: TLabel;
    E1: TLabel;
    E2: TLabel;
    E3: TLabel;
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
	private
		{ Private declarations }
		//PrevRegs:array[0..3] of Byte;
	public
		{ Public declarations }
		procedure UpdateView; override;
	end;

var
	I8257DebugWnd: TI8257DebugWnd;

const I8257Modes: array [0..3] of String = ('CH', 'RD', 'WR', 'хххх');

implementation

{$R *.dfm}

function Create8257DebugWnd(AOwner: TComponent; E:TEmulator; Device:TComputerDevice):TDebugWindow;
begin
	Result := TI8257DebugWnd.CreateDebug(AOwner, E, Device);
end;

procedure TI8257DebugWnd.TimerTimer(Sender: TObject);
begin
	with T8257(FDevice) do begin
		A0.Caption := IntToHex(FRgA[0] + FRgA[1]*256, 4);
		C0.Caption := IntToHex(FRgC[0] + (FRgC[0] and $3F)*256, 4);
		A1.Caption := IntToHex(FRgA[2] + FRgA[3]*256, 4);
		C1.Caption := IntToHex(FRgC[2] + (FRgC[3] and $3F)*256, 4);
		A2.Caption := IntToHex(FRgA[4] + FRgA[5]*256, 4);
		C2.Caption := IntToHex(FRgC[4] + (FRgC[5] and $3F)*256, 4);
		A3.Caption := IntToHex(FRgA[6] + FRgA[7]*256, 4);
		C3.Caption := IntToHex(FRgC[6] + (FRgC[7] and $3F)*256, 4);
		Md.Caption := IntToBin(FRgMode, 8);
		St.Caption := IntToBin(FRgState, 8);
		if FRgMode and $01 > 0 then	E0.Caption := I8257Modes[FRgC[1] shr 6] else E0.Caption := '-';
		if FRgMode and $02 > 0 then	E1.Caption := I8257Modes[FRgC[3] shr 6] else E1.Caption := '-';
		if FRgMode and $04 > 0 then	E2.Caption := I8257Modes[FRgC[5] shr 6] else E2.Caption := '-';
		if FRgMode and $08 > 0 then	E3.Caption := I8257Modes[FRgC[7] shr 6] else E3.Caption := '-';
	end;
end;

procedure TI8257DebugWnd.FormShow(Sender: TObject);
begin
	Timer.Enabled := True;
end;

procedure TI8257DebugWnd.FormHide(Sender: TObject);
begin
	Timer.Enabled := False;
end;

procedure TI8257DebugWnd.UpdateView;
begin
	TimerTimer(Self);
end;

begin
	DebugWindowsManager.RegisterDebugWindow('i8257', @Create8257DebugWnd);
end.
