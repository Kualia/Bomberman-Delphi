unit Tiles;

interface

uses
  GameObject;

type
  TTile = class(TGameObject)
    Class var
      Sprite :char
  end;

  TEmpty = class(TTile)
    private
      constructor create;

    public
      Class function GetInstance(): TEmpty;
      Class var
        FInstance :TEmpty;
        Sprite    :char;
  end;

  TWall  = class(TTile)
    s : char;
    public
    constructor create(x, y :Integer);
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

  TPowerUp = class(TTile)
    class var
      Sprite: char;
  end;

implementation

{ TEmpty }

constructor TEmpty.Create;
begin
  inherited create;
end;

class function TEmpty.GetInstance: TEmpty;
begin
  if not assigned(FInstance) then
    FInstance := TEmpty.Create;

  result := FInstance;
end;

constructor TWall.Create(x, y :Integer);
begin
  inherited create(x, y);
  s := 'i';
end;





end.
