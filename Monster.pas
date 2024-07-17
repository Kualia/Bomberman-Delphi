unit Monster;

interface

uses
  Agent;

type
  TMonster = class(TAgent)
  constructor Create(X, Y :Integer);
    procedure Die();
    class var Sprite :char;
    procedure Update();
  end;

implementation

uses
  Enums, Character, Generics.Collections, Game;

  { TMonster }
constructor TMonster.Create(X, Y :Integer);
begin
  inherited Create(X, Y, 1, 1);
end;

procedure TMonster.Update();
var
  directions :TList<TDirection>;
  direction  :TDirection;
begin
   Directions := TList<TDirection>.create();

  if IsMovable(PosX+1, PosY) then Directions.Add(TDirection.RIGHT);
  if IsMovable(PosX-1, PosY) then Directions.Add(TDirection.LEFT);
  if IsMovable(PosX, PosY+1) then Directions.Add(TDirection.DOWN);
  if IsMovable(PosX, PosY-1) then Directions.Add(TDirection.UP);

  if 0 <= directions.Count then begin
    direction := Directions[Random(directions.Count)];
    Move(Direction);
  end;

  if LastTouched is TCharacter then (LastTouched as TCharacter).Die();
  Directions.Free;
end;

procedure TMonster.Die();
begin
  TGame.GetInstance.Monsters.Remove(Self);
  inherited Die();
end;

end.
