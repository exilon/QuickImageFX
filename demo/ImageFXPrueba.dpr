program ImageFXPrueba;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Quick.ImageFX.Types in '..\Quick.ImageFX.Types.pas',
  Quick.ImageFX.Base in '..\Quick.ImageFX.Base.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
