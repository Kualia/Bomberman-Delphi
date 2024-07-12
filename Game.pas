unit Game;

interface

uses
  Screen, Character, Tiles, GameObject, Helpers, Enums, Bomb, Bombs, ParticleEffects,
  TypInfo, System.Variants, System.Rtti,
  System.JSON, System.Generics.Collections, System.Classes, System.SysUtils,
  Vcl.Dialogs;

type
  TGame =  class(TObject)

  private
    class var FInstance: TGame;
    constructor Create;
  public
    GameSettings    :TJSONObject;
    Theme           :TJSONObject;

    ScreenBuffer    :TScreenBuffer;
    GameObjects     :TBuffer<TGameObject>;
    Bombs           :TBombs;
    Particles       :TParticleEffectMotor;

    Character       :TCharacter;
    KeyState        :TKeys;

    class function GetInstance: TGame;
    procedure LoadGame;
    procedure LoadObject(x, y :Integer);

    procedure SetKeyState(Key: TKeys);
    procedure Update(screen: Tstrings; Key: word); overload;
    procedure UpdateUI(screen :TStrings);
    procedure UpdateLogic();
    function  IsMovable(x, y :integer) :Boolean;
    function  GetSpriteOf(GameObject :TGameObject) :char;

  private
      SettingsFile   :String;
      MapFile        :String;
  end;

implementation
    //

{ TGame }

constructor TGame.Create;
begin
  inherited create;
  SettingsFile := '..\..\..\GameSettings.json';
  MapFile      := '..\..\..\map.txt';
  KeyState     := TKeys.NOKEY;

end;

class function TGame.GetInstance: TGame;
begin
  if not assigned(FInstance) then
      FInstance := TGame.Create;
  result := FInstance;
end;

procedure TGame.LoadGame;
var
  StringList    :TStringList;

  FileStream    :TFileStream;
  x,y           :Integer;
  iChar         :Char;
  YSize, XSize  :Integer;
begin
  // Load map
  StringList    := TStringList.Create;
  LoadStringListFromFile(MapFile, StringList);

  YSize         := StringList.Count;
  XSize         := StringList[0].Length;

  if Assigned(ScreenBuffer) then ScreenBuffer.Free;
  if Assigned(GameObjects)  then GameObjects.Free;
  if Assigned(Particles)    then Particles.Free;

  ScreenBuffer := TScreenBuffer.Create(Ysize, XSize);
  GameObjects  := TBuffer<TGameObject>.Create(YSize, XSize);
  Particles    := TParticleEffectMotor.Create;


  //settings and theme
  if not Assigned(GameSettings) then
  begin
    GameSettings  := TJSONObject.ParseJSONValue(ReadFromFile(SettingsFile)) as TJSONObject;
    Theme         := GameSettings.GetValue<TJSONObject>('Theme');

    TWall.Sprite          := Theme.GetValue<char>('Wall');
    TSand.Sprite          := Theme.GetValue<char>('Sand');
    TExit.Sprite          := Theme.GetValue<char>('Exit');
    TEmpty.Sprite	        := Theme.GetValue<char>('Empty');
    TCharacter.Sprite     := Theme.GetValue<char>('Hero');
    TBomb.BombSprite      := Theme.GetValue<char>('Bomb');
    TBomb.ExplosionSprite := Theme.GetValue<char>('Fire');
    //TEnemy.Sprite := Theme.GetValue<char>('Fire');

    //static settings
    TGameObject.Screen      := ScreenBuffer;
    TGameObject.GameObjects := GameObjects;
    TGameObject.Particles   := Particles;
  end;

  if Assigned(Bombs) then Bombs.Free;
  Bombs := TBombs.Create();

  // Load Objects
  for y := 0 to ysize-1 do
    for x := 0 to xsize-1 do
    begin
        ScreenBuffer[y, x] := StringList[y][x+1];
        LoadObject(x, y);
    end;
end;

procedure TGame.SetKeyState(Key: TKeys);
begin
  KeyState := Key;
end;

procedure TGame.Update(screen: Tstrings; Key: word);
begin
  SetKeyState(TKeysGetKey(key));
  UpdateLogic();
  UpdateUI(screen);
end;

procedure TGame.UpdateUI(Screen :TStrings);
var
  x, y    :Integer;
  obj     :TGameObject;
begin

  for y := 0 to ScreenBuffer.RowCount - 1 do
      for x := 0 to ScreenBuffer.ColumnCount - 1 do
           ScreenBuffer[y, x] := GetSpriteOf(GameObjects[y, x]);

  Particles.DrawParticles(ScreenBuffer);

  //draw
  ScreenBuffer.UpdateScreen(Screen);

  //Log
  Screen.Add('Moves: ' + Character.Health.ToString
  +'/'+GameSettings.GetValue<string>('CharacterHealth'));
end;

procedure TGame.UpdateLogic();
begin
  if KeyState = TKeys.NOKEY then Exit;
  Character.Update(KeyState);
  Bombs.Update;
end;

procedure TGame.LoadObject(x, y :Integer);
var
  c     :char;
  obj   :TGameObject;
begin
  c := ScreenBuffer[y,x];
       if c = Theme.GetValue<char>('Empty')     then obj := TEmpty.GetInstance
  else if c = Theme.GetValue<char>('Wall')      then obj := TWall.Create(x,y)
  else if c = Theme.GetValue<char>('Sand')      then obj := TSand.Create(x,y)
  else if c = Theme.GetValue<char>('Exit')      then obj := TExit.Create(x,y)
  else if c = Theme.GetValue<char>('Hero') then
    begin
      Character := TCharacter.Create(x,y, 200);
      obj := Character;
    end
  else obj := TEmpty.GetInstance;

  GameObjects[y, x] := obj;
end;

function  TGame.isMovable(x, y :integer) :Boolean;
var
  Target      :char;
begin
  Result := False;
  if (x < 0) or (x > ScreenBuffer.ColumnCount-1)
  or (y < 0) or (Y > ScreenBuffer.RowCount-1) then Exit;

  Target := ScreenBuffer[y, x];

  if Target in [TWall.Sprite, TSand.Sprite] then Exit;

  Result := True;
end;


function TGame.GetSpriteOf(GameObject :TGameObject) :char;
var
  cName :string;
begin
  cName := GameObject.ClassName;

       if cName = 'TWall'      then Result := (GameObject as TWall).Sprite
  else if cName = 'TSand'      then Result := (GameObject as TSand).Sprite
  else if cName = 'TEmpty'     then Result := (GameObject as TEmpty).Sprite
  else if cName = 'TCharacter' then Result := (GameObject as TCharacter).Sprite
  else if cName = 'TExit'      then Result := (GameObject as TExit).Sprite
  // bomb
  // enemy
  else begin
    ShowMessage('GetSpriteOf failed cName is: ' + cName);
    raise Exception.Create('Unknown object type');
  end;
                      //
//  ShowMessage('Getspriteof :' +Result);

end;

end.
