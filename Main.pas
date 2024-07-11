unit Main;

interface

uses
  Game,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Screen: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  private

    Game: TGame;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Game  := TGame.GetInstance;
  Game.UpdateUI(Screen.Lines);
  Screen.Lines.Add('Health: ' + Game.Character.Health.ToString
  +'/'+Game.GameSettings.GetValue<string>('CharacterHealth'));
end;

procedure TMainForm.KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Game.SetKeyState(key);
  Game.UpdateLogic();
  Game.UpdateUI(Screen.Lines);

  //logs
  Screen.Lines.Add('Health: ' + Game.Character.Health.ToString
  +'/'+Game.GameSettings.GetValue<string>('CharacterHealth'));

  Screen.Lines.Add('Key: ' + Key.ToString);
  //Screen.Lines.Add(TGame.ToString);
end;



end.
