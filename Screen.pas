unit Screen;

interface

uses
  vcl.Dialogs, System.SysUtils,
  System.Classes, BaseClasses;

type
  TBuffer<T> = class
    private
      Data          :array of array of T;
    public
      RowCount      :Integer;
      ColumnCount   :Integer;
      constructor Create(Rows, Cols :Integer);

      procedure SetSize(Rows, Cols :Integer);
      procedure Fill(Element :T);
      function  GetElement(Row, Col :Integer): T;
      procedure SetElement(Row, Col :Integer; Value :T);
      property  Elements[Row, Col: Integer]: T read GetElement write SetElement; default;
  end;

  TScreenBuffer = class(TBuffer<char>)
    public
      procedure _SetElement(Row, Col: Integer; Value :char); overload;
      procedure GetRow(Row: Integer; var strLine: string);
      procedure UpdateScreen(Screen :TStrings);
  end;

  TGameObjectMap = class(TBuffer<TGameObject>)

  end;

implementation

{ TBuffer }
constructor TBuffer<T>.Create(Rows, Cols :Integer);
begin
  SetSize(Rows, Cols);
end;

procedure TBuffer<T>.SetSize(Rows, Cols :Integer);
begin
  ColumnCount   := Cols;
  RowCount      := Rows;
  SetLength(Data, Rows, Cols);
end;

procedure TBuffer<T>.Fill(Element :T);
var
  x,y           :integer;
begin
  for y := 0 to ColumnCount-1 do
    for x := 0 to RowCount-1 do
      Data[y][x] := Element;
end;

function  TBuffer<T>.GetElement(Row, Col :Integer): T;
begin
  result := Data[Row][Col];
end;

procedure TBuffer<T>.SetElement(Row, Col :Integer; Value :T);
begin
  Data[Row][Col] := Value;
end;

{ TScreenBuffer }

procedure TScreenBuffer._SetElement(Row, Col: Integer; Value: Char);
begin
  if (Row < 0) or (Row >= RowCount) or (Col < 0) or (Col >= ColumnCount) then exit;
  inherited SetElement(Row, Col, Value);
end;

procedure TScreenBuffer.GetRow(Row: Integer; var strLine: string);
begin
    SetString(strLine, PChar(@Data[Row][0]), ColumnCount);
end;

procedure TScreenBuffer.UpdateScreen(Screen :TStrings);
var
  strLine :String;
  i       :integer;
begin
  Screen.Clear;
  for i := 0 to RowCount-1 do
  begin
    GetRow(i, strLine);
    screen.Add(strLine);
  end;
end;

end.