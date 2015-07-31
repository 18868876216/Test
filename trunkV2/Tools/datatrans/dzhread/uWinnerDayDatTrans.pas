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
    procedure CollectJJCodeInfoAns(pAnsData: PAnswerData; var List: TList);//�������ͨѶ��Ϣͷ
    procedure TransWinnerDayData(var CodeList: TList; nDays: Integer; FileName: string);
  end;

procedure TransWinnerDayData;

implementation
var
  theWinnerDayDatTran: TWinnerDayDatTran;
  theEvent: TEvent;

  { TWinnerDayDatTran }

function OnUpdate(serverType: Integer; iFunctionID: Integer; pAnsData: Pointer): Integer; cdecl
begin                                  //cdecl�����������˳��ѹ������ջ���ɵ����߰Ѳ�������ջ
  if iFunctionID = 998 then
  begin
    theEvent.SetEvent; //���ź�
    OutputDebugString('�����ʼ�����.');
  end;
end;

procedure TransWinnerDayData;
var
  List: TList;
  I: Integer;
begin
  theEvent.ResetEvent; //���ź�
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
  pData := AllocMem(ReqLen);//allocmem������ָ�ڶ��з���ָ���ֽڵ��ڴ�飬�������ÿһ���ֽڳ�ʼ��Ϊ 0
  pReqData := PRequestData(pData);
  pReqData.Version := 1;
  pReqData.Len := SizeOf(TCode);
  pReqData.ModuleID := Self.FModuleID;
  pReqData.FunctionID := 1000;
  pReqData.ServerType := Ord('a');
  pReqData.ReqSize := 0;
  pReqData.ReqData := nil;

  try
    //ͬ������
    ReqResult := FDataLayer.FDoSynRequest(pReqData, pAns, 10);
    if ReqResult <> 0 then
    begin
      ShowMessage('����ʧ��.ReqResult=' + IntToStr(ReqResult));
    end;

    //����Ӧ��
    if (pAns <> nil) then
    begin
      List := TList.Create;
      CollectJJCodeInfoAns(PAnswerData(pAns), List);
      //�ͷ�ͬ��Ӧ��ָ��
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
  AppPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)); //���һ���ַ���·���ָ����򲻱�;�������һ��·���ָ�������
  FDataLayer := TDataLayer.Create;          //���������ļ����е�·��
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

    //ͬ������
    ReqResult := FDataLayer.FDoSynRequest(pReqData, pAns, 10);
    if ReqResult <> 0 then
    begin
      ShowMessage('����ʧ��.ReqResult=' + IntToStr(ReqResult));
    end;

    //����Ӧ��
    if (pAns <> nil) then
    begin
      pAnswer := PAnswerData(pAns);
      pAnsDay := PAnsDayDataEx(pAnswer.AnsData);
      pStockDayData := @pAnsDay.DayDataEx;
      for J := 0 to pAnsDay.m_nSize - 1 do
      begin
        SetLength(sTemp, 6);
        Move(pCodeInfo.StockInfo.Code, sTemp[1], 6);
        sTemp := sTemp + ',' + IntToStr(pStockDayData.m_lDate); //rq ����
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lOpenPrice / 1000); //kp ����
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lMaxPrice / 1000); //zg ���
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lMinPrice / 1000); //zd ���
        if pStockDayData.m_lNationalDebtRatio <> 0 then
        begin
          sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lNationalDebtRatio / 1000); //sp ����
        end
        else
        begin
          sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lClosePrice / 1000); //sp ����
        end;
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lTotal / 1000); //cjl �ɽ���
        sTemp := sTemp + ',' + FloatToStr(pStockDayData.m_lMoney / 1000); //cje �ɽ����
        sTemp := sTemp + ',0'; //sl ����
        sTemp := sTemp + ',0'; //xd �µ�
        Writeln(F, sTemp);

        Inc(pStockDayData, 1);
      end;
      //�ͷ�ͬ��Ӧ��ָ��
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

