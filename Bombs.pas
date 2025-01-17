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
      Range   :Integer;
      Timer   :Integer;
    public
      constructor Create();
      procedure Add(x, y :Integer);
      procedure Update();
      function  Count(): Integer;
  end;

implementation

uses
  Tiles, Character, Monster, Game, system.json, system.SysUtils, Enums;

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
    (obj as TSand).Free();

    if Random(101) < TPowerUp.PowerUpRate then
         obj := TPowerUp.Create(x, y)
    else obj := Tempty.GetInstance;
    GameObjects[y, x] := obj;
    Result := False;
  end
  //Hit Wall
  else if obj is TWall then
  begin
    Result := False;
  end
  //Hit Character
  else if obj is TCharacter then
  begin
    if not (obj as TCharacter).Die then Exit;
    Particles.Add(x, y, ExplosionSprite);
    GameObjects[y, x] := TEmpty.GetInstance;
    Result := False;
  end
  //Hit Monster
  else if obj is TMonster then
  begin
    (obj as TMonster).Die();
  end;


  if Result then
  begin
    Particles.Add(x, y, ExplosionSprite);
  end;

end;

{ TBombs }
constructor TBombs.Create();
begin

  Bombs    := TList<TBomb>.create;
  MaxCount := TGame.GetInstance.GameSettings.GetValue<TJSONObject>('BombSettings')
                                            .GetValue<Integer>('MaxCount');
  Range    := TGame.GetInstance.GameSettings.GetValue<TJSONObject>('BombSettings')
                                            .GetValue<Integer>('FireRange');
  Timer    := TGame.GetInstance.GameSettings.GetValue<TJSONObject>('BombSettings')
                                            .GetValue<Integer>('Timer');
end;


procedure TBombs.Add(x: Integer; y: Integer);
begin
  if (Bombs.Count >= MaxCount)
  and (TGame.GetInstance.Character.PowerUp <> TPowerups.MULTIBOMB) then Exit;
  Bombs.Add(TBomb.Create(x, y, Timer, 1, Range, 1));
end;

procedure TBombs.Update();
var
  Bomb :TBomb;
  Exploded :TList<TBomb>;
begin
  Exploded := TList<TBomb>.create;
  for Bomb in Bombs do
  begin
    Bomb.Particles.Add(Bomb.PosX, Bomb.PosY, Bomb.BombSprite);
    Bomb.Timer   := Bomb.Timer - 1;
    if Bomb.Timer <= 0 then begin
      Bomb.explode();
      Exploded.Add(Bomb);
    end;
  end;
  for Bomb in Exploded do
    Bombs.Remove(Bomb);
  Exploded.Free;
end;

function TBombs.Count(): Integer;
begin
  Result := Bombs.Count;
end;

end.
