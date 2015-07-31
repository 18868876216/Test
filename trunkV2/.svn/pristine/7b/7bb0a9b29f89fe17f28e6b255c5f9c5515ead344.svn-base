unit uWinnerDayDatTrans;

interface
uses DataLayer, SysUtils, Forms, Windows, Classes, SyncObjs, uDataLayerProtocol,
  Dialogs;

type
  TWinnerDayDatTran = class
  private
    FDataLayer: TDataLayer;
    FModuleID: Integer;
    FbInti: Boolean;
  public
    constructor Create;
    procedure Init;
    function GetJJCodes: TList;
    procedure CollectJJCodeInfoAns(pAnsData: PAnswerData; var List: TList);//行情程序通讯消息头
    procedure TransWinnerDayData(var CodeList: TList; nDays: Integer; FileName: string);
  end;

procedure TransWinnerDayData;

implementation
var
  theWinnerDayDatTran: TWinnerDayDatTran;
  theEvent: TEvent;

  { TWinnerDayDatTran }

function OnUpdate(serverType: Integer; iFunctionID: Integer; pAnsData: Pointer): Integer; cdecl
begin                                  //cdecl按从右至左的顺序压参数入栈，由调用者把参数弹出栈
  if iFunctionID = 998 then
  begin
    theEvent.SetEvent; //有信号
    OutputDebugString('代码初始化完成.');
  end;
end;

procedure TransWinnerDayData;
var
  List: TList;
  I: Integer;
begin
  theEvent.ResetEvent; //无信号
  theWinnerDayDatTran.Init;
  if (wrSignaled = theEvent.WaitFor(30 * 1000)) then//
  begin
    List := theWinnerDayDatTran.GetJJCodes;
    theWinnerDayDatTran.TransWinnerDayData(List, 3, 'c:\temp.csv');
  end;
end;

constructor TWinnerDayDatTran.Create;
begin
  FbInti := False;
end;

function TWinnerDayDatTran.GetJJCodes: TList;
var
  List: TList;
  pReqData: PRequestData;
  pItem: pCodeInfo;
  ReqLen: Integer;

  pData: PChar;
  pAns: Pointer;
  ReqResult: Integer;
  I: Integer;
  pCode: pStockUserInfo;
begin
  List := nil;

  ReqLen := SizeOf(TRequestData);
  pData := AllocMem(ReqLen);//allocmem函数是指在队中分配指定字节的内存块，将分配的每一个字节初始化为 0
  pReqData := PRequestData(pData);
  pReqData.Version := 1;
  pReqData.Len := SizeOf(TCode);
  pReqData.ModuleID := Self.FModuleID;
  pReqData.FunctionID := 1000;
  pReqData.ServerType := Ord('a');
  pReqData.ReqSize := 0;
  pReqData.ReqData := nil;

  try
    //同步请求
    ReqResult := FDataLayer.FDoSynRequest(pReqData, pAns, 10);
    if ReqResult <> 0 then
    begin
      ShowMessage('请求失败.ReqResult=' + IntToStr(ReqResult));
    end;

    //处理应答
    if (pAns <> nil) then
    begin
      List := TList.Create;
      CollectJJCodeInfoAns(PAnswerData(pAns), List);
      //释放同步应答指针
      FDataLayer.FReleaseAnsData(pAns);
    end;

  finally
    pData := PChar(pReqData);
    FreeMem(pData);
  end;

  Result := List;

end;

procedure TWinnerDayDatTran.Init;
var
  AppPath, Config, SvrFile: string;
  StringList: TStringList;
  I: Integer;
begin
  if FbInti = True then
    Exit;
  AppPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)); //最后一个字符是路径分隔符则不变;否则加上一个路径分隔符返回
  FDataLayer := TDataLayer.Create;          //返回完整文件名中的路径
  FDataLayer.DoInit(PChar(AppPath));
  FDataLayer.FInitalize(PChar(AppPath));
  FModuleID := FDataLayer.FGetModuleId;
  FDataLayer.FRegisterOnUpdate(FModuleID, OnUpdate);

  StringList := TStringList.Create;
  SvrFile := AppPath + 'server.xml';
  StringList.LoadFromFile(SvrFile);  //
  for I := 0 to StringList.Count - 1 do
  begin
    Config := Config + StringList[I];
  end;
  FDataLayer.FSetConfig(PChar(Config), Length(Config));
  StringList.Free;

  FbInti := True;
end;

procedure TWinnerDayDatTran.TransWinnerDayData(var CodeList: TList; nDays: Integer; FileName: string);
var
  pCodeInfo: PStockUserInfo;
  pReqData: PRequestData;
  pAnswer: PAnswerData;
  pDayReq: PReqDayData;
  I, J, ReqLen, ReqResult: Integer;
  pData: PChar;
  pAns: Pointer;
  F: Textfile;
  pAnsDay: PAnsDayDataEx;
  pStockDayData: PStockCompDayDataEx;
  sTemp: string;
begin
  if (CodeList = nil) then
    Exit;

  if fileExists(FileName) then
    DeleteFile(PChar(FileName));
  AssignFile(F, PChar(FileName));
  ReWrite(F);
  Writeln(F, 'dm,rq,kp,zg,zd,sp,cjl,cje,sl,xd');
  for I := 0 to CodeList.Count - 1 do
  begin
    pCodeInfo := PStockUserInfo(CodeList.Items[I]);

    ReqLen := SizeOf(TRequestData) + SizeOf(TReqDayData);
    pData := AllocMem(ReqLen);

    pReqData := PRequestData(pData);
    pReqData.Version := 1;
    pReqData.Len := ReqLen;
    pReqData.ModuleID := Self.FModuleID;
    pReqData.FunctionID := 1011;
    pReqData.ServerType := Ord('a');
    pReqData.ReqSize := 1;
    Inc(pData, SizeOf(TRequestData));
    pReqData.ReqData := pData;
    pDayReq := PReqDayData(pReqData.ReqData);

    pDayReq.m_nPeriodNum := 1;
    pDayReq.m_nSize := 0;
    pDayReq.m_lBeginPosition := 0;
    pDayReq.m_nDay := nDays;
    pDayReq.m_cPeriod := PERIOD_TYPE_DAY;
    pDayReq.m_ciCode := pCodeInfo.StockInfo;

    //同步请求
    ReqResult := FDataLayer.FDoSynRequest(pReqData, pAns, 10);
    if ReqResult <> 0 then
    begin
      ShowMessage('请求失败.ReqResult=' + IntToStr(ReqResult));
    end;

    //处理应答
    if (pAns <> nil) then
    begin
      pAnswer := PAnswerData(pAns);
      pAnsDay := PAnsDayDataEx(pAnswer.AnsData);
      pStockDayData := @pAnsDay.DayDataEx;
      for J := 0 to pAnsDay.m_nSize - 1 do
      begin
        SetLength(sTemp, 6);
        Move(pCodeInfo.StockInfo.Code, sTemp[1], 6);
        sTemp := sTemp + ',' + IntToStr(pStockDayData.m_lDate); //rq 日期
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lOpenPrice / 1000); //kp 开盘
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lMaxPrice / 1000); //zg 最高
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lMinPrice / 1000); //zd 最低
        if pStockDayData.m_lNationalDebtRatio <> 0 then
        begin
          sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lNationalDebtRatio / 1000); //sp 收盘
        end
        else
        begin
          sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lClosePrice / 1000); //sp 收盘
        end;
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lTotal / 1000); //cjl 成交量
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lMoney / 1000); //cje 成交金额
        sTemp := sTemp + ',0'; //sl 上涨
        sTemp := sTemp + ',0'; //xd 下跌
        Writeln(F, sTemp);

        Inc(pStockDayData, 1);
      end;
      //释放同步应答指针
      FDataLayer.FReleaseAnsData(pAns);
    end;

  end;
  Closefile(F);
end;

procedure TWinnerDayDatTran.CollectJJCodeInfoAns(pAnsData: PAnswerData;
  var List: TList);
var
  pAnsEnty: PChar;
  pCodeInfo, pCodeInfoNew: PStockUserInfo;
  I: Integer;
begin
  pAnsEnty := pAnsData.AnsData;
  for I := 0 to pAnsData.AnsSize - 1 do
  begin
    pCodeInfo := PStockUserInfo(pAnsEnty);
    if ((pCodeInfo.StockInfo.CodeType and $F00F) = (STOCK_MARKET or KIND_FUND)) or
     ((pCodeInfo.StockInfo.CodeType and $FF0F) = (STOCK_MARKET or SZ_Bourse or SC_Others)) then
    begin
      New(pCodeInfoNew);
      pCodeInfoNew^ := pCodeInfo^;
      List.Add(pCodeInfoNew);
    end;
    Inc(pAnsEnty, SizeOf(TStockUserInfo));
  end;
end;

initialization
  theWinnerDayDatTran := TWinnerDayDatTran.Create;
  theEvent := Tevent.Create(nil, true, true, '');

finalization
  theWinnerDayDatTran.Free;
  theEvent.Free

end.

