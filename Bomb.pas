unit Bomb;

interface

uses
  Vcl.Dialogs, GameObject, Enums, Tiles;

type
  TBomb = class(TGameObject)
    Health :Integer;
    Damage :Integer;
    Range   :Integer;
    public
      constructor Create(x, y :Integer);
//      class var BombCount  :Integer;
//      class var MaxBombs   :Integer;
      procedure Update;
      procedure Explode;
      procedure Hit(x,y :Integer);
      function  RayCast(Direction :TDirection; Speed :Integer): Integer;
      function  IsMovable(x, y :Integer): boolean;

      //sprites
      class var BombSprite      :Char;
      class var ExplosionSprite :Char;
  end;

implementation

constructor TBomb.Create(x, y :Integer);
begin
//  if BombCount < MaxBombs then
    ShowMessage('Tbomb create');
    Screen[PosY, PosX] := BombSprite;
    Health := 3;
    inherited Create(x, y);

end;

procedure   TBomb.Update();
begin
  Screen[PosY, PosX] := BombSprite;
  ShowMessage('Tbomb update');
  Damage := Health - 1;
  if Health <= 0 then explode();
end;

procedure  TBomb.Explode();
var
  Distance, I :Integer;
begin
     ShowMessage('Tbomb explode');
  Hit(PosX, PosY);
  for I := 1 to RayCast(TDirection.UP,    Range) do Hit(PosX, PosY - I);
  for I := 1 to RayCast(TDirection.DOWN,  Range) do Hit(PosX, PosY + I);
  for I := 1 to RayCast(TDirection.LEFT,  Range) do Hit(PosX - I, PosY);
  for I := 1 to RayCast(TDirection.RIGHT, Range) do Hit(PosX + I, PosY);
end;


procedure TBomb.Hit(x, y :Integer);
var
  I :integer;
  obj : TGameObject;
begin
  Screen[PosY, PosX] := ExplosionSprite;

  // sadece kuma vuruyoz
  if GameObjects[PosY, PosX] is TSand then
  begin
    GameObjects[PosY, PosX].Destroy();
    GameObjects[PosY, PosX] := TEmpty.GetInstance;
  end;

end;


function TBomb.RayCast(Direction :TDirection; Speed :Integer): Integer;
var
 Movable            :Boolean;
 i, counter         :Integer;
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

function  TBomb.IsMovable(x, y :Integer): boolean;
var
  Target      :TGameObject;
begin
  Result := False;
  if (x < 0) or (x > Screen.ColumnCount-1)
  or (y < 0) or (Y > Screen.RowCount) then Exit;

  Target := GameObjects[y, x];
  if (Target is TWall) or (Target is TSand) then
  begin
   Exit;
  end;
  Result := True;
end;




end.