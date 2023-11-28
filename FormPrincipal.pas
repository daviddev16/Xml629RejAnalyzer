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
    DBGridValores: TDBGrid;
    LblTituloInfo: TLabel;
    LblSumVlReais: TLabel;
    LblSumVlAtuais: TLabel;
    LblVlTotalizadorXML: TLabel;
    LLblRej629: TLinkLabel;
    LLblRej564: TLinkLabel;
    LblReferencias: TLabel;
    LinkLabel1: TLinkLabel;
    LblRej564Alerta: TLabel;
    LblDivergentes: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure BtnAnalisarClick(Sender: TObject);
    procedure LinkLabelClickEvent(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure DBGridValoresTitleClick(Column: TColumn);

  private
    { Private declarations }

    GridDataSet : TClientDataSet;

    TotalizadorItensReal : Double;
    TotalizadorItensAtual : Double;
    TotalizadorValorTagTotalXml : Double;
    EncontradoDivergente : Boolean;
    HabilitarDescricaoColunas : Boolean;

    const nmCodigoProduto = 'Cd. Produto';
    const nmVlUnitario = 'Vl. Unitário';
    const nmQuantidade = 'Qtd.';
    const nmVlItem = 'Vl. Item';
    const nmVlReal = 'Vl. Real';
    const nmStatus = 'Status';

    procedure InserirLinha(Dados : Array of TVarRec);
    procedure CriarDicaEmLabel(LLabel : TLabel; Dica : String);
    procedure PersonalizarTextoValidado(LabelComp : TLabel; Validacao : Boolean; Texto : String);
    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol:
      Integer; Column: TColumn; State: TGridDrawState);

    procedure ExpandirTela(Expandir : Boolean);
    procedure CriarDataSetSource();
    procedure CentralizarForm();
    procedure Resetar();


    procedure ProcessarXml(XmlDoc : IXMLDocument);
    procedure ProcessarProdutoDoXml(ProdNodeList : IXMLNodeList);
    procedure ProcessarTotalizadores();
    procedure LimparTotalizadores();


    function VerificarDiferenca(ValorA : Double; ValorB : Double) : Boolean;
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

{ Oncreate TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
begin

  CriarDataSetSource;
  LimparTotalizadores;
  ExpandirTela(False);

  CriarDicaEmLabel(LblSumVlReais, 'Este é o somatório de todos os valores reais dos itens da nota.');
  CriarDicaEmLabel(LblSumVlAtuais, 'Este é o somatório de todos os valores atuais dos itens no XML.');
  CriarDicaEmLabel(LblVlTotalizadorXML, 'Este é valor totalizador dos itens da nota no XML.');

  { Em desenvolvimento }
  HabilitarDescricaoColunas := False;

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
    ValorCell := GridDataSet.FieldByName(nmStatus).Value;

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

procedure TMainForm.DBGridValoresTitleClick(Column: TColumn);
var
  Mensagem : TStringBuilder;
begin

  if Not HabilitarDescricaoColunas then
    Exit;

  Mensagem := TStringBuilder.Create;

  with Mensagem do
  begin
    if Column.FieldName = nmStatus then
    begin
      Append('Divergente: Quando a diferença entre "vUnCom x qCom" e "vProd" é maior que 0.01 centavos;' + sLineBreak);
      Append('Válido: Quando a diferença entre "vUnCom x qCom" e "vProd" é menor ou igual a 0.01;' + sLineBreak);
      Append(sLineBreak);
      Append('vUnCom: Tag XML com o valor unitário do produto;' + sLineBreak);
      Append('qCom: Tag XML com o Valor da quantidade do item;' + sLineBreak);
      Append('vProd: Tag XML com o do Item;');
    end
    else if Column.FieldName = nmCodigoProduto then
    begin
      Append('Código do produto no XML;');
    end
    else if Column.FieldName = nmQuantidade then
    begin
      Append('Quantidade do produto no XML;');
    end

    else
      Mensagem.Append('Sem comentário nesta coluna.');
  end;

  MessageDlg(Mensagem.ToString, mtInformation, [mbOk], 0, mbOk);
  Mensagem.Free;
end;

procedure TMainForm.LinkLabelClickEvent(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
var
  Alerta : String;
begin

  if Sender is TLinkLabel then
  begin
    if (Sender as TLinkLabel).HelpKeyword <> 'RESUMO' then
      MessageDlg(
        'Pode ocorrer do valor no sistema estar correto, ' +
        'e no XML estar errado. Neste caso, deve alterar no XML. ' +
        'Consulte a supervisão para verificar a correção.',
      mtWarning, [TMsgDlgBtn.mbOK], 0);
  end;

  ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

function TMainForm.VerificarDiferenca(ValorA : Double; ValorB : Double) : Boolean;
begin
  Result := Abs(ValorA - ValorB) <= 0.01; {Tolerancia de 0.01 centavos}
end;

procedure TMainForm.BtnAnalisarClick(Sender: TObject);
var
  XmlDoc : IXMLDocument;
begin

  Resetar;

  OpenDialog1.Options := [TOpenOption.ofFileMustExist];
  OpenDialog1.DefaultExt := 'xml';
  OpenDialog1.Filter := 'Arquivo XML|*.xml|Todos os Arquivos|*.*';

  if OpenDialog1.Execute then
  begin
    XmlDoc := TXMLDocument.Create(OpenDialog1.FileName);
    ProcessarXml(XmlDoc);

    if GridDataSet.RecordCount > 0 then
    begin
      GridDataSet.RecNo := 1;
      ProcessarTotalizadores;
      ExpandirTela(True);
    end;

  end;

  if EncontradoDivergente then
  begin
    MessageDlg(
      'Foi encontrado algun(s) produto(s) com valor(es) divergente(s). ' +
      'Tente corrigir no sistema! Caso não seja possível pelo sistema, ou ' + sLineBreak +
      'o sistema continua gerando a tag com valor errado, consulte a ' +
      'supervisão para alterar o XML.',
    mtWarning, [mbOK], 0);
  end;

end;

{ processa as informações dos produtos do XML }
procedure TMainForm.ProcessarXml(XmlDoc : IXMLDocument);
var
  StrTotalizador    : TStringBuilder;
  InfNFeNodeList    : IXMLNodeList;
  ProdNodeList      : IXMLNodeList;
  ICMSTotalNodeList : IXMLNodeList;
  I, J              : Integer;
begin
  InfNFeNodeList  := GetChildNode('infNFe',
                     GetChildNode('NFe', XmlDoc.ChildNodes));

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

  ICMSTotalNodeList := GetChildNode('ICMSTot',
                       GetChildNode('total', InfNFeNodeList));

  TotalizadorValorTagTotalXml := CorrigirSeparadorDecimal(ICMSTotalNodeList['vProd'].Text);

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

  if VerificarDiferenca(VProdRealValor, VProdAtualValor) then
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

{ Processa informações dos totalizadores }
procedure TMainForm.ProcessarTotalizadores();
var
  ValidacaoTotalizadorItensReal : Boolean;
  ValidacaoTotalizadorItensAtual : Boolean;
  ValidacaoTotalizadorValorTagTotalXml : Boolean;
  DeveMostrarAlertas : Boolean;
begin

  ValidacaoTotalizadorItensReal := True;
  ValidacaoTotalizadorItensAtual := VerificarDiferenca(TotalizadorItensReal,
                                                       TotalizadorItensAtual);

  ValidacaoTotalizadorValorTagTotalXml := VerificarDiferenca(TotalizadorItensReal,
                                                             TotalizadorValorTagTotalXml);

  PersonalizarTextoValidado(
    LblSumVlReais,
    ValidacaoTotalizadorItensReal,
    'Somatório dos Valores Reais: ' + Monetario(TotalizadorItensReal));

  PersonalizarTextoValidado(
    LblSumVlAtuais,
    ValidacaoTotalizadorItensAtual,
    'Somatório dos Valores do XML: ' + Monetario(TotalizadorItensAtual));

  PersonalizarTextoValidado(
    LblVlTotalizadorXML,
    ValidacaoTotalizadorValorTagTotalXml,
    'Totalizador do XML: ' + Monetario(TotalizadorValorTagTotalXml));

  PersonalizarTextoValidado(
    LblDivergentes,
    False,
    'Total Divergente: ' + Monetario(Abs(TotalizadorValorTagTotalXml - TotalizadorItensReal)));


   DeveMostrarAlertas := not (ValidacaoTotalizadorItensAtual and
                              ValidacaoTotalizadorValorTagTotalXml);

  LblRej564Alerta.Visible := DeveMostrarAlertas;
  LblDivergentes.Visible := DeveMostrarAlertas;


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
  Exit(StrToFloat(ValorStr.Replace('.', ',')));
end;


procedure TMainForm.CriarDataSetSource();
begin
  { inicializando DataSet/DataSource }
  GridDataSet := TClientDataSet.Create(nil);
  DBGridValores.DataSource := TDataSource.Create(nil);
  DBGridValores.DataSource.DataSet := GridDataSet;

  { inicializando colunas do DataSet }
  GridDataSet.FieldDefs.Add(nmCodigoProduto, ftString, 17);
  GridDataSet.FieldDefs.Add(nmQuantidade, ftString, 12);
  GridDataSet.FieldDefs.Add(nmVlUnitario, ftString, 12);
  GridDataSet.FieldDefs.Add(nmVlItem, ftString, 12);
  GridDataSet.FieldDefs.Add(nmVlReal, ftString, 12);
  GridDataSet.FieldDefs.Add(nmStatus, ftString, 13);
  GridDataSet.CreateDataSet;

  DBGridValores.DefaultDrawing := False;
  DBGridValores.OnDrawColumnCell := DBGridDrawColumnCell;
  GridDataSet.IndexFieldNames := nmStatus;
end;

{ Preenche com X ou V no inicio do texto e muda a cor de acordo com a validação }
procedure TMainForm.PersonalizarTextoValidado(LabelComp : TLabel;
  Validacao : Boolean; Texto : String);
begin
  if Validacao then
  begin
    LabelComp.Caption := '✅ ' + Texto;
    LabelComp.Font.Color := clWebDarkgreen;
  end
  else
  begin
    LabelComp.Caption := '❌ ' + Texto;
    LabelComp.Font.Color := clWebDarkRed;
  end;
end;

{ Criar dica quando passar mouse por cima no TLabel }
procedure TMainForm.CriarDicaEmLabel(LLabel : TLabel; Dica : String);
begin
  LLabel.ShowHint := True;
  LLabel.Hint := Dica;
end;

{ Altera a largura da tela }
procedure TMainForm.ExpandirTela(Expandir : Boolean);
begin
  if Expandir then
    ClientWidth := 885
  else
    ClientWidth := 553;

  CentralizarForm;
end;

{ Converte para texto com formato monetario }
function TMainForm.Monetario(Valor : Double) : String;
begin
  Result := 'R$ ' + FormatFloat('#,###0.00', Valor);
end;

{ resetar todos os valores do programa }
procedure TMainForm.Resetar();
begin
  GridDataSet.EmptyDataSet;
  EncontradoDivergente := False;
  LimparTotalizadores;
  ExpandirTela(False);
end;

{ Limpa todos os totalizadores do Form }
procedure TMainForm.LimparTotalizadores();
begin
  LblSumVlReais.Caption := '';
  LblSumVlAtuais.Caption := '';
  LblVlTotalizadorXML.Caption := '';
  TotalizadorItensReal := 0;
  TotalizadorItensAtual := 0;
  TotalizadorValorTagTotalXml := 0;
end;

{ Centralizar tela }
procedure TMainForm.CentralizarForm();
begin
  Left :=(Screen.Width-Width)  div 2;
  Top :=(Screen.Height-Height) div 2;
end;

end.
