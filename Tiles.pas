unit Tiles;

interface

uses
  BaseClasses;

type
  TTile = class(TGameObject)
    Class var
      Sprite :char
  end;

  TWall  = class(TTile)
    Class var
      Sprite: char;
  end;

  TSand  = class(TTile)
    Class var
      Sprite: char;
  end;

  TExit  = class(TTile)
    Class var
      Sprite: char;
  end;


implementation

end.
