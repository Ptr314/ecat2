unit DigitalFilters;
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

const
		MAXPZ = 10;

type
		TDigitalFilter = class
		private
						FX: array [0..MAXPZ] of Extended;
						FY: array [0..MAXPZ] of Extended;
						FCX: array [0..2*MAXPZ] of Extended;
						FCY: array [0..2*MAXPZ] of Extended;
						FGain: Extended;
						FPtr: Integer;
						FOrder: Integer;
		public
						constructor Create; overload;
						constructor Create(Order:Integer; const CX, CY: array of Extended; Gain: Extended); overload;
						function Calc(Input: Integer):Integer;
						procedure Reset;
		end;

implementation

procedure TDigitalFilter.Reset;
begin
	FPtr := 0;
	FillChar(FX, SizeOf(FX), 0);
	FillChar(FY, SizeOf(FY), 0);
end;

constructor TDigitalFilter.Create;
begin
	Reset;
	FillChar(FCX, SizeOf(FCX), 0);
	FillChar(FCY, SizeOf(FCY), 0);
	FCX[0] := 1;
	FGain := 1;
	FOrder := 1;
end;

constructor TDigitalFilter.Create(Order:Integer; const CX, CY: array of Extended; Gain: Extended);
var i: Integer;
begin
	Create;
	FOrder := Order;
	FGain := Gain;
	for i:=0 to FOrder do begin
		FCX[i]:=CX[i];
		FCY[i]:=CY[i];
	end;
end;

function TDigitalFilter.Calc;
var r: Extended;
		i: Integer;
	function GetVal(const Arr: array of Extended; Ind: Integer): Extended;
	begin
					if (Ind <= FOrder) then
									Result:= Arr[Ind]
					else
									Result:= Arr[Ind - FOrder - 1];
	end;
begin
				FX[FPtr] := Input / FGain;
				r := 0;
				for i:=0 to FOrder do
								r := r + FCX[i] * GetVal(FX , FPtr+i);
				for i:=1 to FOrder do
								r := r + FCY[i] * GetVal(FY , FPtr+i);
				FY[FPtr] := r;
				Dec(FPtr);
				if FPtr < 0 then Inc(FPtr, FOrder+1);
				Result := Round(r);
end;


end.
