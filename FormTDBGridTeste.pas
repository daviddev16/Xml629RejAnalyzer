unit FormTDBGridTeste;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,
  DBClient,
  StdCtrls;

type
  TDBGridTestForm = class(TForm)
    DBGrid1 : TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);

  private

    GridDataSet : TClientDataSet;

    procedure CriarDataSetSource();

  public

  end;

var
  DBGridTestForm: TDBGridTestForm;

implementation

procedure TDBGridTestForm.CriarDataSetSource();
begin
   DBGrid1.DataSource := TDataSource.Create(nil);
   GridDataSet := TClientDataSet.Create(nil);
   DBGrid1.DataSource.DataSet := GridDataSet;
   GridDataSet.FieldDefs.Add('Cd. Produto', ftString, 10);
   GridDataSet.FieldDefs.Add('Qtd.', ftString, 10);
   GridDataSet.FieldDefs.Add('Vl. Unitário', ftString, 10);
   GridDataSet.FieldDefs.Add('Vl. Item', ftString, 10);
   GridDataSet.FieldDefs.Add('Vl. Real', ftString, 10);
   GridDataSet.FieldDefs.Add('Status', ftString, 10);
   GridDataSet.CreateDataSet;

end;

{$R *.dfm}

procedure TDBGridTestForm.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  ValorCell : Variant;
begin

  { verificar se o data set está ativo antes }
  if not DBGrid1.DataSource.DataSet.Active then
    Exit;


  if gdSelected in State then
  begin
    { manter seleção das linhas "animado" }
    DBGrid1.Canvas.Brush.Color := clWebGainsboro;
    DBGrid1.Canvas.Font.Color := clBlack;
  end

  else if (DataCol >= 0) and (DataCol < DBGrid1.Columns.Count) then
  begin

    { mudar cor da linha de acordo com o status }
    ValorCell := GridDataSet.FieldByName(DBGrid1.Columns[5].FieldName).Value;

    if ValorCell = 'V' then
    begin
      DBGrid1.Canvas.Brush.Color := clWhite;
      DBGrid1.Canvas.Font.Color := clWebGreen;
    end
    else
    begin
      DBGrid1.Canvas.Brush.Color := clWebSalmon;
      DBGrid1.Canvas.Font.Color := clWebDarkRed
    end;

  end;

  DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TDBGridTestForm.FormCreate(Sender: TObject);
begin
  CriarDataSetSource;
  GridDataSet.InsertRecord(['1', '2', '3', '4', '5', 'V']);
  GridDataSet.InsertRecord(['1', '2', '3', '4', '5', 'V']);
  GridDataSet.InsertRecord(['1', '2', '3', '4', '5', 'V']);
  GridDataSet.InsertRecord(['1', '2', '3', '4', '5', 'R']);
end;

end.
