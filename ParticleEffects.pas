unit ParticleEffects;

interface

uses
  Screen, System.Generics.Collections, Vcl.Dialogs;
type
  TParticle = class(TObject)
     XPos, YPos :Integer;
     Sprite     :Char;
     public
      constructor create(x, y :Integer; aSprite :Char);
  end;

  TParticleEffectMotor = class(TObject)
    private
      Particles :TStack<TParticle>;
    public
      constructor Create;
      destructor Destroy;
      procedure  Add(Particle: TParticle); overload;
      procedure  Add(x,y :Integer; Sprite :Char); overload;
      procedure  DrawParticles(ScreenBuffer :TScreenBuffer);
  end;


implementation

constructor TParticle.Create(x, y :Integer; aSprite :Char);
begin
  XPos := x;
  YPos := y;
  Sprite := aSprite;
end;

constructor TParticleEffectMotor.Create;
begin
  Particles := TStack<TParticle>.Create;
end;

destructor TParticleEffectMotor.Destroy;
begin
  Particles.free;
end;

procedure TParticleEffectMotor.Add(Particle: TParticle);
begin
  Particles.push(Particle);
end;

procedure TParticleEffectMotor.Add(x,y :Integer; Sprite :Char);
begin
  Particles.push(TParticle.create(x, y, Sprite));
end;

procedure TParticleEffectMotor.DrawParticles(ScreenBuffer :TScreenBuffer);
var
  Particle :TParticle;
  I        :Integer;
begin
  for particle in particles do
  begin
    ScreenBuffer[Particle.YPos, Particle.XPos] := Particle.Sprite;
//    if Particle.Sprite = 'X' then ShowMessage('X');
    
    Particle.free;
  end;
  Particles.clear;
end;

end.
