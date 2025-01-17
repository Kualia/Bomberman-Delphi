unit Dynamic2DArr;

interface

uses
  System.SysUtils,
  System.Classes;

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

end.
