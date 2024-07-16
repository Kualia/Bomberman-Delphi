unit Character;

interface

uses
  Tiles, Enums, Bomb,
  GameObject, Screen, Vcl.Dialogs, System.SysUtils;

type
  TAgent = class(TGameObject)
  public
    Health    :Integer;
    Speed     :Integer;
    LastTouched    : TGameObject;


    constructor Create(PosX, PosY, Health, Speed :Integer); overload;
    function    IsMovable(x, y :Integer): boolean;
    function    Move(Direction :TDirection): Integer; overload;
    function    RayCast(Direction :TDirection; Speed :Integer): Integer;
    procedure   GetHit(Damage :Integer);
    procedure   Die();
  end;

  TCharacter = class(TAgent)
  private
    FPowerUp       : TPowerups;
  public
    PowerUpTimer   : Integer;
    procedure SetPowerUp(PowerUp :TPowerups);
    function  GetPowerUp() :TPowerUps;

    property  PowerUp :TPowerUps read GetPowerUp write SetPowerUp;

    constructor Create(PosX, PosY, Health :Integer; Speed :Integer = 1);
    procedure Die();
    procedure GetHit(Damage :Integer);
    procedure Move(Direction :TDirection); overload;
    procedure Update(KeyState: TKeys);
    procedure DropBomb();
//    procedure ThrowBomb();
  end;

implementation
uses
 Game;

{ TAgent }
constructor TAgent.Create(PosX, PosY, Health, Speed :Integer);
begin
  inherited Create(PosX, PosY);
  Self.Health   := Health;
  Self.Speed    := Speed;
end;

procedure TAgent.GetHit(Damage :Integer);
begin
  Health := Health - Damage;
  if Health <= 0 then
    Die();
end;

procedure TAgent.Die;
begin
  GameObjects[PosY, PosX] := TEmpty.FInstance;
  Destroy();
end;

function  TAgent.IsMovable(x, y :Integer): boolean;
var
  Target      :TGameObject;
begin
  Result := False;
  if (x < 0) or (x > Screen.ColumnCount-1)
  or (y < 0) or (Y > Screen.RowCount) then Exit;

  Target := TGame.GetInstance.GameObjects[y, x];

  if (Target is TWall) or (Target is TSand) then
  begin
   Exit;
  end;
  Result := True;
end;

function  TAgent.Move(Direction :TDirection): Integer;
var
  Movable   :Boolean;
  Distance  :Integer;
  NewPosX,
  NewPosY   :Integer;
begin
  Distance := RayCast(Direction, Speed);
  Result := Distance;
  if Distance = 0 then Exit;

  // MOVE TO MoveTo :)
  NewPosY := PosY;
  NewPosX := PosX;
  case Direction of
    TDirection.UP:    NewPosY := PosY - Distance;
    TDirection.DOWN:  NewPosY := PosY + Distance;
    TDirection.LEFT:  NewPosX := PosX - Distance;
    TDirection.RIGHT: NewPosX := PosX + Distance;
  end;


  LastTouched := GameObjects[NewPosY, NewPosX];
  LastTouched.MoveTo(PosX, PosY);
  GameObjects.SwitchElements(NewPosY, NewPosX, PosY, PosX);
  MoveTo(NewPosX, NewPosY);
end;

function TAgent.RayCast(Direction :TDirection; Speed :Integer): Integer;
var
 Movable  :Boolean;
 i, counter        :Integer;
begin
  Movable := True;
  counter := 0;
  for i := 1 to Speed do
  begin
    case Direction of
      TDirection.UP    : Movable := IsMovable(PosX, PosY - i);
      TDirection.DOWN  : Movable := IsMovable(PosX, PosY + i);
      TDirection.RIGHT : Movable := IsMovable(PosX + i, PosY);
      TDirection.LEFT  : Movable := IsMovable(PosX - i, PosY);
    end;
    counter := counter + 1;
    if not Movable then
    begin
      Result := i - 1;
      Exit;
    end;
  end;
  Result := Speed;
end;

{ TCharacter }
constructor TCharacter.Create(PosX, PosY, Health :Integer; Speed :Integer = 1);
begin
  inherited Create(PosX, PosY, Health, Speed);
  PowerUp := TPowerups.NONE;
end;

procedure TCharacter.Die();
begin
  if PowerUp = TPowerups.SHIELD then exit;
  TGame.GetInstance.State := TGameState.LOSE;
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
var
 r :Integer;
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

    r := Random(5)+1;
    ShowMessage(r.ToString);
    PowerUp := TPowerups(r);

  end
  else if LastTouched is TExit then
    TGame.GetInstance.State := TGameState.NEXTMAP
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
