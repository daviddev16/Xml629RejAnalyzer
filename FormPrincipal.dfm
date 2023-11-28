object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Analisador XML Shop 1.2'
  ClientHeight = 438
  ClientWidth = 885
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object LblTituloInfo: TLabel
    Left = 576
    Top = 11
    Width = 69
    Height = 15
    Caption = 'Informa'#231#245'es:'
  end
  object LblSumVlReais: TLabel
    Left = 576
    Top = 32
    Width = 176
    Height = 17
    Caption = 'Somat'#243'rio dos Valores Reais: '
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    StyleElements = [seClient, seBorder]
  end
  object LblSumVlAtuais: TLabel
    Left = 576
    Top = 53
    Width = 191
    Height = 17
    Caption = 'Somat'#243'rio dos Valores do XML: '
    Color = clHighlight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuHighlight
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    StyleElements = [seClient, seBorder]
  end
  object LblVlTotalizadorXML: TLabel
    Left = 576
    Top = 74
    Width = 118
    Height = 17
    Caption = 'Totalizador do XML:'
    Color = clBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    StyleElements = [seClient, seBorder]
  end
  object LblReferencias: TLabel
    Left = 578
    Top = 171
    Width = 109
    Height = 15
    Caption = 'Entenda as rejei'#231#245'es:'
  end
  object LblRej564Alerta: TLabel
    Left = 578
    Top = 137
    Width = 299
    Height = 15
    Caption = #9888#65039' Totalizadores divergentes! Rejei'#231#227'o 564 ser'#225' retornada.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clOlive
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    StyleElements = [seClient, seBorder]
  end
  object LblDivergentes: TLabel
    Left = 576
    Top = 97
    Width = 98
    Height = 17
    Caption = 'Total Divergente:'
    Color = clBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    StyleElements = [seClient, seBorder]
  end
  object BtnAnalisar: TButton
    Left = 423
    Top = 402
    Width = 121
    Height = 25
    Caption = 'Localizar XML ...'
    TabOrder = 0
    OnClick = BtnAnalisarClick
  end
  object DBGridValores: TDBGrid
    Left = 8
    Top = 11
    Width = 536
    Height = 385
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnTitleClick = DBGridValoresTitleClick
  end
  object LLblRej629: TLinkLabel
    Left = 578
    Top = 192
    Width = 243
    Height = 21
    Hint = 'Rej629'
    Caption = 
      '<a href="https://ajuda.alterdata.com.br/shopbase/rejeicao-629-va' +
      'lor-do-produto-difere-do-produto-valor-unitario-de-comercializac' +
      'ao-e-quantidade-comercial-133333933.html">629: Valor do Produto ' +
      'difere do produto</a>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnLinkClick = LinkLabelClickEvent
  end
  object LLblRej564: TLinkLabel
    Left = 578
    Top = 213
    Width = 308
    Height = 21
    Hint = 'Rej564'
    Caption = 
      '<a href="https://ajuda.alterdata.com.br/shopbase/rejeicao-564-to' +
      'tal-do-produto-servico-difere-do-somatorio-dos-itens-133353097.h' +
      'tml">564: Total do Produto / Servi'#231'o difere do somat'#243'rio</a>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnLinkClick = LinkLabelClickEvent
  end
  object LinkLabel1: TLinkLabel
    Left = 843
    Top = 413
    Width = 34
    Height = 17
    HelpType = htKeyword
    HelpKeyword = 'RESUMO'
    Caption = 
      '<a href="https://github.com/daviddev16/Xml629RejAnalyzer/blob/ma' +
      'ster/README.md">Sobre</a>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnLinkClick = LinkLabelClickEvent
  end
  object OpenDialog1: TOpenDialog
    Left = 272
    Top = 197
  end
end
