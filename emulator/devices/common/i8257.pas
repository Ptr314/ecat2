unit i8257;
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
    Config,
		Core;

type
	T8257 = class (TAddressableDevice)
	private
		FIAddress: TInterface;
		FIData: TInterface;
	protected
		function GetValue(Address:Cardinal):Cardinal; override;
		procedure SetValue(Address:Cardinal; Value:Cardinal); override;
	public
		FRgA: array [0..7] of Byte;
		FRgC: array [0..7] of Byte;
		FPtrA: array [0..3] of Byte;
		FPtrC: array [0..3] of Byte;
		FRgMode: Byte;
		FRgState: Byte;
		constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
		procedure Reset(isCold:Boolean); override;
	end;

implementation

function Create8257(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := T8257.Create(IM, ConfigDevice);
end;

constructor T8257.Create;
begin
	inherited Create(IM, ConfigDevice);

	FIAddress := CreateInterface(2, 'address', MODE_R);
	FIData := CreateInterface(8, 'data', MODE_R);

	Reset(True);
end;

procedure T8257.Reset(isCold:Boolean);
begin
	FillChar(FPtrA, SizeOf(FPtrA), 0);
	FillChar(FPtrC, SizeOf(FPtrC), 0);
end;


function T8257.GetValue(Address:Cardinal):Cardinal;
var A, N:Cardinal;
begin
	A := Address and $0F;
	N := (A shr 1) and $03;
	Result := Cardinal(-1); //To avoid warnings
	case A of
		0, 2, 4, 6: begin
									Result := FRgA[N*2 + FPtrA[N]];
									FPtrA[N] := FPtrA[N] xor 1;
								end;
		1, 3, 5, 7: begin
									Result := FRgC[N*2 + FPtrC[N]];
									FPtrC[N] := FPtrC[N] xor 1;
								end;
		8:          Result := FRgState;
		else FIM.DM.Error(Self, 'Произведено чтение из неизвестного регистра');
	end;
end;

procedure T8257.SetValue(Address:Cardinal; Value:Cardinal);
var A, N:Cardinal;
		V: Byte;
begin
	A := Address and $0F;
	N := (A shr 1) and $03;
	V := Value and $FF;
	case A of
		0, 2, 4, 6: begin
									FRgA[N*2 + FPtrA[N]] := V;
									FPtrA[N] := FPtrA[N] xor 1;
								end;
		1, 3, 5, 7: begin
									FRgC[N*2 + FPtrC[N]] := V;
									FPtrC[N] := FPtrC[N] xor 1;
								end;
		8:          FRgMode := V;
		else FIM.DM.Error(Self, 'Произведена запись в неизвестный регистр');
	end;
end;

begin
	RegisterDeviceCreateFunc('i8257', @Create8257);
end.
