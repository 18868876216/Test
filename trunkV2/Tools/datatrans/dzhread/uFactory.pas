{******************************************************************************}
{ @UnitName     : uFactory.pas                                                 }
{ @Project      : CoreObj                                                      }
{ @Copyright    : Hundsun Electronics Co,.Ltd.                                 }
{ @Author       : Budded                                                       }
{ @Description  : CoreObj Facroty                                              }
{ @FileVersion  : 1.0.0.0                                                      }
{ @CreateDate   : 2007-08-04                                                   }
{ @Comment      :                                                              }
{ @LastUpdate   : Budded, 2007-08-04                                           }
{ @History      : Created By Budded, 2007-08-04 12:00                          }
{******************************************************************************}
unit uFactory;

interface

uses
  SysUtils, Windows, Classes, uContainer;

type
  /// �ֶ�����
  TFieldType = (ftSeek, ftString, ftDate, ftDateTime, ftSingle,
    ftByte, ftShortInt, ftSmallInt, ftInteger, ftIntAuto, ftSingleD10);

  /// ת���ļ�����
  TFileKind = (
    fkSplit,                                      // ��Ȩ
    fkStockInfo,                                  // ��Ʊ��Ϣ
    fkStockInfoEx,                                // �г�+����+���
    fkFinReport,                                  // ���񱨱�
    fkDay, fkMin, fkMin5, fkTick,                 // ֤ȯK��
    fkFutuDay, fkFutuMin, fkFutuMin5, fkFutuTick, // �ڻ�K��
    fkShStopInfo,                                 // �Ϻ�ͣ��
    fkSzStopInfo,                                 // ����ͣ��
    fkSzFundInfo,                                 // ���ڻ����ģ
    fkShFundInfo,                                 // �Ϻ������ģ
    fkEastSzStopInfo,                             // ����ͣ��-�����Ƹ�
    fkBlockInfo,                                  // �����Ϣ
    fkBlockStock,                                 // ������
    fkHS300Info,                                  // ����300����
    fkEastStopInfo,                               // ͣ��-�����Ƹ�
    fkWindStopInfo,                               // ͣ��-���
    fkFundNav,                                    // ����ֵ
    fkFundNavWeb,                                 // ����ֵ-����
    fkFundNavDBF,                                 // ����ֵ-DBF
    fkFundNavfund123,                             // ����ֵ-fund123
    fkETFInfo,                                    // ETF��Ϣ
    fkETFComponent,                               // ETF�ɷݹ�
    fkStockDay,                                   // �ڻ�K��
    fkFundNavToDB,                                // ����ȫ�������
    fkFutuJsj                                     // �ڻ������
  );

  TFileKindSet = Set Of TFileKind;

  PFieldInfo = ^TFieldInfo;
  TFieldInfo = record
    Order,
    Length: Integer; // ���ݳ���
    FT: TFieldType; // ��������
    Name,
    Caption: string;
    Digit: Integer; // ���ݾ���
  end;

  IDataTrans = interface
  ['{0F03AD06-41B3-46FE-851B-876B25BFA192}']  //������
    procedure SetFilter(const ABeginDate, AEndDate: String); overload;
    procedure SetFilter(const ABeginDate, AEndDate: Integer); overload; //��������
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); overload;
  end;

  TDataTrans = class(TInterfacedObject, IDataTrans)  //
    FParam: TList;
    FDateBegin, FDateEnd: Integer;
    FFileSrc, FFileDest: TFileName;
    FFileKind: TFileKind;
  protected
    class function SupportedFileKind(): TFileKindSet; virtual; abstract;
    class function Register: Integer;
    
    procedure DoInit(const AKind: TFileKind); virtual;
    procedure WriteHeader(const ADest: TStream); 
    procedure Write(const ADest: TStream; const Data: TStrings); 
    function Filter(const Data: TStrings): Boolean; virtual;
    function GetFilterField: String; virtual;

    class function SockGet(const AUrl: String): String; overload;
    class function SockGet(const AUrl: String; out Data: String): Boolean; overload;
  protected
    procedure SetFilter(const ABeginDate, AEndDate: String); overload;
    procedure SetFilter(const ABeginDate, AEndDate: Integer); overload;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); overload; virtual;
    procedure TransData(const ASrcFile, ADestFile: TFileName); overload;
    procedure TransData(const ASrcFile: TFileName; const ADest: TStream); overload; virtual;
    procedure TransData(const ASrc, ADest: TStream); overload; virtual; abstract;

  public
    constructor Create(const AKind: TFileKind); reintroduce; overload; virtual;
    destructor Destroy(); override;
    property Param: TList read FParam;
    property FileKind: TFileKind read FFileKind;
    property FileSrc: TFileName read FFileSrc;  
    property FileDest: TFileName read FFileDest;
    property DateBegin: Integer read FDateBegin;
    property DateEnd: Integer read FDateEnd;
  end;
  TDataTransRef = class of TDataTrans;  //��

  IRegister = interface
  ['{B04273C4-CCBF-4E96-8B7E-1B737513FB7B}']
    function Register(Item: TDataTransRef): Integer;
    function UnRegister(Item: TDataTransRef): Integer;
  end;  

  TRefEnumerator = class(TListEnumerator)
  public
    function GetCurrent: TDataTransRef;
    property Current: TDataTransRef read GetCurrent;
  end;

  // �����๤��
  TDataTransFactory = class(TContnrList, IRegister)
  strict private
    { private declarations }
    function FindID(const AID: TFileKind): TDataTransRef;
  protected
    { protected declarations } 
    constructor CreateInstance; override;
  public
    { public declarations }   
    destructor Destroy; override;
    class function Instance(): TDataTransFactory;
    function GetEnumerator: TRefEnumerator;

    function ItemByID(const AID: TFileKind): IDataTrans; overload;   
    function ItemByID(const AID: String): IDataTrans; overload;
    
  {$REGION '<<IRegister>>'}
    function Register(Item: TDataTransRef): Integer;
    function UnRegister(Item: TDataTransRef): Integer;
  {$ENDREGION}
  end;

implementation

uses
  WinInet, TypInfo, Math, uTools;

{ TDataTransFactory }

constructor TDataTransFactory.CreateInstance;
begin
  inherited;
end;

destructor TDataTransFactory.Destroy;
begin
  inherited;
end;

function TDataTransFactory.FindID(const AID: TFileKind): TDataTransRef;
begin
  for Result in Self do
    if AID in Result.SupportedFileKind then
      Exit;
                   
  Result := nil;
end;

function TDataTransFactory.GetEnumerator: TRefEnumerator;
begin
  Result := TRefEnumerator.Create(List);
end;

class function TDataTransFactory.Instance: TDataTransFactory;
begin
  Result := inherited Instance as TDataTransFactory;  //�̳�֮���������ຯ����ʲô��ϵ��
end;

function TDataTransFactory.ItemByID(const AID: String): IDataTrans;
var
  FKind: TFileKind;
begin
  FKind := TFileKind(GetEnumValue(TypeInfo(TFileKind), AID));//
  Result := ItemByID(FKind);
end;

function TDataTransFactory.ItemByID(const AID: TFileKind): IDataTrans;
var
  FMeta: TDataTransRef;
begin
  Result := nil;
  LockList;
  try
    FMeta := FindID(AID);
    if Assigned(FMeta) then
      Result := FMeta.Create(AID);
  finally
    UnLockList;
  end;
end;

function TDataTransFactory.Register(Item: TDataTransRef): Integer;
begin
  Result := inherited Add(Item);
end;

function TDataTransFactory.UnRegister(Item: TDataTransRef): Integer;
begin
  Result := inherited Remove(Item);
end;

{ TRefEnumerator }

function TRefEnumerator.GetCurrent: TDataTransRef;
begin
  Result := inherited GetCurrent;
end;

{ TDataTrans }

constructor TDataTrans.Create(const AKind: TFileKind);
begin
  inherited Create();
  FFileKind := AKind;
  FParam := TMyList.Create;
  if AKind in [Low(TFileKind)..High(TFileKind)] then
    DoInit(AKind);
end;

destructor TDataTrans.Destroy;
begin
  FParam.Free;
  inherited;
end;

procedure TDataTrans.DoInit(const AKind: TFileKind);
const
  S_FILE = '%s\Param\%s.csv';///???
var
  FFile: TFileName;
  I: Integer;
  FParam, FLine: TStrings;
  FPtr: PFieldInfo;
begin
  FFile := GetEnumName(TypeInfo(TFileKind), Ord(AKind));//Ord�Ƿ����ַ�������
  FFile := Format(S_FILE, [GetCurrPath, FFile]); //����һ��ָ����ʽ���ַ�
  if FileExists(FFile) then        //����ļ��Ƿ����
  begin
    FParam := TStringList.Create;
    FLine := TStringList.Create;
    try
      FParam.LoadFromFile(FFile);//
      for I := 1 to FParam.Count - 1 do
      begin
        FLine.CommaText := FParam[I];            //
        if FLine.Count > 4 then
        begin
          if Length(Trim(FLine[0])) = 0 then   //trim����ȥ�������ַ���ǰ��Ŀո�
            Break;

          new(FPtr);                   //�����µĶ�̬����������һָ�����ָ����
          ZeroMemory(FPtr, SizeOf(TFieldInfo));   //�����Ӧ�ֽڳ����ڴ棻
          FPtr.Order := I;
          FPtr.Length := StrToIntDef(FLine[1], 0);
          FPtr.ft := TFieldType(GetEnumValue(TypeInfo(TFieldType), FLine[2]));
          FPtr.Name := FLine[3];
          FPtr.Caption := FLine[4];
          if FPtr.FT in [ftSingle] then
          begin
            FPtr.Digit := 3;
            if FLine.Count > 5 then
              FPtr.Digit := StrToIntDef(FLine[5], 3);
          end;
          Param.Add(FPtr);              //
        end;
      end;  
    finally
      FLine.Free;
      FParam.Free;
    end;
  end;
end;

function TDataTrans.Filter(const Data: TStrings): Boolean;

  function GetIndex(): Integer;
  var
    FFild: String;
    FLst: TList;
    FPtr: PFieldInfo;
  begin
    FFild := GetFilterField;
    FLst := Param;
    if Assigned(FLst) and (Length(FFild) > 0) then    //���Ժ�������̱����Ƿ�Ϊ��
      for Result := 0 to FLst.Count - 1 do
      begin
        FPtr := FLst[Result];
        if Assigned(FPtr) and (FPtr.FT in [ftDate, ftDateTime]) and SameStr(FPtr.Name, FFild) then
          Exit;
      end;
    Result := NegativeValue;
  end;
  function FilterEx(const AIdx, ABegin, AEnd: Integer): Boolean; overload;
  var
    FDate: Integer;
  begin
    FDate := StrToIntDef(Data[AIdx], ZeroValue);
    Result := InRange(FDate, ABegin, AEnd);
  end;
  function FilterEx(const AIdx, ADayCount: Integer): Boolean; overload;
  {$J+}
  const FBegin: Integer = NegativeValue;
  {$J-}
  var
    FYear, FMonth, FDay: Word;
    FDate: Integer;
  begin
    if FBegin = NegativeValue then
    begin
      DecodeDate(Date - ADayCount, FYear, FMonth, FDay);
      FBegin := FYear * 10000 + FMonth * 100 + FDay;
    end;

    FDate := StrToIntDef(Data[AIdx], ZeroValue);
    Result := FDate >= FBegin;
  end;
var
  FIdx: Integer;
begin
  Result := True;
  FIdx := GetIndex;

  if (FIdx <> NegativeValue) and Assigned(Data) and (Data.Count > FIdx) then
  begin
    if (DateBegin >= 19700000) or (DateBegin <= 0) then
      Result := FilterEx(FIdx, DateBegin, DateEnd) /// ����ʱ���
    else
      Result := FilterEx(FIdx, DateBegin); /// �������N������
  end;
end;

function TDataTrans.GetFilterField: String;
begin
  Result := '';
end;

class function TDataTrans.Register: Integer;
var
  FIntf: IRegister;
begin
  Result := -1;
  FIntf := TDataTransFactory.Instance;
  if Assigned(FIntf) then
    Result := FIntf.Register(Self);
end;

procedure TDataTrans.SetFilter(const ABeginDate, AEndDate: String);
var
  FDateBegin, FDateEnd: Integer;
begin
  FDateBegin := StrToIntDef(ABeginDate, 0);
  FDateEnd := StrToIntDef(AEndDate, MaxInt);
  SetFilter(FDateBegin, FDateEnd);
end;

procedure TDataTrans.SetFilter(const ABeginDate, AEndDate: Integer);
begin
  FDateBegin := ABeginDate;
  FDateEnd := AEndDate;
end;

class function TDataTrans.SockGet(const AUrl: String): String;
begin
  SockGet(AUrl, Result);
end;

class function TDataTrans.SockGet(const AUrl: String;
  out Data: String): Boolean;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1024] of Char;
  BytesRead: dWord;
begin
  Result := False;
  NetHandle := InternetOpen('Delphi 11.x', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  if Assigned(NetHandle) then 
  begin
    UrlHandle := InternetOpenUrl(NetHandle, PChar(AUrl), nil, 0, INTERNET_FLAG_RELOAD, 0);

    if Assigned(UrlHandle) then
      { UrlHandle valid? Proceed with download }
    begin
      repeat
        FillChar(Buffer, SizeOf(Buffer), 0); //fillchar���̰��ַ���ֵ������λ��λ���и�ֵ��
        if InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead) then
          Data := Data + Copy(Buffer, 0, BytesRead);
      until BytesRead = 0;
      InternetCloseHandle(UrlHandle);

      Result := True;
    end
    else
      { UrlHandle is not valid. Raise an exception. }
      //raise Exception.CreateFmt('Cannot open URL %s', [AUrl]);

    InternetCloseHandle(NetHandle);
  end
  else
    { NetHandle is not valid. Raise an exception }
    raise Exception.Create('Unable to initialize Wininet');
end;

procedure TDataTrans.Trans(const ASrcFile, ADestFile: TFileName; const Param: String);
begin
  TransData(ASrcFile, ADestFile);
end;

procedure TDataTrans.TransData(const ASrcFile: TFileName; const ADest: TStream);
var
  FStreamSrc: TStream;
begin
  FStreamSrc := TFileStream.Create(FFileSrc, fmOpenRead);
  try
    TransData(FStreamSrc, ADest);
  finally
    FStreamSrc.Free; 
  end;
end;

procedure TDataTrans.TransData(const ASrcFile, ADestFile: TFileName);
var
  FStreamDest: TStream;
begin
  FFileSrc := ASrcFile;
  FFileDest := ADestFile;
  FStreamDest := TFileStream.Create(FFileDest, fmCreate);
  try
    WriteHeader(FStreamDest);
    TransData(ASrcFile, FStreamDest);
  finally
    FStreamDest.Free;
  end;
end;

procedure TDataTrans.Write(const ADest: TStream; const Data: TStrings);
{$J+}
  const iCount: Integer = 0;
{$J-}
var
  S, FBuff: String;
begin
  if Assigned(ADest) and Assigned(Data) then
  begin
    for S in Data do
      FBuff := FBuff + S + ',';

    FBuff := Copy(FBuff, 1, Length(FBuff) - 1) + sLineBreak;
    ADest.WriteBuffer(Pointer(FBuff)^, Length(FBuff));
    Data.Clear;
  end;

  /// ͳ�����
  Inc(iCount);
  if iCount mod 10000 = 0 then
    Writeln('Trans Data: ', iCount);
end;

procedure TDataTrans.WriteHeader(const ADest: TStream);
var
  FList: TStrings;
  FPtr: Pointer;
begin
  FList := TStringList.Create;
  try
    for FPtr in Param do
      FList.Add(PFieldInfo(FPtr).Name);
      
    Write(ADest, FList);
  finally
    FList.Free;
  end;
end;

end.