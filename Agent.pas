unit Agent;

interface

uses
  Enums, GameObject;

type
  TAgent = class(TGameObject)
  public
    Health    :Integer;
    Speed     :Integer;
    LastTouched    :TGameObject;

    constructor Create(PosX, PosY, Health, Speed :Integer); overload;
    function    IsMovable(x, y :Integer): boolean;
    function    Move(Direction :TDirection): Integer; overload;
    function    RayCast(Direction :TDirection; Speed :Integer): Integer;
    procedure   GetHit(Damage :Integer);
    procedure   Die();
  end;

implementation

uses
  Game, Tiles;

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
  Result   := Distance;
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

    if not Movable then
    begin
      Result := i - 1;
      Exit;
    end;
  end;
  Result := Speed;
end;


end.
