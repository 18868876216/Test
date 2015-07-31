unit uStockDayTrans;

interface

uses
  SysUtils, Windows, Classes;

implementation

uses
  IniFiles, StrUtils,
  uFactory, uTools, uDBFReader;

{$REGION'  fkStockDay '}

type
  TStockDayTrans = class(TDataTrans)
  private
    FDate: String;
    procedure TrasnDataDBF(const DBF: TFileName; const ADest: TStream; const ADate, ASC, Header: String);
    procedure TransDataSpecial(const ADest: TStream);
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); override;
    procedure TransData(const ASrc, ADest: TStream); override;
  public
    function GetDBFPath: String;
  end;

function TStockDayTrans.GetDBFPath: String;
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

class function TStockDayTrans.SupportedFileKind: TFileKindSet;
begin
  result := [fkStockDay];
end;

procedure TStockDayTrans.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: String);
begin
  FDate := Param;
  inherited;
end;

procedure TStockDayTrans.TransData(const ASrc, ADest: TStream);
var
  FPath, FFile: String;
begin
  FPath := GetDBFPath();
  /// 深圳
  FFile := FPath + '\VSATDX\SJSHQ.DBF';
  TrasnDataDBF(FFile, ADest, 'HQZQJC', 'SZ', 'HQZQDM,HQJRKP,HQZGCJ,HQZDCJ,HQZJCJ,HQCJSL,HQCJJE');
  /// 上海
  FFile := FPath + '\REMOTE\DBF\SHOW2003.DBF';
  TrasnDataDBF(FFile, ADest, 'S6', 'SH', 'S1,S4,S6,S7,S8,S11,S5');

  /// 特殊行情
  TransDataSpecial(ADest);
end;

procedure TStockDayTrans.TransDataSpecial(const ADest: TStream);
const
  BASE_VALUE = 1000;
type
  PCodes = ^TCodes;
  TCodes = record
    Code, CodeEx: String;
    Value: Integer;
  end;

  function InitParam(const AList: TList): String;
  const
    INI_FILE = '\Param\Quota.ini';
    INI_COMM = 'Comm';
    INI_COMM_SLEEP = 'Sleep';
    INI_COMM_URL = 'Url';
    INI_CODES = 'Codes';
  var
    FIni: TIniFile;
    FTmp: TStrings;
    S: String;
    FCode: PCodes;
  begin
    FIni := TIniFile.Create(GetCurrPath + INI_FILE);
    FTmp := TStringList.Create;
    try
      Result := FIni.ReadString(INI_COMM, INI_COMM_URL, '');
      FIni.ReadSection(INI_CODES, FTmp);
      for S in FTmp do
      begin
        New(FCode);
        FCode.Code := S;
        FCode.CodeEx := FIni.ReadString(INI_CODES, S, '');
        FCode.Value := 0;
        AList.Add(FCode);
      end;
    finally
      FTmp.Free;
      FIni.Free;
    end;
  end;
  procedure Trans(const Data: String; const Codes: TList);

    function GetStr(const StartPos: Integer; const S, StrBegin, StrEnd: String): String;
    var
      FPos, FPosEx: Integer;
    begin
      FPos := PosEx(StrBegin, S, StartPos) + Length(StrBegin);
      FPosEx := PosEx(StrEnd, S, FPos);
      Result := Copy(S, FPos, FPosEx - FPos);
    end;
    function GetDate(const StartPos: Integer): String;
    const
      S_IDX = '"base_nav_dt":"';
      S_IDX_END = '"';
    begin
      Result := GetStr(StartPos, Data, S_IDX, S_IDX_END);
      Result := StringReplace(Result, '-', '', [rfReplaceAll]);
    end;
    function GetValue(const StartPos: Integer): String;
    const
      S_IDX = '"idx_incr_rt":"';
      S_IDX_END = '%';
    var
      FValue: Currency;
    begin
      Result := GetStr(StartPos, Data, S_IDX, S_IDX_END);
      FValue := StrToCurrDef(Result, 1);
      Result := Format('%.2f', [BASE_VALUE * FValue]);
    end;
  const
    S_BASE = '"base_fund_id":"%s"';
    S_SC = 'ZI';
  var
    FCode: PCodes;
    S, FValue: String;
    FPos: Integer;
    FList: TStrings;
  begin
    if Length(Data) > Length(S_BASE) then
    begin
      FList := TStringList.Create;
      try
        for FCode in Codes do
        begin
          S := Format(S_BASE, [FCode.Code]);
          FPos := PosEx(S, Data, 1);
          if FPos <> 0 then
          begin
            FList.Clear;
            FList.Add(GetDate(FPos));
            FList.Add(S_SC);
            FList.Add(S_SC + FCode.CodeEx);
            FValue := GetValue(FPos);
            FList.Add(FValue);
            FList.Add(FValue);
            FList.Add(FValue);
            FList.Add(FValue);
            FList.Add('0');
            FList.Add('0');

            Write(ADest, FList);
          end;
        end;
      finally
        FList.Free;
      end;
    end;  
  end;
var
  FUrl: String;
  FCodes: TList;
begin
  FCodes := TList.Create();
  try
    FUrl := InitParam(FCodes);
    Trans(SockGet(FUrl), FCodes);
  finally
    FCodes.Free;
  end;
end;

procedure TStockDayTrans.TrasnDataDBF(const DBF: TFileName; const ADest: TStream;
  const ADate, ASC, Header: String);
var
  FDBF: TDBFReader;
  FPtr: Pointer;
  FList, FHeader: TStringList;
  FDate: String;
  I: Integer;
begin
  FDBF := TDBFReader.Create(DBF);
  FList := TStringList.Create;
  FHeader := TStringList.Create;
  try
    FHeader.CommaText := Header;

    FDate := FDBF.FieldByName(0, ADate);
    FDBF.Delete(0);

    for FPtr in FDBF do
    begin
      FList.Clear;
      FList.Add(FDate);
      FList.Add(ASC);
      FList.Add(ASC + FDBF.FieldByName(FPtr, FHeader[0]));
      for I := 1 to FHeader.Count - 1 do
        FList.Add(FDBF.FieldByName(FPtr, FHeader[I]));

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
  TStockDayTrans.Register;
  
end.

