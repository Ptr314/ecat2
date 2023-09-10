unit ChooseConfig;
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
	Dialogs, ExtCtrls, StdCtrls, ComCtrls, Buttons,
	Emulator, Config;

type
	TMachineFile = record
		MType, Name, Version, Path:String;
	end;
	PMachineFile = ^TMachineFile;

  TChooseConfigDlg = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    GroupBox2: TGroupBox;
    Description: TMemo;
    Button1: TButton;
    Button2: TButton;
		Selector: TTreeView;
    DefBox: TCheckBox;
    SaveBtn: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure SelectorClick(Sender: TObject);
    procedure SelectorDblClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DescriptionChange(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
	private
		{ Private declarations }
		Machines: array [0..100] of TMachineFile;
		MachineCount: Integer;
		DescChanged: Boolean;
		procedure ListAvailableMachines(Path:String; Level:Integer);
		procedure SortMachines;
		procedure FillTree;
		procedure SetDescription;
	public
		{ Public declarations }
		WorkPath: String;
		CurrentFile: String;
		SelectedFile: String;
	end;

var
	ChooseConfigDlg: TChooseConfigDlg;

implementation

{$R *.dfm}

procedure TChooseConfigDlg.ListAvailableMachines(Path:String; Level:Integer);
var SR:TSearchRec;
		Config: TEmulatorConfig;
		SysDev : TEmulatorConfigDevice;
		//S:String;
begin
	Config := TEmulatorConfig.Create;
	try
		if FindFirst(Path + '\*.*', faDirectory, SR)=0 then begin
			repeat
				if ((sr.Attr and faDirectory) <> 0) and (sr.Name<>'.') and (sr.Name<>'..') then begin
					if Level<5 then	ListAvailableMachines(Path{+'\'}+sr.Name, Level+1)
				end else
				if LowerCase(ExtractFileExt(sr.Name))='.cfg' then	begin
					try
						Config.LoadFromFile(Path+'\'+sr.Name, True); //system only
						SysDev := Config.Devices['system'];
						Machines[MachineCount].MType := SysDev.Parameters['type'].Value;
						Machines[MachineCount].Name := SysDev.Parameters['name'].Value;
						Machines[MachineCount].Version := SysDev.Parameters['version'].Value;
						Machines[MachineCount].Path := Path+'\'+sr.Name;
						Inc(MachineCount);
					except
					end;
				end;
			until FindNext(SR) <> 0;
			FindClose(SR);
		end;
	finally
		Config.Free;
	end;
end;

procedure TChooseConfigDlg.SortMachines;
var i, j: Integer;
		TMP: TMachineFile;
begin
	for i:=1 to MachineCount do
		for j:=1 to MachineCount-1-i do
			if (Machines[j].Name < Machines[j-1].Name) or ( (Machines[j].Name = Machines[j-1].Name) and (Machines[j].Version < Machines[j-1].Version)) then begin
				TMP := Machines[j];
				Machines[j] := Machines[j-1];
				Machines[j-1] := TMP;
			end;
end;

procedure TChooseConfigDlg.FillTree;
var i:Integer;
		prevType: String;
		upNode, Node: TTreeNode;
begin
	Selector.Items.BeginUpdate;
	Selector.Items.Clear;
	prevType := '';
	upNode := nil;
	for i:=0 to MachineCount-1 do begin
		if prevType<>Machines[i].MType then begin
			upNode := Selector.Items.AddObject(nil, Machines[i].Name, nil);
			prevType := Machines[i].MType;
		end;
		Node:=Selector.Items.AddChildObject(upNode, Machines[i].Version, @Machines[i]);
		upNode.Expanded := TRUE;
		if Machines[i].Path = CurrentFile then begin
			Selector.Selected := Node;
			SelectedFile := CurrentFile;
		end;
	end;
	Selector.Items.EndUpdate;
end;

procedure TChooseConfigDlg.FormCreate(Sender: TObject);
begin
	MachineCount := 0;
	SelectedFile := '';
	DescChanged := FALSE;
end;

procedure TChooseConfigDlg.SelectorClick(Sender: TObject);
var Node: TTreeNode;
begin
	Node := Selector.Selected;
	if (Assigned(Node)) and (Assigned(Node.Data)) then begin
		SelectedFile := PMachineFile(Node.Data)^.Path;
		SetDescription;
	end;
end;

procedure TChooseConfigDlg.SetDescription;
var	Txt: String;
begin
	Txt := ChangeFileExt(SelectedFile, '.txt');
	if FileExists(Txt) then
		Description.Lines.LoadFromFile(Txt)
	else
		Description.Lines.Clear;
	DescChanged := FALSE;
	SaveBtn.Enabled := FALSE;
end;

procedure TChooseConfigDlg.SelectorDblClick(Sender: TObject);
begin
	ModalResult := mrOK;
end;

procedure TChooseConfigDlg.FormActivate(Sender: TObject);
begin
	if MachineCount = 0 then begin
		ListAvailableMachines(WorkPath, 0);
		SortMachines;
		FillTree;
		SetDescription;
	end;
end;

procedure TChooseConfigDlg.Button1Click(Sender: TObject);
var R: Word;
begin
	if SelectedFile <> '' then
		if DescChanged then begin
			R := MessageDlg('Сохранить описание?', mtConfirmation, mbYesNoCancel, 0);
			if R=mrYes then begin
				SaveBtnClick(Sender);
				ModalResult := mrOK;
			end else
			if R=mrNo then
				ModalResult := mrOK
			else
				ModalResult := 0;
		end else
			ModalResult := mrOK;
end;

procedure TChooseConfigDlg.DescriptionChange(Sender: TObject);
begin
	DescChanged := TRUE;
	SaveBtn.Enabled := TRUE;
end;

procedure TChooseConfigDlg.SaveBtnClick(Sender: TObject);
var	Txt: String;
begin
	Txt := ChangeFileExt(SelectedFile, '.txt');
	Description.Lines.SaveToFile(Txt);
	DescChanged := FALSE;
	SaveBtn.Enabled := FALSE;
end;

procedure TChooseConfigDlg.Button2Click(Sender: TObject);
var R: Word;
begin
	if DescChanged then begin
		R := MessageDlg('Сохранить описание?', mtConfirmation, mbYesNoCancel, 0);
		if R=mrYes then begin
			SaveBtnClick(Sender);
			ModalResult := mrCancel;
		end else
		if R=mrNo then
			ModalResult := mrCancel
		else
			ModalResult := 0;
	end else
		ModalResult := mrCancel;
end;

end.
