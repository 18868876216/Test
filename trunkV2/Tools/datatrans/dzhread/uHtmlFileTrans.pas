unit uHtmlFileTrans;

interface

uses
  SysUtils, ADODB, Windows, Classes, Controls, Math, Forms, uFactory, PerlRegEx, Dialogs,
  IniFiles, IdMessageClient, IdSMTPBase, IdSMTP, IdMessage;

type
  THtmlFileTrans = class(TDataTrans)
  protected
    procedure TransData(const ASrc, ADest: TStream); overload; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); overload; virtual; abstract;
  public
    class function GetInfFromDB(SQL:String):String;
    class function GetStr(StrSource: string; StrBegin: string; StrEnd: string):String;
  end;

implementation

uses
  DateUtils, StrUtils, ActiveX,
  uTools, WinInet,uDBFReader;

{$REGION ' THtmlFileTrans impls '}
{ THtmlFileTrans }

procedure THtmlFileTrans.TransData(const ASrc, ADest: TStream);
var
  FStr: TStringList;
begin
  inherited;
  if Assigned(ASrc) and Assigned(ADest) then
  begin
    FStr := TStringList.Create;
    try
      FStr.LoadFromStream(ASrc); //LoadFromStream方法将Stream指定的流中的全部内容复制到MemoryStream中，复制过程将取代已有内容，使MemoryStream成为Stream的一份拷贝。
      TransData(FStr, ADest);
    finally
      FStr.Free;
    end;
  end;
end;

class function THtmlFileTrans.GetInfFromDB(SQL:String):String;
var
  ConnStr,SQLStr: String;
  ADOConnection1: TADOConnection;
  ADOQuery1: TADOQuery;
  FFile: TIniFile;
begin
 //动态配置数据源
  ConnStr := GetCurrPath + '\Param\dbpathinf.ini';
  FFile := TIniFile.Create(ConnStr);
  ConnStr := FFile.Readstring('dbpath','path','');
  ADOConnection1 := TADOConnection.Create(nil);
  ADOConnection1.LoginPrompt:=False;
  ADOConnection1.Close;
  ADOConnection1.ConnectionString :=ConnStr;
  ADOConnection1.Connected := true;

  ADOQuery1 := TADOQuery.Create(nil);
  ADOQuery1.Connection := ADOConnection1;
  SQLStr := SQL;
  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Add(SQLStr);
  ADOQuery1.Open;
  Result := trim(ADOQuery1.fields[0].asstring);//赋值给变量。
  ADOConnection1.Free;
  ADOQuery1.Free;
end;

class function THtmlFileTrans.GetStr(StrSource: string; StrBegin: string; StrEnd: string):string;
var
  star,over:integer;
begin
  star := AnsiPos(StrBegin,StrSource)+length(StrBegin);
  over := AnsiPos(StrEnd,StrSource);
  result := copy(StrSource,star,over-star);
end;

{$ENDREGION}

{$REGION ' THtmlFileTransEx '}
type
  THtmlFileTransEx = class(THtmlFileTrans)
  protected   
    class procedure DelFirstLine(const AFile: String);
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: string); override;
  end;

{ THtmlFileTransEx }

class procedure THtmlFileTransEx.DelFirstLine(const AFile: String);
var
  FStr: TStringList;
begin
  FStr := TStringList.Create;
  try
    FStr.LoadFromFile(AFile);  //
    if FStr.Count > 1 then
    begin
      FStr.Delete(1);
      FStr.SaveToFile(AFile);
    end;
  finally
    FStr.Free;
  end;
end;

procedure THtmlFileTransEx.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: string);
begin
  inherited;
  DelFirstLine(ADestFile);
end;
{$ENDREGION}

{$REGION ' fkShStopInfo '}
type
  THtmlFileSHStop = class(THtmlFileTransEx)
  private
    procedure ProcessInfo(const ASrc, ADest: TStrings; const ADate: String);
  protected     
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  end;  

{ THtmlFileSHStop }

procedure THtmlFileSHStop.ProcessInfo(const ASrc, ADest: TStrings; const ADate: String);
var
  sCode, sName, sTFPTime, sStopLength, sStopCause, sDate: string;
begin
  {
    rq	日期
    sc	市场
    dm	代码
    mc	名称
    tpzq	停牌状态     1:停牌 2:复牌 3:说明
    ksrq	开始日期
    jsrq	结束日期
    tpsj	停牌时间     1:全天 2:1小时
    tpyy	停牌原因

  }
//  if lst.count = 0 then
//    exit;
  sCode := ASrc.Strings[0]; //证券代码
  sName := ASrc.Strings[1]; //证券简称
  sTFPTime := ASrc.Strings[2]; //停复牌时间
  sStopLength := ASrc.Strings[3]; //停牌期限
  sStopCause := ASrc.Strings[4]; //停牌原因

  sDate := StringReplace(ADate, '-', '', [rfReplaceAll]);//用空格替换所有的 -

  ADest.Add(sDate); //日期
  ADest.Add('SH'); //类别
  ADest.Add('SH' + sCode); //代码
  ADest.Add(sName); //简称;

  if sTFPTime = '-' then
  begin
    sStopLength := StringReplace(sStopLength, '-', '', [rfReplaceAll]);
    if (Copy(sStopLength, 1, 2) = '自') then //举例：自2011-06-02起连续停牌
    begin
      //s.Add('3');          //停牌状态
      sStopLength := Copy(sStopLength, 3, 8);
      //停牌状态
      //if sStopLength <= sDate then
      if sStopLength = sDate then //状态变动时，才认为停牌
        ADest.Add('1') //停牌
      else
        ADest.Add('3'); //说明

      ADest.Add(sStopLength); //开始日期
      ADest.Add('0'); //结束日期

      ADest.Add('1') //停牌时间
    end
    else if Pos('停牌终止', sStopLength) > 0 then //举例：2011-05-31停牌终止
    begin    //pos()，取出子串在父串中第一次出现的位置
      sStopLength := Copy(sStopLength, 1, 8);
      //停牌状态
      if sStopLength < sDate then
        ADest.Add('2') //复牌
      else
        ADest.Add('1'); //停牌

      ADest.Add('0'); //开始日期
      ADest.Add(sStopLength); //结束日期
      ADest.Add('1') //停牌时间
    end;
  end
  else
  begin
    ADest.Add('1'); //停牌状态
    sTFPTime := StringReplace(sTFPTime, '-', '', [rfReplaceAll]);
    ADest.Add(sTFPTime); //开始日期
    ADest.Add(sTFPTime); //结束日期
    //停牌时间
    if (sStopLength = '全天') then
      ADest.Add('1')
    else
      ADest.Add('2');
  end;
  {
  //停牌时间
  if (sStopLength = '全天') or (Copy(sStopLength, 1, 2) = '自') then
    s.Add('1')
  else
    s.Add('2');
  }
  ADest.Add(sStopCause); //停牌原因
end;

class function THtmlFileSHStop.SupportedFileKind: TFileKindSet;
begin
  Result := [fkShStopInfo]
end;

procedure THtmlFileSHStop.TransData(const ASrc: TStrings; ADest: TStream);
const
  StopFlag = '特别提示';
var
  sContent, sDate: String;
  iPos, iCount, iIndex, iContentIndex: Integer;
  FData, FTmp: TStrings;
begin
  inherited;
  if Assigned(ASrc) and Assigned(ADest) then
  begin
    FData := TStringList.Create;
    FTmp := TStringList.Create;
    try
      iCount := ASrc.Count - 1;
      for iIndex := 0 to iCount do
      begin
        sContent := ASrc[iIndex];
        iPos := Pos(StopFlag, sContent);
        if iPos > 0 then
        begin
          sDate := Copy(sContent, iPos - 10, 10);
          iContentIndex := iIndex + 4;;
          while iContentIndex <= iCount do
          begin
            sContent := ASrc[iContentIndex];
            //一只代码读取开始
            if Pos('<tr bgcolor', sContent) > 0 then
            begin
              FTmp.Clear;
//              s := TStringList.Create;
              Inc(iContentIndex);
//              iColIndex := 0;
              Continue;
            end;
            //一只代码读取结束
            if sContent = '</tr>' then
            begin
              ProcessInfo(FTmp, FData, sDate);
              Write(ADest, FData);
              inc(iContentIndex);
              Continue;
            end;
            //跳过无用的行
            if sContent = '' then
            begin
              inc(iContentIndex);
              Continue;
            end;
            //所有读取内容结束
            if Pos('</table>', sContent) > 0 then
              Break;

            iPos := Pos('>', sContent);
            Delete(sContent, 1, iPos);
            iPos := Pos('<', sContent);
            sContent := Copy(sContent, 1, iPos - 1);
            sContent := Trim(sContent);
            //s.Add(sContent);
            FTmp.Add(sContent);
            Inc(iContentIndex); 
          end; 
          Break;
        end;
      end;
    finally
      FTmp.Free;
      FData.Free;
    end; 
  end;
end;
{$ENDREGION}

{$REGION ' fkSzStopInfo '}
type
  THtmlFileSZStop = class(THtmlFileTransEx)
  private
    procedure ProcessInfo(const ASrc, ADest: TStrings; const ADate: String);
  protected     
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  end; 

{ THtmlFileSZStop }

procedure THtmlFileSZStop.ProcessInfo(const ASrc, ADest: TStrings;
  const ADate: String);
  var
    sCode, sName, sTPTime, sFPTime, sStopLength, sStopCause, sDate: string;
  begin
    {
      rq	日期
      sc	市场
      dm	代码
      mc	名称
      tpzq	停牌状态     1:停牌 2:复牌 3:说明
      ksrq	开始日期
      jsrq	结束日期
      tpsj	停牌时间     1:全天 2:1小时
      tpyy	停牌原因

    }
//    if lst.count = 0 then
//      exit;
    sCode := ASrc.Strings[0]; //证券代码
    sName := ASrc.Strings[1]; //证券简称
    sTPTime := ASrc.Strings[2]; //停牌时间
    sFPTime := ASrc.Strings[3]; //复牌时间
    sStopLength := ASrc.Strings[4]; //停牌期限
    sStopCause := ASrc.Strings[5]; //停牌原因

    sDate := StringReplace(ADate, '-', '', [rfReplaceAll]);

    ADest.Add(sDate); //日期
    ADest.Add('SZ'); //类别
    ADest.Add('SZ' + sCode); //代码
    ADest.Add(sName); //简称;

    if sTPTime = '' then
    begin
      ADest.Add('2'); //停牌状态
      sFPTime := StringReplace(sFPTime, '-', '', [rfReplaceAll]);
      sFPTime := Copy(sFPTime, 1, 8);
      ADest.Add('0'); //开始日期
      ADest.Add(sFPTime); //结束日期
    end
    else
    begin
      ADest.Add('1'); //停牌状态
      sTPTime := StringReplace(sTPTime, '-', '', [rfReplaceAll]);
      sTPTime := Copy(sTPTime, 1, 8);
      ADest.Add(sTPTime); //开始日期
      ADest.Add(sTPTime); //结束日期
    end;
    //停牌时间
    if (sStopLength = '1天') or (sStopLength = '特停') then
      ADest.Add('1')
    else
      ADest.Add('2');
      
    ADest.Add(sStopCause); //停牌原因
end;

class function THtmlFileSZStop.SupportedFileKind: TFileKindSet;
begin
  Result := [fkSzStopInfo];
end;

procedure THtmlFileSZStop.TransData(const ASrc: TStrings; ADest: TStream);
const
  StopFlag = '停复牌提示';
var
  sContent, sDate, sDestContent: String;
  iPos, iCount, iIndex, iContentIndex: Integer;
  FData, FTmp: TStrings;
begin
  inherited;
  if Assigned(ASrc) and Assigned(ADest) then
  begin
    FData := TStringList.Create;
    FTmp := TStringList.Create;
    try
      iCount := ASrc.Count - 1;
      //获得停牌信息
      for iIndex := 0 to iCount do
      begin
        sContent := ASrc.Strings[iIndex];
        iPos := Pos(StopFlag, sContent);
        if iPos > 0 then
        begin
          delete(sContent, 1, iPos - 1);
          sDestContent := sContent;
          iContentIndex := iIndex + 1;
          while iContentIndex <= iCount do
          begin
            sContent := ASrc.Strings[iContentIndex];
            if sContent = '' then
              break;
            sDestContent := sDestContent + sContent;
            Inc(iContentIndex);
          end;                          //
          delete(sDestContent, 1, length('停复牌提示</strong></span>&nbsp;&nbsp;&nbsp;<span class=''cls-subtitle''>'));
          sDate := Copy(sDestContent, 1, 10);
          iPos := Pos('</TABLE>', sDestContent);
          delete(sDestContent, 1, iPos + 7);
          iPos := Pos('</table>', sDestContent);
          sDestContent := Copy(sDestContent, 1, iPos + 7);
          sDestContent := StringReplace(sDestContent, '<tr', #13#10 + '<tr', [rfReplaceAll]);
          sDestContent := StringReplace(sDestContent, '<td', #13#10 + '<td', [rfReplaceAll]);
          sDestContent := StringReplace(sDestContent, '</td>', '</td>' + #13#10, [rfReplaceAll]);
          sDestContent := StringReplace(sDestContent, '</table>', #13#10 + '</table>', [rfReplaceAll]);
          break;

        end;
      end;

      ASrc.Clear;
      ASrc.Text := sDestContent;
      iCount := ASrc.Count - 1;

      for iIndex := 0 to iCount do
      begin
        sContent := ASrc.Strings[iIndex];   //
        //一只代码读取开始
        if Pos('<tr  class', sContent) > 0 then
        begin
          FTmp.Clear;
          FData.Clear;
          Continue;
        end;

        //一只代码读取结束
        if sContent = '</tr>' then
        begin
          ProcessInfo(FTmp, FData, sDate);
          Write(ADest, FData);
          continue;
        end;

        //跳过无用的行
        if ((sContent = '') or (Pos('<table', sContent) > 0)) then
        begin
          continue;
        end;

        //所有内容读取结束
        if Pos('</table>', sContent) > 0 then
          break;

        iPos := Pos('>', sContent);
        delete(sContent, 1, iPos);
        iPos := Pos('<', sContent);
        sContent := Copy(sContent, 1, iPos - 1);
        sContent := Trim(sContent);
        FTmp.Add(sContent);
      end;

      {
      iCount := ASrc.Count - 1;
      for iIndex := 0 to iCount do
      begin
        sContent := ASrc[iIndex];
        iPos := Pos(StopFlag, sContent);
        if iPos > 0 then
        begin
          sDate := Copy(sContent, iPos - 10, 10);
          iContentIndex := iIndex + 4;
          while iContentIndex <= iCount do
          begin
            sContent := ASrc[iContentIndex];
            //一只代码读取开始
            if Pos('<tr bgcolor', sContent) > 0 then
            begin
              FTmp.Clear;
              FData.Clear;
              Inc(iContentIndex);
//              iColIndex := 0;
              Continue;
            end;
            //一只代码读取结束
            if sContent = '</tr>' then
            begin
              ProcessInfo(ASrc, FData, sDate);
              Write(ADest, FData);
              Inc(iContentIndex);
              Continue;
            end;
            //跳过无用的行
            if sContent = '' then
            begin
              Inc(iContentIndex);
              Continue;
            end;
            //所有读取内容结束
            if Pos('</table>', sContent) > 0 then
              Break;

            iPos := Pos('>', sContent);
            delete(sContent, 1, iPos);
            iPos := Pos('<', sContent);
            sContent := Copy(sContent, 1, iPos - 1);
            sContent := Trim(sContent);
            //s.Add(sContent);
            FTmp.Add(sContent);
            Inc(iContentIndex);
          end;
          Break;
        end;
      end;
      }
    finally
      FTmp.Free;
      FData.Free;
    end;
  end;
end;
{$ENDREGION}

{$REGION ' fkEastSzStopInfo '}
type
  THtmlFileEastSzStop = class(THtmlFileTrans)
  private
    function GetDestContent(const ASrc: TStrings; const AStopAdd: String; out ADate: String): String;
    procedure SolveStopInfo(ADest: TStream; const ADestContent, ADate, AMarket: String);
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  end;

{ THtmlFileEastSzStop }

function THtmlFileEastSzStop.GetDestContent(const ASrc: TStrings;
  const AStopAdd: String; out ADate: String): String;
const
  StopFlag = '◆停牌提示◆';
var
  sContent, sDateContent, sMonth, sDay: String;
  iPos, iPos2, iIndex, iCount: Integer;
  iYear, iMonth, iDay: Word;
begin
  Result := '';
  ADate := '';
  iCount := ASrc.Count - 1;
  //获得停牌信息
  for iIndex := 0 to iCount do
  begin
    sContent := ASrc.Strings[iIndex];
    iPos := Pos(AStopAdd, sContent);
    if iPos > 0 then
    begin
      sDateContent := sContent;
      //获得交易日期
      delete(sDateContent, 1, iPos + Length(AStopAdd) - 1);
      delete(sDateContent, 1, 2);
      iPos2 := Pos('）', sDateContent);
      sDateContent := Copy(sDateContent, 1, iPos2 - 1);
      DecodeDate(date, iYear, iMonth, iDay);
      iPos2 := Pos('月', sDateContent);
      sMonth := Copy(sDateContent, 1, iPos2 - 1);
      delete(sDateContent, 1, iPos2 + 1);
      iPos2 := Pos('日', sDateContent);
      sDay := Copy(sDateContent, 1, iPos2 - 1);
      if Length(sMonth) = 1 then
        sMonth := '0' + sMonth;
      if Length(sDay) = 1 then
        sDay := '0' + sDay;

      ADate := IntToStr(iYear) + sMonth + sDay;
      //获取每日交易提示的链接地址
      sContent := Copy(sContent, 1, iPos - 1);
      iPos := Pos('href', sContent);
      delete(sContent, 1, iPos -1);
      iPos := Pos('"', sContent);
      delete(sContent, 1, iPos);
      iPos := Pos('"', sContent);
      sContent := Copy(sContent, 1, iPos - 1);

      Result := SockGet(sContent);

      iPos := Pos(StopFlag, Result);
      delete(Result, 1, iPos + Length(StopFlag));
      iPos := Pos(StopFlag, Result);
      delete(Result, 1, iPos + Length(StopFlag));
      iPos := Pos('◆', Result);
      Result := Copy(Result, 1, iPos - 1);
      Result := StringReplace(Result, '●', #13#10 + '●', [rfReplaceAll]);

      Break;
    end;
  end;
end;

procedure THtmlFileEastSzStop.SolveStopInfo(ADest: TStream; const ADestContent, ADate, AMarket: String);
const
  StopFlag = '◆停牌提示◆';
  sPBegin = '<p>';  //段得开头
  sPEnd = '</p>';   //段得结束
  sDivBegin = '<div'; //
  sDivEnd = '</div>';
var
  sContent, sDestContent, sCause, sCodeContent: String;
  iPos, iPos2, iIndex, iStopCount: Integer;
  FListDest, stmpList, FData: TStrings;
  sCode, sName, sTemp: String;
begin

  FListDest := TStringList.Create;
  stmpList := TStringList.Create;
  FData := TStringList.Create;
  try
    sDestContent := ADestContent;

    FListDest.Text := sDestContent;
    iStopCount := FListDest.Count - 1;
    for iIndex := 0 to iStopCount do
    begin
      sContent := FListDest[iIndex];
      if sContent = '' then
        Continue;
      //一只代码读取开始
      if Pos('●', sContent) > 0 then
      begin

        //取代码内容
        iPos := Pos('(', sContent);
        if iPos > 0 then
          delete(sContent, 1, iPos -1);
        iPos := Pos('。', sContent);
        if iPos > 0 then
          sContent := Copy(sContent, 1, iPos - 1);
        sCodeContent := sContent;
        iPos := Pos('<', sContent);
        while iPos > 0 do
        begin
          iPos2 := Pos('>', sContent);
          delete(sContent, iPos, iPos2 - iPos + 1);
          iPos := Pos('<', sContent);
        end;
        //取停牌原因

        iPos := Pos('-', sContent);
        iPos2 := Pos('，', sContent);
        sCause := Copy(sContent, iPos + 1, iPos2 - iPos - 1);

        //20110713 11:37 gq modify 修改解析代码的功能
        //sContent := Copy(sContent, 1, iPos - 1);
        //sContent := StringReplace(sContent, '、', #13#10, [rfReplaceAll]);
        //循环解析每只代码
        sContent := sCodeContent;
        while sContent <> '' do
        begin
          sTemp := '<span id="stock_';
          iPos := Pos(sTemp, sContent);
          if iPos = 0 then
            Break;
          delete(sContent, 1, iPos + Length(sTemp) - 1);
          sCode := Copy(sContent, 1, 6);
          sTemp := '<a href';
          iPos := Pos('<a href', sContent);
          delete(sContent, 1, iPos);
          sTemp := '>';
          iPos := Pos(sTemp, sContent);
          delete(sContent, 1, iPos);
          sTemp := '</a>';
          iPos := Pos(sTemp, sContent);
          sName := Copy(sContent, 1, iPos - 1);
          delete(sContent, 1, iPos + Length(sTemp) - 1);

          FData.Clear;
          FData.Add(ADate);
          FData.Add(AMarket);
          FData.Add(AMarket + sCode);   //代码
          FData.Add(sName);             //名称
          FData.Add('1');       //停牌状态：停牌
          FData.Add(ADate);     //开始日期
          FData.Add(ADate);     //结束日期
          FData.Add('1');       //停牌时间
          FData.Add(sCause);     //停牌原因

          Write(ADest, FData);
        end;
        {
        //解析每只代码
        stmpList.Text := sContent;
        for iCodeIndex := 0 to stmpList.Count - 1 do
        begin
          sContent := stmpList.Strings[iCodeIndex];
          FData.Clear;
          FData.Add(ADate);
          FData.Add(AMarket);
          iPos := Pos('(', sContent);
          iPos2 := Pos(')', sContent);
          FData.Add(AMarket + Copy(sContent, iPos + 1, iPos2 - iPos - 1));   //代码
          delete(sContent, 1, iPos2);
          iPos := Pos('(', sContent);
          FData.Add(Copy(sContent, 1, iPos - 1));  //名称
          delete(sContent, 1, iPos);
          FData.Add('1');       //停牌状态：停牌
          FData.Add(ADate);     //开始日期
          FData.Add(ADate);     //结束日期
          FData.Add('1');       //停牌时间
          FData.Add(sCause);     //停牌原因

          Write(ADest, FData);
        end;
        }


      end;
      Continue;
    end;    
  finally
    FData.Free;
    stmpList.Free;
    FListDest.Free;
  end;
end;

class function THtmlFileEastSzStop.SupportedFileKind: TFileKindSet;
begin
  Result := [fkEastSzStopInfo]
end;

procedure THtmlFileEastSzStop.TransData(const ASrc: TStrings; ADest: TStream);
const
  StopAddSZ = '深市每日交易提示';
  StopAddSH = '沪市每日交易提示';
var
  FContent, FDate: String;
begin
  FContent := GetDestContent(ASrc, StopAddSZ, FDate);
  SolveStopInfo(ADest, FContent, FDate, 'SZ');
  FContent := GetDestContent(ASrc, StopAddSH, FDate);
  SolveStopInfo(ADest, FContent, FDate, 'SH');
end;
{$ENDREGION}

{$REGION ' fkSzFundInfo '}
type
  THtmlFileSzFundInfo = class(THtmlFileTransEx)
  private
    FTradeDate: String;
    FDataOk: Boolean;
    function GetDate(const ASrc: TStrings): String;

    procedure ProcessInfo(const ASrc, AData: TStrings; ADest: TStream; const ADate: String);
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: string); override;
  end;

{ THtmlFileSzFundInfo }

function THtmlFileSzFundInfo.GetDate(const ASrc: TStrings): String;
const
  FundFlag = '基金列表';
  FundAdd = 'http://www.szse.cn/main/marketdata/jypz/fundlist1/';
var
  S, sDateContent: String;
  iPos, iPos2: Integer;
  lst: TStringList;
begin  
  Result := '';
  if FTradeDate <> '' then
    Result := FTradeDate
  else
  begin
    //20110624 gq 14:10 gq modify 如果没有传入日期，则去下载分析当天的日期
    lst := TStringList.Create;
    sDateContent := SockGet(FundAdd);
    lst.Text := sDateContent;
    //if Assigned(lst) then
    for S in lst do
    begin
      iPos := Pos(FundFlag, S);
      if iPos > 0 then
      begin
        sDateContent := S;
        //获得交易日期
        delete(sDateContent, 1, iPos + Length(FundFlag) - 1);
        iPos2 := Pos('</span>', sDateContent);
        delete(sDateContent, 1, iPos2 + 6);
        iPos2 := Pos('</span>', sDateContent);
        sDateContent := Copy(sDateContent, iPos2 - 10 , 10);
        Result := stringReplace(sDateContent, '-', '', [rfReplaceALl]);
        Break;
      end;
    end;
    lst.Free;
  end;
end;

procedure THtmlFileSzFundInfo.ProcessInfo(const ASrc, AData: TStrings;
  ADest: TStream; const ADate: String);
var
  sCode, sName, sssRq, sjjgm, stemp: String;
begin
  {
    rq	日期
    sc	市场
    dm	代码
    mc	名称
    ssrq	上市日期
    gm	基金规模


  }
  //if FDataOk then
  begin
    sCode := ASrc.Strings[0];           //证券代码
    sName := ASrc.Strings[1];           //证券简称
    sssRq := ASrc.Strings[2];           //上市日期
    sjjgm := ASrc.Strings[3];           //基金规模

    AData.Add(ADate); //日期
    AData.Add('SZ');  //类别
    AData.Add('SZ' + sCode);  //代码
    AData.Add(sName);  //简称;
    sTemp := sssRq;
    sTemp := stringReplace(sTemp, '-', '', [rfReplaceALl]);
    AData.Add(sTemp);   //上市日期
    sTemp := sjjgm;
    sTemp := stringReplace(sTemp, ',', '', [rfReplaceALl]);
    AData.Add(sTemp);   //基金规模

    Write(ADest, AData);
  end;
end;

class function THtmlFileSzFundInfo.SupportedFileKind: TFileKindSet;
begin
  Result := [fkSzFundInfo]
end;

procedure THtmlFileSzFundInfo.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: string);
begin
  FTradeDate := Param;
  inherited;
end;

procedure THtmlFileSzFundInfo.TransData(const ASrc: TStrings; ADest: TStream);
const
  FundAdd = 'http://www.szse.cn/szseWeb/FrontController.szse?ACTIONID=8&CATALOGID=1105&TABKEY=tab1&ENCODE=1';
var
  FDestList, FTmp, FData: TStringList;
  S, FContent, FDate, FDestContent: String;
  iPos: Integer;
begin
  //20110624 gq 14:10 gq modify 直接分析传入的基金列表文件
  FDate := GetDate(ASrc);
  FDate := GetInfFromDB('SELECT ytbase.dbo.GetPrecJYDay('+FDate+')');
  FDestContent := SockGet(FundAdd);
//  FDestContent := ASrc.Text;
  FDestContent := StringReplace(FDestContent, '<tr', #13#10 + '<tr', [rfReplaceAll]);
  FDestContent := StringReplace(FDestContent, '<td', #13#10 + '<td', [rfReplaceAll]);
  FDestContent := StringReplace(FDestContent, '</td>', '</td>' + #13#10, [rfReplaceAll]);
  FDestContent := StringReplace(FDestContent, '</table>', #13#10 + '</table>', [rfReplaceAll]);

  FDataOk := false;
  FDestList := TStringList.Create;
  FTmp := TStringList.Create;
  FData := TStringList.Create;
  try
    FDestList.Text := FDestContent;
    for S in FDestList do
    begin

      //一只代码读取开始
      if Pos('<tr  class', S) > 0 then
      begin
        FTmp.Clear;
        FData.Clear;
        Continue;
      end;

      //一只代码读取结束
      if S = '</tr>' then
      begin
        ProcessInfo(FTmp, FData, ADest, FDate);
        FDataOk := true;
        Continue;
      end;

      //所有内容读取结束
      if Pos('</table>', S) > 0 then
        Break;

      //跳过无用的行
      if ((S = '') or (Pos('<table', S) > 0)) or (Pos('<meta', s) > 0) then
        Continue;

      FContent := S;
      iPos := Pos('>', FContent);
      delete(FContent, 1, iPos);
      iPos := Pos('<', FContent);
      FContent := Trim(Copy(FContent, 1, iPos - 1));
      FTmp.Add(FContent);
    end;
  finally
    FData.Free;
    FTmp.Free;
    FDestList.Free;
  end;
end;
{$ENDREGION}

{$REGION ' fkShFundInfo '}
type
  THtmlFileShFundInfo = class(THtmlFileTrans)
  protected
    FDate: String;
    const S_MARKET = 'SH';
    class function SupportedFileKind(): TFileKindSet; override;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  end;

{ THtmlFileShFundInfo }

class function THtmlFileShFundInfo.SupportedFileKind: TFileKindSet;
begin
  Result := [fkShFundInfo];
end;

procedure THtmlFileShFundInfo.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: String);
begin
  FDate := Param;
  inherited;
end;

procedure THtmlFileShFundInfo.TransData(const ASrc: TStrings; ADest: TStream);

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
      FSize := floattostr(strtofloat(FSize) * 10000);
      if TryStrToCurr(FSize, FCurr) and (FCurr > 0) then
      begin
        FSize := currtostrf(FCurr,ffFixed,4);
        FDate := ADestContent[IDX_DATE];
        FMarket := S_MARKET;
        FCode := ADestContent[IDX_CODE];
        FName := ADestContent[IDX_NAME];
        FListingDate := '';                    //上市日期为空
        FList.CommaText := FDate+','+FMarket+','+FMarket+FCode+','+FName+','+FListingDate+','+FSize;
        write(ADest,FList);
      end;
    end;
    FList.Free;
  end;

const
  url='http://www.sse.com.cn/assortment/fund/fjlof/scale/';
var

  FStream: TFileStream;
  FData, FFile: String;
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

{$ENDREGION}

{$REGION ' fkEastStopInfo '}
type
  THtmlFileEastStop = class(THtmlFileTrans)
  private
    function GetDate(const ADateStr: String): String;
    function GetDestContent(const ASrc: TStrings; const AStopAdd: String; out ADate: String): String;
    procedure SolveStopInfo(ADest: TStream; const ADestContent, ADate, AMarket: String);
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  end;

{ THtmlFileEastStop }

function THtmlFileEastStop.GetDate(const ADateStr: String): String;
var
  sDateContent, sMonth, sDay: String;
  iPos2: Integer;
  iYear, iMonth, iDay: Word;
begin
  sDateContent := ADateStr;
  iPos2 := Pos('月', sDateContent);
  sMonth := Copy(sDateContent, 1, iPos2 - 1);
  delete(sDateContent, 1, iPos2 + 1);
  iPos2 := Pos('日', sDateContent);
  sDay := Copy(sDateContent, 1, iPos2 - 1);
  if Length(sMonth) = 1 then
    sMonth := '0' + sMonth;
  if Length(sDay) = 1 then
    sDay := '0' + sDay;

  //获得交易日期
  DecodeDate(date, iYear, iMonth, iDay);
  Result := IntToStr(iYear) + sMonth + sDay;
end;

function THtmlFileEastStop.GetDestContent(const ASrc: TStrings;
  const AStopAdd: String; out ADate: String): String;
const
  StopFlagBegin = '<div id="ContentBody" class="Body">';
  StopFlagEnd = '<div class="BodyEnd">';
var
  sContent, sDateContent: String;
  iPos, iIndex, iCount: Integer;
begin
  Result := '';
  ADate := '';
  iCount := ASrc.Count - 1;
  //获得停牌信息
  for iIndex := 0 to iCount do
  begin
    sContent := ASrc.Strings[iIndex];
    iPos := Pos(AStopAdd, sContent);
    if iPos > 0 then
    begin
      //举例：<li><span>2011-06-08 22:08</span><a href="http://stock.eastmoney.com/news/1396,20110608141016376.html" title="6月9日沪深股市交易提示" target="_blank">6月9日沪深股市交易提示</a></li>

      //获取每日交易提示的链接地址
      sContent := Copy(sContent, 1, iPos - 1);
      iPos := Pos('href', sContent);
      delete(sContent, 1, iPos -1);
      iPos := Pos('"', sContent);
      delete(sContent, 1, iPos);

      sDateContent := sContent;
      iPos := Pos('"', sContent);
      sContent := Copy(sContent, 1, iPos - 1);

      delete(sDateContent, 1, iPos);
      iPos := Pos('"', sDateContent);
      delete(sDateContent, 1, iPos);

      ADate := GetDate(sDateContent);
      {
      iPos2 := Pos('月', sDateContent);
      sMonth := Copy(sDateContent, 1, iPos2 - 1);
      delete(sDateContent, 1, iPos2 + 1);
      iPos2 := Pos('日', sDateContent);
      sDay := Copy(sDateContent, 1, iPos2 - 1);
      if Length(sMonth) = 1 then
        sMonth := '0' + sMonth;
      if Length(sDay) = 1 then
        sDay := '0' + sDay;

      //获得交易日期
      DecodeDate(date, iYear, iMonth, iDay);
      ADate := IntToStr(iYear) + sMonth + sDay;
      }
      //取目的地址的内容
      Result := SockGet(sContent);

      iPos := Pos(StopFlagBegin, Result);
      delete(Result, 1, iPos + Length(StopFlagBegin));
      iPos := Pos(StopFlagEnd, Result);
      Result := Copy(Result, 1, iPos - 1);
      Result := trim(Result);
      Result := Copy(Result, 1, length(Result) - 6);
      Result := trim(Result);
      //Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
      Break;
    end;
  end;
end;

procedure THtmlFileEastStop.SolveStopInfo(ADest: TStream; const ADestContent,
  ADate, AMarket: String);
const
  StopFlag = '◆停牌提示◆';
  sPBegin = '<p>';  //段得开头
  sPEnd = '</p>';   //段得结束
  sDivBegin = '<div'; //
  sDivEnd = '</div>';
var
  sContent, sDestContent, sOneCode: String;
  iPos, iPos2, iIndex, iStopCount: Integer;
  FListDest, stmpList, FData: TStrings;
  iCausePos1, iCausePos2: Integer;
  iCodePos1, iCodePos2: Integer;
  sCause, sStopSj, sCode, sName, slsDate, sStopStatus: String;
  bOhterStop: Boolean;
begin
  FListDest := TStringList.Create;
  stmpList := TStringList.Create;
  FData := TStringList.Create;
  try
    sDestContent := ADestContent;
    sDestContent := StringReplace(sDestContent, ' ', '', [rfReplaceAll]);
    sDestContent := StringReplace(sDestContent, '　', '', [rfReplaceAll]);
    sDestContent := StringReplace(sDestContent, #13#10, '', [rfReplaceAll]);
    sDestContent := StringReplace(sDestContent, sPEnd + sPBegin, sPEnd + #13#10 + sPBegin, [rfReplaceAll]);
    //20110624 8:53 gq add 增加'</p><div' '</div><p>'这种情况的分析
    sDestContent := StringReplace(sDestContent, sPEnd + sDivBegin, sPEnd + #13#10 + sDivBegin, [rfReplaceAll]);
    sDestContent := StringReplace(sDestContent, sDivEnd + sPBegin, sDivEnd + #13#10 + sPBegin, [rfReplaceAll]);

    bOhterStop := false;
    FListDest.Text := sDestContent;
    iStopCount := FListDest.Count - 1;
    //增加默认设置
    sStopStatus := '1';
    sStopSj := '1';
    sCause := '不知道原因';
    for iIndex := 0 to iStopCount do
    begin
      sContent := FListDest[iIndex];
      //读取停牌原因  有的字体加粗，有的不加粗，所以要两种判断
      if (Copy(sContent, 4, 2) = '因') or (Copy(sContent, 12, 2) = '因') then
      begin
        sStopStatus := '1';
        sStopSj := '1';
        iCausePos1 := Pos(sPBegin, sContent);
        iCausePos2 := Pos(sPEnd, sContent);
        sCause := Copy(sContent, iCausePos1 + 3, iCausePos2 - iCausePos1 - length(sPBegin));
        iPos := Pos('因', sCause);
        if iPos > 0 then
        begin
          delete(sCause, 1, iPos + 1);
          iPos2 := Pos('停牌一天', sCause);
          if iPos2 > 0 then
          begin
            sStopSj := '1';
            sCause := Copy(sCause, 1, iPos2 - 1);
          end
          else
          begin
            iPos2 := Pos('停牌一小时', sCause);
            if iPos2 > 0 then
            begin
              sStopSj := '2';
              sCause := Copy(sCause, 1, iPos2 - 1);
            end
          end;
        end;
        continue;
      end
      else if Pos('其他停牌', sContent) > 0 then
      begin
        bOhterStop := true;
        sStopStatus := '1';
        sStopSj := '1';
        continue;
      end;
      {
      if not bStart then
        continue;
      }
      //读取代码信息
      //<span id="stock_0000502"><a href="http://quote.eastmoney.com/SZ000050.html" class="keytip" target="_blank">深天马</a></span>
      iPos := Pos('<div', sContent);
      if iPos > 0 then
      begin
        iPos2 := Pos('</div>', sContent);
        delete(sContent, iPos, iPos2 - iPos + 6);
      end;

      if bOhterStop then
      begin
        if Pos('特别停牌', sContent) > 0 then   //ST零七(000007)、万泽股份(000534)特别停牌。
        begin
          sCause := '特别停牌'
        end
        else if Pos('连续停牌', sContent) > 0 then   //中国南车(601766)因重要事项未公告，自6月9日起连续停牌
        begin
          iCausePos1 := Pos('因', sContent);
          sCause := Copy(sContent, iCausePos1, Length(sContent) - iCausePos1 + 1);
          sContent := Copy(sContent, 1, iCausePos1 - 1);

          iCausePos1 := Pos('因', sCause);
          delete(sCause, 1, iCausePos1 + 1);

          iCausePos1 := Pos('自', sCause);
          iCausePos2 := Pos('起', sCause);
          slsDate := Copy(sCause, iCausePos1 + 2, iCausePos2 - iCausePos1 - 2);
          slsDate := GetDate(slsDate);

          iCausePos1 := Pos('，', sCause);
          sCause := Copy(sCause, 1, iCausePos1 - 1);

          if slsDate <> ADate  then
            sStopStatus := '3';    
        end;
      end;

      iCodePos1 := Pos('<ahref', sContent);
      if iCodePos1 > 0 then
      begin
        while iCodePos1 > 0 do
        begin
          delete(sContent, 1, iCodePos1 - 1);
          iCodePos2 := Pos('</a>', sContent);
          sOneCode := Copy(sContent, 1, iCodePos2 - 1);
          delete(sContent, 1, iCodePos2 + 3);
          iCodePos2 := Pos('.html', sOneCode);
          sCode := Copy(sOneCode, iCodePos2 - 8, 8);
          iCodePos2 := Pos('>', sOneCode);
          delete(sOneCode, 1, iCodePos2);
          sName := sOneCode;
          //20110624 8:57 gq add 增加股票名称含停牌一览这种情况的过滤 例如：沪市停牌一览；深市停牌一览
          if Pos('停牌一览', sName) = 0 then
          begin
            FData.Clear;
            FData.Add(ADate);
            FData.Add(Copy(sCode, 1, 2));
            FData.Add(sCode);   //代码
            FData.Add(sName);   //名称
            FData.Add(sStopStatus);     //停牌状态
            FData.Add(ADate);   //开始日期
            FData.Add(ADate);   //结束日期
            FData.Add(sStopSj); //停牌时间
            FData.Add(sCause);  //停牌原因

            Write(ADest, FData);
          end;
          iCodePos1 := Pos('<ahref', sContent);
        end;
      end;
    end;

  finally
    FData.Free;
    stmpList.Free;
    FListDest.Free;
  end;
end;


class function THtmlFileEastStop.SupportedFileKind: TFileKindSet;
begin
  result := [fkEastStopInfo]
end;

procedure THtmlFileEastStop.TransData(const ASrc: TStrings; ADest: TStream);
const
  StopAdd = '沪深股市交易提示';
var
  FContent, FDate: String;
begin
  FContent := GetDestContent(ASrc, StopAdd, FDate);
  SolveStopInfo(ADest, FContent, FDate, '');
end;
{$ENDREGION}

{$REGION ' fkWindStopInfo '}
type
  THtmlFileWindStop = class(THtmlFileTrans)
  private
    function GetDate(const ADateStr: String): String;
    function GetDestContent(const ASrc: TStrings; const AStopAdd: String; out ADate: String): String;
    procedure SolveStopInfo(ADest: TStream; const ADestContent, ADate, AMarket: String);
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
  end;
 
{ THtmlFileWindStop }

function THtmlFileWindStop.GetDate(const ADateStr: String): String;
var
  sDateContent, sYear, sMonth, sDay: String;
  iPos2: Integer;
begin
  sDateContent := ADateStr;
  iPos2 := Pos('-', sDateContent);
  sYear := Copy(sDateContent, 1, iPos2 - 1);
  delete(sDateContent, 1, iPos2);
  iPos2 := Pos('-', sDateContent);
  sMonth := Copy(sDateContent, 1, iPos2 - 1);
  delete(sDateContent, 1, iPos2);
  sDay := sDateContent;
  Result := sYear + sMonth + sDay;
end;

function THtmlFileWindStop.GetDestContent(const ASrc: TStrings;
  const AStopAdd: String; out ADate: String): String;
const
  StopFlagBegin = '<table cellspacing="0" cellpadding="0" border="0" width="100%">';
  StopFlagEnd = '</table>';
  DateFlag = 'A股特别提示';
var
  iPosStart, iPosEnd, iDateStart, iDateEnd: Integer;
  sSourceContent, sDateContent: String;
begin
  sSourceContent := ASrc.Text;
  result := sSourceContent;
  sDateContent := sSourceContent;
  iDateStart := Pos(DateFlag, sDateContent);
  begin
    delete(sDateContent, 1, length(DateFlag) + iDateStart);
    iDateEnd := Pos(')', sDateContent);
    sDateContent := Copy(sDateContent, 1, iDateEnd - 1);
    ADate := GetDate(sDateContent);
  end;

  iPosStart := Pos(StopFlagBegin, sSourceContent);
  if iPosStart > 0 then
  begin
    delete(sSourceContent, 1, length(StopFlagBegin) + iPosStart - 1);
    iPosEnd := Pos(StopFlagEnd, sSourceContent);
    if iPosEnd > 0 then
      result := Copy(sSourceContent, 1, iPosEnd - 1);
  end;
end;

procedure THtmlFileWindStop.SolveStopInfo(ADest: TStream; const ADestContent,
  ADate, AMarket: String);
const
  StopFlag = '◆停牌提示◆';
  sPBegin = '<p>';  //段得开头
  sPEnd = '</p>';   //段得结束
  sDivBegin = '<div'; //
  sDivEnd = '</div>';
var
  sContent, sDestContent, sOneCode: String;
  iPos, iIndex, iStopCount: Integer;
  FListDest, stmpList, FData: TStrings;
  sCause, sStopSj, sCode, sName, sStopStatus, sMarket: String;
  iCodeInfoPos: Integer;
begin
  FListDest := TStringList.Create;
  stmpList := TStringList.Create;
  FData := TStringList.Create;
  try
    sDestContent := ADestContent;
    //sDestContent := StringReplace(sDestContent, ' ', '', [rfReplaceAll]);
    //sDestContent := StringReplace(sDestContent, '　', '', [rfReplaceAll]);
    sDestContent := StringReplace(sDestContent, #13#10, '', [rfReplaceAll]);
    sDestContent := StringReplace(sDestContent, '</tr><tr', '</tr>' + #13#10 + '<tr', [rfReplaceAll]);
    //20110624 8:53 gq add 增加'</p><div' '</div><p>'这种情况的分析
    //sDestContent := StringReplace(sDestContent, sPEnd + sDivBegin, sPEnd + #13#10 + sDivBegin, [rfReplaceAll]);
    //sDestContent := StringReplace(sDestContent, sDivEnd + sPBegin, sDivEnd + #13#10 + sPBegin, [rfReplaceAll]);

    FListDest.Text := sDestContent;
    FListDest.Delete(0);
    iStopCount := FListDest.Count - 1;
    //增加默认设置
    sStopStatus := '1';
    sStopSj := '1';
    sCause := '不知道原因';
    for iIndex := 0 to iStopCount do
    begin
      //<tr class="TRBackGroundOne"><td valign="top" width="20%">SST华新(000010)</td><td>继续停牌(起始停牌日：2013-04-26)；今天停牌原因：重大事项</td></tr>
      sContent := FListDest[iIndex];
      iCodeInfoPos := Pos('<td', sContent);
      delete(sContent, 1, iCodeInfoPos - 1);
      iCodeInfoPos := Pos('>', sContent);
      delete(sContent, 1, iCodeInfoPos);
      iCodeInfoPos := Pos('</td>', sContent);
      sOneCode := Copy(sContent, 1, iCodeInfoPos - 1);
      delete(sContent, 1, iCodeInfoPos - 1);
      //</td><td>继续停牌(起始停牌日：2013-04-26)；今天停牌原因：重大事项</td></tr>
      delete(sContent, 1, 9);
      iPos := Pos('</td>', sContent);
      sCause := Copy(sContent, 1,iPos - 1);
      iPos := Pos('(', sOneCode);
      sName := Copy(sOneCode, 1, iPos - 1);
      Delete(sOneCode, 1, iPos);
      sCode := Copy(sOneCode, 1, Length(sOneCode) - 1);
      sMarket := 'SH';
      if sCode[1] in ['0', '3'] then
        sMarket := 'SZ';
      sStopStatus := '1';
      sStopSj := '1';

      FData.Clear;
      FData.Add(ADate);
      FData.Add(sMarket);
      FData.Add(sMarket + sCode);   //代码
      FData.Add(sName);   //名称
      FData.Add(sStopStatus);     //停牌状态
      FData.Add(ADate);   //开始日期
      FData.Add(ADate);   //结束日期
      FData.Add(sStopSj); //停牌时间
      FData.Add(sCause);  //停牌原因

      Write(ADest, FData);

    end;

  finally
    FData.Free;
    stmpList.Free;
    FListDest.Free;
  end;
end;

class function THtmlFileWindStop.SupportedFileKind: TFileKindSet;
begin
  result := [fkWindStopInfo];
end;

procedure THtmlFileWindStop.TransData(const ASrc: TStrings; ADest: TStream);
const
  WindStopInfoPath = 'WindStopInfo';

var
  FContent, FDate: String;
  sFilePath: String;
begin
  sFilePath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  sFilePath := sFilePath + WindStopInfoPath;
  if not DirectoryExists(sFilePath) then
    ForceDirectories(sFilePath);
  ASrc.SaveToFile(sFilePath + '\' + formatDateTime('YYYYMMDDHHMMSS', now) + '.txt');

  ASrc.Text := UTF8ToAnsi(ASrc.Text);
  FContent := GetDestContent(ASrc, '', FDate);
  SolveStopInfo(ADest, FContent, FDate, '');
end;
{$ENDREGION}

{$REGION' fkFundNav '}

type
  THtmlwebFundNav = class(THtmlFileTrans)
  public
    FDate: String;
    const S_MARKET = 'OF';
    procedure MailErrInf(ErrInf: String);
    procedure TransDataWeb(Temporarylist: TStrings);
    procedure TransDataDBF(Temporarylist: TStrings);
    procedure TransData123(Temporarylist: TStrings);
    procedure TransDataFinaWeb(Temporarylist: TStrings);
    procedure TransDataNavlist(ADest:TStream; AList: TStrings);
    procedure TransDataFuGuo(AList: TStrings);
    procedure TransDataJinYing(AList: TStrings);
    procedure TransDataNuoDe(AList: TStrings);
    procedure TransDataGuoTai(AList: TStrings);
    procedure TransDataXingYe(AList: TStrings);
    procedure TransDataYinHua(AList: TStrings);
    procedure TransDataPengHua(AList: TStrings);
    procedure TransDataZhongOu(AList: TStrings);
    procedure TransDataShenWan(AList: TStrings);
    procedure TransDataGongYin(AList: TStrings);
    procedure TransDataXinCheng(AList: TStrings);
    procedure TransDataZhaoShang(AList: TStrings);
    procedure TransDataChangSheng(AList: TStrings);
    procedure TransDataHuaShang(AList: TStrings);
    procedure TransDataGuoLianAn(AList: TStrings);
    procedure TransDataGuangFa(AList: TStrings);
    procedure TransDataGuoJin(AList: TStrings);
    procedure TransDataHuiTianFu(AList: TStrings);
    procedure TransDataYiFangDa(AList: TStrings);
    procedure TransDataGuoTuRuiYin(AList: TStrings);
    procedure TransDataTaiDaHongLi(AList: TStrings);
    procedure TransDataXinHua(AList: TStrings);
    procedure TransDataJianXin(AList: TStrings);
    procedure TransDataZheShang(AList: TStrings);
    procedure TransDataDongWu(AList: TStrings);
    procedure TransDataJiaShi(AList: TStrings);
    procedure TransDataNanFang(AList: TStrings);
    procedure TransDataHuaAn(AList: TStrings);
    procedure TransDataYinHe(AList: TStrings);
    procedure TransDataWanJia(AList: TStrings);
    procedure TransDatafund123(AList: TStrings);
    procedure TransDataifund(AList: TStrings);
    procedure TransDatastockstar(AList: TStrings);
    procedure TransDataHeXun(AList: TStrings);
    procedure TransDataJRJ(AList: TStrings);
    procedure TransDataSJSXXN(AList: TStrings);
    procedure TransShLof(AList: TStrings);
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); override;
    procedure TransData(const ASrc: TStrings; ADest: TStream); override;
    procedure TransData(const AList: TStrings); overload; virtual;
  end;

{ THtmlFundNav }

class function THtmlwebFundNav.SupportedFileKind: TFileKindSet;
begin
  Result := [fkFundNav];
end;

procedure THtmlwebFundNav.Trans(const ASrcFile, ADestFile: TFileName;  const Param: String);
begin
  FDate := Param;
  inherited;
end;

procedure THtmlwebFundNav.TransData(const AList: TStrings);
begin
  TransDataWeb(AList);
  TransDataDBF(AList);
  TransData123(AList);
  TransDataFinaWeb(AList);
end;

procedure THtmlwebFundNav.TransData(const ASrc: TStrings; ADest: TStream);

var
  FFile: String;
  Temporarylist: TStringlist;
  FStream: TFileStream;
begin
  Temporarylist := TStringlist.Create;
  Temporarylist.Clear;

  TransData(Temporarylist);
  
  TransDataNavlist(ADest, Temporarylist);
  FFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'NAV';
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
  Temporarylist.Free;
end;

procedure THtmlwebFundNav.TransDataDBF(Temporarylist: TStrings);
begin
{$REGION'  SJSXXN.DBF  '}
  try
    writeln('开始处理 深交所数据库...');
    TransDataSJSXXN(Temporarylist);
  except on E: Exception do
  end;
  try
    writeln('开始处理 上交所LOF...');
    TransShLof(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}
end;

procedure THtmlwebFundNav.TransDataWeb(Temporarylist: TStrings);
begin

{$REGION'   GuoTai Fund  '}
  try
    writeln('开始处理 国泰基金...');
    TransDataGuoTai(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  JinYing Fund  '}
  try
    writeln('开始处理 金鹰基金...');
    TransDataJinYing(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION' HuaShang Fund  '}
  try
    writeln('开始处理 华商基金...');
    TransDataHuaShang(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  ZhongOu Fund  '}
  try
    writeln('开始处理 中欧基金...');
    TransDataZhongOu(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   NuoDe Fund   '}
  try
    writeln('开始处理 诺德基金...');
    TransDataNuoDe(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   XingYe Fund  '}
  try
    writeln('开始处理 兴业基金...');
    TransDataXingYe(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   YinHe Fund   '}
  try
    writeln('开始处理 银河基金...');
    TransDataYinHe(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   HuaAn Fund   '}
  try
    writeln('开始处理 华安基金...');
    TransDataHuaAn(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   FuGuo Fund   '}
  try
    writeln('开始处理 富国基金...');
    TransDataFuGuo(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   JiaShi Fund  '}
  try
    writeln('开始处理 嘉实基金...');
    TransDataJiaShi(Temporarylist);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION'   YinHua Fund  '}
  try
    writeln('开始处理 银华基金...');
    TransDataYinHua(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   XinHua Fund  '}
  try
    writeln('开始处理 新华基金...');
    TransDataXinHua(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   DongWu Fund  '}
  try
    writeln('开始处理 东吴基金...');
    TransDataDongWu(Temporarylist);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION'  WanJia Fund   '}
  try
    writeln('开始处理 万家基金...');
    TransDataWanJia(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  PengHua Fund  '}
 try
    writeln('开始处理 鹏华基金...');
    TransDataPengHua(Temporarylist);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION'  JianXin Fund  '}
 try
    writeln('开始处理 建信基金...');
    TransDataJianXin(Temporarylist);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION'  GuangFa Fund  '}
 try
    writeln('开始处理 广发基金...');
    TransDataGuangFa(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  GongYin Fund  '}
  try
    writeln('开始处理 工银基金...');
    TransDataGongYin(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  NanFang Fund  '}
  try
    writeln('开始处理 南方基金...');
    TransDataNanFang(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION' ZheShang Fund  '}
  try
    writeln('开始处理 浙商基金...');
    TransDataZheShang(Temporarylist);
  except on E: Exception do
  end;
 {$ENDREGION}

{$REGION' XinCheng Fund  '}
  try
    writeln('开始处理 信诚基金...');
    TransDataXinCheng(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  ZhaoShang Fund  '}
  try
    writeln('开始处理 招商基金...');
    TransDataZhaoShang(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  ChangSheng Fund '}
  try
    writeln('开始处理 长盛基金...');
    TransDataChangSheng(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  GuoLianAn Fund  '}
  try
    writeln('开始处理 国联安基金...');
    TransDataGuoLianAn(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  YiFangDa  Fund  '}
 try
    writeln('开始处理 易方达基金...');
    TransDataYiFangDa(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  HuiTianFu Fund  '}
  try
    writeln('开始处理 汇添富基金...');
    TransDataHuiTianFu(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  GuoTuRuiYin Fund  '}
  try
    writeln('开始处理 国投瑞银基金...');
    TransDataGuoTuRuiYin(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  TaiDaHongLi Fund  '}
  try
    writeln('开始处理 泰达宏利基金...');
    TransDataTaiDaHongLi(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  ShenWanLingxin Fund  '}
  try
    writeln('开始处理 申万菱信基金...');
    TransDataShenWan(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  GuoJinTongYong Fund  '}
  try
    writeln('开始处理 国金通用基金...');
    TransDataGuoJin(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

end;

procedure THtmlwebFundNav.TransData123(Temporarylist: TStrings);
begin
{$REGION'   Fund 123   '}
  try
    writeln('开始处理 123基金...');
    TransDatafund123(Temporarylist);
  except on E: Exception do
  end;
  
  {$ENDREGION}
end;

procedure THtmlwebFundNav.TransDataFinaWeb(Temporarylist: TStrings);
begin
{$REGION'  iFund  '}
 try
    writeln('开始处理 爱基金...');
    TransDataifund(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'   JRJ Fund   '}
  try
    writeln('开始处理 金融界基金...');
    TransDataJRJ(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION'  HeXun Fund    '}
 try
    writeln('开始处理 和讯网基金...');
    TransDataHeXun(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}

{$REGION ' Stockstar Fund '}
  try
    writeln('开始处理 证券之星基金...');
    TransDatastockstar(Temporarylist);
  except on E: Exception do
  end;
{$ENDREGION}
end;

procedure THtmlwebFundNav.TransDataNavlist(ADest: TStream; AList: TStrings);

  procedure WriteNavFile( ADest: TStream; AList: TStrings; AFileName:string);
  var
    I,K: Integer;
    List1,List2,List3: TStringlist;
    FStream: TFileStream;
  begin
    List1:= TStringlist.Create;
    List2:= TStringlist.Create;
    List3:= TStringlist.Create;
    TStringlist(AList).Sort;
    //处理同一代码数据
    K := 1;
    List3.Add(inttostr(K));
    List1.CommaText := AList[0];
    I := 1;
    while I <= AList.Count-1 do
    begin
      List2.CommaText:=AList[I];
      if strtocurr(List1[3]) = strtocurr(List2[3]) then
        begin
          inc(K);
          List3.Add(inttostr(K));
          List3[I-1] := '0';
          inc(I);
        end
      else
        begin
          K := 1;
          List3.Add(inttostr(K));
          List1.CommaText := AList[I];
          inc(I);
        end;
    end;
    //输出最终净值数据
    K := 1;
    List1.Clear;
    for I := 0 to List3.Count - 1 do
    begin
      if strtofloat(List3[I]) >= AList.Count/2 then
      begin
        List1.CommaText := AList[I];
        K := K * -1;
      end;
    end;

    case K of
    -1:  write(ADest,List1);
     1:  begin
          if FileExists(AFileName) then
            FStream := TFileStream.Create(AFileName, fmOpenWrite)
          else
            FStream := TFileStream.Create(AFileName, fmCreate);
          try
            FStream.Seek(0, soFromEnd);
            AList.SaveToStream(FStream);
          finally
            FStream.Free;
          end;
         end;
    end;

    List1.Free;
    List2.Free;
    List3.Free;
  end;

var
  FFile,FFile1,Date:String;
  List1,List2,List3: TStringlist;
  I: Integer;
begin
  FFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))+ 'ErrorNAV';
  ForceDirectories(FFile);
  FFile1 :=  FFile +'\'+ formatDateTime('YYYYMMDDHHMMSS', now) + '.txt';
  List1 := TStringlist.Create;
  List2 := TStringlist.Create;
  List3 := TStringlist.Create;
  Date := GetInfFromDB('SELECT ytbase.dbo.GetPrecTradeDay()');//上一交易日期
  TStringlist(AList).Sort;
  I:=0;
  while pos(Date,AList[I])=0 do
    inc(I);
  List2.Add(AList[I]);
  List1.CommaText := AList[I];
  inc(I);
  while I <= AList.Count-1 do
  begin
    if pos(Date,AList[I])>0 then
      begin
      if (List1[2]<>'') and (List1[2]<>'OF') and (pos(List1[2],AList[I])>0) then
        begin
          List2.Add(AList[I]);
          inc(I);
        end
      else
        begin
          WriteNavFile(ADest,List2,FFile1);
          List2.Clear;
          List2.Add(AList[I]);
          List1.CommaText := AList[I];
          inc(I);
        end;
      end
    else
      inc(I);
  end;
  WriteNavFile(ADest,List2,FFile1);
  //发送异常数据到邮箱
  if FileExists(FFile1) then
  begin
    List3.LoadFromFile(FFile1);
    if List3.Count > 0 then
      MailErrInf(List3.Text);
  end;
  List1.Free;
  List2.Free;
  List3.Free;
end;

procedure THtmlwebFundNav.MailErrInf(ErrInf: String);
var
  IdSMTP1: TIdSMTP;
  IdMessage1: TIdMessage;
  inifile1: Tinifile;
  mailinf: String;
  List: TStringlist;
begin
  IdSMTP1 := TIdSMTP.Create;
  IdMessage1 := TIdMessage.Create;
  List := TStringlist.Create;
  inifile1 := TIniFile.Create('Param\mailinf.ini');
  mailinf := inifile1.Readstring('mail','inf','');
  List.CommaText := mailinf;
  if length(ErrInf) > 0 then
  begin
    try
      IdSMTP1.Host := List[0];
      IdSMTP1.Username := List[1];
      IdSMTP1.Password := List[2];
      IdSMTP1.Port := strtoint(List[3]);
      IdSMTP1.Capabilities.Add('Auth=Login');
      IdSMTP1.Connect;
      IdMessage1.Recipients.EMailAddresses := List[4];
      IdMessage1.From.Address := List[5];
      IdMessage1.Subject := List[6];
      IdMessage1.Body.Text := ErrInf;
      IdSMTP1.Authenticate;
      IdSMTP1.Send(IdMessage1);
      IdSMTP1.Disconnect;
    except
      IdSMTP1.Disconnect;
      Exit;
    end;
  end;
  IdSMTP1.Free;
  IdMessage1.Free;
  List.Free;
end;

procedure THtmlwebFundNav.TransDataSJSXXN(AList: TStrings);

  function GetDBFPath: String;
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
          AList.Add(rq+','+ASC+','+ASC+dm+','+jz+','+jz+','+jz+','+jz+',0,0');
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
  FFile := FPath + '\VSATDX\SJSXXN.DBF';
  TrasnDataSZ(FFile, AList);
end;

procedure THtmlwebFundNav.TransShLof(AList: TStrings);

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
      AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataifund(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataHeXun(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDatafund123(AList: TStrings);

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

        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDatastockstar(AList: TStrings); //更新为 集思录 官网数据 20150717

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataJRJ(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataFuGuo(AList: TStrings);

  function DataToList(const AData: String): TStrings;
  var
    FData: String;
    reg: TPerlRegEx;
  begin
    Result := TStringList.Create;
    FData := GetStr(AData,'晨星评级','富国富钱包');
    FData := stringreplace(FData,slinebreak,'',[rfreplaceall]);
    reg := TPerlRegEx.Create(nil);
    reg.Subject := FData;
    reg.RegEx := '<td class="ttit">.*?<tr>';
    while reg.MatchAgain do
    begin
      Result.Add(reg.MatchedExpression);
    end;
    reg.free;
  end;

  procedure SolveFundNavInfo(AList: TStrings; const ADestContent: TStrings);
  const
    IDX_DATE = 1;
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
      FDate := stringreplace(FDate,'-','',[rfreplaceall]);
      FCode := ADestContent[IDX_CODE];
      AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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
      FContant.Add(S);
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<td>.*?</td>';
      while reg.MatchAgain do
      begin
        S := GetStr(reg.MatchedExpression,'<td>','</td>');
        FContant.Add(S);
      end;
      reg.free;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

procedure THtmlwebFundNav.TransDataNuoDe(AList: TStrings);

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
      AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataGuoTai(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataXingYe(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataZhongOu(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataYinHua(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataPengHua(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataShenWan(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataGongYin(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataXinCheng(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataZhaoShang(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataChangSheng(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataHuaShang(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataHuiTianFu(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataGuoLianAn(AList: TStrings);

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
          AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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
      FContant.Add(S);
      reg := TPerlRegEx.Create(nil);
      reg.Subject := FData;
      reg.RegEx := '<td class="center">.*?</td>';
      while reg.MatchAgain do
      begin
        FContant.Add(GetStr(reg.MatchedExpression,'<td class="center">','</td>'));
      end;
      SolveFundNavInfo(AList, FContant);
    end;
  finally
    FContant.Free;
    FList.Free;
  end;
end;

procedure THtmlwebFundNav.TransDataGuangFa(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataGuoJin(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataYiFangDa(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataGuoTuRuiYin(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataTaiDaHongLi(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataXinHua(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
      end;
    end;
  end;

const
  url='http://www.ncfund.com.cn/main/index.shtml';
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

procedure THtmlwebFundNav.TransDataJianXin(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataZheShang(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataDongWu(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataJiaShi(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataJinYing(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataNanFang(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataHuaAn(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataYinHe(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

procedure THtmlwebFundNav.TransDataWanJia(AList: TStrings);

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
        AList.Add(FDate+','+S_MARKET+','+S_MARKET+FCode+','+FNav+','+FNav+','+FNav+','+FNav+',0,0');
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

{$ENDREGION}

{$REGION' fkFundNavWeb '}

type
  THtmlwebFundNavWeb = class(THtmlwebFundNav)
  protected
    procedure TransData(const AList: TStrings); overload; override;
  protected
    class function SupportedFileKind(): TFileKindSet; override;
  end;

{ THtmlFundNav }

procedure THtmlwebFundNavWeb.TransData(const AList: TStrings);
begin
  TransDataWeb(AList);
end;

class function THtmlwebFundNavWeb.SupportedFileKind: TFileKindSet;
begin
  Result := [fkFundNavWeb];
end;

{$ENDREGION}

{$REGION' fkFundNavDBF '}

type
  THtmlwebFundNavDBF = class(THtmlwebFundNav)
  protected
    procedure TransData(const AList: TStrings); overload; override;
  protected
    class function SupportedFileKind(): TFileKindSet; override;
  end;

{ THtmlFundNav }

procedure THtmlwebFundNavDBF.TransData(const AList: TStrings);
begin
  TransDataDBF(AList);
end;

class function THtmlwebFundNavDBF.SupportedFileKind: TFileKindSet;
begin
  Result := [fkFundNavDBF];
end;

{$ENDREGION}

{$REGION' fkFundNavfund123 '}

type
  THtmlwebFundNavfund123 = class(THtmlwebFundNav)

  protected
    procedure TransData(const AList: TStrings); overload; override;
  protected
    class function SupportedFileKind(): TFileKindSet; override;
  end;

{ THtmlFundNav }

procedure THtmlwebFundNavfund123.TransData(const AList: TStrings);
begin
  TransData123(AList);
end;


class function THtmlwebFundNavfund123.SupportedFileKind: TFileKindSet;
begin
  Result := [fkFundNavfund123];
end;

{$ENDREGION}

initialization

  THtmlFileSHStop.Register;
  THtmlFileSZStop.Register;
  THtmlFileEastSzStop.Register;
  THtmlFileSzFundInfo.Register;
  THtmlFileShFundInfo.Register;
  THtmlFileEastStop.Register;
  THtmlFileWindStop.Register;
  THtmlwebFundNav.Register;
  THtmlwebFundNavWeb.Register;
  THtmlwebFundNavDBF.Register;
  THtmlwebFundNavfund123.Register;

  coinitialize(nil);

finalization
  couninitialize();
  
end.

