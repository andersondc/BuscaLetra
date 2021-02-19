program APILetra;

uses
  System.StartUpCopy,
  FMX.Forms,
  Principal in 'Principal.pas' {FLetra};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFLetra, FLetra);
  Application.Run;
end.
