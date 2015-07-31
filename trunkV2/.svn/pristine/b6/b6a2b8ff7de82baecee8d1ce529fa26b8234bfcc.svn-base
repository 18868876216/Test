unit uInterface;

interface
uses
  Windows, SysUtils, Classes;

type
  TFileKindEx = (
    fkFundNav_DBF,                                 // 基金净值-DBF
    fkFundNav_Web,                                 // 基金净值-官网
    fkFundNav_fund123,                             // 基金净值-fund123
    fkFundNav_ifund,                               // 基金净值-爱基金
    fkFundNav_stockstar,                           // 基金净值-证券之星
    fkFundNav_HeXun,                               // 基金净值-和讯
    fkFundNav_JRJ                                  // 基金净值-金融界
  );
  TFileKindSetEx = set of TFileKindEx;

const
  ALL_FILE_KIND: TFileKindSetEx = [fkFundNav_DBF,
    fkFundNav_Web,
    fkFundNav_fund123,
    fkFundNav_ifund,
    fkFundNav_stockstar,
    fkFundNav_HeXun,
    fkFundNav_JRJ];
    
type
  IFundNav = interface
  ['{5C78597E-F857-4F7B-89C1-D39B10874A43}']
    function GetSupportedFileKind(): TFileKindSetEx;
    procedure GetFundNav( AFileKind: TFileKindEx; Temporarylist: TStrings);
    procedure GetFinaNav(const ADest: TStream; Temporarylist: TStrings);
  end;

implementation

end.
