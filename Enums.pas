unit Enums;

interface

type
  TDirection = (UP, DOWN, RIGHT, LEFT);
  TKeys = (NOKEY, UPKEY, DOWNKEY, RIGHTKEY, LEFTKEY, BOMBKEY);
  TGameState = (WELCOME, PLAY, LOSE, NEXTMAP, WIN);
  TPowerups = (NONE, RUN, SKATEBOARD, POWERFIST, MULTIBOMB, SHIELD);
  function TKeysGetKey(Key :Word): TKeys;
implementation

function TKeysGetKey(Key :Word): TKeys;
begin
  case Key of
    87: Result  := TKeys.UPKEY;
    83: Result  := TKeys.DOWNKEY;
    65: Result  := TKeys.LEFTKEY;
    68: Result  := TKeys.RIGHTKEY;
    32: Result  := TKeys.BOMBKEY;
    else Result := TKeys.NOKEY;
  end;
end;


end.
