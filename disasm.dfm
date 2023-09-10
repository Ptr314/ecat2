object DisAsmWnd: TDisAsmWnd
  Left = 232
  Top = 126
  Width = 691
  Height = 485
  Caption = 'DisAsmWnd'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 683
    Height = 47
    Align = alTop
    BorderWidth = 5
    TabOrder = 0
    object labelFile: TLabel
      Left = 14
      Top = 18
      Width = 569
      Height = 13
      AutoSize = False
      Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1076#1083#1103' '#1076#1080#1079#1072#1089#1089#1077#1084#1073#1083#1080#1088#1086#1074#1072#1085#1080#1103' ->'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Panel4: TPanel
      Left = 577
      Top = 6
      Width = 100
      Height = 35
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object BitBtn1: TBitBtn
        Left = 19
        Top = 5
        Width = 75
        Height = 25
        Caption = #1054#1090#1082#1088#1099#1090#1100'...'
        TabOrder = 0
        OnClick = BitBtn1Click
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 47
    Width = 197
    Height = 404
    Align = alLeft
    BorderWidth = 10
    TabOrder = 1
    object Label2: TLabel
      Left = 56
      Top = 14
      Width = 59
      Height = 13
      Caption = #1055#1088#1086#1094#1077#1089#1089#1086#1088':'
    end
    object Label4: TLabel
      Left = 34
      Top = 40
      Width = 81
      Height = 13
      Caption = #1041#1072#1079#1086#1074#1099#1081' '#1072#1076#1088#1077#1089':'
    end
    object Label1: TLabel
      Left = 14
      Top = 96
      Width = 101
      Height = 13
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1074' '#1092#1072#1081#1083#1077':'
    end
    object Label3: TLabel
      Left = 46
      Top = 68
      Width = 69
      Height = 13
      Caption = #1044#1083#1080#1085#1072' '#1073#1083#1086#1082#1072':'
    end
    object Label5: TLabel
      Left = 42
      Top = 124
      Width = 73
      Height = 13
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081':'
    end
    object Label6: TLabel
      Left = 75
      Top = 150
      Width = 40
      Height = 13
      Caption = #1040#1076#1088#1077#1089#1072':'
    end
    object Label7: TLabel
      Left = 75
      Top = 168
      Width = 30
      Height = 13
      Caption = #1050#1086#1076#1099':'
    end
    object boxProcessor: TComboBox
      Left = 120
      Top = 10
      Width = 60
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'i8080'
      Items.Strings = (
        'i8080'
        'Z80')
    end
    object editBase: TMaskEdit
      Left = 120
      Top = 36
      Width = 42
      Height = 21
      AutoSize = False
      EditMask = '$>AAAA;1;_'
      MaxLength = 5
      TabOrder = 1
      Text = '$    '
    end
    object editOffset: TMaskEdit
      Left = 120
      Top = 92
      Width = 42
      Height = 21
      AutoSize = False
      EditMask = '$>AAAA;1;_'
      MaxLength = 5
      TabOrder = 2
      Text = '$    '
    end
    object editLength: TMaskEdit
      Left = 120
      Top = 64
      Width = 42
      Height = 21
      AutoSize = False
      EditMask = '$>AAAA;1;_'
      MaxLength = 5
      TabOrder = 3
      Text = '$    '
    end
    object btnStart: TBitBtn
      Left = 16
      Top = 190
      Width = 166
      Height = 25
      Caption = #1055#1091#1089#1082'!'
      Enabled = False
      TabOrder = 4
      OnClick = btnStartClick
    end
    object editComment: TEdit
      Left = 120
      Top = 120
      Width = 60
      Height = 21
      TabOrder = 5
      Text = ';'
    end
    object checkAddresses: TCheckBox
      Left = 120
      Top = 148
      Width = 20
      Height = 17
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object checkCodes: TCheckBox
      Left = 120
      Top = 166
      Width = 20
      Height = 17
      Checked = True
      State = cbChecked
      TabOrder = 7
    end
    object btnSave: TBitBtn
      Left = 16
      Top = 244
      Width = 166
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083'...'
      Enabled = False
      TabOrder = 8
      OnClick = btnSaveClick
    end
    object btnCopy: TBitBtn
      Left = 16
      Top = 274
      Width = 166
      Height = 25
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1074' '#1073#1091#1092#1077#1088
      Enabled = False
      TabOrder = 9
      OnClick = btnCopyClick
    end
    object BitBtn2: TBitBtn
      Left = 16
      Top = 308
      Width = 166
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1072#1090#1100'...'
      Enabled = False
      TabOrder = 10
    end
    object ProgressBar: TProgressBar
      Left = 17
      Top = 222
      Width = 163
      Height = 17
      TabOrder = 11
    end
  end
  object Panel3: TPanel
    Left = 197
    Top = 47
    Width = 486
    Height = 404
    Align = alClient
    BorderWidth = 10
    TabOrder = 2
    object memoResult: TRichEdit
      Left = 11
      Top = 11
      Width = 464
      Height = 382
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      Lines.Strings = (
        '')
      ParentFont = False
      PlainText = True
      PopupMenu = PopupMenu1
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
      WordWrap = False
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 
      #1042#1089#1077' '#1087#1086#1076#1076#1077#1088#1078#1080#1074#1072#1077#1084#1099#1077' '#1092#1086#1088#1084#1072#1090#1099' |*.bin; *.rom; *.mon; *.hex; *.rk?; *' +
      '.rk; *gam; *.bru; *.ord|'#1044#1074#1086#1080#1095#1085#1099#1077' '#1092#1072#1081#1083#1099' (*.bin; *.rom; *.mon)|*.b' +
      'in; *.rom; *.mon|HEX-'#1092#1072#1081#1083#1099' (*.hex)|*.hex|'#1060#1072#1081#1083#1099' '#1054#1088#1080#1086#1085'-128 (*.rko;' +
      ' *.bru; *.ord)|*.rko; *.bru; *.ord|'#1060#1072#1081#1083#1099' RK (*.rk?; *.gam; *.pki' +
      ')|*.rk?; *.rk; *.gam; *.pki|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 14
    Top = 410
  end
  object PopupMenu1: TPopupMenu
    Left = 154
    Top = 407
    object N2: TMenuItem
      Action = EditCut1
    end
    object N1: TMenuItem
      Action = EditCopy1
    end
    object N3: TMenuItem
      Action = EditPaste1
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N5: TMenuItem
      Action = EditSelectAll1
    end
  end
  object ActionList1: TActionList
    Left = 120
    Top = 407
    object EditCut1: TEditCut
      Category = 'Edit'
      Caption = #1042#1099#1088#1077#1079#1072#1090#1100
      Hint = #1042#1099#1088#1077#1079#1072#1090#1100'|'#1042#1099#1088#1082#1079#1072#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1081' '#1090#1077#1082#1089#1090' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
      ImageIndex = 0
      ShortCut = 16472
    end
    object EditCopy1: TEditCopy
      Category = 'Edit'
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      Hint = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100'|'#1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1081' '#1090#1077#1082#1089#1090' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072
      ImageIndex = 1
      ShortCut = 16451
    end
    object EditPaste1: TEditPaste
      Category = 'Edit'
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100
      Hint = #1042#1089#1090#1072#1074#1080#1090#1100'|'#1042#1089#1090#1072#1074#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1081' '#1090#1077#1082#1089#1090' '#1080#1079' '#1073#1091#1092#1077#1088#1072' '#1086#1073#1084#1077#1085#1072
      ImageIndex = 2
      ShortCut = 16470
    end
    object EditSelectAll1: TEditSelectAll
      Category = 'Edit'
      Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1077
      Hint = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1077'|'#1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1077#1089#1100' '#1090#1077#1082#1089#1090
      ShortCut = 16449
    end
  end
  object SaveDialog: TSaveDialog
    Filter = 
      #1058#1077#1082#1089#1090#1086#1074#1099#1077' '#1092#1072#1081#1083#1099' (*.txt)|*.txt|'#1060#1072#1081#1083#1099' ASM (*.asm)|*.asm|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|' +
      '*.*'
    Left = 48
    Top = 409
  end
end
