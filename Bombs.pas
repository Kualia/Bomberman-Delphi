unit Bombs;

interface

uses
  GameObject, System.Generics.Collections;

type
  TBomb = class(TGameObject)
    x, y, Timer, Damage,
    Range, Drill  :Integer;
    isActive      :Boolean;
    public
      constructor Create(aX, aY, aTimer, aDamage, aRange, aDrill: Integer);
      procedure Explode;
      function  TryToHit(x,y :Integer): boolean;
      class var BombSprite      :Char;
      class var ExplosionSprite :Char;

  end;

  TBombs = class(TObject)
    MaxCount  :Integer;
    private
      Bombs   :TList<TBomb>;
    public
      constructor Create();
      procedure Add(x, y :Integer);
      procedure Update();
  end;

implementation

uses
  Tiles, Character, Game, system.json;


{ TBomb }
constructor TBomb.Create(aX, aY, aTimer, aDamage, aRange, aDrill: Integer);
begin
  X := aX; Y:= aY; Timer := aTimer;
  Range := aRange; Drill := aDrill;
  inherited Create(x, y);
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

//  Destroy();
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
    Particles.Add(x, y, ExplosionSprite);
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
    (obj as TCharacter).Die;
    GameObjects[y, x] := TEmpty.GetInstance;
    Result := False;
  end;

  if Result then
  begin
    Particles.Add(x, y, ExplosionSprite);
  end;

end;

{ TBombs }
constructor TBombs.Create();
begin
//  destructo for Bomb in Bombs do Bomb.free
  Bombs    := TList<TBomb>.create;
  MaxCount := TGame.GetInstance.GameSettings.GetValue<TJSONObject>('BombSettings')
                                            .GetValue<Integer>('MaxCount');
end;


procedure TBombs.Add(x: Integer; y: Integer);
begin
  if Bombs.Count >= MaxCount then Exit;
  Bombs.Add(TBomb.Create(x, y, 3, 3, 4, 1));
end;

procedure TBombs.Update();
var
  Bomb :TBomb;
begin
  for Bomb in Bombs do
  begin
    Bomb.Particles.Add(Bomb.PosX, Bomb.PosY, Bomb.BombSprite);
    Bomb.Timer   := Bomb.Timer - 1;
    if Bomb.Timer <= 0 then begin
      Bomb.explode();
      Bombs.Remove(Bomb);
    end;
  end;
end;


end.
