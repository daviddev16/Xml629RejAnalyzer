unit FormPrincipal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Types,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Grids,
  Vcl.StdCtrls,
  Xml.XMLDoc,
  Xml.XMLIntf,
  Data.DB,
  Vcl.DBGrids,
  DBClient,
  Vcl.ExtCtrls,
  ShellAPI;

type
  TMainForm = class(TForm)
    BtnAnalisar: TButton;
    OpenDialog1: TOpenDialog;
    ChckCorrigirDecimal: TCheckBox;
    LblTituloGeral: TLabel;
    BtnInfo: TButton;
    DBGridValores: TDBGrid;
    LblTituloInfo: TLabel;
    LblSumVlReais: TLabel;
    LblSumVlAtuais: TLabel;
    LblVlTotalizadorXML: TLabel;
    BtnResetar: TButton;
    LLblRej629: TLinkLabel;
    LLblRej564: TLinkLabel;
    LblReferencias: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure BtnAnalisarClick(Sender: TObject);
    procedure BtnInfoClick(Sender: TObject);
    procedure BtnResetarClick(Sender: TObject);
    procedure LinkLabelClickEvent(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);

  private
    { Private declarations }

    GridDataSet : TClientDataSet;

    TotalizadorItensReal : Double;
    TotalizadorItensAtual : Double;
    TotalizadorValorTagTotalXml : Double;
    EncontradoDivergente : Boolean;

    procedure CriarDicaEmLabel(LLabel : TLabel; Dica : String);
    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol:
      Integer; Column: TColumn; State: TGridDrawState);

    procedure InserirLinha(Dados : Array of TVarRec);
    procedure ProcessarXml(XmlDoc : IXMLDocument);
    procedure ProcessarProdutoDoXml(ProdNodeList : IXMLNodeList);
    procedure ProcessarTotalizadores();
    procedure LimparTotalizadores();
    procedure CriarDataSetSource();
    procedure LimparTudo();
    procedure CentralizarForm();

    function GetChildNode(Nome : String; ParenteNodeList : IXMLNodeList) : IXMLNodeList;
    function CorrigirSeparadorDecimal(ValorStr : String) : Double;
    function Monetario(Valor : Double) : String;


  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.CentralizarForm();
begin
  Left :=(Screen.Width-Width)  div 2;
  Top :=(Screen.Height-Height) div 2;
end;

{ Oncreate TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
begin

  { Centralizar tela }
  LimparTotalizadores;
  CriarDataSetSource;
  DBGridValores.DefaultDrawing := False;
  DBGridValores.OnDrawColumnCell := DBGridDrawColumnCell;
  GridDataSet.IndexFieldNames := 'Status';

  CriarDicaEmLabel(LblSumVlReais, 'Este é o somatório de todos os valores reais dos itens da nota.');
  CriarDicaEmLabel(LblSumVlAtuais, 'Este é o somatório de todos os valores atuais dos itens no XML.');
  CriarDicaEmLabel(LblVlTotalizadorXML, 'Este é valor totalizador dos itens da nota no XML.');

end;

procedure TMainForm.DBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  ValorCell : Variant;
begin

  { verificar se o data set está ativo antes }
  if not DBGridValores.DataSource.DataSet.Active then
    Exit;

  if (DataCol >= 0) and (DataCol < DBGridValores.Columns.Count) then
  begin
    { mudar cor da linha de acordo com o status }
    ValorCell := GridDataSet.FieldByName(DBGridValores.Columns[5].FieldName).Value;

    if ValorCell = 'Divergente' then
    begin
      if gdSelected in State then
      begin
        DBGridValores.Canvas.Brush.Color := clWebDarkRed;
        DBGridValores.Canvas.Font.Color := clWebSalmon;
      end
      else
      begin
        DBGridValores.Canvas.Brush.Color := clWebSalmon;
        DBGridValores.Canvas.Font.Color := clWebDarkRed;
      end;

    end
    else
    begin
      if gdSelected in State then
      begin
        DBGridValores.Canvas.Brush.Color := clWebGainsboro;
        DBGridValores.Canvas.Font.Color := clBlack;
      end
      else
      begin
        DBGridValores.Canvas.Brush.Color := clWhite;
        DBGridValores.Canvas.Font.Color := clWebGreen;
      end;
    end;

  end;

  DBGridValores.DefaultDrawColumnCell(Rect, DataCol, Column, State);

end;

procedure TMainForm.CriarDataSetSource();
begin

  { inicializando DataSet/DataSource }
  GridDataSet := TClientDataSet.Create(nil);
  DBGridValores.DataSource := TDataSource.Create(nil);
  DBGridValores.DataSource.DataSet := GridDataSet;

  { inicializando colunas do DataSet }
  GridDataSet.FieldDefs.Add('Cd. Produto', ftString, 17);
  GridDataSet.FieldDefs.Add('Qtd.', ftString, 12);
  GridDataSet.FieldDefs.Add('Vl. Unitário', ftString, 12);
  GridDataSet.FieldDefs.Add('Vl. Item', ftString, 12);
  GridDataSet.FieldDefs.Add('Vl. Real', ftString, 12);
  GridDataSet.FieldDefs.Add('Status', ftString, 13);
  GridDataSet.CreateDataSet;
end;


procedure TMainForm.BtnInfoClick(Sender: TObject);
begin
  ShowMessage('Essa opção converte "." em "," caso o sistema esteja configurado para "," como separador decimal.');
end;

procedure TMainForm.BtnResetarClick(Sender: TObject);
begin
  LimparTudo;
end;

{
  0 = <vUnCom>
  1 = <qCom>
  2 = <vProd> Atual
  3 = <vProd> Real [vProd = vUnCom * qCom]
  4 = Compatível [Compatível se (vProdAtual - vProdReal) <= 0.01]
}
procedure TMainForm.BtnAnalisarClick(Sender: TObject);
var
  XmlDoc : IXMLDocument;
begin

  { limpar grid e totalizadores }
  LimparTudo;

  OpenDialog1.Options := [TOpenOption.ofFileMustExist];
  OpenDialog1.DefaultExt := 'xml';
  OpenDialog1.Filter := 'Arquivo XML|*.xml|Todos os Arquivos|*.*';
  if OpenDialog1.Execute then
  begin
    XmlDoc := TXMLDocument.Create(OpenDialog1.FileName);
    ProcessarXml(XmlDoc);
  end;

  if EncontradoDivergente then
  begin
    MessageDlg
    (
      'Foi encontrado algun(s) produto(s) com valor(es) divergente(s). ' +
      'Tente corrigir no sistema! Caso não seja possível pelo sistema, ou ' + sLineBreak +
      'o sistema continua gerando a tag com valor errado, consulte a ' +
      'supervisão para alterar o XML.',
    mtWarning, [mbOK], 0);
  end;

end;

{ processa as informações dos produtos do XML no TStringGrid }
procedure TMainForm.ProcessarXml(XmlDoc : IXMLDocument);
var
  StrTotalizador    : TStringBuilder;
  NfeNodeList       : IXMLNodeList;
  InfNFeNodeList    : IXMLNodeList;
  ProdNodeList      : IXMLNodeList;
  ICMSTotalNodeList : IXMLNodeList;
  I, J              : Integer;
begin
  NfeNodeList     := GetChildNode('NFe', XmlDoc.ChildNodes);
  InfNFeNodeList  := GetChildNode('infNFe', NfeNodeList);

  { acessa tags <det> }
  for I := 0 to InfNFeNodeList.Count - 1 do
  begin
    if InfNFeNodeList[I].NodeName = 'det' then
    begin
      { acessa tags <prod> }
      for J := 0 to InfNFeNodeList[I].ChildNodes.Count - 1 do
      begin
        if InfNFeNodeList[I].ChildNodes[J].NodeName = 'prod' then
        begin
          ProcessarProdutoDoXml(InfNFeNodeList[I].ChildNodes[J].ChildNodes);
        end;
      end;
    end;
  end;

  ICMSTotalNodeList := GetChildNode('ICMSTot', GetChildNode('total', InfNFeNodeList));
  TotalizadorValorTagTotalXml := CorrigirSeparadorDecimal(ICMSTotalNodeList['vProd'].Text);
  StrTotalizador := TStringBuilder.Create;

  with StrTotalizador do
  begin
    Append('Totalizador Vl.Real: ' + Monetario(TotalizadorItensReal) + ', ');
    Append('Totalizador Vl.Atual: ' + Monetario(TotalizadorItensAtual) + ', ');
    Append('Totalizador do XML: ' + Monetario(TotalizadorValorTagTotalXml));
  end;

  ProcessarTotalizadores;
  GridDataSet.RecNo := 1;

end;

procedure TMainForm.ProcessarTotalizadores();
begin
  LblSumVlReais.Caption := 'Somatório dos Valores Reais: ' + Monetario(TotalizadorItensReal);
  LblSumVlAtuais.Caption := 'Somatório dos Valores do XML: ' + Monetario(TotalizadorItensAtual);
  LblVlTotalizadorXML.Caption := 'Totalizador do XML: ' + Monetario(TotalizadorValorTagTotalXml);
  ClientWidth := 860;
  BtnResetar.Enabled := True;
  BtnAnalisar.Enabled := False;
  CentralizarForm;
end;

procedure TMainForm.LimparTotalizadores();
begin
  LblSumVlReais.Caption := '';
  LblSumVlAtuais.Caption := '';
  LblVlTotalizadorXML.Caption := '';
  TotalizadorItensReal := 0;
  TotalizadorItensAtual := 0;
  TotalizadorValorTagTotalXml := 0;
  ClientWidth := 553;
  CentralizarForm;
end;


{ processa as informações dos produtos do XML no TStringGrid }
procedure TMainForm.ProcessarProdutoDoXml(ProdNodeList : IXMLNodeList);
var
  QComValor       : Double;
  VUnComValor     : Double;
  VProdAtualValor : Double;
  VProdRealValor  : Double;
  Status          : String;
  CProdValor      : String;
begin

  CProdValor      := ProdNodeList['cProd'].Text;
  QComValor       := CorrigirSeparadorDecimal(ProdNodeList['qCom'].Text);
  VUnComValor     := CorrigirSeparadorDecimal(ProdNodeList['vUnCom'].Text);
  VProdAtualValor := CorrigirSeparadorDecimal(ProdNodeList['vProd'].Text);
  VProdRealValor  := QComValor * VUnComValor;

  TotalizadorItensReal := TotalizadorItensReal + VProdRealValor;
  TotalizadorItensAtual := TotalizadorItensAtual + VProdAtualValor;

  if Abs(VProdRealValor - VProdAtualValor) <= 0.01 then
  begin
    Status := 'Válido';
  end
  else
  begin
    Status := 'Divergente';
    EncontradoDivergente := True;
  end;

  InserirLinha([
    CProdValor,
    FloatToStr(QComValor),
    Monetario(VUnComValor),
    Monetario(VProdAtualValor),
    Monetario(VProdRealValor),
    Status
  ]);

end;

{ Utilizado para acessar os filhos das tags com mais facilidade }
function TMainForm.GetChildNode(Nome : String; ParenteNodeList : IXMLNodeList) : IXMLNodeList;
var
  I : Integer;
begin
  for I := 0 to ParenteNodeList.Count - 1 do
  begin
    if ParenteNodeList[I].NodeName = Nome then
    begin
      Exit(ParenteNodeList[I].ChildNodes);
    end;
  end;
end;

{Inseri linha nova no TBDGrid }
procedure TMainForm.InserirLinha(Dados : Array of TVarRec);
begin
  GridDataSet.InsertRecord(Dados);
end;

{ corrige o separador de casa decimal caso o sistema utilize ',' para separar }
function TMainForm.CorrigirSeparadorDecimal(ValorStr : String) : Double;
begin
  ValorStr := ValorStr.Trim;
  if ChckCorrigirDecimal.State = cbChecked then
  begin
    Exit(StrToFloat(ValorStr.Replace('.', ',')));
  end;
  Exit(StrToFloat(ValorStr));
end;


function TMainForm.Monetario(Valor : Double) : String;
begin
  Result := 'R$ ' + FormatFloat('#,###0.00', Valor);
end;


{ resetar todos os valores do programa }
procedure TMainForm.LimparTudo();
begin
  GridDataSet.EmptyDataSet;
  EncontradoDivergente := False;
  LimparTotalizadores;
  BtnResetar.Enabled := False;
  BtnAnalisar.Enabled := True;
end;

procedure TMainForm.LinkLabelClickEvent(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainForm.CriarDicaEmLabel(LLabel : TLabel; Dica : String);
begin
  LLabel.ShowHint := True;
  LLabel.Hint := Dica;
end;

end.
