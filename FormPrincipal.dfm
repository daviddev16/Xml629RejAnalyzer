object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Analisador XML Shop 1.1'
  ClientHeight = 485
  ClientWidth = 814
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object LblTituloGeral: TLabel
    Left = 8
    Top = 18
    Width = 450
    Height = 28
    Alignment = taCenter
    Caption = 'Analisador de XML / Auxilia nas Rejei'#231#245'es 629 e 564'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object LblTituloInfo: TLabel
    Left = 576
    Top = 62
    Width = 69
    Height = 15
    Caption = 'Informa'#231#245'es:'
  end
  object LblSumVlReais: TLabel
    Left = 576
    Top = 83
    Width = 176
    Height = 17
    Caption = 'Somat'#243'rio dos Valores Reais: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object LblSumVlAtuais: TLabel
    Left = 576
    Top = 104
    Width = 191
    Height = 17
    Caption = 'Somat'#243'rio dos Valores do XML: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object LblVlTotalizadorXML: TLabel
    Left = 576
    Top = 125
    Width = 118
    Height = 17
    Caption = 'Totalizador do XML:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object LblReferencias: TLabel
    Left = 576
    Top = 182
    Width = 63
    Height = 15
    Caption = 'Refer'#234'ncias:'
  end
  object BtnAnalisar: TButton
    Left = 423
    Top = 453
    Width = 121
    Height = 25
    Caption = 'Localizar XML ...'
    TabOrder = 0
    OnClick = BtnAnalisarClick
  end
  object ChckCorrigirDecimal: TCheckBox
    Left = 8
    Top = 453
    Width = 161
    Height = 25
    Caption = 'Corrigir separador decimal'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object BtnInfo: TButton
    Left = 175
    Top = 453
    Width = 26
    Height = 25
    Caption = '?'
    TabOrder = 2
    OnClick = BtnInfoClick
  end
  object DBGridValores: TDBGrid
    Left = 8
    Top = 62
    Width = 536
    Height = 385
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object BtnResetar: TButton
    Left = 353
    Top = 453
    Width = 64
    Height = 25
    Caption = 'Resetar'
    Enabled = False
    TabOrder = 4
    OnClick = BtnResetarClick
  end
  object LLblRej629: TLinkLabel
    Left = 576
    Top = 203
    Width = 172
    Height = 21
    Caption = 
      '<a href="https://www.oobj.com.br/bc/article/rejei%C3%A7%C3%A3o-6' +
      '29-valor-do-produto-difere-do-produto-valor-unit%C3%A1rio-de-com' +
      'ercializa%C3%A7%C3%A3o-e-quantidade-comercial-como-resolver-44.h' +
      'tml">Entenda a Rejei'#231#227'o: 629 aqui</a>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnLinkClick = LinkLabelClickEvent
  end
  object LLblRej564: TLinkLabel
    Left = 576
    Top = 230
    Width = 172
    Height = 21
    Caption = 
      '<a href="https://www.oobj.com.br/bc/article/rejei%C3%A7%C3%A3o-5' +
      '64-total-do-produto-servi%C3%A7o-difere-do-somat%C3%B3rio-dos-it' +
      'ens-como-resolver-277.html">Entenda a Rejei'#231#227'o: 564 aqui</a>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnLinkClick = LinkLabelClickEvent
  end
  object OpenDialog1: TOpenDialog
    Left = 272
    Top = 248
  end
end
