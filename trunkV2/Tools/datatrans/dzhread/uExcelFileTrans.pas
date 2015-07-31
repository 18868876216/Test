unit uExcelFileTrans;

interface

uses
  SysUtils, Windows, Classes, Controls, ComObj, ActiveX, Variants, Math;

implementation

uses
  uFactory, uTools;

type
  TExcelFileTrans = class(TDataTrans)
  protected
    procedure TransExcel(const AData: TStrings; const AExcel: Variant; ADest: TStream); virtual;
    procedure TransExcelSheet(const AData: TStrings; const ASheet: Variant; ADest: TStream); virtual; abstract;
  protected    
    class function SupportedFileKind(): TFileKindSet; override;
    procedure TransData(const ASrcFile: TFileName; const ADest: TStream);override;
  public
    constructor Create(const AKind: TFileKind); override;
    destructor Destroy(); override;
  end;

  TExcelHS300Trans = class(TExcelFileTrans)
  protected
    procedure TransExcelSheet(const AData: TStrings; const ASheet: Variant; ADest: TStream); override;
  end;

{ TExcelFileTrans }

constructor TExcelFileTrans.Create(const AKind: TFileKind);
begin
  inherited;
  CoInitialize(nil);
end;

destructor TExcelFileTrans.Destroy;
begin
  CoUninitialize;
  inherited;
end;

class function TExcelFileTrans.SupportedFileKind: TFileKindSet;
begin
  Result := [fkHS300Info];
end;

procedure TExcelFileTrans.TransData(const ASrcFile: TFileName; const ADest: TStream);
var
  FData: TStringList;
  FExcel: Variant;
begin
  FData := TStringList.Create;
  FExcel := CreateOleObject('Excel.Application');
  try
    FExcel.workbooks.Open(FileSrc);
    TransExcel(FData, FExcel, ADest);
  finally
    FExcel.Quit;
    FExcel := Null;
    FData.Free;
  end;
end;

procedure TExcelFileTrans.TransExcel(const AData: TStrings; const AExcel: Variant; ADest: TStream);
var
  I: Integer;
begin
  if (not VarIsNull(AExcel)) and Assigned(ADest) then
    for I := 1 to AExcel.workbooks[1].Sheets.Count do
      TransExcelSheet(AData, AExcel.workbooks[1].Sheets[I], ADest);
end;

{ TExcelHS300Trans }

procedure TExcelHS300Trans.TransExcelSheet(const AData: TStrings;
  const ASheet: Variant; ADest: TStream);
var
  I: Integer;
begin
  if (not VarIsNull(ASheet)) and Assigned(ADest) then
    for I := 1 to ASheet.UsedRange.Rows.Count do
    begin
      if string(ASheet.Cells[I, 1]) = '' then
        break;
      AData.Clear;
      AData.Add(ASheet.Cells[I, 4]);
      AData.Add(ASheet.Cells[I, 5]);
      Write(ADest, AData);
    end;
end;

initialization
  TExcelHS300Trans.Register;
    
end. 
