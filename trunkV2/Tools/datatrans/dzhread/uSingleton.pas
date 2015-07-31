{******************************************************************************}
{ @UnitName     : uSingleton.pas                                               }
{ @Project      : MService                                                     }
{ @Copyright    : HUNDSUN Co.Ltd. (C) 2006                                     }
{ @Author       : Budded                                                       }
{ @Description  : ����ģʽ, ���ö��ֲ��ҷ��ӿ�����ٶ�;
                  ע�⣺�����಻������
                  �������ԭ���Ƚ����                                       }
{ @FileVersion  : 1.0.0.0                                                      }
{ @CreateDate   : 2006-06-01                                                   }
{ @Comment      : ��Ԫ���ۣ����������ۣ�                                     }
{ @LastUpdate   : Budded, 2006-06-01                                           }
{ @History      : Created By Budded, 2006-06-01 10:20                          }
{******************************************************************************}
unit uSingleton;

interface

uses
  SysUtils, Contnrs, Classes, Windows, Messages;

type
  TAccessType = (atGet, atFree, atFreeAll,atNil);
  /// <summary>
  ///   ϵͳ������
  /// </summary>
  TSingleton = class(TInterfacedPersistent)
  private
    class function AccessInstance(const AccessType: TAccessType = atGet): TSingleton;
  protected
    /// <summary>
    ///   �����๹�캯��
    /// </summary>
    constructor CreateInstance; virtual;
    /// <summary>
    ///   ������������¼�
    /// </summary>
    procedure AfterConstruct; virtual;
  public
    /// <summary>
    ///   �����಻��ͨ���˷�������
    /// </summary>
    constructor Create();
    /// <summary>
    ///   ��������
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///   �ຯ������������ʷ���
    /// </summary>
    class function Instance(): TSingleton;
    /// <summary>
    ///   ������ǰ��ʵ��
    /// </summary>
    class procedure ReleaseInstance();
    /// <summary>
    ///   �������е���ʵ��
    /// </summary>
    class procedure ReleaseAllInstance();  
  end;

  /// <summary>
  ///   ������ĵ���
  /// </summary>
  THandleSingleton = class(TSingleton)
  private
    FHandle: HWND;
  protected
    constructor CreateInstance; override;
    /// <summary>
    ///   ��Ϣ������
    /// </summary>
    procedure WndProc(var Msg: TMessage); virtual;
  public
    destructor Destroy; override;
    class function Instance(): THandleSingleton;
    /// <summary>
    ///   ���
    /// </summary>
    property Handle: HWND read FHandle;
  end;

var
  GProc: procedure = nil;  //������һ�����̵ı�����������ֵʵ���Ͼ��ǹ��̵Ŀ�ʼ��ַ��ָ�룩����������ĳ�ʼֵΪnil.

procedure ClearSingletons(); stdcall; //stdcall�Ƕ���������ĵ��÷�ʽ�����������˲�������˳���Ǵ��ҵ��������������������ջ

implementation

uses
  SyncObjs, IniFiles;

exports               //
  ClearSingletons;
     
procedure ClearSingletons();
begin
  if Assigned(GProc) then
    GProc;

  TSingleton.ReleaseAllInstance;
end;

type               //
  /// <summary>
  ///   ��������������Hash�������ʵ������ObjectList�����ʵ��
  /// </summary>
  TSingletonList = class(TComponent)
  private
    FList: TObjectList;
    FStrList: TStringList;
    FCtl: TCriticalSection;
    function GetItems(const AClass: TClass): TSingleton;
    function GetItemsByIndex(const AIndex: Integer): TSingleton;
  protected  
    procedure Remove(AClass: String); overload;
    procedure Remove(AIndex: Integer); overload;
    procedure Clear();
    property ItemsByIndex[const AIndex: Integer]: TSingleton read GetItemsByIndex;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Add(ASingleton: TSingleton): Integer;

    procedure Remove(ASingleton: TSingleton); overload;
    procedure Remove(AClass: TClass); overload;
    property Items[const AClass: TClass]: TSingleton read GetItems;

    procedure Lock;
    procedure UnLock;
  end;

{ TSingleton }

var
  FInstance: TSingletonList = nil;

class function TSingleton.AccessInstance(const AccessType: TAccessType = atGet): TSingleton;
  {$J+}
  {commented by LL 2009-2-18: �����������ڶ��߳�����ʱ���ܻᵼ������
  ����������ʹ�ò��ٷ�ʽ��¼10���λ����һ�����Ӳ��ϣ��϶���վ����ͨ��
  ��������Ĵ������������������������
  const FInstance: TSingletonList = nil;}
  {$J-}
begin
  {//commented by LL 2009-2-18: �����������ڶ��߳�����ʱ���ܻᵼ������
  if not Assigned(FInstance) then
    FInstance := TSingletonList.Create(nil);
  }


  Result := nil;
  case AccessType of
    atGet:
      begin
        FInstance.Lock;
        try
          Result := FInstance.Items[Self];
          if not Assigned(Result) then
          begin
            Result := Self.CreateInstance();
            FInstance.Add(Result);  
            Result.AfterConstruct;
          end;
        finally
          FInstance.UnLock;
        end;
      end;
    atFree:
      begin
        FInstance.Lock;
        try
          FInstance.Remove(Self);
        finally
          FInstance.UnLock;
        end;               
      end;
    atFreeAll:
      if Assigned(FInstance) then       
      begin
        FInstance.Free;
        FInstance := nil;
      end;
    atNil: ;
  end;
end;

procedure TSingleton.AfterConstruct;
begin
//                  //
end;

constructor TSingleton.Create();
begin
  raise Exception.Create('TSingleton can only access through Instance function!');
end;    //Raise��������׳��쳣

constructor TSingleton.CreateInstance;
begin
  inherited Create();
end;

destructor TSingleton.Destroy;
begin
  
  inherited;
end;

class function TSingleton.Instance: TSingleton;
begin
  Result := AccessInstance;
end;

class procedure TSingleton.ReleaseAllInstance;
begin
  AccessInstance(atFreeAll);
end;

class procedure TSingleton.ReleaseInstance;
begin
  AccessInstance(atFree);
end;

{ TSingletonList }

function TSingletonList.Add(ASingleton: TSingleton): Integer;
begin
  Result := FStrList.AddObject(ASingleton.ClassName, ASingleton);
  FList.Add(ASingleton);
end;

procedure TSingletonList.Clear;
begin
{  FList.Clear;          }
  while FList.Count > 0 do
    Remove(FList.Count - 1);
end;

constructor TSingletonList.Create(AOwner: TComponent);
begin
  inherited;
  FCtl := TCriticalSection.Create;
  
  FStrList := TStringList.Create;  
  FStrList.Sorted := True;
  FStrList.Duplicates := dupIgnore;

  FList := TObjectList.Create;
end;

destructor TSingletonList.Destroy;
begin
  Clear;
  FStrList.Free;
  FList.Free;
  FCtl.Free;
  inherited;
end;

function TSingletonList.GetItems(const AClass: TClass): TSingleton;
var
  I: Integer;
begin
  Result := nil;
  if Assigned(AClass) then
  begin
    I := FStrList.IndexOf(AClass.ClassName);
    if I <> -1 then
      Result := ItemsByIndex[I];
  end;
end;

procedure TSingletonList.Remove(ASingleton: TSingleton);
begin
  if Assigned(ASingleton) then
    Remove( ASingleton.ClassName );
end;

function TSingletonList.GetItemsByIndex(const AIndex: Integer): TSingleton;
begin
  Result := nil;  
  if (AIndex >= 0) and (AIndex < FStrList.Count) then
    Result := TSingleton(FStrList.Objects[AIndex]);
end;

procedure TSingletonList.Lock;
begin
  FCtl.Enter;
end;

procedure TSingletonList.Remove(AClass: TClass);
begin
  if Assigned(AClass) then
    Remove( AClass.ClassName );
end;

procedure TSingletonList.Remove(AClass: String);
begin
  Remove( FStrList.IndexOf(AClass) );
end;

procedure TSingletonList.Remove(AIndex: Integer);
var
  FObj: TSingleton;
begin
  if (AIndex >= 0) and (AIndex < FStrList.Count) then
  begin
    FObj := ItemsByIndex[AIndex];
    FStrList.Delete(AIndex);
    if Assigned(FObj) then
      FList.Remove(FObj);
  end;
end;

procedure TSingletonList.UnLock;
begin
  FCtl.Leave 
end;

{ THandleSingleton }

constructor THandleSingleton.CreateInstance;
begin
  inherited;
            
  FHandle := AllocateHWnd(WndProc);
end;

destructor THandleSingleton.Destroy;
begin
  DeallocateHWnd(FHandle);

  inherited;
end;

class function THandleSingleton.Instance: THandleSingleton;
begin
  Result := inherited Instance as THandleSingleton;
end;

procedure THandleSingleton.WndProc(var Msg: TMessage);
begin
  with Msg do
    Result := DefWindowProc(FHandle, Msg, wParam, lParam);
end;

initialization
  FInstance := TSingletonList.Create(nil);
  //OutputDebugString(pchar(GetModuleName(HInstance) + ' SingletonList create'));
finalization
  //TSingleton.ReleaseAllInstance;
  //OutputDebugString(pchar(GetModuleName(HInstance) + ' SingletonList release'));

end.
