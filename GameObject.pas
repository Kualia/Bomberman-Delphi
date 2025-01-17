unit GameObject;
interface

uses
  Screen, Enums, Vcl.Dialogs, ParticleEffects, System.SysUtils;

type
  TGameObject = class(TObject)
    PosX    :Integer;
    PosY    :Integer;
    public
      constructor Create(x, y :Integer); overload;
      constructor Create(); overload;
      procedure   Move(Direction :TDirection; Speed :Integer = 1);
      procedure   MoveTo(x, y: Integer);

      class var  Sprite       :Char;
      class var  Screen       :TScreenBuffer;
      class var  GameObjects  :TBuffer<TGameObject>;
      class var  Particles    :TParticleEffectMotor;
  end;

implementation

{ TGameObject }
constructor TGameObject.Create();
begin
  Create(0, 0);
end;

constructor TGameObject.Create(x, y :Integer);
begin
  PosX := x;
  PosY := y;
end;

procedure TGameObject.Move(Direction :TDirection; Speed :Integer = 1);
begin
  case Direction of
    TDirection.UP:    PosY := PosY - Speed;
    TDirection.DOWN:  PosY := PosY + Speed;
    TDirection.LEFT:  PosX := PosX - Speed;
    TDirection.RIGHT: PosX := PosX + Speed;
  end;
end;

procedure TGameObject.MoveTo(x, y: Integer);
begin
  PosY := y;
  PosX := x;
end;


end.
