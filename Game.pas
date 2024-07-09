unit Game;

interface

uses
  Screen, Character, Tiles,
  BaseClasses, Helpers,
  System.JSON, System.Generics.Collections, System.Classes, System.SysUtils,
  Vcl.Dialogs;

type
  TGame =  class(TObject)

  private
    class var FInstance: TGame;
    constructor Create;
  public
    GameSettings    :TJSONObject;
    Theme           :TDictionary<String, Char>;

    ScreenBuffer    :TScreenBuffer;

    Xsize           :Integer;
    Ysize           :Integer;

//  Character       :TCharacter;
    ObjectList      :TObjectList<TGameObject>;

    GameObjets      :TGameObjectMap;

    KeyState        :TKeys;

    class function GetInstance: TGame;
    procedure LoadGame;
    procedure LoadObject(x, y :Integer);

    procedure SetKeyState(Key: word);
    procedure Update(screen: Tstrings; Key: word); overload;
    procedure UpdateUI(screen :TStrings);
    procedure UpdateLogic();
    function  isMovable(x, y :integer) :Boolean;
  private
      SettingsFile   :String;
      MapFile        :String;
  end;


implementation


{ TGame }

constructor TGame.Create;
begin
  inherited create;
  SettingsFile := '..\..\..\GameSettings.json';
  MapFile      := '..\..\..\map.txt';
  KeyState     := TKeys.NOKEY;
  LoadGame();
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
  innerArr      :array of char;
begin
  //settings
  GameSettings  := TJSONObject.ParseJSONValue(ReadFromFile(SettingsFile)) as TJSONObject;
  ObjectList    := TObjectList<TGameObject>.Create;
  Theme         := TDictionary<String, Char>.Create;

  Theme.Add('Wall', '#');
  Theme.Add('Empty', ' ');
  Theme.Add('Sand', '-');
  Theme.Add('Hero', 'C');
  Theme.Add('Bomb', '@');
  Theme.Add('Fire', 'X');
  Theme.Add('Exit', '%');
  Theme.Add('Enemy', 'E');

  TWall.Sprite := Theme.Items['Wall'];
  TSand.Sprite := Theme.Items['Sand'];
  TExit.Sprite := Theme.Items['Exit'];


  ShowMessage('TWall sprite: ' + TWall.Sprite);
  ShowMessage('TSand sprite: ' + TSand.Sprite);
  ShowMessage('TExit sprite: ' + TExit.Sprite);

  // Load map
  StringList    :=TStringList.Create;
  LoadStringListFromFile(MapFile, StringList);

  YSize         :=StringList.Count;
  XSize         :=StringList[0].Length;

  // Set ScreenBuffer
  ScreenBuffer := TScreenBuffer.Create(Ysize, XSize);

  // Load Objects
  for y := 0 to ysize-1 do
    for x := 0 to xsize-1 do
    begin
      iChar := StringList[y][x+1];
      ScreenBuffer[y, x] := iChar;
      LoadObject(x, y);
    end;
end;

procedure TGame.SetKeyState(Key: word);
begin
 case Key of
    87: KeyState := TKeys.UPKEY;
    83: KeyState := TKeys.DOWNKEY;
    65: KeyState := TKeys.LEFTKEY;
    68: KeyState := TKeys.RIGHTKEY;
    else KeyState := TKeys.NOKEY;
  end;

end;

procedure TGame.Update(screen: Tstrings; Key: word);
begin
  SetKeyState(Key);
  UpdateLogic();
  UpdateUI(screen);
end;

procedure TGame.UpdateUI(screen :TStrings);
begin
  ScreenBuffer.UpdateScreen(Screen);
end;

procedure TGame.UpdateLogic();
var
  iObject   :TGameObject;
  tC
begin
  if KeyState = TKeys.NOKEY then Exit;

  for iObject in ObjectList do
    iObject.Update(KeyState);

  for tCharacter in ObjectList do
    tC
      ;


end;

procedure TGame.LoadObject(x, y :Integer);
begin
  case ScreenBuffer[y,x] of
    '#' : ObjectList.add(TWall.Create(x,y));
    '-' : ObjectList.add(TSand.Create(x,y));
    'C' : ObjectList.add(TCharacter.Create(x,y, GameSettings.GetValue<Integer>('CharacterHealth')));
    '%' : ObjectList.add(TExit.Create(x,y));
    ' ' : Exit;
  end;
end;

function  TGame.isMovable(x, y :integer) :Boolean;
var
  Target      :char;
begin
  Target := ScreenBuffer[y, x];
end;

end.
