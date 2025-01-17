unit Game;

interface

uses
  Screen, Character, Tiles, GameObject, Helpers, Enums, Bomb, Bombs, ParticleEffects,
  Monster, TypInfo, System.Variants, System.Rtti,
  System.JSON, System.Generics.Collections, System.Classes, System.SysUtils,
  Vcl.Dialogs;

type
  TGame =  class(TObject)

  private
    FState              :TGAmeState;
    class var FInstance :TGame;
    constructor Create(aScreen :TStrings);
    procedure SetState(State :TGameState);
    function  GetState() :TGameState;

  public
    GameSettings    :TJSONObject;
    Theme           :TJSONObject;

    Screen          :TStrings;
    ScreenBuffer    :TScreenBuffer;
    Bombs           :TBombs;
    Monsters        :TList<TMonster>;
    Particles       :TParticleEffectMotor;

    KeyState        :TKeys;
    IsUpdated       :Boolean;
    PowerUp         :TPowerups;

    MapCount        :Integer;
    CurrentLevel    :Integer;

    GameObjects     :TBuffer<TGameObject>;
    Character       :TCharacter;
    ExitX, ExitY    :Integer;


    class function GetInstance(aScreen :TStrings): TGame; overload;
    class function GetInstance(): TGame; overload;
    procedure LoadGame;
    procedure LoadGameTheme;
    procedure LoadObject(x, y :Integer);

    procedure SetKeyState(Key: TKeys);
    procedure Update(Key: word);
    procedure UpdateLogic();
    function  GetSpriteOf(GameObject :TGameObject) :char;

    procedure DrawWelcomeScreen();
    procedure DrawLoseScreen();
    procedure DrawNextMapScreen();
    procedure DrawWinScreen();
    procedure DrawGame();

    property  State :TGameState read GetState write SetState;

  private
      SettingsFile   :String;
      MapFile        :String;
  end;

implementation

{ TGame }
constructor TGame.Create(aScreen :TStrings);
begin
  inherited create;
  SettingsFile := '..\..\..\GameSettings.json';
  GameSettings  := TJSONObject.ParseJSONValue(ReadFromFile(SettingsFile)) as TJSONObject;
  MapCount     := 2;
  CurrentLevel := 1;
  KeyState     := TKeys.NOKEY;
  Screen       := aScreen;
  State        := TGameState.WELCOME;
  TPowerUp.PowerUpRate  := GameSettings.GetValue<Integer>('PowerUpRate');
  TPowerUp.PowerUpTimer := GameSettings.GetValue<Integer>('PowerUpTimer');

  LoadGameTheme();
  Update(0);
end;

class function TGame.GetInstance(aScreen :TStrings): TGame;
begin
  if not assigned(FInstance) then
      FInstance := TGame.Create(aScreen);
  result := FInstance;
end;

class function TGame.GetInstance: TGame;
begin
  if not assigned(FInstance) then
      FInstance := TGame.Create(TStrings.Create);
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
  MapFile       := Format('..\..\..\Maps\map%d.txt', [CurrentLevel]);
  StringList    := TStringList.Create;
  LoadStringListFromFile(MapFile, StringList);


  YSize         := StringList.Count;
  XSize         := StringList[0].Length;

  if Assigned(ScreenBuffer) then ScreenBuffer.Free;
  if Assigned(GameObjects)  then GameObjects.Free;
  if Assigned(Particles)    then Particles.Free;
  if Assigned(Bombs)        then Bombs.Free;
  if Assigned(Monsters)      then Monsters.Free;


  ScreenBuffer := TScreenBuffer.Create(Ysize, XSize);
  GameObjects  := TBuffer<TGameObject>.Create(YSize, XSize);
  Particles    := TParticleEffectMotor.Create;
  Bombs        := TBombs.Create();
  Monsters     := TList<TMonster>.create;

  //Set GameObject Properties
  TGameObject.Screen      := ScreenBuffer;
  TGameObject.GameObjects := GameObjects;
  TGameObject.Particles   := Particles;

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

procedure TGame.Update(Key: word);
begin
  while True do Begin
    case State of

      WELCOME: begin
        if IsUpdated then begin
          CurrentLevel := 1;
          State := TGameState.PLAY;
          LoadGame();
          DrawGame();
        end
        else DrawWelcomeScreen();
        Break;
      end;

      PLAY:    begin
        SetKeyState(TKeysGetKey(key));
        if KeyState = TKeys.NOKEY then Exit;
        UpdateLogic();
        DrawGame();
        If State <> NEXTMAP then Exit;
      end;

      LOSE:    begin
        if IsUpdated then State := TGameState.WELCOME
        else begin
           DrawLoseScreen();
           Break;
        end;
      end;

      NEXTMAP: begin
        if IsUpdated then begin
         State := TGameState.PLAY;
         LoadGame();
         DrawGame();
         Break;
        end
        else begin
          if MapCount <= CurrentLevel then
          begin
            State := TGameState.WIN;
          end
          else begin
            CurrentLevel := CurrentLevel + 1;
            DrawNextMapScreen();
            Break;
          end;
        end;
      end;

      WIN:     begin
        if IsUpdated then State := TGameState.WELCOME
        else begin
          DrawWinScreen();
          Break;
        end;
      end;
    end;
  end;

  IsUpdated := True;
end;

procedure TGame.UpdateLogic();
var
  Monster :TMonster;
begin
  Character.Update(KeyState);
  Bombs.Update;
  for Monster in Monsters do
    Monster.Update();
//  Monsters.Update;
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
  else if c = Theme.GetValue<char>('Enemy') then begin obj := TMonster.Create(x,y);
                                                 Monsters.Add((obj as TMonster)) end
  else if c = Theme.GetValue<char>('Exit')  then begin
   obj := TExit.Create(x,y);
   ExitX := x;
   ExitY := y;
  end
  else if c = Theme.GetValue<char>('Hero') then
    begin
      Character := TCharacter.Create(x,y, GameSettings.GetValue<Integer>('CharacterHealth'));
      obj := Character;
    end
  else obj := TEmpty.GetInstance;

  GameObjects[y, x] := obj;
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
  else if cName = 'TPowerUp'   then Result := (GameObject as TPowerUp).Sprite
  else if cName = 'TMonster'   then Result := (GameObject as TMonster).Sprite
  else begin
    ShowMessage('GetSpriteOf failed cName is: ' + cName + '<<<<');
    raise Exception.Create('Unknown object type');
  end;
end;


procedure TGame.LoadGameTheme();
begin
  Theme                 := GameSettings.GetValue<TJSONObject>('Theme');
  TWall.Sprite          := Theme.GetValue<char>('Wall');
  TSand.Sprite          := Theme.GetValue<char>('Sand');
  TExit.Sprite          := Theme.GetValue<char>('Exit');
  TEmpty.Sprite	        := Theme.GetValue<char>('Empty');
  TMonster.Sprite       := Theme.GetValue<char>('Enemy');
  TCharacter.Sprite     := Theme.GetValue<char>('Hero');
  TBomb.BombSprite      := Theme.GetValue<char>('Bomb');
  TBomb.ExplosionSprite := Theme.GetValue<char>('Fire');
  TPowerUp.Sprite       := Theme.GetValue<char>('PowerUp');
end;

procedure TGame.SetState(State :TGameState);
begin
  FState    := State;
  IsUpdated := False;
end;

function TGame.GetState(): TGameState;
begin
  Result := FState;
end;

procedure TGame.DrawWelcomeScreen();
begin
  Screen.Clear;
  Screen.AddStrings([
  '######################################',
  '######################################',
  '### Welcome to the Bomberman Game! ###',
  '####### Press SPACE to Play ##########',
  '######################################',
  '######################################']);
end;

procedure TGame.DrawLoseScreen();
begin
  Screen.Clear;
  Screen.AddStrings([
  '######################################',
  '######################################',
  '#### BOOOOO!!!                    ####',
  '#### You have been failed  :((((  ####',
  '#### Press any key to play again  ####',
  '######################################']);
end;

procedure TGame.DrawNextMapScreen();
begin
  Screen.Clear;
  Screen.AddStrings([
  '######################################',
  '######################################',
  '####### Congratulations!!!    ########',
  '####### Press any key to Play ########',
  '############# Level: '+(CurrentLevel).ToString+'  ##############',
  '######################################']);
end;

procedure TGame.DrawWinScreen();
begin
  Screen.Clear;
  Screen.AddStrings([
  '######################################',
  '######################################',
  '####### Congratulations!!!    ########',
  '####### You have finished the game ###',
  '######################################',
  '######################################']);
end;

procedure TGame.DrawGame();
var
  x, y    :Integer;
  obj     :TGameObject;
  PowerUp :String;
begin
  Screen.Clear;
  for y := 0 to ScreenBuffer.RowCount - 1 do
  for x := 0 to ScreenBuffer.ColumnCount - 1 do
       ScreenBuffer[y, x] := GetSpriteOf(GameObjects[y, x]);

  Particles.DrawParticles(ScreenBuffer);

  ScreenBuffer.UpdateScreen(Screen);

  //logs
  Screen.Add(FORMAT('Moves: %d/%s ', [Character.Health,
    GameSettings.GetValue<string>('CharacterHealth')]));
  Screen.Add(FORMAT('Bombs: %d/%d ', [Bombs.Count, Bombs.MaxCount]));

  if      Character.PowerUp = TPowerups.RUN         then PowerUp := 'Run'
  else if Character.PowerUp = TPowerups.SKATEBOARD  then PowerUp := 'SkateBoard'
  else if Character.PowerUp = TPowerups.NONE        then PowerUp := 'None'
  else if Character.PowerUp = TPowerups.POWERFIST   then PowerUp := 'POWERFIST'
  else if Character.PowerUp = TPowerups.MULTIBOMB   then PowerUp := 'MULTIBOMB'
  else if Character.PowerUp = TPowerups.SHIELD      then PowerUp := 'Shield';

  Screen.Add(FORMAT('PowerUp: %s Steps: %d ', [PowerUp,  Character.PowerUpTimer]));
end;

end.
