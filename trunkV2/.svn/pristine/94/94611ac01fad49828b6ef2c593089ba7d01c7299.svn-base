{******************************************************************************}
{ @UnitName     : uTransEtfInfo.pas                                            }
{ @Project      : dzhRead                                                      }
{ @Copyright    : CM Tech Inc.                                                 }
{ @Author       : Budded                                                       }
{ @Description  : ETFÐÅÏ¢×ª»»                                                  }
{ @FileVersion  : 1.0.0.0                                                      }
{ @CreateDate   : 2013-06-27                                                   }
{ @Comment      :                                                              }
{ @LastUpdate   : Budded, 2013-06-27                                           }
{ @History      : Created By Budded, 2013-06-27 08:30                          }
{******************************************************************************}
unit uTransEtfInfo;

interface

uses
  SysUtils, Windows, Classes, StrUtils;

implementation

uses
  uFactory, uHtmlFileTrans, uTools;

type
  TDataType = (dtSH, dtSZ);

type
  TTransEtf = class(THtmlFileTrans)
  strict private
    FEtfPath, FDate: String;
    FDataList, FDataRow: TStrings;
  private
    function GetEtfPath(const AMarket: TDataType): String;
    function GetEtfFile(const AMarket: TDataType; const ACode: String): String;
  protected
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); override;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    property CurrDate: String read FDate;

    property DataList: TStrings read FDataList;
    property DataRow: TStrings read FDataRow;
  end;

const
  S_DATA_TYPE: array [TDataType] of String = ('SH', 'SZ');

{ TTransEtf }

procedure TTransEtf.AfterConstruction;
begin          
  FDataList := TStringList.Create;
  FDataRow := TStringList.Create;
  FDate := GetCurrDate;
  inherited;
end;

procedure TTransEtf.BeforeDestruction;
begin
  inherited;
  FDataList.Free;
  FDataRow.Free;
end;

function TTransEtf.GetEtfFile(const AMarket: TDataType;
  const ACode: String): String;
begin
  Result := Format('%s\%s.ETF', [GetEtfPath(AMarket), ACode]);
end;

function TTransEtf.GetEtfPath(const AMarket: TDataType): String;
begin
  Result := Format('%s\ETF\%s\%s', [GetCurrPath, FDate, S_DATA_TYPE[AMarket]]);
  ForceDirectories(Result);
end;

procedure TTransEtf.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: String);
begin
  if Length(Param) > 0 then
    FDate := Param;

  inherited;
end;

type
  TTransEtfInfo = class(TTransEtf)
  strict private
    FNeedDownload: Boolean;
  private
    function GetUrl(const AMarket: TDataType; const S: String): String;
    procedure TransData(const AMarket: TDataType; const ASrc: TStrings; ADest: TStream); overload;
    procedure TransDataUrl(const AUrl: String; const AMask: TDataType; ADest: TStream);
    procedure TransDataFile(const AFile: TStrings; const AMask: TDataType; ADest: TStream);
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  protected
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); override;
  end;

const
  URL_SH = 'http://query.sse.com.cn/etfDownload/downloadETF2Bulletin.do?etfType=%s';
  URL_SZ = 'http://www.szse.cn/szseWeb/common/szse/files/text/etfDown/%setf%s.txt';

  S_DATA_TYPE_URL: array [TDataType] of String = (URL_SH, URL_SZ);

{ TTransEtfInfo }

function TTransEtfInfo.GetUrl(const AMarket: TDataType;
  const S: String): String;
begin
  case AMarket of
    dtSH: Result := Format(URL_SH, [S]);
    dtSZ: Result := Format(URL_SZ, [S, CurrDate]);
  end;
end;

class function TTransEtfInfo.SupportedFileKind: TFileKindSet;
begin
  Result := [fkETFInfo];
end;

procedure TTransEtfInfo.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: String);
begin
  FNeedDownload := Length(Param) = 0;
  inherited;
end;

procedure TTransEtfInfo.TransData(const ASrc: TStrings; ADest: TStream);
var
  FList: TStrings;
  FType: TDataType;
  FFile, FFileName: String;
begin
  inherited;
  FList := TStringList.Create;
  try
    for FType in [Low(TDataType)..High(TDataType)] do
    begin
      if FNeedDownload then
      begin
        FList.CommaText := ASrc.Values[S_DATA_TYPE[FType]];
        TransData(FType, FList, ADest);
      end else begin
        FFile := S_DATA_TYPE[FType];
        if FType = dtSH then
          FFile := FFile + 'C';
        FList.CommaText := ASrc.Values[FFile];
        for FFile in FList do
        begin
          FFileName := GetEtfFile(FType, S_DATA_TYPE[FType] + FFile);
          if FileExists(FFileName) then
          begin
            DataList.LoadFromFile(FFileName);
            TransDataFile(DataList, FType, ADest);
          end;
        end;
      end;
    end;
  finally
    FList.Free;
  end;
end;

procedure TTransEtfInfo.TransData(const AMarket: TDataType;
  const ASrc: TStrings; ADest: TStream);
var
  S, FUrl: String;
begin
  for S in ASrc do
  begin
    FUrl := GetUrl(AMarket, S);
    TransDataUrl(FUrl, AMarket, ADest)
  end;
end;

const
  S_FUND_ID: array [TDataType] of String = ('Fundid1', 'FundID');
  S_RCD_NUM: array [TDataType] of String = ('RecordNum', 'TotalRecordNum');

procedure TTransEtfInfo.TransDataFile(const AFile: TStrings;
  const AMask: TDataType; ADest: TStream);
var
  FCode: String;
  FRecNum: String;
begin
  if (AFile.Count > 0) then
  begin
    FCode := S_DATA_TYPE[AMask] + AFile.Values[S_FUND_ID[AMask]];
    with DataRow do
    begin
      Clear;
      Add(CurrDate);
      Add(S_DATA_TYPE[AMask]);
      Add(FCode);
      Add(AFile.Values['CreationRedemptionUnit']);
      Add(AFile.Values['CashBalance']);
      Add(AFile.Values['MaxCashRatio']);

      FRecNum := AFile.Values[S_RCD_NUM[dtSH]];
      if Length(FRecNum) = 0 then 
        FRecNum := AFile.Values[S_RCD_NUM[dtSZ]];
      Add(FRecNum);

      Add(AFile.Values['TradingDay']);
      Add(AFile.Values['PreTradingDay']);
      Add(AFile.Values['NAV']);
      Add(AFile.Values['CashComponent']);
      Add(AFile.Values['NAVperCU']);
      Add(AFile.Values['Publish']);
    end;

    Write(ADest, DataRow);
  end;
end;

procedure TTransEtfInfo.TransDataUrl(const AUrl: String; const AMask: TDataType; ADest: TStream);
var
  FData, FFile, FHeader: String;
begin
  if SockGet(AUrl, FData) then
  begin
    DataList.Text := FData;
    if (DataList.Count > 0) and (FData[1] = '[') then
    begin
      FHeader := S_DATA_TYPE[AMask] + DataList.Values[S_FUND_ID[AMask]];
      DataList.SaveToFile(GetEtfFile(AMask, FHeader));
      TransDataFile(DataList, AMask, ADest);
    end;
  end;
end;

type
  TTransEtfComponent = class(TTransEtf)
  private
    function GetExch(const ACode: String): String;
    procedure TransDataFile(const S: String; const ADest: TStrings; const IsSimple: Boolean); overload;
    procedure TransDataFile(const AMask: TDataType; const ASrc: TStrings; ADest: TStream); overload;
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  end;

{ TTransEtfComponent }

function TTransEtfComponent.GetExch(const ACode: String): String;
begin
  Result := 'SH';
  if (Length(ACode) >= 1) and (ACode[1] in ['0', '3']) then
    Result := 'SZ';
end;

class function TTransEtfComponent.SupportedFileKind: TFileKindSet;
begin
  Result := [fkETFComponent];
end;

procedure TTransEtfComponent.TransData(const ASrc: TStrings; ADest: TStream);
var
  FList: TStrings;
  FPath, FFile: String;
  FType: TDataType;
begin
  inherited;
  FList := TStringList.Create;
  try
    for FType in [Low(TDataType)..High(TDataType)] do
    begin
      FList.Clear;
      FPath := GetEtfPath(FType);
      if FindFile(FList, FPath) > 0 then
        for FFile in FList do
        begin
          DataList.LoadFromFile(FFile);
          TransDataFile(FType, DataList, ADest);
        end;
    end;
  finally
    FList.Free;
  end;
end;

procedure TTransEtfComponent.TransDataFile(const S: String;
  const ADest: TStrings; const IsSimple: Boolean);
const
  I_SET = [1, 2, 3, 4, 5];
  I_SET_EX = [2, 3, 4, 5, 6];

var
  FData: TStringList;
  FSet: TIntegerSet;
  I, FC: Integer;
  FExch, FCode: String;
begin
  FData := TStringList.Create;
  try
    FData.Delimiter := '|';
    FData.DelimitedText := StringReplace(S, ' ', '', [rfReplaceAll]);

    if IsSimple then
    begin
      FSet := I_SET;
      FCode := FData[0];
    end else begin
      FSet := I_SET_EX;
      FCode := FData[1];
    end;
                
      FExch := GetExch(FCode);
    ADest.Add(FExch);
    ADest.Add(FExch + FCode);
    for I in FSet do
      ADest.Add(FData[I]);
  finally
    FData.Free;
  end;
end;

procedure TTransEtfComponent.TransDataFile(const AMask: TDataType;
  const ASrc: TStrings; ADest: TStream);
var
  FCode: String;
  FIsSimple: Boolean;
  FPos, FPosEx, FIdx: Integer;
begin
  FCode := S_DATA_TYPE[AMask] + ASrc.Values[S_FUND_ID[AMask]];

  FIsSimple := False;
  FPos := ASrc.IndexOf('[RECORDBEGIN]');
  if FPos <> -1 then
    FPosEx := ASrc.IndexOf('[RECORDEND]')
  else begin
    FPos := ASrc.IndexOf('TAGTAG');
    FPosEx := ASrc.IndexOf('ENDENDEND');
    FIsSimple := True;
  end;

  for FIdx := FPos + 1 to FPosEx - 1 do
  begin
    with DataRow do
    begin
      Clear;
      Add(CurrDate);
      Add(FCode);
      Add(S_DATA_TYPE[AMask]);
    end;
    TransDataFile(ASrc[FIdx], DataRow, FIsSimple);
    Write(ADest, DataRow);
  end;
end;

initialization
  TTransEtfInfo.Register;
  TTransEtfComponent.Register;

end.
