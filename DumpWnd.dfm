object DumpWindow: TDumpWindow
  Left = 257
  Top = 172
  BorderStyle = bsDialog
  ClientHeight = 446
  ClientWidth = 602
  Color = clBtnFace
  Constraints.MaxWidth = 610
  Constraints.MinWidth = 610
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 602
    Height = 41
    Align = alTop
    TabOrder = 0
    object GoBtn: TSpeedButton
      Left = 58
      Top = 12
      Width = 23
      Height = 22
      Caption = '->'
      OnClick = GoBtnClick
    end
    object SpeedButton1: TSpeedButton
      Left = 498
      Top = 10
      Width = 65
      Height = 22
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      OnClick = SpeedButton1Click
    end
    object AddrEdit: TEdit
      Left = 12
      Top = 12
      Width = 37
      Height = 21
      MaxLength = 4
      TabOrder = 0
      Text = 'FFFF'
      OnKeyPress = AddrEditKeyPress
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 576
    Height = 405
    Align = alClient
    BorderWidth = 10
    Color = clBlack
    TabOrder = 1
    object DumpBox: TPaintBox
      Left = 11
      Top = 11
      Width = 554
      Height = 383
      Align = alClient
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      OnPaint = DumpBoxPaint
    end
  end
  object Panel3: TPanel
    Left = 576
    Top = 41
    Width = 26
    Height = 405
    Align = alRight
    TabOrder = 2
    object ScrollBar: TScrollBar
      Left = 9
      Top = 1
      Width = 16
      Height = 403
      Align = alRight
      Ctl3D = False
      Kind = sbVertical
      Max = 65536
      PageSize = 100
      ParentCtl3D = False
      TabOrder = 0
      TabStop = False
      OnScroll = ScrollBarScroll
    end
  end
end
