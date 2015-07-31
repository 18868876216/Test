program dzhRead;

{$R 'Version.res' 'Version.rc'}
{$R 'Icon.res' 'Icon.rc'}

uses
  SysUtils,
  uTools in 'uTools.pas',
  uSingleton in 'uSingleton.pas',
  uContainer in 'uContainer.pas',
  uFactory in 'uFactory.pas',
  uDzhBinFileTrans in 'uDzhBinFileTrans.pas',
  uHtmlFileTrans in 'uHtmlFileTrans.pas',
  uExcelFileTrans in 'uExcelFileTrans.pas',
  uDzhAbkFileTrans in 'uDzhAbkFileTrans.pas',
  DataLayer in 'DataLayer.pas',
  uWinnerDayDatTrans in 'uWinnerDayDatTrans.pas',
  uDataLayerProtocol in 'uDataLayerProtocol.pas',
  uTransEtfInfo in 'uTransEtfInfo.pas',
  uStockDayTrans in 'uStockDayTrans.pas',
  uDBFReader in 'uDBFReader.pas',
  uFutuDayTrans in 'uFutuDayTrans.pas',
  uDataToDB in 'uDataToDB.pas',
  uInterface in 'uInterface.pas',
  uGetFundNav in 'uGetFundNav.pas',
  uStockInfo in 'uStockInfo.pas';

{$APPTYPE CONSOLE}

var
  FIntf: IDataTrans;
begin
   { if ParamStr(1) = 'fkWinnerDayData' then
    begin
      TransWinnerDayData;
      Exit;
    end;   }
    FIntf := TDataTransFactory.Instance.ItemByID(ParamStr(1));
    if Assigned(FIntf) then
    begin
      FIntf.SetFilter(ParamStr(4), ParamStr(5));
      FIntf.Trans(ParamStr(2), ParamStr(3), ParamStr(4));
    end
    else
      raise Exception.CreateFmt('未知文件类型参数：%s', [ParamStr(1)]);
end.

