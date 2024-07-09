unit Character;

interface

uses
  BaseClasses, Screen, Vcl.Dialogs, System.SysUtils;

type
  TAgent = class(TGameObject)
  private
    Health    :Integer;
    Speed     :Integer;

  public
    constructor Create(PosX, PosY, Health, Speed :Integer); overload;
    procedure   GetHit(Damage :Integer);
    procedure   Die();
  end;

  TCharacter = class(TAgent)
  public
    constructor Create(PosX, PosY, Health :Integer; Speed :Integer = 1);
    procedure Update(KeyState: TKeys);
    procedure Draw(ScreenBuffer :TScreenBuffer);
  end;

implementation

{ TAgent }
constructor TAgent.Create(PosX, PosY, Health, Speed :Integer);
begin
  inherited Create(PosX, PosY);

  Self.Health   := Health;
  Self.Speed    := Speed;
  ShowMessage('TAgent created spd:' + IntToStr(Speed));
end;

procedure TAgent.GetHit(Damage :Integer);
begin
  Health := Health - Damage;
  if Health <= 0 then
    Die();
end;

procedure TAgent.Die;
begin
  Destroy();
end;

{ TCharacter }
constructor TCharacter.Create(PosX, PosY, Health :Integer; Speed :Integer = 1);
begin
  //showmessage
  inherited Create(PosX, PosY, Health, Speed);

  ShowMessage('TAgent created spd:' + IntToStr(Speed));
end;

procedure TCharacter.Update(KeyState: TKeys);
begin
  ShowMessage('NEW OBJECT x,y:' + IntToStr(PosX) + '  ' + IntToStr(PosY));
  case KeyState of
    TKeys.UPKEY     :Move(TDirection.UP);
    TKeys.DOWNKEY   :Move(TDirection.DOWN);
    TKeys.LEFTKEY   :Move(TDirection.LEFT);
    TKeys.RIGHTKEY  :Move(TDirection.RIGHT);
  end;
end;

procedure TCharacter.Draw(ScreenBuffer: TScreenBuffer);
begin
  ScreenBuffer[PosY, PosX] := 'C';
end;

end.
