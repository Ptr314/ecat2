unit dskdef;
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

		This module is based on a work by Willy, which you can find here:
		<http://www.fpns.net/willy/wteledsk.htm>

Russian:
		��� 䠩� ���� ᢮����� �ணࠬ��� ���ᯥ祭���, �� �����
		�����࠭��� � �������� ��� �� �᫮���� ��業��� GNU General Public
		License, ��㡫��������� Free Software Foundation, ���ᨨ 3, ���
		����� �������, �� ��� �ᬮ�७��.

		�ணࠬ�� �����࠭���� � ��������, �� ��� �������� ��������,
		�� ��� �����-���� ��������, � ⮬ �᫥ ���ࠧ㬥������ ��࠭⨩
		������������ �������� ��� ����������� ��� ������������ �����.
		���஡��� ᬮ��� ⥪�� ��業��� GNU General Public License.

		����� ⥪�� ��業��� ������ ���⠢������ ����� � �⨬ 䠩���,
		� ��⨢��� ��砥 �� ����� ������� �� �� �����
		<http://www.gnu.org/licenses/>

		����: Panther <http://www.emuverse.ru/wiki/User:Panther>
}

interface

type
		TDiskInfo=packed record
			Sides: Integer;
			Tracks: Integer;
			Sectors: Integer;
			SectSize: Integer;
			ImageSize: Integer;
		end;

implementation

end.
