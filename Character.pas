unit Character;

interface

uses
  Tiles, Enums, Bomb, Agent,
  GameObject, Screen, Vcl.Dialogs, System.SysUtils;

type

  TCharacter = class(TAgent)
  private
    FPowerUp       : TPowerups;
  public
    PowerUpTimer   : Integer;
    class var Sprite :Char;
    procedure SetPowerUp(PowerUp :TPowerups);
    function  GetPowerUp() :TPowerUps;

    property  PowerUp :TPowerUps read GetPowerUp write SetPowerUp;

    constructor Create(PosX, PosY, Health :Integer; Speed :Integer = 1);
    function  Die() :Boolean;
    procedure GetHit(Damage :Integer);
    procedure Move(Direction :TDirection); overload;
    procedure Update(KeyState: TKeys);
    procedure DropBomb();
//    procedure ThrowBomb();
  end;

implementation
uses
 Game, Monster;

{ TCharacter }
constructor TCharacter.Create(PosX, PosY, Health :Integer; Speed :Integer = 1);
begin
  inherited Create(PosX, PosY, Health, Speed);
  PowerUp := TPowerups.NONE;
end;

function TCharacter.Die() :Boolean;
begin
  Result := False;
  if PowerUp = TPowerups.SHIELD then exit;
  TGame.GetInstance.State := TGameState.LOSE;
  Result := True;
//  inherited Die();
end;

procedure TCharacter.GetHit(Damage :Integer);
begin
  if PowerUp = TPowerups.SHIELD then Exit;
  inherited GetHit(Damage);
end;

procedure TCharacter.Move(Direction :TDirection);
begin
  if PowerUp = TPowerups.RUN then Self.Speed := 2
  else if PowerUp = TPowerups.SKATEBOARD then Self.Speed := 50;
  if inherited Move(Direction) > 0 then GetHit(1);
  Self.Speed := 1;
end;

procedure TCharacter.Update(KeyState: TKeys);
begin
  case KeyState of
    TKeys.UPKEY     :Move(TDirection.UP);
    TKeys.DOWNKEY   :Move(TDirection.DOWN);
    TKeys.LEFTKEY   :Move(TDirection.LEFT);
    TKeys.RIGHTKEY  :Move(TDirection.RIGHT);
    TKeys.BOMBKEY	  :DropBomb();
  end;

  if PowerUp <> None then begin
    PowerUpTimer := PowerUpTimer - 1;
    if PowerUpTimer <= 0 then
      FPowerUp := TPowerups.NONE;
  end;

  if LastTouched is TPowerUp then begin
    TGame.GetInstance
     .GameObjects[LastTouched.PosY, LastTouched.PosX] := TEmpty.GetInstance;
    LastTouched.Free;
    LastTouched := TEmpty.GetInstance;

    PowerUp := TPowerups(Random(5)+1);
  end
  else if LastTouched is TExit then
    TGame.GetInstance.State := TGameState.NEXTMAP
  else if LastTouched is TMonster then Die()
  else if Health <= 0 then Die();
end;

procedure TCharacter.DropBomb();
begin
  TGame.GetInstance.Bombs.Add(PosX, PosY);
end;

procedure TCharacter.SetPowerUp(PowerUp :TPowerUps);
begin
  FPowerUp := PowerUp;
  if PowerUp = TPowerups.NONE then PowerUpTimer := 0
  else PowerUpTimer := TPowerUp.PowerUpTimer;
end;

function TCharacter.GetPowerUp: TPowerups;
begin
  Result := FPowerUp;
end;

end.
