unit Bomb;

interface

uses
  Vcl.Dialogs, GameObject, Enums;

type
  TBomb = class(TGameObject)
    Timer  :Integer;
    Damage :Integer;
    Range  :Integer;
    Drill  :Integer;
    State  :Integer;
    public
      constructor Create(x, y :Integer);
//      class var BombCount  :Integer;
//      class var MaxBombs   :Integer;
      procedure Update;
      procedure Explode;
      function  TryToHit(x,y :Integer): boolean;

      //sprites
      class var BombSprite      :Char;
      class var ExplosionSprite :Char;
  end;

implementation

uses
  Character, Tiles;

constructor TBomb.Create(x, y :Integer);
begin
//  if BombCount < MaxBombs then

    Timer := 4+1;
    Range := 2;
    State := 1;
    inherited Create(x, y);

end;

procedure   TBomb.Update();
begin
  if State <= 0 then exit;
  Particles.Add(PosX, PosY, BombSprite);
  Timer := Timer - 1;
  if Timer <= 0 then explode();
end;

procedure  TBomb.Explode();
var
  Distance, I :Integer;
begin
  TryToHit(PosX, PosY);
  for I := 1 to Range do if not TryToHit(PosX, PosY - I) then break;
  for I := 1 to Range do if not TryToHit(PosX, PosY + I) then break;
  for I := 1 to Range do if not TryToHit(PosX - I, PosY) then break;
  for I := 1 to Range do if not TryToHit(PosX + I, PosY) then break;

  state := 0;
end;

function TBomb.TryToHit(x, y :Integer): Boolean;
var
  obj : TGameObject;
begin
  obj := GameObjects[y, x];
  Result := True;

  //Hit sand
  if obj is TSand then
  begin

    obj.Free();
    GameObjects[y, x] := TEmpty.GetInstance;
    Result := False;
  end
  //Hit Character
  else if obj is TWall then
  begin
    Result := False;
  end
  else if obj is TCharacter then
  begin
    Particles.Add(x, y, ExplosionSprite);
    (obj as TCharacter).Die;
    GameObjects[y, x] := TEmpty.GetInstance;
    Result := False;
  end;

  if Result then
  begin
    Particles.Add(x, y, ExplosionSprite);
  end;

end;

end.
