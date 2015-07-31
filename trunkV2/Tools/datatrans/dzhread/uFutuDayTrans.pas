unit uFutuDayTrans;

interface

uses
  SysUtils, Classes, uFactory, IniFiles, uTools, DateUtils, uHtmlFileTrans;

type
  TDate = Integer;                            // ����
  TTime = Integer;                            // ʱ��
  TPeriod = type Byte;                        // ����
  TPeriodSet = set of TPeriod;
  TVolumn = type Cardinal;                    // ����
  TValue = type Currency;                     // ���
  TValueArray = array of TValue;
  TPrice = type Currency;

{$REGION ' ����ʱ�� '}
type
  PDateTime = ^TDateTime;
  TDateTime = packed record                    // ����ʱ��
    Date: TDate;
    Time: TTime;
    Notify: Boolean;
  end;
const
  SizeOfDateTime = SizeOf(TDateTime);
{$ENDREGION}

{$REGION ' Tick Data Rec '}
type
  TDateTimeEx = packed record
    Date: TDate;
    Time: TTime;
    Millisec: TTime;
  end;
  TDataTickRecData = packed record
    New: TPrice;
    VOL: TVolumn;
    Hold: TVolumn;
    Sell: TPrice;
    SellAmount: TVolumn;
    Buy: TPrice;
    BuyAmount: TVolumn;
  end;
  PDataTickRec = ^TDataTickRec;
  TDataTickRec = packed record
    Time: TDateTimeEx;
    Data: TDataTickRecData;
  end;
const
  SizeOfDataTickRec = SizeOf(TDataTickRec);
{$ENDREGION}

type
  TFutuDayTrans = class(TDataTrans)
  private
    FDate: String;
    FTime: TTime;
    FOpen, FHigh, FLow, FClose, FCloseDiff, FCloseOld, FVOL, FVOLDiff, FVolOld: TPrice;
    function GetFutuDayPath(Param: String): String;
    function GetStr(StrSource, StrBegin, StrEnd: string): string;
  protected
    class function SupportedFileKind (): TFileKindSet; override;
    procedure Trans (const ASrcFile, ADestFile: TFileName; const Param: String); override;
    procedure TransData (const ASrc, ADest: TStream); override;
    procedure TransData (const ADest: TStream; AList: TStrings); overload;
    function QuickSortCompare (const Item1, Item2: Pointer): Integer;
    procedure ProcessData (Ptr: Pointer; Action: TListNotification);
    procedure OnMergeData (const AOld, ANew: Pointer);
  end;

implementation

uses
  Math, StrUtils,
  uContainerEx;

{$REGION'  fkFutuDay '}

procedure TFutuDayTrans.OnMergeData(const AOld, ANew: Pointer);
begin
  if assigned(AOld) and assigned(ANew) then
  begin
    FVOL := PDataTickRec(ANew).Data.VOL;
    if (FVOL >0) and (FVolOld = 0) then
      FOpen := PDataTickRec(ANew).Data.New;
    FVolOld := FVOL;
    FCloseDiff := PDataTickRec(ANew).Data.New - FCloseOld;
    if (FVOLDiff = 0) and (FCloseDiff <> 0) then
      FClose := FCloseOld;
    FCloseOld := PDataTickRec(ANew).Data.New;
    if FVOL > 0 then
    begin
      FHigh := Max(FHigh, PDataTickRec(ANew).Data.New);
      FLow := Min(FLow, PDataTickRec(ANew).Data.New);
    end;
    FreeMem(ANew);
  end;
end;

procedure TFutuDayTrans.ProcessData(Ptr: Pointer; Action: TListNotification);
begin
  if (action = lnDeleted) and assigned(Ptr) then
    FreeMem(Ptr);
end;

function TFutuDayTrans.QuickSortCompare(const Item1, Item2: Pointer): Integer;
begin
  Result := SORT_DEF_NUM;
  if assigned(Item1) and assigned(Item2) then
    Result := PDataTickRec(Item1).Time.Date - PDataTickRec(Item2).Time.Date;
end;

class function TFutuDayTrans.SupportedFileKind: TFileKindSet;
begin
  result := [fkFutuDay];
end;

function TFutuDayTrans.GetFutuDayPath(Param: String): String;
var
  FFile: TIniFile;
begin
  FFile := TIniFile.Create(GetCurrPath + '\Param\futupathinf.ini');
  try
    Result := FFile.Readstring('futudaypath',Param,'');
    Result := IncludeTrailingPathDelimiter(Result);
  finally
    FFile.Free;
  end;
end;

procedure TFutuDayTrans.Trans(const ASrcFile, ADestFile: TFileName;  const Param: String);
begin
  FDate := Param;
  if DateEnd = MaxInt then
  begin
    if FDate = '' then
      FDate := formatDateTime('YYYYMMDD', Date);
    SetFilter(FDate, FDate);
  end;
  inherited;
end;

procedure TFutuDayTrans.TransData(const ASrc, ADest: TStream);
var
  FPath, EXT: String;
  AllfileList: TStringlist;
begin
  AllfileList := TStringlist.Create;
  FPath := GetFutuDayPath('path');
  EXT := GetFutuDayPath('ext');
  EXT := ExcludeTrailingPathDelimiter(EXT);
  if DateBegin = DateEnd then
    FPath := FPath + inttostr(DateBegin);
  FindFile(AllfileList,FPath,EXT,True);
  TransData(ADest,AllfileList);
  AllfileList.free;
end;

procedure TFutuDayTrans.TransData(const ADest: TStream; AList: TStrings);
var
  List: TStringlist;
  I: Integer;
  rq,dm,kp,zg,zd,sp,cjl: String;
  FFile: String;
  FParser: TContnrListEx;
begin
  List := TStringList.Create;
  FParser := TContnrListEx.Create;
  FParser.Sorted := True;
  FParser.Duplicates := dupeMerge;
  FParser.OnMergeData := OnMergeData;
  FParser.OnProcessData := ProcessData;
  FParser.CompareFunc := QuickSortCompare;
  for I := 0 to AList.Count - 1 do
  begin
    FFile := AList[I];
    rq := GetStr(FFile, 'Quotas\', '\I');
    if (strtoint(rq) >= DateBegin) and (strtoint(rq) <= DateEnd) then
    begin
      FHigh := 0;
      FVolOld := 0;
      FClose := 0;
      FCloseOld := 0;
      FLow := maxInt;

      FFile := AList[I];
      FParser.Clear;
      FParser.FileLoad(FFile,SizeOfDataTickRec);
      dm := GetStr(FFile,rq+'\','.dat');
      dm := stringreplace(dm,'\Tick','',[rfreplaceall]);
      kp := currtostr(FOpen);
      zg := currtostr(FHigh);
      zd := currtostr(FLow);
      if FClose = 0 then
        FClose := FCloseOld;
      sp := currtostr(FClose);
      cjl := currtostr(FVOL);
      List.CommaText := rq+','+'SF'+','+'SF'+dm+','+kp+','+zg+','+zd+','+sp+','+cjl+',0,0,0';
      write(ADest,List);
    end;
  end;
  FParser.Free;
  List.free;
end;

function TFutuDayTrans.GetStr(StrSource: string; StrBegin: string; StrEnd: string):string;
var
  star,over:integer;
begin
  star := AnsiPos(StrBegin,StrSource)+ length(StrBegin);
  over := PosEx(StrEnd,StrSource, star);
  result := Copy(StrSource,star,over-star);
end;

{$ENDREGION$}

{$REGION'  fkFutuJsj '}

type
  TFutuJsj = class(TFutuDayTrans)
  private
    FDate, jsj: String;
    FTime: TTime;
    FPrice, FPriceDiff, FVOL, OldVol: TPrice;
    TempList: TStringList;
  protected
    class function SupportedFileKind (): TFileKindSet; override;
    procedure Trans (const ASrcFile, ADestFile: TFileName; const Param: String); override;
    procedure TransData (const ASrc, ADest: TStream); override;
    procedure TransData (const ADest: TStream; AList: TStrings); overload;
    function QuickSortCompare (const Item1, Item2: Pointer): Integer;
    procedure ProcessData (Ptr: Pointer; Action: TListNotification);
    procedure OnMergeData (const AOld, ANew: Pointer);
  end;

procedure TFutuJsj.OnMergeData(const AOld, ANew: Pointer);
begin
  if assigned(AOld) and assigned(ANew) then
  begin
    FTime := PDataTickRec(ANew).Time.Time;
    FPriceDiff := PDataTickRec(ANew).Data.New - FPrice;
    FPrice := PDataTickRec(ANew).Data.New;
    FVOL := PDataTickRec(ANew).Data.VOL - OldVol;
    OldVol := PDataTickRec(ANew).Data.VOL;
    if FVOL <> 0 then
      TempList.Add(inttostr(FTime)+','+currtostr(FPrice)+','+currtostr(FVOL));
    if (FVOL = 0) and (FPriceDiff <> 0) then
      jsj := currtostr(FPrice);
    FreeMem(ANew);
  end;
end;

procedure TFutuJsj.ProcessData(Ptr: Pointer; Action: TListNotification);
begin
  if (action = lnDeleted) and assigned(Ptr) then
    FreeMem(Ptr);
end;

function TFutuJsj.QuickSortCompare(const Item1, Item2: Pointer): Integer;
begin
  Result := SORT_DEF_NUM;
  if assigned(Item1) and assigned(Item2) then
    Result := PDataTickRec(Item1).Time.Date - PDataTickRec(Item2).Time.Date;
end;

class function TFutuJsj.SupportedFileKind: TFileKindSet;
begin
  result := [fkFutuJsj];
end;

procedure TFutuJsj.Trans(const ASrcFile, ADestFile: TFileName;  const Param: String);
begin
  FDate := Param;
  if DateEnd = MaxInt then
  begin
    if FDate = '' then
      FDate := formatDateTime('YYYYMMDD', Date);

    SetFilter(FDate, FDate);
  end;
  inherited;
end;

procedure TFutuJsj.TransData(const ASrc, ADest: TStream);
var
  FPath, EXT: String;
  AllfileList: TStringlist;
begin
  AllfileList := TStringlist.Create;
  FPath := GetFutuDayPath('path');
  EXT := GetFutuDayPath('ext');
  EXT := ExcludeTrailingPathDelimiter(EXT);
  if DateBegin = DateEnd then
    FPath := FPath + inttostr(DateBegin);
  FindFile(AllfileList,FPath,EXT,True);
  TransData(ADest,AllfileList);
  AllfileList.free;
end;

procedure TFutuJsj.TransData(const ADest: TStream; AList: TStrings);
var
  List, List1: TStringlist;
  I, K: Integer;
  A, B: Double;
  rq, dm: String;
  FFile: String;
  FParser: TContnrListEx;
begin
  List := TStringList.Create;
  List1 := TStringList.Create;
  FParser := TContnrListEx.Create;
  FParser.Sorted := True;
  FParser.Duplicates := dupeMerge;
  FParser.OnProcessData := ProcessData;
  FParser.OnMergeData := OnMergeData;
  FParser.CompareFunc := QuickSortCompare;
  for I := 0 to AList.Count - 1 do
  begin
    TempList := TStringList.Create;
    FFile := AList[I];
    rq := GetStr(FFile, 'Quotas\', '\I');
    if (strtoint(rq) >= DateBegin) and (strtoint(rq) <= DateEnd) then
    begin
      A := 0;
      B := 0;
      OldVol := 0;
      FPrice := 0;
      FParser.Clear;
      FParser.FileLoad(FFile,SizeOfDataTickRec);
      dm := GetStr(FFile,rq+'\','.dat');
      dm := stringreplace(dm,'\Tick','',[rfreplaceall]);
      if jsj = '' then
      begin
        if FTime >= 151600 then
           FTime := 151500;
        repeat
          FTime := FTime - 10000;
          for K := 0 to TempList.Count - 1 do
          begin
            List1.CommaText := TempList[K];
            if (strtoint(List1[0]) >= FTime) and (strtoint(List1[0]) < FTime + 10000) then
              begin
                A := A + strtofloat(List1[1]) * strtofloat(List1[2]);
                B := B + strtofloat(List1[2]);
              end;
          end;
        until B <> 0;
        jsj := floattostr(roundto(A/B,-1));
      end;
      List.CommaText := rq+','+'SF'+','+'SF'+dm+','+jsj;
      write(ADest,List);
    end;
    TempList.Free;
  end;
  FParser.Free;
  List.free;
  List1.free;

end;

{$ENDREGION}

initialization

  TFutuDayTrans.Register;
  TFutuJsj.Register;

end.