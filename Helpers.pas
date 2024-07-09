unit Helpers;

interface
 uses
  System.SysUtils, System.Classes;


function  ReadFromFile(const FileName: string): String;
procedure LoadStringListFromFile(const FileName: string; var StringList: TStringList);

implementation

function ReadFromFile(const FileName: string): String;
var
  FileStream      :TFileStream;
  StringStream    :TStringStream;
begin
  FileStream    := TFileStream.Create(FileName, fmOpenRead);
  StringStream  := TStringStream.Create;
  try
    StringStream.CopyFrom(FileStream, FileStream.Size);
    StringStream.Position := 0;
    Result := StringStream.DataString;
  finally
    FileStream.Free;
    StringStream.Free;
  end;
end;

procedure LoadStringListFromFile(const FileName: string; var StringList: TStringList);
var
  FileStream    :TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  StringList.LoadFromStream(FileStream);

  FileStream.free;
end;

procedure StrToCharArray(const str: string; var arr: array of char);
var
  c: char;
begin
//  for c in str do
//    arr
//

end;


end.
