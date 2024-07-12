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
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
uses
  Enums;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Game  := TGame.GetInstance;
  Game.UpdateUI(Screen.Lines);
end;

procedure TMainForm.KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Game.Update(Screen.Lines, Key);
end;



end.
