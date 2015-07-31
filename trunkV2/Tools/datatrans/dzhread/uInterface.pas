unit uInterface;

interface
uses
  Windows, SysUtils, Classes;

type
  TFileKindEx = (
    fkFundNav_DBF,                                 // ����ֵ-DBF
    fkFundNav_Web,                                 // ����ֵ-����
    fkFundNav_fund123,                             // ����ֵ-fund123
    fkFundNav_ifund,                               // ����ֵ-������
    fkFundNav_stockstar,                           // ����ֵ-֤ȯ֮��
    fkFundNav_HeXun,                               // ����ֵ-��Ѷ
    fkFundNav_JRJ                                  // ����ֵ-���ڽ�
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
