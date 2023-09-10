object I8255DebugWnd: TI8255DebugWnd
  Left = 420
  Top = 213
  BorderStyle = bsDialog
  Caption = 'I8255DebugWnd'
  ClientHeight = 136
  ClientWidth = 217
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
  object ABin: TLabel
    Left = 32
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
  end
  object Label1: TLabel
    Left = 12
    Top = 15
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
  object AHex: TLabel
    Left = 128
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
  object Label3: TLabel
    Left = 12
    Top = 39
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
  object BBin: TLabel
    Left = 32
    Top = 38
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
  end
  object BHex: TLabel
    Left = 128
    Top = 38
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
  object Label6: TLabel
    Left = 12
    Top = 63
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
  object CHBin: TLabel
    Left = 32
    Top = 62
    Width = 41
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = '0000'
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
  object CHex: TLabel
    Left = 128
    Top = 62
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
  object Label9: TLabel
    Left = 14
    Top = 107
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
  object DBin: TLabel
    Left = 32
    Top = 106
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
  end
  object DHex: TLabel
    Left = 128
    Top = 106
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
  object ADir: TLabel
    Left = 168
    Top = 15
    Width = 35
    Height = 14
    Caption = #1042#1099#1074#1086#1076
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object BDir: TLabel
    Left = 168
    Top = 39
    Width = 35
    Height = 14
    Caption = #1042#1099#1074#1086#1076
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object CHDir: TLabel
    Left = 32
    Top = 83
    Width = 41
    Height = 14
    Alignment = taCenter
    AutoSize = False
    Caption = #1042#1099#1074#1086#1076
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object CLDir: TLabel
    Left = 80
    Top = 83
    Width = 41
    Height = 14
    Alignment = taCenter
    AutoSize = False
    Caption = #1042#1099#1074#1086#1076
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object CLBin: TLabel
    Left = 80
    Top = 62
    Width = 41
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = '0000'
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
    Left = 186
    Top = 106
  end
end
