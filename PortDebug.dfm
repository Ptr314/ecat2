object PortDebugWnd: TPortDebugWnd
  Left = 416
  Top = 424
  BorderStyle = bsDialog
  Caption = 'PortDebugWnd'
  ClientHeight = 43
  ClientWidth = 175
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bin: TLabel
    Left = 26
    Top = 14
    Width = 89
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = '00000000'
    Color = clSilver
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = False
    OnClick = BinClick
  end
  object Hex: TLabel
    Left = 122
    Top = 14
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
  end
  object Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerTimer
    Left = 68
    Top = 34
  end
end
