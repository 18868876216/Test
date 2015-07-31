unit uDataToDB;

interface

uses
  Windows, SysUtils, Classes, Forms, Math, TypInfo, uInterface,
  uHtmlFileTrans, uFactory;
type
  TFundNav = class(THtmlFileTrans, IFundNav)
  public
    procedure GetFundNav( AFileKind: TFileKindEx; Temporarylist: TStrings);
    procedure GetFinaNav(const ADest: TStream; Temporarylist: TStrings);
    function GetSupportedFileKind(): TFileKindSetEx;
  protected
    Temporarylist: TStrings;
    procedure Trans(const ASrcFile, ADestFile: TFileName; const Param: String); override;
    procedure TransData(const ASrc,ADest: TStream); override;
    class function SupportedFileKind(): TFileKindSet; override;
  end;

implementation

{ TDataTrans }
uses
  DateUtils, uGetFundNav;

procedure TFundNav.Trans(const ASrcFile, ADestFile: TFileName;  const Param: String);
begin
  inherited;
end;

procedure TFundNav.TransData(const ASrc,ADest: TStream);
var
  FKind: TFileKindEx;
  FFileKindSetEx: TFileKindSetEx;
begin
  Temporarylist := TStringlist.Create;
  Temporarylist.Clear;
  FFileKindSetEx := GetSupportedFileKind();
  for FKind in FFileKindSetEx do
    GetFundNav(FKind, Temporarylist);
  GetFinaNav(ADest,Temporarylist);
  Temporarylist.Free;
end;

procedure TFundNav.GetFinaNav(const ADest: TStream; Temporarylist: TStrings);

  procedure WriteNavFile(const ADest: TStream; AList: TStrings);
  var
    I: Integer;
    rq, dm, jz_DBF, jz_Web, jz_123, jz_ifund, jz_stockstar, jz_hexun, jz_jrj: String;
    List, List1: TStringlist;
  begin
    List:= TStringlist.Create;
    List1:= TStringlist.Create;
    for I := 0 to AList.Count - 1 do
    begin
      List.CommaText := AList[I];
      case StrtoInt(List[3]) of
        1:        jz_DBF := List[2];
        2:        jz_Web := List[2];
        3:        jz_123 := List[2];
        4:        jz_jrj := List[2];
        5:        jz_hexun := List[2];
        6:        jz_stockstar := List[2];
      end;
    end;
    rq := List[0];
    dm := List[1];
    List1.CommaText := rq+','+dm+','+jz_DBF+','+jz_Web+','+jz_123+','+jz_jrj
    +','+jz_hexun+','+jz_stockstar;
    Write(ADest,List1);
    List.Free;
    List1.Free;
  end;

var
  Date:String;
  List1,List2,List3: TStringlist;
  I: Integer;
begin
  List1 := TStringlist.Create;
  List2 := TStringlist.Create;
  List3 := TStringlist.Create;
  Date := GetInfFromDB('SELECT ytbase.dbo.GetPrecTradeDay()');
  TStringlist(Temporarylist).Sort;
  I:=0;
  while pos(Date,Temporarylist[I])=0 do
    inc(I);
  List2.Add(Temporarylist[I]);
  List1.CommaText := Temporarylist[I];
  inc(I);
  while I <= Temporarylist.Count-1 do
  begin
    if pos(Date,Temporarylist[I])>0 then
      begin
      if pos(List1[1],Temporarylist[I])>0 then
        begin
          List2.Add(Temporarylist[I]);
          inc(I);
        end
      else
        begin
          WriteNavFile(ADest,List2);
          List2.Clear;
          List2.Add(Temporarylist[I]);
          List1.CommaText := Temporarylist[I];
          inc(I);
        end;
      end
    else
      inc(I);
  end;
  WriteNavFile(ADest,List2);
  List1.Free;
  List2.Free;
  List3.Free;
end;

procedure TFundNav.GetFundNav(AFileKind: TFileKindEx; Temporarylist: TStrings);

begin
  case AFileKind of
    fkFundNav_DBF:          TGetData.TransDataDBF(Temporarylist);
    fkFundNav_Web:          TGetData.TransDataWeb(Temporarylist);
    fkFundNav_fund123:      TGetData.TransDatafund123(Temporarylist);
    fkFundNav_stockstar:    TGetData.TransDatastockstar(Temporarylist);
    fkFundNav_HeXun:        TGetData.TransDataHeXun(Temporarylist);
    fkFundNav_JRJ:          TGetData.TransDataJRJ(Temporarylist);
    //fkFundNav_ifund:        TGetData.TransDataifund(Temporarylist);
  end;
end;

function TFundNav.GetSupportedFileKind(): TFileKindSetEx;
begin
  Result := ALL_FILE_KIND;
end;

class function TFundNav.SupportedFileKind: TFileKindSet;
begin
  Result := [fkFundNavToDB];
end;

initialization

  TFundNav.Register;

end.
