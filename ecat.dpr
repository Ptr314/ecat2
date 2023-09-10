program ecat;
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
		���� ���� �������� ��������� ����������� ������������, �� ������
		�������������� � �������� ��� �� �������� �������� GNU General Public
		License, �������������� Free Software Foundation, ������ 3, ���
		����� �������, �� ���� ����������.

		��������� ���������������� � ��������, ��� ��� �������� ��������,
		�� ��� �����-���� ��������, � ��� ����� ��������������� ��������
		������������ �������� ��� ����������� ��� ������������ �����.
		��������� �������� ����� �������� GNU General Public License.

		����� ������ �������� ������ ������������ ������ � ���� ������,
		� ��������� ������ �� ������ �������� �� �� ������
		<http://www.gnu.org/licenses/>

		�����: Panther <http://www.emuverse.ru/wiki/User:Panther>
}

uses
  Forms,
  main in 'main.pas' {Form1},
  TapeControlWnd in 'TapeControlWnd.pas' {TapeWnd},
  disasm in 'disasm.pas' {DisAsmWnd},
  ChooseConfig in 'ChooseConfig.pas' {ChooseConfigDlg},
  About in 'About.pas' {AboutDlg};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'eCat2';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDisAsmWnd, DisAsmWnd);
  Application.CreateForm(TChooseConfigDlg, ChooseConfigDlg);
  Application.CreateForm(TAboutDlg, AboutDlg);
  Application.Run;
end.
