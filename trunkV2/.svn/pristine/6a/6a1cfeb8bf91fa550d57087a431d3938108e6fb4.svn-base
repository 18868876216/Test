unit uGetShFundInfo;

interface

uses
  SysUtils, ADODB, Windows, Classes, Controls, Math, Forms, PerlRegEx,
  Dialogs, IniFiles, IdMessageClient, uHtmlFileTrans, uFactory;

type
  TGetShFundInfo = class(THtmlFileTrans)
  protected
    FDate: String;
    const S_MARKET = 'SH';
    class function SupportedFileKind(): TFileKindSet; override;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  end;

implementation

class function TGetShFundInfo.SupportedFileKind: TFileKindSet;
begin
  Result := [fkShFundInfo];
end;

procedure TGetShFundInfo.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: String);
begin
  FDate := Param;
  inherited;
end;

procedure TGetShFundInfo.TransData(const ASrc: TStrings; ADest: TStream);

  function DataToList(const AData: String): TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,'分级LOF场内规模统计','分拆合并统计');
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,',','',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td>.*?</td></tr>';
    while reg.MatchAgain do
      begin
        Result.Add(reg.MatchedExpression);
      end;
    reg.free;
  end;

  procedure SolveFundInfo(ADest: TStream; const ADestContent: TStrings);
  const
    IDX_DATE = 1;
    IDX_CODE = 2;
    IDX_NAME = 3;
    IDX_SIZE = 4;
  var
    FDate, FMarket, FCode, FName, FListingDate, FSize: String;
    FList: TStringlist;
    FCurr: Currency;
  begin
    FList := TStringlist.Create;
    if Assigned(ADest) and Assigned(ADestContent) and (ADestContent.Count > 4) then
    begin
      FSize := ADestContent[IDX_SIZE];
      if TryStrToCurr(FSize, FCurr) and (FCurr > 0) then
      begin
        FSize := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FMarket := S_MARKET;
        FCode := ADestContent[IDX_CODE];
        FName := ADestContent[IDX_NAME];
        FListingDate := '';                    //上市日期为空
        FList.CommaText := FDate+','+FMarket+','+FCode+','+FName+','+FListingDate+','+FSize;
        write(ADest,FList);
      end;
    end;
    FList.Free;
  end;

const
  url='http://www.sse.com.cn/assortment/fund/fjlof/scale/';
var

  FStream: TFileStream;
  FData, FFile, S: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := Utf8Decode(SockGet(url));
  FList := DataToList(FData);
  reg:= TPerlRegEx.Create(nil);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg.Subject:=FData;
      reg.RegEx:='<.*?>';
      reg.Replacement:=',';
      reg.ReplaceAll;
      reg.regex:=',+';
      reg.replacement:=',';
      reg.replaceall;
      FContant.CommaText:= reg.Subject;
      SolveFundInfo(ADest, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
    reg.free;
  end;
  FFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'ShFundInfo';
  ForceDirectories(FFile);
  FFile := FFile + '\' + formatDateTime('YYYYMMDDHHMMSS', now) + '.txt';
  FStream := TFileStream.Create(FFile, fmCreate or fmOpenWrite);
  try
    FStream.Size := 0;
    ADest.Position := 0;
    FStream.CopyFrom(ADest, ADest.Size);
  finally
    FStream.Free;
  end;
end;

initialization

  TGetShFundInfo.Register;

end.
