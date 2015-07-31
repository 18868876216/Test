unit ufrmDataMng;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB, StdCtrls, ExtCtrls, ComCtrls, DateUtils, Menus;

type
  TfrmDataMng = class(TForm)
    confx: TADOConnection;
    commdfx: TADOCommand;
    pnlFundNav: TPanel;
    Bevel1: TBevel;
    btnDownLoadFundNav: TButton;
    dtpEnd: TDateTimePicker;
    dtpStart: TDateTimePicker;
    Label2: TLabel;
    lblInterval: TLabel;
    mFundNavLog: TMemo;
    pmParamSet: TPopupMenu;
    miRealEnv: TMenuItem;
    miTestEnv: TMenuItem;
    procedure btnDownLoadFundNavClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miRealEnvClick(Sender: TObject);
    procedure miTestEnvClick(Sender: TObject);
  private
    { Private declarations }
    function SockGet(const AUrl: String): String;
    procedure SolveFundNavInfo(ADest: TStringList; const ADestContent, ADate, AMarket: String);
  public
    { Public declarations }
  end;

var
  frmDataMng: TfrmDataMng;

implementation
uses
  IdHTTP;
{$R *.dfm}

procedure TfrmDataMng.btnDownLoadFundNavClick(Sender: TObject);
var
  iStartDate, iEndDate: TDateTime;
  iDayIndex: Integer;
  sDate, url, sContent: String;
  sqlList: TStringList;
begin
  iStartDate := dtpStart.DateTime;
  iEndDate := dtpEnd.DateTime;
  sqlList := TStringList.Create;
  mFundNavLog.Lines.Add('基金净值下载开始');
  while iStartDate <= iEndDate do
  begin
    sqlList.Clear;
    iDayIndex := DayOfTheWeek(iStartDate);
    if (iDayIndex >= 1) and (iDayIndex <= 5) then
    begin
      url := 'http://www.fund123.cn/LatestData.aspx?Type=' + FormatDateTime('YYYY-MM-DD', iStartDate);
      sDate := FormatDateTime('YYYYMMDD', iStartDate);
      mFundNavLog.Lines.Add('正在下载交易日' + sDate + '的基金净值...');
      sContent := SockGet(url);
      if sContent <> '' then
      begin
        mFundNavLog.Lines.Add('正在解析交易日' + sDate + '的基金净值...');
        SolveFundNavInfo(sqlList, sContent, sDate, '');
        if sqlList.Count > 0 then
        begin
          mFundNavLog.Lines.Add('正在删除交易日' + sDate + '的基金净值...');
          commdfx.CommandText := 'delete from priceday where rq=' + sDate + ' and sc=''' + 'OF''';
          commdfx.Execute;
          mFundNavLog.Lines.Add('正在新增交易日' + sDate + '的基金净值...');
          commdfx.CommandText := sqlList.Text;
          commdfx.Execute;
          sqlList.SaveToFile('24.txt');
        end;
      end;
    end;
    iStartDate := IncDay(iStartDate, 1);
  end;
  sqlList.Free;
  mFundNavLog.Lines.Add('基金净值下载结束');
end;

procedure TfrmDataMng.FormCreate(Sender: TObject);
begin
  dtpStart.DateTime := date;
  dtpEnd.DateTime := date;
end;

procedure TfrmDataMng.miRealEnvClick(Sender: TObject);
var
  sConnectStr: String;
begin
  sConnectStr := 'Provider=SQLOLEDB.1;Password=13116753765;Persist Security Info=T' +
    'rue;User ID=sa;Initial Catalog=ytfx;Data Source=10.19.19.250';
  confx.Close;
  confx.ConnectionString := sConnectStr;
  confx.Connected := true;
end;

procedure TfrmDataMng.miTestEnvClick(Sender: TObject);
var
  sConnectStr: String;
begin
  sConnectStr := 'Provider=SQLOLEDB.1;Password=13116753765;Persist Security Info=T' +
    'rue;User ID=sa;Initial Catalog=ytfx;Data Source=10.19.19.110';
  confx.Close;
  confx.ConnectionString := sConnectStr;
  confx.Connected := true;
end;

function TfrmDataMng.SockGet(const AUrl: String): String;
var
  FSocks: TIdHTTP;
begin
  FSocks := TIdHTTP.Create(nil);
  try
    Result := FSocks.Get(AUrl);
  finally
    FSocks.Free;
  end;
end;

procedure TfrmDataMng.SolveFundNavInfo(ADest: TStringList; const ADestContent, ADate,
  AMarket: String);
var
  s1, s: TStringList;
  s2, sTemp, sDestContent: String;
  iFundIndex: Integer;
  iValueIndex: Integer;
  sCode, sMarket: String;
  sNav: String;
  FData: TStrings;
  sSql: String;
begin
  FData :=  TStringList.Create;
  s1 := TStringList.Create;
  s := TStringList.Create;
  sDestContent := ADestContent;
  sDestContent := StringReplace(sDestContent, '],[', #13#10, [rfReplaceAll]);
  s1.Text := sDestContent;
  sMarket := 'OF';
  for iFundIndex := 0 to s1.Count - 1 do
  begin
    s2 := s1.Strings[iFundIndex];
    s2 := StringReplace(s2, '[', '', [rfReplaceAll]);
    s2 := StringReplace(s2, ',', #3#10, [rfReplaceAll]);
    s2 := StringReplace(s2, #3, '', [rfReplaceAll]);
    s.Text := s2;
    if (s.Count < 5) then
		  continue;
    sNav := s.Strings[3];
    sNav := StringReplace(sNav, '''', '', [rfReplaceAll]);
    if sNav = '' then
			continue;

    sCode := s.Strings[1];
    sCode := StringReplace(sCode, '''', '', [rfReplaceAll]);
    if Pos('募集中', sCode) > 0 then
      continue;

    sSql := format('insert into priceday values(%s, ''%s'', ''%s'', %s, %s, %s, %s, 0, 0);', [ADate, sMarket, sMarket + sCode, sNav, sNav, sNav, sNav]);
    ADest.Add(sSql);
  end;
end;


end.
