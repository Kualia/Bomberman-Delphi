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

    constructor Create(PosX, PosY, Health, Speed :Integer); overload;
    function    IsMovable(x, y :Integer): boolean;
    function    Move(Direction :TDirection): Integer; overload;
    function    RayCast(Direction :TDirection; Speed :Integer): Integer;
    procedure   GetHit(Damage :Integer);
    procedure   Die();
  end;

  TCharacter = class(TAgent)
  public
    constructor Create(PosX, PosY, Health :Integer; Speed :Integer = 1);
    procedure Die();
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
begin
  MoveTo(PosX, PosY);
  Distance := RayCast(Direction, Speed);
  Result := Distance;
  if Distance = 0 then Exit;

  // Noooo

  // MOVE TO MoveTo :)
  case Direction of
    TDirection.UP:    GameObjects.SwitchElements(PosY - Distance, PosX, PosY, PosX);
    TDirection.DOWN:  GameObjects.SwitchElements(PosY + Distance, PosX, PosY, PosX);
    TDirection.LEFT:  GameObjects.SwitchElements(PosY, PosX - Distance, PosY, PosX);
    TDirection.RIGHT: GameObjects.SwitchElements(PosY, PosX + Distance, PosY, PosX);
  end;

  case Direction of
    TDirection.UP:    MoveTo(PosX, PosY - Distance);
    TDirection.DOWN:  MoveTo(PosX, PosY + Distance);
    TDirection.LEFT:  MoveTo(PosX - Distance, PosY);
    TDirection.RIGHT: MoveTo(PosX + Distance, PosY);
  end;

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
end;

procedure TCharacter.Die();
begin
  TGame.GetInstance.State := TGameState.LOSE;
//  inherited Die();
end;

procedure TCharacter.Move(Direction :TDirection);
begin
  if inherited Move(Direction) > 0 then GetHit(1);
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

  if (PosX = TGame.GetInstance.ExitX) and (PosY = TGame.GetInstance.ExitY) then
  TGame.GetInstance.State := TGameState.NEXTMAP

  else if Health <= 0 then Die();
end;

procedure TCharacter.DropBomb();
begin
  TGame.GetInstance.Bombs.Add(PosX, PosY);
end;


end.
