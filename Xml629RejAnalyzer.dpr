program Xml629RejAnalyzer;

uses
  Vcl.Forms,
  FormPrincipal in 'FormPrincipal.pas' {MainForm},
  FormTDBGridTeste in 'FormTDBGridTeste.pas' {DBGridTestForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Luna');
  Application.Title := 'Analisador XML NFe Shop';
  Application.CreateForm(TMainForm, MainForm);
  //Application.CreateForm(TDBGridTestForm, DBGridTestForm);
  Application.Run;
end.
