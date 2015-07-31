unit DataLayer;

interface
uses
  Windows;
type
  TOnUpdate = function(serverType: Integer; iFunctionID: Integer; pAnsData: Pointer): Integer; cdecl;
  TOnError = function(serverType: Integer; iErrorNO: Integer; pAnsData: Pointer): Integer; cdecl;

  TInitalize = function(BasePath: PChar): Integer; cdecl;
  TFinalize = function(): Integer; cdecl;
  TGetModuleId = function(): Integer; cdecl;
  TRegisterOnUpdate = function(ModuleID: Integer;OnUpdate: TOnUpdate): Integer; cdecl;
  TRegisterOnError = function(ModuleID: Integer;OnUpdate: TOnUpdate): Integer; cdecl;
  TUnRegisterOnUpdate = function(ModuleID: Integer): Integer; cdecl;
  TUnRegisterOnError = function(ModuleID: Integer): Integer; cdecl;
  TDoSynRequest = function(pReqData: Pointer; var pAnsData: Pointer; timeOut: Integer): Integer; cdecl;
  TDoAsynRequest = function(pReqData: Pointer): Integer; cdecl;
  TReleaseAnsData = function(pAnsData: Pointer): Integer; cdecl;

  TSetAccountInfo = function(AccType: Integer;Account: PChar; Passwrod: PChar; Reserve:PChar = nil): Integer;cdecl;
  TSetConfig = function(buf: PChar; Len: Integer):Integer;cdecl;

  TDataLayer = class
  public
    FDLLHandle: HMODULE;
    FInitalize: TInitalize;
    FFinalize: TFinalize;
    FGetModuleId: TGetModuleId;
    FRegisterOnUpdate: TRegisterOnUpdate;
    FRegisterOnError: TRegisterOnError;
    FUnRegisterOnUpdate: TUnRegisterOnUpdate;
    FUnRegisterOnError: TUnRegisterOnError;
    FDoSynRequest: TDoSynRequest;
    FDoAsynRequest: TDoAsynRequest;
    FReleaseAnsData: TReleaseAnsData;
    FSetAccountInfo: TSetAccountInfo;
    FSetConfig: TSetConfig;
  public
    procedure DoInit(Path: string);
    procedure DoFinalize();
  end;
implementation

{ TDataLayer }

procedure TDataLayer.DoFinalize;
begin
  if (FDLLHandle <> 0) then
  begin
    FFinalize();
    FreeLibrary(FDLLHandle);
  end;
end;

procedure TDataLayer.DoInit(Path: string);
var
  FuncPointer: Pointer;
begin
  FDLLHandle := LoadLibrary(PChar(Path + 'data_layer.dll'));
  if (FDLLHandle <> 0) then
  begin
    FuncPointer := GetProcAddress(FDLLHandle, 'initalize');
    FInitalize := TInitalize(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'finalize');
    FFinalize := TFinalize(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'getModuleId');
    FGetModuleId := TGetModuleId(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'registerOnUpdate');
    FRegisterOnUpdate := TRegisterOnUpdate(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'registerOnError');
    FRegisterOnError := TRegisterOnError(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'unregisterOnUpdate');
    FUnRegisterOnUpdate := TUnRegisterOnUpdate(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'unregisterOnError');
    FUnRegisterOnError := TUnRegisterOnError(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'doSynRequest');
    FDoSynRequest := TDoSynRequest(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'doAsynRequest');
    FDoAsynRequest := TDoAsynRequest(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'releaseAnsData');
    FReleaseAnsData := TReleaseAnsData(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'setAccountInfo');
    FSetAccountInfo := TSetAccountInfo(FuncPointer);

    FuncPointer := GetProcAddress(FDLLHandle, 'setConfigInfo');
    FSetConfig := TSetConfig(FuncPointer);
  end;
end;

end.

