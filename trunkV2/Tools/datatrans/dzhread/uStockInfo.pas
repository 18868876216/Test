unit uStockInfo;

interface

uses
  SysUtils, Windows, Classes, uFactory;

type
  TStockInfoEx = class(TDataTrans)
  private
    FDate: String;
    procedure TrasnDataDBF(const DBF: TFileName; const ADest: TStream; const ASC, Header: String);
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); override;
    procedure TransData(const ASrc, ADest: TStream); override;
  public
    function GetDBFPath: String;
  end;

implementation

uses
  IniFiles,
  uTools, uDBFReader;

{$REGION'  fkStockInfoEx '}

function TStockInfoEx.GetDBFPath: String;
var
  FFile: TIniFile;
begin
  FFile := TIniFile.Create(GetCurrPath + '\Param\dbfpathinf.ini');
  try
    Result := FFile.Readstring('dbfpath','path','');
    Result := IncludeTrailingPathDelimiter(Result) + FDate;
  finally
    FFile.Free;
  end;
end;

class function TStockInfoEx.SupportedFileKind: TFileKindSet;
begin
  result := [fkStockInfoEx];
end;

procedure TStockInfoEx.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: String);
begin
  FDate := Param;
  inherited;
end;

procedure TStockInfoEx.TransData(const ASrc, ADest: TStream);
var
  FPath, FFile: String;
begin
  FPath := GetDBFPath();
  /// ����
  FFile := FPath + '\VSATDX\SJSXXN.DBF';
  TrasnDataDBF(FFile, ADest, 'SZ', 'XXZQDM,XXZQJC');
  /// �Ϻ�
  FFile := FPath + '\REMOTE\DBF\SHOW2003.DBF';
  TrasnDataDBF(FFile, ADest, 'SH', 'S1,S2');
end;

procedure TStockInfoEx.TrasnDataDBF(const DBF: TFileName; const ADest: TStream;
  const ASC, Header: String);
var
  dm: String;
  FDBF: TDBFReader;
  FPtr: Pointer;
  FList, FHeader: TStringList;
begin
  FDBF := TDBFReader.Create(DBF);
  FList := TStringList.Create;
  FHeader := TStringList.Create;
  try
    FHeader.CommaText := Header;
    FDBF.Delete(0);

    for FPtr in FDBF do
    begin
      FList.Clear;
      dm := FDBF.FieldByName(FPtr, FHeader[0]);
      if (pos('15',dm)=1) or (pos('16',dm)=1) or (pos('18',dm)=1) or (pos('502',dm)=1) then
        begin
          FList.Add('OF');
          FList.Add('OF' + dm);
        end
      else
        begin
          FList.Add(ASC);
          FList.Add(ASC + dm);
        end;
      FList.Add(FDBF.FieldByName(FPtr, FHeader[1]));
      Write(ADest, FList);
    end;
  finally
    FHeader.Free;
    FList.Free;
    FDBF.Free;
  end;
end;

{$ENDREGION}


initialization

  TStockInfoEx.Register;

end.
