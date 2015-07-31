{******************************************************************************}
{ @UnitName     : uContainer.pas                                               }
{ @Project      : Common                                                       }
{ @Copyright    : Hundsun Electronics Co,.Ltd.                                 }
{ @Author       : Budded                                                       }
{ @Description  : Singleton Container, Thread Safe                             }
{ @FileVersion  : 1.0.0.0                                                      }
{ @CreateDate   : 2007-07-13                                                   }
{ @Comment      :                                                              }
{ @LastUpdate   : Budded, 2007-07-13                                           }
{ @History      : Created By Budded, 2007-07-13 12:00                          }
{                 Modified By Budded, Add Thread Safe Support, 2007-07-31      }
{                 Modified By Budded, Add Enum Method, 2009-08-31              }
{******************************************************************************}
unit uContainer;

interface

uses
  SysUtils, Classes, Contnrs, Controls, SyncObjs, uSingleton;

type
  TListClass = class of TList;
  TQuickSortCompare = function (Item1, Item2: Pointer): Integer of object;
  
  /// <summary>
  ///   单例List容器，线程安全
  /// </summary>
  TContnrList = class(TSingleton)
  private
    { private declarations }
    FList: TList; 
    FLock: TCriticalSection; //临界区对象

    function GetItems(const I: Integer): Pointer;
    procedure SetItems(const I: Integer; const Value: Pointer);
  protected
    { protected declarations }
    /// <summary>
    ///   获取列表元素数量
    /// </summary>
    function GetCount: Integer;
    /// <summary>
    ///   列表
    /// </summary>
    property List: TList read FList;
    constructor CreateInstance; override;
    /// <summary>
    ///   获取列表元类
    /// </summary>
    function ListClass: TListClass; virtual;
    /// <summary>
    ///   锁定列表
    /// </summary>
    function LockList: TList;
    /// <summary>
    ///   解锁列表
    /// </summary>
    procedure UnLockList;
      
    /// 快速排序
    procedure QuickSort(L, R: Integer; DoQuickSortCompare: TQuickSortCompare);
    /// 判断 Item1与Item2的先后顺序
    ///  Item1排在前则返回小于0
    ///  Item1排在后则返回大于0
    ///  两者相等则返回0
    function QuickSortCompare(Item1, Item2: Pointer): Integer; virtual;
  public
    { public declarations }
    destructor Destroy; override;
    class function Instance(): TContnrList;
    /// <summary>
    ///   列表元素枚举
    /// </summary>
    function GetEnumerator: TListEnumerator;

    /// <summary>
    ///   排序
    /// </summary>
    procedure Sort;  
    /// <summary>
    ///   自定义排序
    /// </summary>
    procedure CustomSort(DoQuickSortCompare: TQuickSortCompare);
    /// <summary>
    ///   清空列表
    /// </summary>
    procedure Clear; virtual;
    /// <summary>
    ///   根据索引值删除列表元素
    /// </summary>
    procedure Delete(Index: Integer);
    /// <summary>
    ///   从列表中取出某元素
    /// </summary>
    function Extract(Item: Pointer): Pointer;
    /// <summary>
    ///   获取某一元素在列表中的索引值
    /// </summary>
    function IndexOf(Item: Pointer): Integer;
    /// <summary>
    ///   将元素添加到列表中，并返回在列表中的索引值
    /// </summary>
    function Add(Item: Pointer): Integer;
    /// <summary>
    ///   从列表中删除某元素
    /// </summary>
    function Remove(Item: Pointer): Integer;
    /// <summary>
    ///   获取列表元素数量
    /// </summary>
    property Count: Integer read GetCount;
    /// <summary>
    ///   根据索引值访问列表元素
    /// </summary>
    property Items[const I: Integer]: Pointer read GetItems write SetItems; default;
  end;

  TObjEnumerator = class(TListEnumerator)
  public
    function GetCurrent: TObject;
    property Current: TObject read GetCurrent;
  end;
             
  TEnumProc = function (const AObj: TObject): Boolean of object;  
  TEnumProcEx = function (const AObj: TObject; const Param: Pointer = nil): Boolean of object;
  /// <summary>
  ///   单例ObjectList
  /// </summary>
  TContnrObjList = class(TContnrList)
  private
    { private declarations }
    function GetItems(const I: Integer): TObject;
    procedure SetItems(const I: Integer; const Value: TObject);
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);
  protected
    { protected declarations }
    constructor CreateInstance; override;
    /// <summary>
    ///   获取列表元类
    /// </summary>
    function ListClass: TListClass; override;
  public
    { public declarations }
    destructor Destroy; override;
    class function Instance(): TContnrObjList;
    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
      
    function EnumItems(const AEnumProc: TEnumProc): TObject; overload;   
    function EnumItems(const AEnumProc: TEnumProcEx; const Param: Pointer = nil;
      const ExitWhenFind: Boolean = True): TObject; overload; 
    /// <summary>
    ///   列表元素枚举
    /// </summary>
    function GetEnumerator: TObjEnumerator;
    /// <summary>
    ///   从列表中取出Object
    /// </summary>
    function Extract(Item: TObject): TObject;
    /// <summary>
    ///   获取Item在列表中的索引值
    /// </summary>
    function IndexOf(Item: TObject): Integer;
    /// <summary>
    ///   将Item添加到列表中，并返回Item的索引值
    /// </summary>
    function Add(Item: TObject): Integer;
    /// <summary>
    ///   将Item从列表中删除
    /// </summary>
    function Remove(Item: TObject): Integer; virtual;
    /// <summary>
    ///   根据索引值访问列表
    /// </summary>
    property Items[const I: Integer]: TObject read GetItems write SetItems; default;
    /// <summary>
    ///   在列表中查找某元类的实例
    /// </summary>
    /// <param name="AClass">寻找的元类</param>
    /// <param name="AExact">是否查找确切的类，当传入False的时候AClass的子类也将列入查找范围</param>     
    /// <param name="AStartAt">开始查找位置的索引值</param>
    /// <returns>找到实例的索引值</returns>
    function FindInstanceOf(AClass: TClass; AExact: Boolean = True; AStartAt: Integer = 0): Integer;

    /// <summary>
    ///   class factory, who will calls the default constructor
    /// </summary>
    function CreateObj(AClass: TClass): TObject;
    /// <summary>
    ///   find extract class, if failed to find, then Create
    /// </summary>
    function FindCreateObj(AClass: TClass): TObject;
  end;

  TCompEnumerator = class(TObjEnumerator)
  public
    function GetCurrent: TComponent;
    property Current: TComponent read GetCurrent;
  end;

  /// <summary>
  ///   Component Singleton List
  /// </summary>
  TContnrCompList = class(TContnrObjList)
  private        
    { private declarations }  
    function GetItems(const I: Integer): TComponent;   //组件
    procedure SetItems(const I: Integer; const Value: TComponent);
  protected
    { protected declarations }  
    constructor CreateInstance; override;
    function ListClass: TListClass; override;
  public
    { public declarations }
    destructor Destroy; override;
    class function Instance(): TContnrCompList;

    function GetEnumerator: TCompEnumerator;

    function Add(Item: TComponent): Integer;

    property Items[const I: Integer]: TComponent read GetItems write SetItems; default;

    function CreateObj(AClass: TComponentClass; AOwner: TComponent = nil): TComponent;
    function FindCreateObj(AClass: TComponentClass; AOwner: TComponent = nil): TComponent;
  end;
  
  TWinCtlEnumerator = class(TCompEnumerator)
  public
    function GetCurrent: TWinControl;   
    property Current: TWinControl read GetCurrent;
  end;

  /// <summary>
  ///   WinControl Singleton List
  /// </summary>
  TWinCtlList = class(TContnrCompList)
  private
    { private declarations }
    function GetItems(const I: Integer): TWinControl;//窗口组件，本身是一个windows窗口（有窗口句柄）
    function GetItemByHandle(const AHandle: THandle): TWinControl;
    procedure SetItems(const I: Integer; const Value: TWinControl);
  protected
    { protected declarations }  
    constructor CreateInstance; override;
  public
    { public declarations }  
    destructor Destroy; override;
    class function Instance(): TWinCtlList;
    
    function GetEnumerator: TWinCtlEnumerator;
                   
    function Add(Item: TWinControl): Integer;
    property Items[const I: Integer]: TWinControl read GetItems write SetItems;
    property ItemByHandle[const AHandle: THandle]: TWinControl read GetItemByHandle;
    function Active(const AHandle: THandle): Boolean; virtual;

    function CreateObj(AClass: TWinControlClass; AOwner: TComponent = nil): TWinControl;
    function FindCreateObj(AClass: TWinControlClass; AOwner: TComponent = nil): TWinControl;
  end;

implementation

uses
  Math;

{ TContainer }

function TContnrList.Add(Item: Pointer): Integer;
begin
  Result := -1;
  if Assigned(Item) then    
    with LockList do
    try
      Result := Add(Item);
    finally
      UnLockList;
    end;
end;

procedure TContnrList.Clear;
begin
  with LockList do
  try
    Clear;
  finally
    UnLockList;
  end;
end;

constructor TContnrList.CreateInstance;
begin
  inherited;
  FLock := TCriticalSection.Create;
  FList := ListClass.Create;
end;

procedure TContnrList.CustomSort(DoQuickSortCompare: TQuickSortCompare);
begin
  with LockList do
  try
    QuickSort(0, Count - 1, DoQuickSortCompare);
  finally
    UnLockList;
  end;
end;

procedure TContnrList.Delete(Index: Integer);
begin
  with LockList do
  try
    Delete(Index);
  finally
    UnLockList;
  end;
end;

destructor TContnrList.Destroy;
begin
  Clear();
  FList.Free;
  FLock.Free;
  
  inherited;
end;

function TContnrList.Extract(Item: Pointer): Pointer;
begin
  with LockList do
  try
    Result := Extract(Item);  //提取指针
  finally
    UnLockList;
  end;  
end;

function TContnrList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TContnrList.GetEnumerator: TListEnumerator;
begin
  Result := TListEnumerator.Create(FList);
end;

function TContnrList.GetItems(const I: Integer): Pointer;
begin
  Result := nil;
  with LockList do
  try
    if InRange(I, 0, Count - 1) then
      Result := Items[I];
  finally
    UnLockList;
  end;
end;

function TContnrList.IndexOf(Item: Pointer): Integer;
begin
  Result := FList.IndexOf(Item);
end;

class function TContnrList.Instance: TContnrList;
begin
  Result := inherited Instance as TContnrList;
end;

function TContnrList.ListClass: TListClass;
begin
  Result := TList;
end;

function TContnrList.LockList: TList;
begin
  FLock.Enter;
  Result := FList;
end;

procedure TContnrList.QuickSort(L, R: Integer; DoQuickSortCompare: TQuickSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;//二进制数向右移n位,首部补n个零
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

function TContnrList.QuickSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result := 0;
end;

function TContnrList.Remove(Item: Pointer): Integer;
begin
  with LockList do
  try
    Result := Remove(Item);
  finally
    UnLockList;
  end;
end;

procedure TContnrList.SetItems(const I: Integer; const Value: Pointer);
begin
  with LockList do
  try
    Items[I] := Value;
  finally
    UnLockList;
  end;
end;

procedure TContnrList.Sort;
begin   
  with LockList do
  try
    QuickSort(0, Count - 1, QuickSortCompare);
  finally
    UnLockList;
  end;
end;

procedure TContnrList.UnLockList;
begin
  FLock.Leave;
end;

{ TObjEnumerator }

function TObjEnumerator.GetCurrent: TObject;
begin
  Result := inherited GetCurrent;  //current() 函数返回当前被内部 指针指向的数组元素的值，并不移动指针
end;

{ TContnrObjList }

function TContnrObjList.Add(Item: TObject): Integer;
begin
  Result := inherited Add(Item);
end;

constructor TContnrObjList.CreateInstance;
begin
  inherited;
  // Owns the Object, parent class class calls
  // TObject.Create to Constructor to FList
  TObjectList(List).OwnsObjects := True;
end;

function TContnrObjList.CreateObj(AClass: TClass): TObject;
begin
  Result := nil;
  if Assigned(AClass) then
  begin
    Result := AClass.Create;
    Add(Result);
  end;
end;

destructor TContnrObjList.Destroy;
begin
  inherited;
end;

function TContnrObjList.EnumItems(const AEnumProc: TEnumProc): TObject;
begin
  if Assigned(AEnumProc) then
  begin
    LockList;
    try
      for Result in Self do
        if AEnumProc(Result) then
          Exit;
    finally
      UnLockList;
    end;
  end;
  Result := nil;
end;

function TContnrObjList.EnumItems(const AEnumProc: TEnumProcEx;
  const Param: Pointer; const ExitWhenFind: Boolean): TObject;
begin
  if Assigned(AEnumProc) then
  begin
    LockList;
    try
      for Result in Self do
        if AEnumProc(Result, Param) and ExitWhenFind then
          Exit;
    finally
      UnLockList;
    end;
  end;
  Result := nil;
end;

function TContnrObjList.Extract(Item: TObject): TObject;
begin
  Result := inherited Extract(Item);
end;

function TContnrObjList.FindCreateObj(AClass: TClass): TObject;
var
  I: Integer;
begin
  I := FindInstanceOf(AClass);
  if I <> -1 then
    Result := Items[I]
  else Result := CreateObj(AClass)
end;

function TContnrObjList.FindInstanceOf(AClass: TClass; AExact: Boolean;
  AStartAt: Integer): Integer;
begin
  Result := TObjectList(List).FindInstanceOf(AClass, AExact, AStartAt);
end;

function TContnrObjList.GetEnumerator: TObjEnumerator;
begin
  Result := TObjEnumerator.Create(List);
end;

function TContnrObjList.GetItems(const I: Integer): TObject;
begin
  Result := inherited Items[I];
end;

function TContnrObjList.GetOwnsObjects: Boolean;
begin
  Result := TObjectList(List).OwnsObjects;
end;

function TContnrObjList.IndexOf(Item: TObject): Integer;
begin
  Result := inherited IndexOf(Item);
end;

class function TContnrObjList.Instance: TContnrObjList;
begin
  Result := inherited Instance as TContnrObjList;
end;

function TContnrObjList.ListClass: TListClass;
begin
  Result := TObjectList;
end;

function TContnrObjList.Remove(Item: TObject): Integer;
begin
  Result := inherited Remove(Item);
end;

procedure TContnrObjList.SetItems(const I: Integer; const Value: TObject);
begin
  inherited Items[I] := Value;
end;

procedure TContnrObjList.SetOwnsObjects(const Value: Boolean);
begin
  TObjectList(List).OwnsObjects := Value;
end;

{ TCompEnumerator }

function TCompEnumerator.GetCurrent: TComponent;
begin
  Result := inherited GetCurrent as TComponent;
end;

{ TContnrCompList }

function TContnrCompList.Add(Item: TComponent): Integer;
begin
  Result := inherited Add(Item);
end;

constructor TContnrCompList.CreateInstance;
begin
  inherited;
end;

function TContnrCompList.CreateObj(AClass: TComponentClass; AOwner: TComponent): TComponent;
begin
  Result := nil;
  if Assigned(AClass) then
  begin
    Result := AClass.Create(AOwner);
    Add(Result);
  end;
end;

destructor TContnrCompList.Destroy;
begin
  inherited;
end;

function TContnrCompList.FindCreateObj(AClass: TComponentClass; AOwner: TComponent): TComponent;
var
  I: Integer;
begin
  I := FindInstanceOf(AClass);
  if I <> -1 then
    Result := Items[I]
  else Result := CreateObj(AClass, AOwner);
end;

function TContnrCompList.GetEnumerator: TCompEnumerator;
begin
  Result := TCompEnumerator.Create(List);
end;

function TContnrCompList.GetItems(const I: Integer): TComponent;
begin
  Result := inherited Items[I] as TComponent;
end;

class function TContnrCompList.Instance: TContnrCompList;
begin
  Result := inherited Instance as TContnrCompList;
end;

function TContnrCompList.ListClass: TListClass;
begin
  Result := TComponentList;
end;

procedure TContnrCompList.SetItems(const I: Integer; const Value: TComponent);
begin
  inherited Items[I] := Value;
end;

{ TWinCtlEnumerator }

function TWinCtlEnumerator.GetCurrent: TWinControl;
begin
  Result := inherited GetCurrent as TWinControl;
end;

{ TWinCtlMng }

function TWinCtlList.Active(const AHandle: THandle): Boolean;
var
  FCtl: TWinControl;
begin
  Result := False;
  FCtl := ItemByHandle[AHandle];
  if Assigned(FCtl) then
  begin            
    FCtl.BringToFront;
    if FCtl.Visible then
      FCtl.SetFocus;
    
    Result := FCtl.Visible;
  end;
end;

function TWinCtlList.Add(Item: TWinControl): Integer;
begin
  Result := inherited Add(Item);
end;

constructor TWinCtlList.CreateInstance;
begin
  inherited;
end;

function TWinCtlList.CreateObj(AClass: TWinControlClass; AOwner: TComponent): TWinControl;
begin
  Result := inherited CreateObj(AClass, AOwner) as TWinControl; 
end;

destructor TWinCtlList.Destroy;
begin
  inherited;
end;

function TWinCtlList.FindCreateObj(AClass: TWinControlClass; AOwner: TComponent): TWinControl;
begin
  Result := inherited FindCreateObj(AClass, AOwner) as TWinControl;
end;

function TWinCtlList.GetEnumerator: TWinCtlEnumerator;
begin
  Result := TWinCtlEnumerator.Create(List);
end;

function TWinCtlList.GetItemByHandle(const AHandle: THandle): TWinControl;
begin
  for Result in Self do
    if AHandle = Result.Handle then
      Exit;
      
  Result := nil;
end;

function TWinCtlList.GetItems(const I: Integer): TWinControl;
begin
  Result := inherited Items[I] as TWinControl;
end;

class function TWinCtlList.Instance: TWinCtlList;
begin
  Result := inherited Instance as TWinCtlList;
end;

procedure TWinCtlList.SetItems(const I: Integer; const Value: TWinControl);
begin
  inherited Items[I] := Value;
end;

end.
