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
  Xml.XMLIntf;

type
  TMainForm = class(TForm)
    GridValores: TStringGrid;
    BtnAnalisar: TButton;
    OpenDialog1: TOpenDialog;
    ChckCorrigirDecimal: TCheckBox;
    LblTotalizadores: TLabel;
    Memo1: TMemo;
    Label1: TLabel;
    BtnAjuda: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnAnalisarClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure BtnAjudaClick(Sender: TObject);

  private
    { Private declarations }

    TotalizadorItensReal : Double;
    TotalizadorItensAtual : Double;
    TotalizadorValorTagTotalXml : Double;
    EncontradoDivergente : Boolean;

    procedure InserirLinha(Dados : Array of String);
    procedure ProcessarXml(XmlDoc : IXMLDocument);
    procedure ProcessarProdutoDoXml(ProdNodeList : IXMLNodeList);
    procedure LimparTudo();

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
var
  I: Integer;
begin

  { Centralizar tela }
  Left :=(Screen.Width-Width)  div 2;
  Top :=(Screen.Height-Height) div 2;

  GridValores.ColCount := 6;
  GridValores.FixedCols := 0;
  GridValores.FixedRows := 0;

  GridValores.Cells[0, 0] := 'qCom';
  GridValores.ColWidths[0] := 50;

  GridValores.Cells[1, 0] := 'vUnCom';
  GridValores.ColWidths[1] := 70;

  GridValores.Cells[2, 0] := 'vProdAtual';
  GridValores.ColWidths[2] := 100;

  GridValores.Cells[3, 0] := 'vProdReal';
  GridValores.ColWidths[3] := 100;

  GridValores.Cells[4, 0] := 'Status';
  GridValores.ColWidths[4] := 80;

  GridValores.Cells[5, 0] := 'Cd. Produto';
  GridValores.ColWidths[5] := 110;

  Memo1.Clear;

  with Memo1.Lines do
  begin
    Add(String.Empty);
    Add('  Legenda: ');
    Add('  qCom: Quantidade do Item no XML;');
    Add('  vUnCom: Valor total do item no XML;');
    Add('  vProdAtual: Valor total do item no XML (valor de "<det> -> <vProd>");');
    Add('  vProdReal: Valor total do item seguindo (qCom * vUnCom);');
    Add('  Cd.Produto: Código do produto no XML;');
    Add('  Status: Se o valor total real do item condiz com o valor do XML;');
    Add('          Verifica: | vProdAtual - vProdReal | <= 0.01');
    Add('            Se for verdadeiro = Válido');
    Add('            Se for falso = Divergente');
    Add(String.Empty);
    Add('  Totalizador Vl.Real: Somatório dos valores de vProdReal;');
    Add('  Totalizador Vl.Atual: Somatório dos valores de vProdAtual;');
    Add('  Totalizador do XML: Valor da tag "<total> -> <ICMSTot> -> <vProd>";');
    Add(String.Empty);
  end;



end;


procedure TMainForm.BtnAjudaClick(Sender: TObject);
var
  StrAjudaMensagem : TStringBuilder;
begin
  StrAjudaMensagem := TStringBuilder.Create;

  with StrAjudaMensagem do
  begin
    Append('A rejeição 564: "Total do Produto / Serviço difere do somatório dos itens", ocorre quando ');
    Append('O totalizador das tags "<det> -> <vProd>" é diferente de "<total> -> <ICMSTot> -> <vProd>". ');
    Append('Este sistema pode te ajudar a encontrar se há algum valor que ao somar os valores dos ');
    Append('itens, fique diferente do totalizador real no XML.');
  end;
  ShowMessage(StrAjudaMensagem.ToString);
  StrAjudaMensagem.Clear;

  with StrAjudaMensagem do
  begin
    Append('A rejeição 629: "Valor do Produto difere do produto Valor Unitário de Comercialização e ');
    Append('Quantidade Comercial", ocorre quando ao multiplicar o valor unitário do XML com a quantidade ');
    Append('do item no XML para cada produto, encontrasse um valor diferente do valor esperado do total ');
    Append('do produto. O valor de diferença não pode ultrapassar 0.01 centavos. Caso ultrapasse, o ');
    Append('programa vai informar na coluna "Status" o valor "Divergente".');
  end;
  ShowMessage(StrAjudaMensagem.ToString);
  StrAjudaMensagem.Free;

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
    ShowMessage
    (
      'Foi encontrado algum produto com valor divergente. Tente corrigir no WShop' +
      ', Caso não seja possível de nenhum jeito pelo o sistema ou o mesmo continue ' +
      'gerando a tag com valor errado, consulte a supervisão para alterar o XML.'
    );
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

  LblTotalizadores.Caption := StrTotalizador.ToString;

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
    FloatToStr(QComValor),
    Monetario(VUnComValor),
    Monetario(VProdAtualValor),
    Monetario(VProdRealValor),
    Status,
    CProdValor
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

{Inseri linha nova no TStringGrid }
procedure TMainForm.InserirLinha(Dados : Array of String);
var
  CurrRow : Integer;
  I : Integer;
begin

  CurrRow := GridValores.RowCount;
  GridValores.RowCount := CurrRow + 1;

  for I := 0 to GridValores.ColCount - 1 do
  begin
    GridValores.Cells[I, CurrRow] := Dados[i];
  end;

end;

procedure TMainForm.Label1Click(Sender: TObject);
begin

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

procedure TMainForm.LimparTudo();
var
  I, J: Integer;
begin
  for I := 1 to GridValores.ColCount - 1 do
  begin
    for J := 1 to GridValores.RowCount - 1 do
    begin
      GridValores.Cells[I, J] := '';
    end;
  end;
  GridValores.RowCount := 1;
  LblTotalizadores.Caption := 'Aguardando XML para calcular totalizadores...';
  TotalizadorItensReal := 0;
  TotalizadorItensAtual := 0;
  TotalizadorValorTagTotalXml := 0;
  EncontradoDivergente := False;
end;

end.
