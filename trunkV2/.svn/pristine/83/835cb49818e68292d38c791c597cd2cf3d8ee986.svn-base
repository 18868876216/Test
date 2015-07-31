object frmDataMng: TfrmDataMng
  Left = 0
  Top = 0
  Caption = #25968#25454#31649#29702
  ClientHeight = 334
  ClientWidth = 664
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = pmParamSet
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFundNav: TPanel
    Left = 0
    Top = 0
    Width = 664
    Height = 201
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 274
      Top = 8
      Width = 16
      Height = 22
      Shape = bsSpacer
    end
    object Label2: TLabel
      Left = 166
      Top = 8
      Width = 20
      Height = 22
      Alignment = taCenter
      AutoSize = False
      Caption = '--'
      Layout = tlCenter
    end
    object lblInterval: TLabel
      Left = 8
      Top = 8
      Width = 65
      Height = 22
      AutoSize = False
      Caption = #19979#36733#26102#38388#65306
      Layout = tlCenter
    end
    object btnDownLoadFundNav: TButton
      Left = 290
      Top = 8
      Width = 75
      Height = 22
      Caption = #19979#36733#22522#37329#20928#20540
      TabOrder = 0
      OnClick = btnDownLoadFundNavClick
    end
    object dtpEnd: TDateTimePicker
      Left = 186
      Top = 8
      Width = 88
      Height = 22
      Date = 40127.000000000000000000
      Time = 40127.000000000000000000
      TabOrder = 1
    end
    object dtpStart: TDateTimePicker
      Left = 73
      Top = 8
      Width = 93
      Height = 22
      Date = 40127.000000000000000000
      Time = 40127.000000000000000000
      TabOrder = 2
    end
    object mFundNavLog: TMemo
      Left = 0
      Top = 36
      Width = 664
      Height = 165
      Align = alBottom
      ScrollBars = ssVertical
      TabOrder = 3
    end
  end
  object confx: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=13116753765;Persist Security Info=T' +
      'rue;User ID=sa;Initial Catalog=ytfx;Data Source=10.19.19.250'
    Provider = 'SQLOLEDB.1'
    Left = 336
    Top = 104
  end
  object commdfx: TADOCommand
    Connection = confx
    Parameters = <>
    Left = 336
    Top = 136
  end
  object pmParamSet: TPopupMenu
    Left = 488
    Top = 152
    object miRealEnv: TMenuItem
      Caption = #30495#23454#29615#22659
      OnClick = miRealEnvClick
    end
    object miTestEnv: TMenuItem
      Caption = #27979#35797#29615#22659
      OnClick = miTestEnvClick
    end
  end
end
