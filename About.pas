unit About;
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

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, ShellApi, Buttons, ExtCtrls;

type
  TAboutDlg = class(TForm)
    Label1: TLabel;
    VersionLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LinkLabel: TLabel;
    Memo1: TMemo;
    Bevel1: TBevel;
    BitBtn1: TBitBtn;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure LinkLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutDlg: TAboutDlg;

implementation

{$R *.dfm}

// ����������: nValue1,2,3,4 ������ ���� ��������� ����������, ��� ������� �� ����� ��������!
function GetFileVersion(const sFilename: String; var nValue1,nValue2,nValue3,nValue4: Integer): String;
var 
   pInfo,pPointer: Pointer; 
   nSize: DWORD; 
   nHandle: DWORD; 
   pVerInfo: PVSFIXEDFILEINFO;
   nVerInfoSize: DWORD; 
begin 
   Result:='?.?.?.?'; 
	 nValue1:=-1;
	 nValue2:=-1;
	 nValue3:=-1;
	 nValue4:=-1;

   nSize:=GetFileVersionInfoSize(PChar(sFilename),nHandle); 
   if (nSize <>0) then begin 
     GetMem(pInfo,nSize); 
     try 
       FillChar(pInfo^,nSize,0); 

       if (GetFileVersionInfo(PChar(sFilename),nHandle,nSize,pInfo)) then begin 
         nVerInfoSize:=SizeOf(VS_FIXEDFILEINFO); 
         GetMem(pVerInfo,nVerInfoSize); 
         try 
           FillChar(pVerInfo^,nVerInfoSize,0); 
           pPointer:=Pointer(pVerInfo); 
           VerQueryValue(pInfo,'\',pPointer,nVerInfoSize); 
           nValue1:=PVSFIXEDFILEINFO(pPointer)^.dwFileVersionMS shr 16; 
           nValue2:=PVSFIXEDFILEINFO(pPointer)^.dwFileVersionMS and $FFFF; 
           nValue3:=PVSFIXEDFILEINFO(pPointer)^.dwFileVersionLS shr 16; 
           nValue4:=PVSFIXEDFILEINFO(pPointer)^.dwFileVersionLS and $FFFF; 

					 Result:=IntToStr(nValue1)+'.'+IntToStr(nValue2)+'.'+IntToStr(nValue3)+'.'+IntToStr(nValue4);
         finally 
           FreeMem(pVerInfo,nVerInfoSize); 
         end; 
       end; 
     finally 
       FreeMem(pInfo,nSize); 
     end; 
   end; 
end;

procedure TAboutDlg.FormCreate(Sender: TObject);
var nValue1, nValue2, nValue3, nValue4: Integer;
begin
	GetFileVersion(Application.ExeName, nValue1, nValue2, nValue3, nValue4);
	VersionLabel.Caption := '������ '+IntToStr(nValue2)+'.'+IntToStr(nValue3)+'.'+IntToStr(nValue4);
	Memo1.Lines.LoadFromFile(ExtractFilePath(Application.ExeName)+'COPYRIGHT.TXT');;
end;

procedure TAboutDlg.LinkLabelClick(Sender: TObject);
begin
	ShellExecute(GetDesktopWindow(), 'open', PChar(LinkLabel.Caption), '', '', SW_SHOWDEFAULT);
end;

end.
