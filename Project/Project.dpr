program Project;

uses
  Vcl.Forms,
  Main in '..\Main.pas' {MainForm},
  GameObject in '..\GameObject.pas',
  Game in '..\Game.pas',
  Helpers in '..\Helpers.pas',
  Screen in '..\Screen.pas',
  Character in '..\Character.pas',
  Tiles in '..\Tiles.pas',
  Dynamic2DArr in '..\Dynamic2DArr.pas',
  Enums in '..\Enums.pas',
  Bomb in '..\Bomb.pas',
  ParticleEffects in '..\ParticleEffects.pas',
  Bombs in '..\Bombs.pas',
  Agent in '..\Agent.pas',
  Monster in '..\Monster.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
