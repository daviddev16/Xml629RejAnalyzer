program Xml629RejAnalyzer;

uses
  Vcl.Forms,
  FormPrincipal in 'FormPrincipal.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
