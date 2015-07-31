unit uContainerEx;

interface

uses
  SysUtils, Windows, Classes, Contnrs, SyncObjs;

type
  TListClass = class of TList;
  TQuickSortCompare = function (const Item1, Item2: Pointer): Integer of object;
  TProcessData = procedure (Ptr: Pointer; Action: TListNotification) of object;
  TOnMergeData = procedure (const AOld, ANew: Pointer) of object;

  IListLock = interface
  ['{AFA51A98-A3DA-42C8-B547-C17CC1BA24CB}']
    function LockList: TList;
    procedure UnLockList;
  end;

  IListEnumerator = interface
  ['{C5CB7F54-4617-4EE4-B44B-B6B287E4A549}']
    function MoveNext: Boolean;
    function GetCurrent: Pointer;
    property Current: Pointer read GetCurrent;
  end;
  
  IContnrListEx = interface(IListLock)
  ['{279F545A-48C1-4763-8287-99EA00461DC3}']
    function GetEnumerator: IListEnumerator;
    function GetCount: Integer;
    property Count: Integer read GetCount;
    function GetItems(const I: Integer): Pointer;
    property Items[const I: Integer]: Pointer read GetItems; default;
  end;

  IContnrListMng = interface
  ['{645F8275-337A-4D18-8A57-B75CF2F3B529}']
    procedure Clear;
    function Add(const Item: Pointer): Integer;
    function Remove(const Item: Pointer): Integer;
  end;
  
  TDuplicatesEx = (dupeIgnore, dupeAccept, dupeMerge, dupeError);

  // List
  TContnrListEx = class(TInterfacedObject, IContnrListEx, IContnrListMng)
  private
    { private declarations }
    FList: TList;
    FLocker: TCriticalSection;
    FDuplicates: TDuplicatesEx;
    FSorted: Boolean;
    FCompareFunc: TQuickSortCompare;
    FOnProcessData: TProcessData;
    FOnMergeData: TOnMergeData;
    FTag: Integer;
    procedure SetSorted(const Value: Boolean);
  protected
    { protected declarations }
    function GetItems(const I: Integer): Pointer;
    procedure SetItems(const I: Integer; const Value: Pointer);
    function GetTag: Integer;
    procedure SetTag(const Value: Integer);
    function GetCount: Integer;
    property List: TList read FList;
    function ListClass: TListClass; virtual;

    // 快速排序
    procedure QuickSort(L, R: Integer; const DoQuickSortCompare: TQuickSortCompare);
    /// 判断 Item1与Item2的先后顺序
    ///  Item1排在前则返回小于0
    ///  Item1排在后则返回大于0
    ///  两者相等则返回0
    function QuickSortCompare(const Item1, Item2: Pointer): Integer; virtual;

    procedure InsertItem(const Index: Integer; const Item: Pointer); virtual;
    procedure MergeItem(const Old: Integer; const New: Pointer); virtual;
    procedure ProcessData(Ptr: Pointer; Action: TListNotification); virtual;
    procedure DoMergeItem(const Old, New: Pointer); virtual;

    function FileBlockToMem(const Buff: Pointer; const BlockSize: Integer; out AMemBuff: Pointer): Boolean; virtual;
    function MemBlockToFile(const Buff: Pointer; const BlockSize: Integer; out AFileBuff: Pointer): Boolean; virtual;
  public
    { public declarations }
    constructor Create; virtual;
    destructor Destroy; override;
    property Tag: Integer read GetTag write SetTag;

    function LockList: TList; virtual;
    procedure UnLockList; virtual;

    procedure Assign(const Source: TContnrListEx); virtual;

    function GetEnumerator: IListEnumerator;
    // 排序
    procedure Sort;

    property Sorted: Boolean read FSorted write SetSorted;
    property Duplicates: TDuplicatesEx read FDuplicates write FDuplicates;
    property CompareFunc: TQuickSortCompare read FCompareFunc write FCompareFunc;

    property OnProcessData: TProcessData read FOnProcessData write FOnProcessData;
    property OnMergeData: TOnMergeData read FOnMergeData write FOnMergeData;

    procedure CustomSort(const DoQuickSortCompare: TQuickSortCompare);
    procedure Clear; virtual;
    procedure Delete(const Index: Integer); virtual;
    function Extract(const Item: Pointer): Pointer; overload;
    function Extract(const Idx: Integer): Pointer; overload;
    function IndexOf(const Item: Pointer): Integer;
    function Find(const Item: Pointer; var Index: Integer; const AFunc: TQuickSortCompare = nil): Boolean; overload;
    function Find(const Item: Pointer; var AData: Pointer; const AFunc: TQuickSortCompare = nil): Boolean; overload;
    function Find(const Item: Pointer; var Index: Integer; var AData: Pointer; const AFunc: TQuickSortCompare): Boolean; overload;

    function Add(const Item: Pointer): Integer;
    function Remove(const Item: Pointer): Integer;
    property Count: Integer read GetCount;
    property Items[const I: Integer]: Pointer read GetItems write SetItems; default;
    
    procedure FileLoad(const AFile: TFileName; const BlockSize: Integer);
		procedure FileSave(const AFile: TFileName; const BlockSize: Integer);
  end;

const
  LIST_ADD_FAIL = -1;
  LIST_NOT_FUND = -1;
  SORT_DEF_NUM = -1;
  lnModified = TListNotification(4);

implementation

uses
  Math;
  
type
  TOnNotify = procedure (Ptr: Pointer; Action: TListNotification) of object;

  TListEx = class(TList)
  strict private
    FOnNotify: TOnNotify;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    property OnNotify: TOnNotify read FOnNotify write FOnNotify;
  end;

  TSeekSeq = (skASC, skDESC);

  TListEnumerator = class(TInterfacedObject, IListEnumerator)
  private
    FIndex: Integer;
    FList: TList;
    FSeek: TSeekSeq;
  public
    constructor Create(AList: TList; const Seek: TSeekSeq = skASC);
    function GetCurrent: Pointer;
    function MoveNext: Boolean;
    property Current: Pointer read GetCurrent;
  end;

{ TContainer }

function TContnrListEx.Add(const Item: Pointer): Integer;
begin
  Result := LIST_ADD_FAIL;
  if Assigned(Item) then
    with LockList do
    try
      if not Sorted then
      begin
        if Duplicates <> dupeAccept then
        begin
          Result := Self.IndexOf(Item);
          if Result <> LIST_NOT_FUND then
          begin
            if Duplicates = dupeMerge then
              MergeItem(Result, Item);
            Exit;
          end;
        end;
          
        Result := Count;
      end
      else
        if Find(Item, Result) then
          case Duplicates of
            dupeIgnore: Exit;
            dupeMerge: begin
              MergeItem(Result, Item);
              Exit;
            end;
          end;

      InsertItem(Result, Item);
    finally
      UnLockList;
    end;
end;

procedure TContnrListEx.Assign(const Source: TContnrListEx);
begin
  if Assigned(Source) then
    List.Assign(Source.List, laOr);
end;

procedure TContnrListEx.Clear;
begin
  with LockList do
  try
    Clear;
  finally
    UnLockList;
  end;
end;

constructor TContnrListEx.Create;
begin
  inherited;
  FLocker := TCriticalSection.Create;
  FList := ListClass.Create;
  if FList is TListEx then
    TListEx(FList).OnNotify := ProcessData;

  FSorted := False;
  FDuplicates := dupeAccept;
end;

procedure TContnrListEx.CustomSort(const DoQuickSortCompare: TQuickSortCompare);
begin
  with LockList do
  try
    QuickSort(0, Count - 1, DoQuickSortCompare);
  finally
    UnLockList;
  end;
end;

procedure TContnrListEx.Delete(const Index: Integer);
begin
  with LockList do
  try
    Delete(Index);
  finally
    UnLockList;
  end;
end;

destructor TContnrListEx.Destroy;
begin
  Clear();
  FList.Free;
  FLocker.Free;
  inherited;
end;

procedure TContnrListEx.DoMergeItem(const Old, New: Pointer);
begin
  if Assigned(FOnMergeData) then
    FOnMergeData(Old, New);
end;

function TContnrListEx.Extract(const Idx: Integer): Pointer;
begin
  Result := nil;
  with LockList do
  try
    if InRange(Idx, 0, Count - 1) then
    begin
      Result := Items[Idx];
      Delete(Idx);
    end;
  finally
    UnLockList;
  end;
end;

function TContnrListEx.Extract(const Item: Pointer): Pointer;
begin
  with LockList do
  try
    Result := Extract(Item);
  finally
    UnLockList;
  end;
end;

function TContnrListEx.Find(const Item: Pointer; var AData: Pointer; const AFunc: TQuickSortCompare): Boolean;
var
  FIdx: Integer;
  FFunc: TQuickSortCompare;
begin
  FFunc := AFunc;
  //20120203 13:04 gq modify 此处逻辑应该是错误的，因为没有传入比较函数的话，才应该使用默认的排序方法
  //if Assigned(FFunc) then
  if not Assigned(FFunc) then
    FFunc := QuickSortCompare;
  Result := Find(Item, FIdx, AData, FFunc);
end;

function TContnrListEx.FileBlockToMem(const Buff: Pointer;
  const BlockSize: Integer; out AMemBuff: Pointer): Boolean;
begin
  Result := Assigned(Buff) and (BlockSize > 0);
  if Result then
  begin
    AMemBuff := AllocMem(BlockSize);
    Move(Buff^, AMemBuff^, BlockSize);
  end;
end;

procedure TContnrListEx.FileLoad(const AFile: TFileName;
  const BlockSize: Integer);
var
	FData, FMem: Pointer;
	FSize: Int64;
begin
	if FileExists(AFile) and (BlockSize > 0) then
    with LockList do
    try
			with TFileStream.Create(AFile, fmOpenRead) do
			try
				FSize := Size;
				Position := 0;
         
        FData := AllocMem(BlockSize);
        try

          while Position < FSize do
            if (Read(FData^, BlockSize) > 0) and FileBlockToMem(FData, BlockSize, FMem) then
              Self.Add(FMem);
        finally
          FreeMem(FData);
        end;
			finally
				Free;
			end;
    finally
      UnLockList;
    end;
end;

procedure TContnrListEx.FileSave(const AFile: TFileName;
  const BlockSize: Integer);
var
	FData, FBuff: Pointer;
  FPath: String;
begin
  if BlockSize > 0 then
  begin
    LockList;
    try
      if Count > 0 then
      begin
        FPath := ExtractFilePath(AFile);
        ForceDirectories(FPath);
        with TFileStream.Create(AFile, fmCreate) do
        try
          for FData in Self do
            if MemBlockToFile(FData, BlockSize, FBuff) then
              Write(FBuff^, BlockSize);
        finally
          Free;
        end;
      end;
    finally
      UnLockList;
    end;
  end;
end;

function TContnrListEx.Find(const Item: Pointer; var Index: Integer;
  var AData: Pointer; const AFunc: TQuickSortCompare): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  with LockList do
  try
    L := 0;
    H := Count - 1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      AData := Items[I];
      C := AFunc(AData, Item);
      if C < 0 then L := I + 1 else
      begin
        H := I - 1;
        if C = 0 then
        begin
          L := I;
          Result := True;
          Break;
        end;
      end;
    end;
  finally
    UnLockList;
  end;

  Index := L;
end;

function TContnrListEx.Find(const Item: Pointer; var Index: Integer; const AFunc: TQuickSortCompare): Boolean;
var
  FData: Pointer;
  FFunc: TQuickSortCompare;
begin
  FFunc := AFunc;
  if not Assigned(FFunc) then
    FFunc := QuickSortCompare;
  Result := Find(Item, Index, FData, FFunc);
end;

function TContnrListEx.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TContnrListEx.GetEnumerator: IListEnumerator;
begin
  Result := TListEnumerator.Create(FList);
end;

function TContnrListEx.GetItems(const I: Integer): Pointer;
begin
  with LockList do
  try
    Result := Items[I];
  finally
    UnLockList;
  end;
end;

function TContnrListEx.GetTag: Integer;
begin
  Result := FTag
end;

function TContnrListEx.IndexOf(const Item: Pointer): Integer;
var
  FCount: Integer;
begin
  LockList;
  try
    if not Sorted then
    begin
      Result := 0;
      FCount := Count;
      while (Result < FCount) and (QuickSortCompare(FList.Items[Result], Item) <> SORT_DEFAULT) do
        Inc(Result);
      if Result = FCount then
        Result := LIST_NOT_FUND;
    end else
      if not Find(Item, Result) then Result := LIST_NOT_FUND;
  finally
    UnLockList;
  end;
end;

procedure TContnrListEx.InsertItem(const Index: Integer; const Item: Pointer);
begin
  with LockList do
  try
    Insert(Index, Item);
  finally
    UnLockList;
  end;
end;

function TContnrListEx.ListClass: TListClass;
begin
  Result := TListEx;
end;

function TContnrListEx.LockList: TList;
begin
  FLocker.Enter;
  Result := FList;
end;

function TContnrListEx.MemBlockToFile(const Buff: Pointer;
  const BlockSize: Integer; out AFileBuff: Pointer): Boolean;
begin
  Result := Assigned(Buff) and (BlockSize > 0);
  AFileBuff := Buff;
end;

procedure TContnrListEx.MergeItem(const Old: Integer; const New: Pointer);
var
  FOld: Pointer;
begin
  FOld := Items[Old];
  DoMergeItem(FOld, New);
  ProcessData(FOld, lnModified);
  // do nothing
end;

procedure TContnrListEx.ProcessData(Ptr: Pointer; Action: TListNotification);
begin
  if Assigned(FOnProcessData) then
    FOnProcessData(Ptr, Action);
end;

procedure TContnrListEx.QuickSort(L, R: Integer; const DoQuickSortCompare: TQuickSortCompare);
var
  I, J, P: Integer;
begin
  if L < R then
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while DoQuickSortCompare(Items[I], Items[P]) < 0 do Inc(I);
      while DoQuickSortCompare(Items[J], Items[P]) > 0 do Dec(J);
      if I <= J then
      begin
        //ExchangeItems(I, J);
        FList.Exchange(I, J);

        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J, DoQuickSortCompare);
    L := I;
  until I >= R;
end;

function TContnrListEx.QuickSortCompare(const Item1, Item2: Pointer): Integer;
begin
//  Result := SORT_DEF_NUM;
  if Assigned(FCompareFunc) then
    Result := FCompareFunc(Item1, Item2)
  else Result := Integer(Item1) - Integer(Item2);
end;

function TContnrListEx.Remove(const Item: Pointer): Integer;
begin
  with LockList do
  try
    Result := Self.IndexOf(Item);
    if Result <> LIST_NOT_FUND then
      Delete(Result);
  finally
    UnLockList;
  end;
end;

procedure TContnrListEx.SetItems(const I: Integer; const Value: Pointer);
begin
  with LockList do
  try
    Items[I] := Value;
  finally
    UnLockList;
  end;
end;

procedure TContnrListEx.SetSorted(const Value: Boolean);
begin
  if FSorted <> Value then
  begin
    FSorted := Value;
    if Value then
      Sort;
  end;
end;

procedure TContnrListEx.SetTag(const Value: Integer);
begin
  FTag := Value;
end;

procedure TContnrListEx.Sort;
begin
  with LockList do
  try
    QuickSort(0, Count - 1, QuickSortCompare);
    FSorted := True;
  finally
    UnLockList;
  end;
end;

procedure TContnrListEx.UnLockList;
begin
  FLocker.Leave;
end;

{ TListEnumerator }

constructor TListEnumerator.Create(AList: TList; const Seek: TSeekSeq);
begin
  inherited Create;
  FIndex := LIST_NOT_FUND;
  FList := AList;
  FSeek := Seek;
  case FSeek of
    skASC: FIndex := LIST_NOT_FUND;
    skDESC: FIndex := FList.Count;
  end;
end;

function TListEnumerator.GetCurrent: Pointer;
begin
  Result := FList[FIndex];
end;

function TListEnumerator.MoveNext: Boolean;
begin
  case FSeek of
    skASC: begin
      Result := FIndex < FList.Count - 1;
      if Result then
        Inc(FIndex);
    end;
    skDESC: begin
      Result := FIndex > 0;
      if Result then
        Dec(FIndex);
    end;
  else Result := False;
  end;
end;

{ TListEx }

procedure TListEx.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Assigned(FOnNotify) then
    FOnNotify(Ptr, Action);
end;

end.
