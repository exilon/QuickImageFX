program ImageFXPrueba;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Quick.ImageFX.Types in '..\Quick.ImageFX.Types.pas',
  Quick.ImageFX in '..\Quick.ImageFX.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
