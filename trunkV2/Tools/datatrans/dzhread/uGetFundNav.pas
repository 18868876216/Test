unit uGetFundNav;

interface

uses
  SysUtils, ADODB, Windows, Classes, Controls, Math, Forms, PerlRegEx,
  Dialogs, IniFiles, IdMessageClient, uHtmlFileTrans;

type
  TGetData = class(THtmlFileTrans)
  public
    class procedure TransDataWeb(AList: TStrings);
    class procedure TransDataDBF(AList: TStrings);
    class procedure TransDataFuGuo(AList: TStrings);
    class procedure TransDataJinYing(AList: TStrings);
    class procedure TransDataNuoDe(AList: TStrings);
    class procedure TransDataGuoTai(AList: TStrings);
    class procedure TransDataXingYe(AList: TStrings);
    class procedure TransDataYinHua(AList: TStrings);
    class procedure TransDataPengHua(AList: TStrings);
    class procedure TransDataZhongOu(AList: TStrings);
    class procedure TransDataShenWan(AList: TStrings);
    class procedure TransDataGongYin(AList: TStrings);
    class procedure TransDataXinCheng(AList: TStrings);
    class procedure TransDataZhaoShang(AList: TStrings);
    class procedure TransDataChangSheng(AList: TStrings);
    class procedure TransDataHuaShang(AList: TStrings);
    class procedure TransDataGuoLianAn(AList: TStrings);
    class procedure TransDataGuangFa(AList: TStrings);
    class procedure TransDataGuoJin(AList: TStrings);
    class procedure TransDataHuiTianFu(AList: TStrings);
    class procedure TransDataYiFangDa(AList: TStrings);
    class procedure TransDataGuoTuRuiYin(AList: TStrings);
    class procedure TransDataTaiDaHongLi(AList: TStrings);
    class procedure TransDataXinHua(AList: TStrings);
    class procedure TransDataJianXin(AList: TStrings);
    class procedure TransDataZheShang(AList: TStrings);
    class procedure TransDataDongWu(AList: TStrings);
    class procedure TransDataJiaShi(AList: TStrings);
    class procedure TransDataNanFang(AList: TStrings);
    class procedure TransDataHuaAn(AList: TStrings);
    class procedure TransDataYinHe(AList: TStrings);
    class procedure TransDataWanJia(AList: TStrings);
    class procedure TransDatafund123(AList: TStrings);
    class procedure TransDataifund(AList: TStrings);
    class procedure TransDatastockstar(AList: TStrings);
    class procedure TransDataHeXun(AList: TStrings);
    class procedure TransDataJRJ(AList: TStrings);
    class procedure TransDataSJSXXN(AList: TStrings);
    class procedure TransShLof(AList: TStrings);
  protected

  end;

implementation

uses
  DateUtils, StrUtils, ActiveX,
  WinInet, uDBFReader, uTools;

const S_MARKET = 'OF';

class procedure TGetData.TransDataDBF(AList: TStrings);
begin
{$REGION'  SJSXXN.DBF  '}
  try
    TransDataSJSXXN(AList);
  except on E: Exception do
  end;
  try
    TransShLof(AList);
  except on E: Exception do
  end;
{$ENDREGION}
end;

class procedure TGetData.TransDataWeb(AList: TStrings);
begin

{$REGION'  JianXin Fund  '}
 try
    TransDataJianXin(AList);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION'   XinHua Fund  '}
  try
    TransDataXinHua(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  ShenWanLingxin Fund  '}
  try
    TransDataShenWan(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  JinYing Fund  '}
  try
    TransDataJinYing(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   GuoTai Fund  '}
  try
    TransDataGuoTai(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  GuoLianAn Fund  '}
  try
    TransDataGuoLianAn(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   YinHua Fund  '}
  try
    TransDataYinHua(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  YiFangDa  Fund  '}
 try
    TransDataYiFangDa(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION' HuaShang Fund  '}
  try
    TransDataHuaShang(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  ZhongOu Fund  '}
  try
    TransDataZhongOu(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   NuoDe Fund   '}
  try
    TransDataNuoDe(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   XingYe Fund  '}
  try
    TransDataXingYe(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   YinHe Fund   '}
  try
    TransDataYinHe(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   HuaAn Fund   '}
  try
    TransDataHuaAn(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   FuGuo Fund   '}
  try
    TransDataFuGuo(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   JiaShi Fund  '}
  try
    TransDataJiaShi(AList);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION'   DongWu Fund  '}
  try
    TransDataDongWu(AList);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION'  WanJia Fund   '}
  try
    TransDataWanJia(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  PengHua Fund  '}
 try
    TransDataPengHua(AList);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION'  GuangFa Fund  '}
 try
    TransDataGuangFa(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  GongYin Fund  '}
  try
    TransDataGongYin(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  NanFang Fund  '}
  try
    TransDataNanFang(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION' ZheShang Fund  '}
  try
    TransDataZheShang(AList);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION' XinCheng Fund  '}
  try
    TransDataXinCheng(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  ZhaoShang Fund  '}
  try
    TransDataZhaoShang(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  ChangSheng Fund '}
  try
    TransDataChangSheng(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  HuiTianFu Fund  '}
  try
    TransDataHuiTianFu(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  GuoTuRuiYin Fund  '}
  try
    TransDataGuoTuRuiYin(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  TaiDaHongLi Fund  '}
  try
    TransDataTaiDaHongLi(AList);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  GuoJinTongYong Fund  '}
  try
    TransDataGuoJin(AList);
  except on E: Exception do
  end;
{$ENDREGION}

end;

class procedure TGetData.TransDataSJSXXN(AList: TStrings);

  function GetDBFPath: String;
  var
    FFile: TIniFile;
  begin
    FFile := TIniFile.Create(GetCurrPath + '\Param\dbfpathinf.ini');
    try
      Result := FFile.Readstring('dbfpath','path','');
      Result := IncludeTrailingPathDelimiter(Result);
    finally
      FFile.Free;
    end;
  end;

  procedure TrasnDataDBF(const DBF: TDBFReader; AList: TStrings;  const ADate, ASC, Header: String);
  var
    FPtr: Pointer;
    FHeader: TStringList;
    dqrq,rq,dm,jz: String;
  begin
    FHeader := TStringList.Create;
    try
      FHeader.CommaText := Header;
      dqrq := DBF.FieldByName(0, ADate); //当前日期
      rq := GetInfFromDB('SELECT ytbase.dbo.GetPrecJYDay('+dqrq+')');
      for FPtr in DBF do
      begin
        dm := DBF.FieldByName(FPtr, FHeader[0]);
        jz := DBF.FieldByName(FPtr, FHeader[1]);
        jz := stringreplace(jz,' ','',[rfreplaceall]);
        if ((pos('15',dm)=1) or (pos('16',dm)=1) or (pos('18',dm)=1)) and (strtofloat(jz) <> 0) then
        begin
          AList.Add(rq+','+dm+','+jz+',1');
        end;
      end;
    finally
      FHeader.Free;
    end;
  end;

  procedure TrasnDataSZ(const AFile: TFileName; AList: TStrings);
  var
    FDBF: TDBFReader;
  begin
    FDBF := TDBFReader.Create(AFile);
    try
      TrasnDataDBF(FDBF,AList,'XXZQJC','OF','XXZQDM,XXSNLR');
    finally
      FDBF.Free;
    end;
  end;

var
  FPath, FFile: String;
begin
  FPath := GetDBFPath();
  //深交所数据库
  FFile := FPath + 'VSATDX\SJSXXN.DBF';
  TrasnDataSZ(FFile, AList);
end;

class procedure TGetData.TransShLof(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
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

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 3;
    IDX_CODE = 1;
    IDX_NAV = 4;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
      FNav := currtostrf(FCurr,ffFixed,4);
      FDate := ADestContent[IDX_DATE];
      FDate := stringreplace(FDate,'-','',[rfreplaceall]);
      FCode := ADestContent[IDX_CODE];
      AList.Add(FDate+','+FCode+','+FNav+',1');
      end;
    end;
  end;
const
  url='http://www.sse.com.cn/assortment/fund/fjlof/netvalue/';
var
  FData: String;
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
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
    reg.free;
  end;
end;

class procedure TGetData.TransDataifund(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  var
  FData: String;
  reg: TPerlRegEx;
  begin
  Result := TStringList.Create;
  FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
  FData := stringreplace(FData,#9,'',[rfreplaceall]);
  FData := stringreplace(FData,' ','',[rfreplaceall]);
  reg := TPerlRegEx.Create(nil);
  reg.Subject := FData;
  reg.RegEx := '{"code.*?}';
  while reg.MatchAgain do
  begin
    Result.Add(reg.MatchedExpression);
  end;
  reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > 20) then
    begin
      ADestContent.NameValueSeparator := ':';
      FNav := ADestContent.Values['net'];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent.Values['SYENDDATE'];
        FDate := stringreplace(FDate,'-','',[rfreplaceall]);
        FCode := ADestContent.Values['{code'];
        AList.Add(FDate+','+FCode+','+FNav+',5');
      end;
    end;
  end;

const
  url='http://fund.ijijin.cn/data/Net/info/all_rate_desc_0_0_1_9999_0_0_0_jsonp_g.html';
var
  FData,S: String;
  FList, FContant: TStrings;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S:= FData;
      S:=stringreplace(S,'"','',[rfreplaceall]);
      FContant.CommaText := S;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataHeXun(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  const
    S_BEGIN = '{';
    S_END = '}';
  var
    FPosBegin, FPosEnd, FLen: Integer;
    FData: String;
  begin
    Result := TStringList.Create;
    FPosBegin := 1;
    FPosEnd := 1;
    while (FPosBegin > 0) and (FPosEnd > 0) do
    begin
      FPosBegin := PosEx(S_BEGIN, AData, FPosEnd + 1);
      if FPosBegin > 0 then
      begin
        FPosEnd := PosEx(S_END, AData, FPosBegin + 1);
        FLen := FPosEnd - FPosBegin - 1;
        if FLen > 0 then
        begin
          FData := Copy(AData, FPosBegin + 1, FLen);
          FData := Stringreplace(FData,'"','',[rfreplaceall]);
          Result.Add(FData);
        end;
      end;
    end;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    FDate := GetInfFromDB('SELECT ytbase.dbo.GetPrecTradeDay()');
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > 10) then
    begin
      ADestContent.NameValueSeparator := ':';
      FNav := ADestContent.Values['tNet'];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FCode := ADestContent.Values['fundCode'];
        AList.Add(FDate+','+FCode+','+FNav+',5');
      end;
    end;
  end;
var
  FData: String;
  FList, FContant: TStrings;
begin
  FData := SockGet('http://jingzhi.funds.hexun.com/jz/JsonData/kaifangjingz.aspx?callback=callback');
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      FContant.CommaText := FData;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDatafund123(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  const
    S_BEGIN = '[';
    S_END = ']';
  var
    FPosBegin, FPosEnd, FLen: Integer;
    FData: String;
  begin
    Result := TStringList.Create;
    FPosBegin := 1;
    FPosEnd := 1;
    while (FPosBegin > 0) and (FPosEnd > 0) do
    begin
      FPosBegin := PosEx(S_BEGIN, AData, FPosEnd + 1);
      if FPosBegin > 0 then
      begin
        FPosEnd := PosEx(S_END, AData, FPosBegin + 1);
        FLen := FPosEnd - FPosBegin - 1;
        if FLen > 0 then
        begin
          FData := Copy(AData, FPosBegin + 1, FLen);
          Result.Add(FData);
        end;
      end;
    end;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 16;
    IDX_CODE = 0;
    IDX_NAV = 2;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      FNav := StringReplace(FNav, '''', '', [rfReplaceAll]);
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '''', '', [rfReplaceAll]);
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);

        FCode := ADestContent[IDX_CODE];
        FCode := StringReplace(FCode, '''', '', [rfReplaceAll]);

        AList.Add(FDate+','+FCode+','+FNav+',3');
      end;
    end;
  end;

var
  FData: String;
  FList, FContant: TStrings;
begin
  FData := SockGet('http://hqqd.fund123.cn/netvalues.js');
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      FContant.CommaText := FData;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDatastockstar(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  const
    S_BEGIN = '{';
    S_END = '}';
  var
    FPosBegin, FPosEnd, FLen: Integer;
    FData: String;
  begin
    Result := TStringList.Create;
    FPosBegin := 1;
    FPosEnd := 1;
    while (FPosBegin > 0) and (FPosEnd > 0) do
    begin
      FPosBegin := PosEx(S_BEGIN, AData, FPosEnd + 1);
      if FPosBegin > 0 then
      begin
        FPosEnd := PosEx(S_END, AData, FPosBegin + 1);
        FLen := FPosEnd - FPosBegin - 1;
        if FLen > 0 then
        begin
          FData := Copy(AData, FPosBegin + 1, FLen);
          Result.Add(FData);
        end;
      end;
    end;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > 20) then
    begin
      ADestContent.NameValueSeparator := ':';
      FNav := ADestContent.Values['price'];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent.Values['last_chg_dt'];
        FDate := stringreplace(FDate,'-','',[rfreplaceall]);
        FCode := ADestContent.Values['id'];

        AList.Add(FDate+','+FCode+','+FNav+',6');
      end;
    end;
  end;

var
  FData: String;
  FList, FContant: TStrings;
begin
  FData := UTF8Decode(SockGet('http://www.jisilu.cn/data/sfnew/fundm_list/?___t=1437093672328'));
  FData := stringreplace(FData,'"','',[rfreplaceall]);
  FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
  FData := stringreplace(FData,#9,'',[rfreplaceall]);
  FData := stringreplace(FData,' ','',[rfreplaceall]);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      FContant.CommaText := FData;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataJRJ(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  const
    S_BEGIN = '[';
    S_END = ']';
  var
    FPosBegin, FPosEnd, FLen: Integer;
    FData: String;
  begin
    Result := TStringList.Create;
    FPosBegin := 1;
    FPosEnd := 1;
    while (FPosBegin > 0) and (FPosEnd > 0) do
    begin
      FPosBegin := PosEx(S_BEGIN, AData, FPosEnd + 1);
      if FPosBegin > 0 then
      begin
        FPosEnd := PosEx(S_END, AData, FPosBegin + 1);
        FLen := FPosEnd - FPosBegin - 1;
        if FLen > 0 then
        begin
          FData := Copy(AData, FPosBegin + 1, FLen);
          Result.Add(FData);
        end;
      end;
    end;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_CODE = 0;
    IDX_NAV = 7;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_NAV) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := GetInfFromDB('SELECT ytbase.dbo.GetPrecTradeDay()');
        FCode := ADestContent[IDX_CODE];
        FCode := StringReplace(FCode, '''', '', [rfReplaceAll]);
        FCode := StringReplace(FCode, '[', '', [rfReplaceAll]);
        AList.Add(FDate+','+FCode+','+FNav+',4');
      end;
    end;
  end;

var
  FData: String;
  FList, FContant: TStrings;
begin
  FData := SockGet('http://qf.jrjimg.cn/fund/netvalue/list/open_all.js');
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      FContant.CommaText := FData;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataFuGuo(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
   Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
      FNav := currtostrf(FCurr,ffFixed,4);
      FDate := intToStr(Yearof(dateof(now)))+ADestContent[IDX_DATE];
      FDate := stringreplace(FDate,'-','',[rfreplaceall]);
      FCode := ADestContent[IDX_CODE];
      AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData, S: String;
  FList, FContant: TStrings;
  reg:TPerlRegEx;
begin
  FData := UTF8Decode(SockGet('http://www.fullgoal.com.cn/funds/index.html'));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      if pos('富国',FData)>0 then
        S := GetStr(FData,'title="','">富国')
      else
        S := '500015';
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S + reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataNuoDe(AList: TStrings);

  function DataToList(const AData: String):TStrings;
    var
    FData:String;
    reg:TPerlRegEx;
    begin
      Result := TStringList.Create;
      FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
      FData := stringreplace(FData,#9,'',[rfreplaceall]);
      FData := stringreplace(FData,' ','',[rfreplaceall]);
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<tdwidth.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
    end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 3;
    IDX_CODE = 1;
    IDX_NAV = 4;
  var
    FDate,FCode,FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
      FNav := currtostrf(FCurr,ffFixed,4);
      FDate := '20'+ADestContent[IDX_DATE];
      FDate := stringreplace(FDate,'-','',[rfreplaceall]);
      FCode := ADestContent[IDX_CODE];
      AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData: String;
  FList, FContant: TStrings;
  reg:TPerlRegEx;
begin
  FData := SockGet('http://www.lordabbettchina.com/main/index.shtml');
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject:=FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataGuoTai(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData:String;
    reg:TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := intToStr(Yearof(dateof(now)))+ADestContent[IDX_DATE];
        FDate := stringreplace(FDate,'-','',[rfreplaceall]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData, S: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet('http://www.gtfund.com/product/productlist/index.html'));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'title="','"class');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S + reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataXingYe(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,'开放式基金','货币型基金');
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_CODE = 2;
    IDX_NAV = 5;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_NAV) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := GetInfFromDB('SELECT ytbase.dbo.GetPrecTradeDay()');
        FCode := ADestContent[IDX_CODE];
        FCode := stringreplace(FCode,'(','',[rfreplaceall]);
        FCode := stringreplace(FCode,')','',[rfreplaceall]);
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet('http://www.xyfunds.com.cn/column.do?mode=searchtopic&channelid=2');
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex :=',+';
      reg.replacement :=',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataZhongOu(AList: TStrings);

  function DataToList(const AData:String):TStrings;
  var
    FData:String;
    reg:TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    FData := stringreplace(FData,'*','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tdalign.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_CODE = 0;
    IDX_NAV = 2;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_NAV) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := GetInfFromDB('SELECT ytbase.dbo.GetPrecTradeDay()');
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData,S: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8DeCode(SockGet('http://www.lcfunds.com/'));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := 'title=".*?"';
      while reg.MatchAgain do
      begin
        S := reg.MatchedExpression;
        S := stringreplace(S,'title=','',[rfreplaceall]);
        S := stringreplace(S,'"','',[rfreplaceall]);
      end;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataYinHua(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  var
    FData: string;
    reg: TPerlRegEx;
  begin
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    Result := TStringList.Create;
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><tdclass.*?</tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_NAV) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := stringreplace(FDate,'-','',[rfreplaceall]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.yhfund.com.cn/main/qxjj/index.shtml';
var
  FData, S: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'qxjj/','/fndFacts');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S + reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataPengHua(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,'<!-- 股票型 -->','<!-- 短期理财 -->')+GetStr(AData,'<!-- 指数型 -->','<!-- 封闭式 -->');
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := 'fundcode.*?</tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := intToStr(Yearof(dateof(now)))+ADestContent[IDX_DATE];
        FDate := stringreplace(FDate,'/','',[rfreplaceall]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData,S: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet('http://www.phfund.com.cn/main_new/index.shtml');
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'fundcode=','" ');
      if  AnsiContainsStr(FData,'鹏华资源A') then   S:='150100';
      if  AnsiContainsStr(FData,'鹏华资源B') then   S:='150101';
      if  AnsiContainsStr(FData,'鹏华丰泽A') then   S:='160619';
      if  AnsiContainsStr(FData,'鹏华丰泽B') then   S:='150061';
      if  AnsiContainsStr(FData,'鹏华丰利债A') then   S:='160623';
      if  AnsiContainsStr(FData,'鹏华丰利债B') then   S:='150129';
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '">.*?</td>';
      while reg.MatchAgain do
      begin
        S := S+','+GetStr(reg.MatchedExpression,'>','</td>');
      end;
      reg.free;
      FContant.CommaText := S;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataShenWan(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData:String;
    reg:TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td>.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 6;
    IDX_CODE = 1;
    IDX_NAV = 7;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet('http://www.swsmu.com/index.html'));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataGongYin(AList: TStrings);

  function DataToList(const AData:String):TStrings;
  const
    BEGIN1 = '股票型基金开始';
    END1   = '债券型基金结束';
    BEGIN2 = '指数基金开始';
    END2   = '短期理财基金开始';
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,BEGIN1,END1)+GetStr(AData,BEGIN2,END2);
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 6;
    IDX_CODE = 1;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.icbccs.com.cn/cif/MainCtrl?page=IndexFunddayPage';
var
  FData : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataXinCheng(AList: TStrings);

  function DataToList(const AData:String):TStrings;
  const
    BEGIN1 = '全部基金';
    END1   = '基金首页列表模板（全部）';
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,BEGIN1,END1);
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 10;
    IDX_CODE = 3;
    IDX_NAV = 11;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.citicprufunds.com.cn/funds_2012/fund.shtml';
var
  FData : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataZhaoShang(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  const
    BEGIN1 = '全部理财产品';
    END1   = '七日年化收益率';
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,BEGIN1,END1);
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 4;
    IDX_CODE = 0;
    IDX_NAV = 5;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.cmfchina.com/main/index/qxjj/index.shtml';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'/main/','/fundinfo');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataChangSheng(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  const
    BEGIN1 = '混合型基金';
    END1   = '货币型基金';
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,BEGIN1,END1);
    FData := stringreplace(FData,#10,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,'*','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td class.*?</td><tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 5;
    IDX_CODE = 0;
    IDX_NAV = 2;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := intToStr(Yearof(dateof(now)))+ADestContent[IDX_DATE];
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.csfunds.com.cn/d2s/';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'jjjz','" name');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataHuaShang(AList: TStrings);

  function DataToList(const AData:String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_CODE = 2;
    IDX_DATE = 3;
    IDX_NAV = 4;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_NAV) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := stringreplace(FDate,'-','',[rfreplaceall]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8DeCode(SockGet('http://www.hsfund.com/product/index.shtml?id=6102'));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataHuiTianFu(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData:String;
    reg:TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,'股票型 start','指数型结束');
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    FData := stringreplace(FData,'<p>','<',[rfreplaceall]);
    FData := stringreplace(FData,'</p>','>',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tdwidth="7%">.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_CODE =1;
    IDX_DATE =3;
    IDX_NAV =4;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_NAV) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := stringreplace(FDate,'-','',[rfreplaceall]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

var
  FData: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet('http://www.99fund.com/main/products/jijinhb/index.shtml');
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataGuoLianAn(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 6;
    IDX_CODE = 0;
    IDX_NAV = 2;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FCode := ADestContent[IDX_CODE];
        FDate := intToStr(Yearof(dateof(now)))+ADestContent[IDX_DATE];
        if Pos('/',FDate) > 0 then
        begin
          FDate := StringReplace(FDate, '/', '', [rfReplaceAll]);
          AList.Add(FDate+','+FCode+','+FNav+',2');
        end
        else
          Exit;
      end;
    end;
  end;

const
  url='http://www.gtja-allianz.com/index.shtml';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'product/','/index');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S + reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataGuangFa(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    Result := TStringList.Create;
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '{.*?}';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 1;
    IDX_CODE = 2;
    IDX_NAV = 8;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      ADestContent.NameValueSeparator := ':';
      FNav := ADestContent.Values['netValue'];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent.Values['endDate'];
        FDate := stringreplace(FDate,'-','',[rfreplaceall]);
        FDate := stringreplace(FDate,'T00:00:00','',[rfreplaceall]);
        FCode := ADestContent.Values['fundCode'];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.gffunds.com.cn/funddaily/findNetValue.jsp?type=';
var
  FData : String;
  FList, FContant: TStrings;
  i: integer;
begin
  for i := 1 to 5 do
  begin
    FData:=FData+UTF8Decode(SockGet(url+inttostr(i)));
  end;
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      FContant.CommaText := stringreplace(FData,'"','',[rfreplaceall]);
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataGuoJin(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringlist.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr class.*?</tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.Free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := stringreplace(FDate,'-','',[rfreplaceall]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url = 'http://www.gfund.com/';
  CodeIndex : array[0..7] of string = ('000749','762001','000453','000454','000455','150140','150141','167601');
  NameIndex : array[0..7] of string = ('fund/1387','fund/762001','<td>国金通用鑫利分级</td>','fund/553','fund/704','fund/705','fund/706','fund/469');
var
  FData : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
  I: integer;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    reg := TPerlRegEx.Create(nil);
    for FData in FList do
    begin
      for I := 0 to 7 do
      begin
        if AnsiContainsStr(FData,NameIndex[I]) then
        begin
          reg.Subject := CodeIndex[I]+','+FData;
          reg.RegEx := '<.*?>';
          reg.Replacement := ',';
          reg.ReplaceAll;
          reg.regex := ',+';
          reg.replacement := ',';
          reg.replaceall;
          FContant.CommaText:= reg.Subject;
          SolveFundNavInfo(AList, FContant);
        end;
      end;
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataYiFangDa(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringlist.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#13,'',[rfreplaceall]);
    FData := stringreplace(FData,#10,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<trclass="news_c">.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.Free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 3;
    IDX_CODE = 2;
    IDX_NAV = 4;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := stringreplace(ADestContent[IDX_DATE],'-','',[rfreplaceall]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url = 'http://www.efunds.com.cn/html/menu/1.htm';
var
  FData: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataGuoTuRuiYin(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  const
    S_BEGIN = '{';
    S_END = '}';
  var
    FPosBegin, FPosEnd, FLen: Integer;
    FData: String;
  begin
    Result := TStringList.Create;
    FPosBegin := 1;
    FPosEnd := 1;
    while (FPosBegin > 0) and (FPosEnd > 0) do
    begin
      FPosBegin := PosEx(S_BEGIN, AData, FPosEnd + 1);
      if FPosBegin > 0 then
      begin
        FPosEnd := PosEx(S_END, AData, FPosBegin + 1);
        FLen := FPosEnd - FPosBegin - 1;
        if FLen > 0 then
        begin
          FData := Copy(AData, FPosBegin + 1, FLen);
          FData := Stringreplace(FData,'"','',[rfreplaceall]);
          Result.Add(FData);
        end;
      end;
    end;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > 25) then
    begin
      ADestContent.NameValueSeparator := ':';
      FNav := ADestContent.Values['nav'];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent.Values['settledate'];
        FCode := ADestContent.Values['fundid'];
        AList.Add(FDate+','+FCode+','+FNav+',5');
      end;
    end;
  end;

const
  url = 'http://2015.ubssdic.com/main/jjcp/index.shtml';
var
  FData: String;
  FList, FContant: TStrings;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      FContant.CommaText := FData;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataTaiDaHongLi(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
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

   procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 3;
    IDX_CODE = 1;
    IDX_NAV = 4;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.mfcteda.com/Channel/4332';
var
  FData : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataXinHua(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData:String;
    reg:TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td>.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 3;
    IDX_CODE = 2;
    IDX_NAV = 4;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := StringReplace(ADestContent[IDX_DATE], '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.ncfund.com.cn/main/index.shtml';
var
  FData : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataJianXin(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<td>.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FDate := StringReplace(FDate, '/', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.ccbfund.cn/jxjj/index/new/index.jsp';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      S := GetStr(FData,'wjmlurl=','">');
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataZheShang(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
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

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 3;
    IDX_CODE = 0;
    IDX_NAV = 4;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := intToStr(Yearof(dateof(now)))+ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '/', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.zsfund.com/QXJJMAIN.do?mode=searchtopic&channelid=2';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      if   AnsiContainsStr(FData,'浙商聚潮产业成长股票') then   S:='688888';
      if   AnsiContainsStr(FData,'浙商聚潮新思维混合')   then   S:='166801';
      if   AnsiContainsStr(FData,'浙商沪深300指数分级')  then   S:='166802';
      if   AnsiContainsStr(FData,'浙商进取')             then   S:='150077';
      if   AnsiContainsStr(FData,'浙商稳健')             then   S:='150076';
      if   AnsiContainsStr(FData,'浙商聚盈信用债债券C')  then   S:='686869';
      if   AnsiContainsStr(FData,'浙商聚盈信用债债券A')  then   S:='686868';
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataDongWu(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<td >.*?</tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 3;
    IDX_CODE = 1;
    IDX_NAV = 4;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.scfund.com.cn/flagfund_2011/index.shtml?m=jjcp';
var
  FData : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := stringreplace(FData,' ','',[rfreplaceall]);
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataJiaShi(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,'股票型开始','封闭式结束');
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tdstyle=.*?</tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.jsfund.cn/Services/cn/jsp/product/DetailList.jsp';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'NavHistory.jsp?SiteID=1&FundCode=','"target');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataJinYing(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tdwidth.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 0;
    IDX_CODE = 1;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FDate := StringReplace(FDate, '"', '', [rfReplaceAll]);
        FDate := StringReplace(FDate, '>', '', [rfReplaceAll]);
        FDate := StringReplace(FDate, 'title=', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.gefund.com.cn/main/product/gefund/index.shtml';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := 'title=.*?>';
      while reg.MatchAgain do
        S := reg.MatchedExpression;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataNanFang(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    FData := GetStr(FData,'股票型</td>','货币基金</th>');
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><tdalign.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.nffund.com/FundServlet.java?action=searchsyl';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'fundcode=','&index');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataHuaAn(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr><td.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 4;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := StringReplace(ADestContent[IDX_CODE], '''', '', [rfReplaceAll]);
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.huaan.com.cn/supermarket/index.shtml';
var
  FData,S : String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'viewFund(',')">');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataYinHe(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<tr>.*?</td></tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 5;
    IDX_CODE = 1;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='https://www.galaxyasset.com/etrade/index.html';
var
  FData: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := SockGet(url);
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      reg:= TPerlRegEx.Create(nil);
      reg.Subject:=FData;
      reg.RegEx:='<.*?>';
      reg.Replacement:=',';
      reg.ReplaceAll;
      reg.regex:=',+';
      reg.replacement:=',';
      reg.replaceall;
      FContant.CommaText:= reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

class procedure TGetData.TransDataWanJia(AList: TStrings);

  function DataToList(const AData: String):TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := stringreplace(AData,slinebreak,'',[rfreplaceall]);
    FData := stringreplace(FData,#9,'',[rfreplaceall]);
    FData := stringreplace(FData,' ','',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<span><strong>.*?</dd>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 2;
    IDX_CODE = 0;
    IDX_NAV = 3;
  var
    FDate, FCode, FNav: String;
    FCurr: Currency;
  begin
    if Assigned(AList) and Assigned(ADestContent) and (ADestContent.Count > IDX_DATE) then
    begin
      FNav := ADestContent[IDX_NAV];
      if TryStrToCurr(FNav, FCurr) and (FCurr > 0) then
      begin
        FNav := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FDate := StringReplace(FDate, '-', '', [rfReplaceAll]);
        FCode := ADestContent[IDX_CODE];
        AList.Add(FDate+','+FCode+','+FNav+',2');
      end;
    end;
  end;

const
  url='http://www.wjasset.com/';
var
  FData,S: String;
  FList, FContant: TStrings;
  reg: TPerlRegEx;
begin
  FData := UTF8Decode(SockGet(url));
  FList := DataToList(FData);
  FContant := TStringList.Create;
  try
    for FData in FList do
    begin
      S := GetStr(FData,'title="','">');
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<.*?>';
      reg.Replacement := ',';
      reg.ReplaceAll;
      reg.regex := ',+';
      reg.replacement := ',';
      reg.replaceall;
      FContant.CommaText := S+reg.Subject;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;

end;

end.
