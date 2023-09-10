object Debug8080: TDebug8080
  Left = 243
  Top = 160
  BorderStyle = bsToolWindow
  Caption = '8080'
  ClientHeight = 446
  ClientWidth = 605
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 434
    Top = 0
    Width = 171
    Height = 446
    Align = alRight
    Color = clBlack
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 15
      Width = 14
      Height = 14
      Caption = 'PC'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelPC: TLabel
      Left = 32
      Top = 14
      Width = 45
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FFFF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnDblClick = LabelPCDblClick
      OnMouseUp = LabelPCMouseUp
    end
    object LabelSP: TLabel
      Left = 108
      Top = 14
      Width = 45
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FFFF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
    end
    object Label4: TLabel
      Left = 88
      Top = 15
      Width = 14
      Height = 14
      Caption = 'SP'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label5: TLabel
      Left = 18
      Top = 41
      Width = 7
      Height = 14
      Caption = 'A'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelA: TLabel
      Left = 32
      Top = 40
      Width = 27
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnClick = LabelAClick
    end
    object Label7: TLabel
      Left = 18
      Top = 65
      Width = 7
      Height = 14
      Caption = 'B'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelB: TLabel
      Left = 32
      Top = 64
      Width = 27
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnClick = LabelBClick
    end
    object Label9: TLabel
      Left = 18
      Top = 89
      Width = 7
      Height = 14
      Caption = 'C'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelC: TLabel
      Left = 32
      Top = 88
      Width = 27
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnClick = LabelCClick
    end
    object LabelD: TLabel
      Left = 32
      Top = 112
      Width = 27
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnClick = LabelDClick
    end
    object Label12: TLabel
      Left = 18
      Top = 113
      Width = 7
      Height = 14
      Caption = 'D'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label15: TLabel
      Left = 18
      Top = 185
      Width = 7
      Height = 14
      Caption = 'L'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelL: TLabel
      Left = 32
      Top = 184
      Width = 27
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnClick = LabelLClick
    end
    object LabelH: TLabel
      Left = 32
      Top = 160
      Width = 27
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnClick = LabelHClick
    end
    object Label18: TLabel
      Left = 18
      Top = 161
      Width = 7
      Height = 14
      Caption = 'H'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label19: TLabel
      Left = 18
      Top = 137
      Width = 7
      Height = 14
      Caption = 'E'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelE: TLabel
      Left = 32
      Top = 136
      Width = 27
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnClick = LabelEClick
    end
    object Label21: TLabel
      Left = 88
      Top = 65
      Width = 14
      Height = 14
      Caption = 'BC'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelBC: TLabel
      Left = 108
      Top = 64
      Width = 45
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FFFF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnMouseUp = LabelBCMouseUp
    end
    object LabelDE: TLabel
      Left = 108
      Top = 114
      Width = 45
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FFFF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnMouseUp = LabelDEMouseUp
    end
    object Label24: TLabel
      Left = 88
      Top = 115
      Width = 14
      Height = 14
      Caption = 'DE'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label25: TLabel
      Left = 88
      Top = 161
      Width = 14
      Height = 14
      Caption = 'HL'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelHL: TLabel
      Left = 108
      Top = 160
      Width = 45
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FFFF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnMouseUp = LabelHLMouseUp
    end
    object LabelF: TLabel
      Left = 108
      Top = 40
      Width = 27
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'FF'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      OnClick = LabelFClick
    end
    object Label14: TLabel
      Left = 94
      Top = 41
      Width = 7
      Height = 14
      Caption = 'F'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label33: TLabel
      Left = 36
      Top = 211
      Width = 7
      Height = 14
      Caption = 'S'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelFS: TLabel
      Left = 32
      Top = 228
      Width = 17
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = '0'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
    end
    object Label35: TLabel
      Left = 62
      Top = 211
      Width = 7
      Height = 14
      Caption = 'Z'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelFZ: TLabel
      Left = 58
      Top = 228
      Width = 17
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = '0'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
    end
    object LabelFAC: TLabel
      Left = 84
      Top = 228
      Width = 17
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = '0'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
    end
    object Label38: TLabel
      Left = 86
      Top = 211
      Width = 14
      Height = 14
      Caption = 'AC'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label39: TLabel
      Left = 115
      Top = 211
      Width = 7
      Height = 14
      Caption = 'P'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object LabelFP: TLabel
      Left = 110
      Top = 228
      Width = 17
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = '0'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
    end
    object LabelFC: TLabel
      Left = 136
      Top = 228
      Width = 17
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = '0'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
    end
    object Label42: TLabel
      Left = 140
      Top = 211
      Width = 7
      Height = 14
      Caption = 'C'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object SeekBtn: TSpeedButton
      Left = 32
      Top = 402
      Width = 123
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = #1054#1058#1057#1051#1045#1046#1048#1042#1040#1058#1068
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
      Transparent = False
      OnClick = SeekBtnClick
    end
    object StepInto: TSpeedButton
      Left = 32
      Top = 260
      Width = 123
      Height = 22
      Caption = 'STEP INTO (F7)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
      OnClick = StepIntoClick
    end
    object RunTo: TSpeedButton
      Left = 32
      Top = 316
      Width = 123
      Height = 22
      Caption = #1044#1054' '#1058#1054#1063#1050#1048' (F9)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
      OnClick = RunToClick
    end
    object SpeedButton3: TSpeedButton
      Left = 32
      Top = 373
      Width = 123
      Height = 22
      Caption = #1054#1057#1058#1040#1053#1054#1042
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButton3Click
    end
    object StepOver: TSpeedButton
      Left = 32
      Top = 288
      Width = 123
      Height = 22
      Caption = 'STEP OVER (F8)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
      OnClick = StepOverClick
    end
    object SpeedButton7: TSpeedButton
      Left = 32
      Top = 344
      Width = 123
      Height = 22
      Caption = #1047#1040#1055#1059#1057#1050
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
      OnClick = StartClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 434
    Height = 446
    Align = alClient
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 1
    object ASMPanel: TPaintBox
      Left = 6
      Top = 14
      Width = 400
      Height = 390
      Color = clNavy
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      OnMouseUp = ASMPanelMouseUp
      OnPaint = ASMPanelPaint
    end
    object ScrollBar: TScrollBar
      Left = 410
      Top = 12
      Width = 16
      Height = 390
      Ctl3D = False
      Kind = sbVertical
      Max = 65536
      PageSize = 100
      ParentCtl3D = False
      TabOrder = 0
      TabStop = False
      OnScroll = ScrollBarScroll
    end
    object Panel3: TPanel
      Left = 0
      Top = 409
      Width = 434
      Height = 37
      Align = alBottom
      Color = clBlack
      TabOrder = 1
      object NewAddrBtn: TSpeedButton
        Left = 54
        Top = 8
        Width = 24
        Height = 24
        Hint = #1055#1077#1088#1077#1081#1090#1080' '#1082' '#1072#1076#1088#1077#1089#1091
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B00000000000000000000D8E9ECD8E9EC
          D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECE2762BED6606EC7118E1B997D8E9ECD8
          E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          DD5E07F66F09F97814F06908E89253DCD7CBD8E9ECD8E9ECD8E9ECD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD65B08F46D07FF7708FC7C16F37412ED
          7620E2B895D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          CF631EE46A11FD821EFF7306FF7B12F97F1BF26A08EA9556DAE1DDD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD6D1C7CF753CDC6C22F88D3BFF7B16FF
          7A0DFC8724F67515EF7722E1C2A8D8E8EBD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          D8E9ECD8E2E2D29E7ED56A28EB8B48FE8224FF760AFE8B27F88423F36A0DEA98
          62DAE1DED8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD7D3CBD17A44DE
          6314F96D05FF7000FF8117FDAC60F79143F17E2DD8E9ECD8E9ECD8E9ECD8E9EC
          D8E9ECD8E9ECD8E9ECD3C9BECB6B32DB5F0BFA750FFF801CFFBD7DFACCA2EF84
          3AEC7F34D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD6E0E0C28A70C25316E57C2DFE
          9437FFB064FDD9AFEDAF7FDF6620DE986ED9E4E4D8E9ECD8E9ECD8E9ECD8E9EC
          CCC1B7B15932C45F24F2A65EFFB86CFFD39EF6D2AFDB7E48D1662CD8C5B4D8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECA5461ACD814CFDD396FFD89EFEE4BFE5
          B08CC4551BCD8A65D8E4E4D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          9C3911E3BA88FFFED7F4D9BEC97C56B8572ACFB5A4D8E9ECD8E9ECD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC9C3A13E1BB9AE2C4ACAB4A22B87A62D5
          DAD8D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          A85D38A74D25A34E2EC4ACA3D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8
          E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC}
        ParentShowHint = False
        ShowHint = True
        OnClick = NewAddrBtnClick
      end
      object SpeedButton4: TSpeedButton
        Left = 322
        Top = 9
        Width = 103
        Height = 22
        Caption = #1047#1040#1050#1056#1067#1058#1068
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        OnClick = SpeedButton4Click
      end
      object SpeedButton8: TSpeedButton
        Left = 86
        Top = 8
        Width = 24
        Height = 24
        Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1090#1086#1095#1082#1091' '#1086#1089#1090#1072#1085#1086#1074#1072
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B00000000000000000000D8E9ECD8E9EC
          D8E9ECD8E9EC80AD8A39783463915C638F5B648D5A688E5E47743B6F956FD6E8
          EAD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECC3DBD5317531E2EBE0FFFFFFFB
          FFFBFCFFFCFFFFFFF2F4F04D7640ADC6BAD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          D8E9ECB6D2C7518A4FFFFFFF71B9723B9E3B3CA33D5CB35CF7FFF8829C7399B5
          A4D8E9ECD8E9ECD8E9ECD8E9ECBCD7CD95BBA37AA585458042FAFDFA3FA14000
          7E00008500249A24EDFBEE759367678C719BB5A5B7CCC4D8E9EC81B28D347E32
          699E6465986094B592FFFFFF4AA64A038503098B092FA02FEFFBF0B3C1A96D8A
          5F7792664F703C7793742F7C31E0ECDFFEFFFEF2FBF3F2FAF3E3F1E342A24205
          85050A8B0A2E9F2ED2EBD2F2FCF3F4FFF5FAFFFCF2F4F04D6A3B488A47FFFFFF
          75B3752E882F329332309630178C17108B10128F121A941A35A4353AAA3A30A8
          3063C164FFFFFF71865D478946FFFFFF50A150006F00017A01047F040D880D13
          8D13148F141592150E930E0E960E04940440B241FCFFFD6D825A478947FFFFFF
          4FA04F006D00007800017E010C880C138D13158F151492140C910C0C950C0294
          023FB240FDFFFD6D825B478A46FFFFFF7FBA7F3C923C409B403D9D3D1A8E1A0F
          8B0F118F111A951A42A9424BB04B41B04170C771FFFFFF71855D2F7C31D6E5D6
          FFFFFFFBFFFAFFFFFFEEF7EE45A245048504098B092F9F2FDAEEDAFEFFFFFEFF
          FDFFFFFFE9ECE54968378CB9992D7B2D599457548D5389AC87FEFFFF4AA64A03
          8503098B092FA02FEEFBEFA9B9A05A7C53688459466733809B7ED8E9ECC1DAD3
          A1C4B084AD90458144FAFDFA3EA03E007D00008400229922EDFCEF7793686F92
          79A6BEB1BCD0CAD8E9ECD8E9ECD8E9ECD8E9ECB5D1C650894EFFFFFF7ABF7B46
          A64749AB4A66BA66F9FFFA809B7197B4A2D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          D8E9ECC6DCD830752FD9E5D6FFFFFFFFFFFFFFFFFFFFFFFFE9EEE647723AB0C9
          BED8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC8BB49632742F53875054
          844F54824F5883513E6D337B9D7DD7E8EBD8E9ECD8E9ECD8E9EC}
        ParentShowHint = False
        ShowHint = True
        OnClick = SpeedButton8Click
      end
      object SpeedButton9: TSpeedButton
        Left = 118
        Top = 8
        Width = 24
        Height = 24
        Hint = #1059#1073#1088#1072#1090#1100' '#1090#1086#1095#1082#1091' '#1086#1089#1090#1072#1085#1086#1074#1072
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B00000000000000000000D8E9ECD8E9EC
          D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8
          E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9EC9EC4AC2876284587434787454785444883444A81444B
          7F444D7E444E7D44507B445179445378445779463B5F288EA890337F37AFCDAC
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFEFFFFFEFFFFFDFFFFFD
          FFFFFFFFCDD6C73F602E418640FFFFFEC6E1C7A3CFA3AAD4ABABD5ABAAD7ABAC
          D9ADADDAAEAEDBAFAEDCAFAFDEB0ABDDACC1E6C1FFFFFF667F55478A48FFFFFF
          56A256017001067B060680060685060989090B8B0B0D8F0D0F930F1198110795
          0743B443FEFFFD6F845D468946FFFFFF55A455007300077E070982090B870B0D
          8B0D0F8D0F1190111395131599150B970B45B446FCFFFD6C825A468946FFFFFF
          55A355007200067D060881080A860A0C8A0C0E8D0E1091101295121499140A97
          0A44B445FCFFFD6C825A488A48FFFFFF5AA45A0873080C7E0C0C840C0C870C0D
          8B0D108E101291121495141699160C980C47B448FDFFFD6F845C3F853EFDFDFD
          CFE6CFB0D5B0B6D9B7B7DBB7B7DCB7B7DEB8B8DFB8B9E0B9BAE0BABAE2BAB7E2
          B7C9EBCAFFFFFF657D5136813A9EC29DF9FAF8FCFBFAFAF9F8FAF8F7FAF8F7FB
          F7F7FAF7F7FAF7F7FAF6F7FBF6F7FCF6F8FDF8F9BFCAB740612FA9CBB82B772D
          397D383B7D3A3A7B393B78393B77393E75393F7439407239427039446F39466F
          3A466C3A335A249BB3A0D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8
          E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
          D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8
          E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC}
        ParentShowHint = False
        ShowHint = True
        OnClick = SpeedButton9Click
      end
      object SpeedButton1: TSpeedButton
        Left = 150
        Top = 8
        Width = 24
        Height = 24
        Hint = #1054#1095#1080#1089#1090#1080#1090#1100' '#1090#1086#1095#1082#1080' '#1086#1089#1090#1072#1085#1086#1074#1072
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B00000000000000000000D8E9ECD8E9EC
          D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9
          ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECA9B7D4494BA37372B4494DA0C1D0DFD8
          E9ECD8E9ECCADAE44B50987171A74B4D91A1AEC7D8E9ECD8E9ECD8E9ECACB9D7
          5556AAE1E2EDD0D2F5D1D1E3474B9DC7D7E2D0E0E7474C97C8C7D8CFCEE5E0E0
          E55C5D96A2AFC8D8E9ECD8E9EC4648ABE1E0F0757FE20D0EC39BA1E6D8D8E544
          479B454999CDCDDEA7A7DB0C0C9A6363BDE1E1E5494B8FD8E9ECD8E9EC6463B9
          DFE4FC1015D00008C90309C39B9EE4D0D0E0C9C9DCA7A8DD0505A90000A20404
          9BD0D0E57373A7D8E9ECD8E9EC5459B3BDBDDFB9C1F40C18D2000DCC000AC39E
          A1E1A9ABE10506B40001AF0606A8A7A7DBC4C4D84C5096D8E9ECD8E9ECCDDDE7
          4B4FAEC6C4E2BAC0F30C19D1000DCB0513C60712C10004BB0507B4A5A6DED0D0
          DE484C96C7D7E1D8E9ECD8E9ECD8E9ECD0E1E94A4FAFC2C0DEB6BCEF101FD100
          11CC000FC60913C0A8ABE1CBCADD45499ACDDDE5D8E9ECD8E9ECD8E9ECD8E9EC
          CDDDE8474BB0C6C5E1ACB4F10D20D80014D00012CC0714C69FA2E1CFCEDF4448
          9DC9D9E3D8E9ECD8E9ECD8E9ECC7D7E6484CB4D3D1E7ACB8FA061BE00014DC0A
          20D80D1FD3000DCC0009C3999DE4DBDBE6484B9CC0CFDFD8E9ECD8E9EC4F53BB
          C5C4E7AEBDFF0821ED001AE8061BE1AEB6F1B9C0EF0C17D1000CCB020AC39CA1
          E6CFCFE34A4D9ED8E9ECD8E9EC6664C6DFE9FF0F29F9001AF20621EDADB9F9C7
          C5E2BFBFDEBAC0F30D17D10009CA0306C2D1D4F57474B4D8E9ECD8E9EC484ABD
          DBDBF2869EFF1729F9AEBDFFCFCDE7474BAF484CADC5C4E1BBC3F51618D17580
          E3E2E3EC4749A2D8E9ECD8E9ECB5C4E04D4FBDDBDCF1DFE7FFCAC8E8474BB4CF
          DFE8D4E4EA4A4EAEC0BFDFDDE2FDDFE1F05355A9ABB9D5D8E9ECD8E9ECD8E9EC
          B5C4DF4A4CBE6563C54D52BCCBDBE7D8E9ECD8E9ECCFDFE84E54B36363B9484A
          ABABB9D6D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8
          E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC}
        ParentShowHint = False
        ShowHint = True
        OnClick = SpeedButton1Click
      end
      object NewAddrEdit: TEdit
        Left = 8
        Top = 10
        Width = 41
        Height = 17
        TabStop = False
        BorderStyle = bsNone
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        MaxLength = 4
        ParentFont = False
        TabOrder = 0
        Text = 'FFFF'
        OnKeyPress = NewAddrEditKeyPress
      end
    end
  end
  object SeekTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = SeekTimerTimer
    Left = 5
    Top = 2
  end
end
