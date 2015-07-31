unit uDzhAbkFileTrans;

interface

uses
  SysUtils, Windows, Classes, Controls, Math, IniFiles;

implementation

uses
  uFactory, uTools;

type
  TDataKind = (dkSummary, dkDetail);

  TDzhAbkFileTrans = class(TDataTrans)
  private
    function Read(const ASrc: TStream; const Count: integer): string;
  protected
    class function SupportedFileKind(): TFileKindSet; override;
    function DataKind: TDataKind;
    function ResolveBlockName(const ABlockName: string): string;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: string);
      override;

    procedure TransDataFile(const ASrc: string; ADest: TStream);
    procedure TransDataDir(const ADir: string; ADest: TStream);
    procedure TransDataDirFile(const AFile: string; ADest: TStream);
  end;

  { TDzhAbkFileTrans }

function TDzhAbkFileTrans.DataKind: TDataKind;
begin
  Result := dkSummary;
  if FileKind = fkBlockStock then
    Result := dkDetail;
end;

function TDzhAbkFileTrans.Read(const ASrc: TStream;
  const Count: integer): string;
var
  PC: PChar;
  iLoop: integer;
begin
  result := '';
  new(PC);
  for iLoop := 0 to Count - 1 do
  begin
    ASrc.Read(PC^, 1);
    //kettle里处理char(0)麻烦，这里过滤
    if PC[0] <> char(0) then
      result := result + PC[0];
  end;
end;

function TDzhAbkFileTrans.ResolveBlockName(const ABlockName: string): string;
var
  sBlockName, sDest, sTemp: string;
  iIndex, iLength: Integer;
begin
  sBlockName := ABlockName;
  iLength := Length(sBlockName);
  sDest := '';
  iIndex := 1;
  while iIndex <= iLength do
  begin
    if sBlockName[iIndex] in ['0'..'9', 'a'..'z', 'A'..'Z', '-', ' ', '(', ')']
      then
    begin
      if not (sBlockName[iIndex] in [' ', '(', ')']) then
        sDest := sDest + sBlockName[iIndex];
      Inc(iIndex);
    end
    else
    begin
      sTemp := Copy(sBlockName, iIndex, 2);
      if sTemp = '、' then
        sDest := sDest + '['
      else
        sDest := sDest + ChnToPY(sTemp); //ChinessToPinyin(sTemp);
      Inc(iIndex, 2);
    end;
  end;

  Result := sDest;
end;

class function TDzhAbkFileTrans.SupportedFileKind: TFileKindSet;
begin
  Result := [fkBlockInfo, fkBlockStock];
end;

procedure TDzhAbkFileTrans.TransDataDir(const ADir: string; ADest: TStream);
const
  S_EXT = '.BLK';
var
  FList: TStrings;
  FFile: TFileName;
begin
  FList := TStringList.Create;
  try
    if FindFile(FList, ADir, S_EXT) > 0 then
      for FFile in FList do
        TransDataDirFile(FFile, ADest);
  finally
    FList.Free;
  end;
end;

procedure TDzhAbkFileTrans.TransDataDirFile(const AFile: string;
  ADest: TStream);

  function GetBlock(const AFileName: string): string;
  var
    iPos: Integer;
  begin
    Result := ExtractFileName(AFile);
    iPos := Pos('.', Result);
    //Result := Copy(Result, 1, Length(Result) - iPos);
    Result := Copy(Result, 1, iPos - 1);
  end;

  procedure AddSummary(const AData: TStrings);
  const
    S_BLOCK = '板块指数';
  var
    FBlk: string;
  begin
    FBlk := GetBlock(AFile);
    AData.Add(FBlk);
    AData.Add(FBlk);
    AData.Add(S_BLOCK);

    Write(ADest, AData);
  end;

  procedure AddDetail(const AData: TStrings);
  var
    FStream: TFileStream;
    FSize: Int64;
    FBlk, FCode: string;
  begin
    FStream := TFileStream.Create(AFile, fmOpenRead);
    try
      FBlk := GetBlock(AFile);
      FSize := FStream.Size;
      FStream.Position := 4;
      while FStream.Position < FSize do
      begin
        FCode := Read(FStream, 12);
        AData.Add(FBlk);
        AData.Add(Copy(FCode, 1, 2));
        AData.Add(FCode);
        AData.Add('0');

        Write(ADest, AData);
      end;
    finally
      FStream.Free;
    end;
  end;
var
  FData: TStrings;
begin
  if Assigned(ADest) then
  begin
    FData := TStringList.Create;
    try
      case DataKind of
        dkSummary: AddSummary(FData);
        dkDetail: AddDetail(FData);
      end;
    finally
      FData.Free;
    end;
  end;
end;

procedure TDzhAbkFileTrans.TransDataFile(const ASrc: string; ADest: TStream);
var
  FFile: TCustomIniFile;
  FSection, FValue, FDetail, FList: TStrings;
  FSec, FStr, FCode, FData, FTmpCode, FCodeList: string;
  FAllBlockCodeList, FtmpCodeList: TStringList;
  FBlkCodeIndex: integer;
begin
  inherited;
  if FileExists(ASrc) and Assigned(ADest) then
  begin
    FFile := TMemIniFile.Create(ASrc);
    try
      FSection := TStringList.Create;
      FValue := TStringList.Create;
      FDetail := TStringList.Create;
      FList := TStringList.Create;

      FAllBlockCodeList := TStringList.Create;
      FtmpCodeList := TStringList.Create;

      try
        FDetail.Delimiter := ' '; /// 空格
        FFile.ReadSections(FSection);
        for FSec in FSection do
        begin
          FFile.ReadSection(FSec, FValue);
          for FStr in FValue do
          begin

            FCode := ResolveBlockName(FStr);
            FTmpCode := FCode;

            //控制重复编号
            FBlkCodeIndex := FAllBlockCodeList.IndexOfName(FCode);
            if FBlkCodeIndex = -1 then
            begin
              FAllBlockCodeList.Add(FCode + '=' + FCode);
            end
            else
            begin
              FCodeList := FAllBlockCodeList.Values[FCode];
              FCodeList := StringReplace(FCodeList, '|', #13#10,
                [rfReplaceAll]);
              FtmpCodeList.Text := FCodeList;
              FCode := FCode + '_' + IntToStr(FtmpCodeList.Count);
              FtmpCodeList.Add(FCode);
              FCodeList := FtmpCodeList.Text;
              FCodeList := StringReplace(FCodeList, #13#10, '|',
                [rfReplaceAll]);
              FAllBlockCodeList.Values[FTmpCode] := FCodeList;
            end;

            case DataKind of
              dkSummary:
                begin
                  FList.Add(FCode); /// 代码
                  FList.Add(FStr); /// 名称
                  FList.Add(FSec); /// 类别;

                  /// 输出
                  Write(ADest, FList);
                end;
              dkDetail:
                begin
                  FTmpCode := FFile.ReadString(FSec, FStr, '');
                  //                    outputdebugstring(PChar('Budded ' + FTmpCode));
                  FTmpCode := stringreplace(FTmpCode, ' ', slinebreak,
                    [rfreplaceall]);
                  FDetail.Text := FTmpCode;
                  for FData in FDetail do
                  begin

                    FList.Add(FCode); /// 代码
                    FList.Add(Copy(FData, 1, 2));
                    FList.Add(FData);
                    FList.Add('0');

                    /// 输出
                    Write(ADest, FList);

                  end;
                end;
            end;

          end;
        end;
      finally
        FList.Free;
        FDetail.Free;
        FValue.Free;
        FSection.Free;
        FAllBlockCodeList.Free;
        FtmpCodeList.Free;
      end;
    finally
      FFile.Free;
    end;
  end;
end;

procedure TDzhAbkFileTrans.Trans(const ASrcFile, ADestFile: TFileName;
  const Param: string);
var
  FDest: TStream;
  FData: TStrings;  
begin
  FDest := TFileStream.Create(ADestFile, fmCreate);
  try
    WriteHeader(FDest);
    /// 第一部分，Abk文件
    TransDataFile(ASrcFile, FDest);
    /// 第二部分，block目录
    TransDataDir(Param, FDest);
  finally
    FDest.Free;
  end;
end;

initialization
  TDzhAbkFileTrans.Register;

end.

