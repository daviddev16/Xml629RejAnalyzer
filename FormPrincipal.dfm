object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Analisador XML Shop'
  ClientHeight = 635
  ClientWidth = 552
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object LblTotalizadores: TLabel
    Left = 8
    Top = 432
    Width = 536
    Height = 15
    Alignment = taCenter
    AutoSize = False
  end
  object Label1: TLabel
    Left = 8
    Top = 10
    Width = 270
    Height = 15
    Caption = 'Analisador de XML / Auxilia nas Rejei'#231#245'es 629 e 564'
    OnClick = Label1Click
  end
  object GridValores: TStringGrid
    Left = 8
    Top = 62
    Width = 537
    Height = 363
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goVertLine, goHorzLine, goRowSizing, goFixedRowDefAlign]
    TabOrder = 0
  end
  object BtnAnalisar: TButton
    Left = 8
    Top = 31
    Width = 121
    Height = 25
    Caption = 'Analisar XML...'
    TabOrder = 1
    OnClick = BtnAnalisarClick
  end
  object ChckCorrigirDecimal: TCheckBox
    Left = 383
    Top = 8
    Width = 161
    Height = 17
    Caption = 'Corrigir separador decimal'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object Memo1: TMemo
    Left = 7
    Top = 453
    Width = 537
    Height = 172
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object BtnAjuda: TButton
    Left = 518
    Top = 31
    Width = 26
    Height = 25
    Caption = '?'
    TabOrder = 4
    OnClick = BtnAjudaClick
  end
  object OpenDialog1: TOpenDialog
    Left = 216
    Top = 248
  end
end
