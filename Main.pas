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
    procedure ScreenKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

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
  Screen.Lines.Add(Game.GameSettings.GetValue<string>('CharacterHealth'));
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ScreenKeyDown(Sender, Key,  Shift);
end;

procedure TMainForm.ScreenKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Game.SetKeyState(key);
  Game.UpdateLogic();
  Game.UpdateUI(Screen.Lines);

  Screen.Lines.Add(key.ToString);
end;

end.