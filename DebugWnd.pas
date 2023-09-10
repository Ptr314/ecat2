unit DebugWnd;
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

uses  Classes, Forms,
			Emulator, Core;

const
	cMaxDebugWidows = 100;

type
			TDebugWindow = class (TForm)
			protected
				FDevice: TComputerDevice;
				FE: TEmulator;
			public
				constructor CreateDebug(AOwner: TComponent; E:TEmulator; Device:TComputerDevice);
				procedure UpdateView; virtual; abstract;
			end;

			TDebugWndCreateFunc = function(AOwner: TComponent; E:TEmulator; Device:TComputerDevice):TDebugWindow;

			TDebugWndFuncData = record
				DType: String;
				CreateFunc: TDebugWndCreateFunc;
			end;

			TDebugWindowsManager = class
			private
				FDebugWndData: array [0..cMaxDebugWidows-1] of TDebugWndFuncData;
				FDebugWindows: array [0..cMaxDebugWidows-1] of TDebugWindow;
				FDebugWndCount: Cardinal;
			public
				constructor Create;
				procedure RegisterDebugWindow(Typ: String; Func:Pointer);
				function HasDebugWindow(Typ:String):Boolean;
				procedure OpenDebugWindow(AOwner:TComponent; E:TEmulator; Index:Integer);
				procedure Clear;
				procedure UpdateViews;
			end;

var
		DebugWindowsManager: TDebugWindowsManager;

implementation

constructor TDebugWindow.CreateDebug(AOwner: TComponent; E:TEmulator; Device:TComputerDevice);
begin
	inherited Create(AOwner);
	FDevice := Device;
	FE := E;
	Caption:=FDevice.DType + ' : ' +FDevice.Name;
end;

constructor TDebugWindowsManager.Create;
begin
	inherited Create;
	FDebugWndCount := 0;
	FillChar(FDebugWindows, SizeOf(FDebugWindows), 0);
end;

procedure TDebugWindowsManager.RegisterDebugWindow(Typ: String; Func:Pointer);
begin
		Inc(FDebugWndCount);

		with FDebugWndData[FDebugWndCount-1] do begin
			DType :=  Typ;
			@CreateFunc := Func;
		end;
end;

function TDebugWindowsManager.HasDebugWindow(Typ:String):Boolean;
var i:Integer;
begin
	Result := False;
	for i:=0 to FDebugWndCount do begin
		if FDebugWndData[i].DType=Typ then begin
			Result:=True;
			break;
		end;
	end;
end;

procedure TDebugWindowsManager.OpenDebugWindow(AOwner:TComponent; E:TEmulator; Index:Integer);
var i : Integer;
		F : TDebugWndCreateFunc;
begin
	if Assigned(FDebugWindows[Index]) then
		FDebugWindows[Index].Show
	else begin
		F := nil;
		for i:=0 to FDebugWndCount do begin
			if FDebugWndData[i].DType=E.DM[Index].DeviceType then begin
				F:=FDebugWndData[i].CreateFunc;
				break;
			end;
		end;
		if Assigned(F) then begin
			FDebugWindows[Index] := F(AOwner, E, E.DM[Index].Device);
			FDebugWindows[Index].Show;
		end;
	end;
end;

procedure TDebugWindowsManager.Clear;
var i : Integer;
begin
	//Если были созданы отладочные окна, то они удаляются
	for i:=0 to cMaxDebugWidows-1 do
		if Assigned(FDebugWindows[i]) then FDebugWindows[i].Free;
		
	FillChar(FDebugWindows, SizeOf(FDebugWindows), 0);
end;

procedure TDebugWindowsManager.UpdateViews;
var i : Integer;
begin
	for i:=0 to cMaxDebugWidows-1 do
		if Assigned(FDebugWindows[i]) then FDebugWindows[i].UpdateView;
end;

begin
	DebugWindowsManager := TDebugWindowsManager.Create;
end.
