unit uTools;

interface

uses
  SysUtils, Windows, Classes;

type
  TMyList = class(TList)
  public
    procedure clear;
    procedure Delete(Index: Integer);
  end;

function GetCurrPath: String;
function GetCurrDate: String;
function StrToDateEx(const Date: string): TDateTime;

function ChnPy(Value: array of char): Char;
function SbctoDbc(s:string):string;
function ChnToPY(Value: string): string;
function ChinessToPinyin(hzchar: string): char;

const
  EXT_ANY_FILE = '.*';

function FindFile(AList: TStrings; const APath: TFileName;
  const Ext: String = EXT_ANY_FILE; const Recurisive: Boolean = False): Integer;

procedure Debug(const S: String); overload;  
procedure Debug(const S: String; const Arg: array of const); overload;

implementation

function GetCurrPath: String;
begin
  Result := ExcludeTrailingPathDelimiter(ExtractFilePath(GetModuleName(HInstance)));
end;    //用来去掉一个路径末尾的斜杠符 //返回指定文件的路径 //获取组建名
function GetCurrDate: String;
begin
  Result := FormatDateTime('YYYYMMDD', Date);  //获取当前日期
end;

procedure TMyList.clear;
var
  iLoop: integer;
begin
  for iLoop := 0 to Count - 1 do
  begin
    dispose(items[iLoop]);   //释放动态变量所占的空间
  end;
  inherited clear;
end;

procedure TMyList.Delete(Index: Integer);
begin
  dispose(items[Index]);
  inherited delete(Index);
end;

function StrToDateEx(const Date: string): TDateTime;
var
  FDate: string;
  FDateS: Char;
begin
  FDate := ShortDateFormat;
  FDateS := DateSeparator;     //日期分隔符
  try // try
    ShortDateFormat := 'YYYY-MM-DD';
    DateSeparator := '-';

    Result := StrToDate(Date);
  finally // wrap up finally
    ShortDateFormat := FDate;
    DateSeparator := FDateS;
  end; // end try finally
end;

procedure Debug(const S: String);
begin
{$IFDEF DEBUG}
  OutputDebugString(PChar('Budded: ' + S));
{$ENDIF}
end;
procedure Debug(const S: String; const Arg: array of const);
begin
{$IFDEF DEBUG}        //编译开关
  Debug(Format(S, Arg));
{$ENDIF}
end;

function FindFile(AList: TStrings; const APath: TFileName;
  const Ext: String; const Recurisive: Boolean): Integer;
var
  FSearchRec: TSearchRec;  //   文件信息记录
  FPath: TFileName;
  FRtn: integer;
begin
  Result := -1;
  if Assigned(AList) then    
  try
    FPath := IncludeTrailingPathDelimiter(APath);
    FRtn := FindFirst(FPath + '*.*', faAnyFile, FSearchRec);
    if FRtn = 0 then //寻找目标目录下的第一个文件
      repeat
        if (FSearchRec.Attr and faDirectory) = faDirectory then //faDirectory表示文件是目录，即文件夹
        begin
          if Recurisive and (FSearchRec.Name <> '.') and (FSearchRec.Name <> '..') then
            FindFile(AList, FPath + FSearchRec.Name, Ext, Recurisive);
        end
        else if SameText(Ext, EXT_ANY_FILE) or
          SameText(LowerCase(Ext), LowerCase(ExtractFileExt(FSearchRec.Name))) then //lowercase()小写字母
            AList.Add(FPath + FSearchRec.Name);
      until FindNext(FSearchRec) <> 0
    else  RaiseLastOSError;
  finally
    SysUtils.FindClose(FSearchRec); //FindClose释放由FindFirst分配的内存
    Result := AList.Count;
  end;
end;

const py: array[216..247] of string = (   
{216}'CJWGNSPGCGNESYPB' + 'TYYZDXYKYGTDJNMJ' + 'QMBSGZSCYJSYYZPG' +
{216}'KBZGYCYWYKGKLJSW' + 'KPJQHYZWDDZLSGMR' + 'YPYWWCCKZNKYDG',
{217}'TTNJJEYKKZYTCJNM' + 'CYLQLYPYQFQRPZSL' + 'WBTGKJFYXJWZLTBN' +
{217}'CXJJJJZXDTTSQZYC' + 'DXXHGCKBPHFFSSYY' + 'BGMXLPBYLLLHLX',
{218}'SPZMYJHSOJNGHDZQ' + 'YKLGJHXGQZHXQGKE' + 'ZZWYSCSCJXYEYXAD' +
{218}'ZPMDSSMZJZQJYZCD' + 'JEWQJBDZBXGZNZCP' + 'WHKXHQKMWFBPBY',
{219}'DTJZZKQHYLYGXFPT' + 'YJYYZPSZLFCHMQSH' + 'GMXXSXJJSDCSBBQB' +
{219}'EFSJYHXWGZKPYLQB' + 'GLDLCCTNMAYDDKSS' + 'NGYCSGXLYZAYBN',
{220}'PTSDKDYLHGYMYLCX' + 'PYCJNDQJWXQXFYYF' + 'JLEJBZRXCCQWQQSB' +
{220}'ZKYMGPLBMJRQCFLN' + 'YMYQMSQYRBCJTHZT' + 'QFRXQHXMJJCJLX',
{221}'QGJMSHZKBSWYEMYL' + 'TXFSYDSGLYCJQXSJ' + 'NQBSCTYHBFTDCYZD' +
{221}'JWYGHQFRXWCKQKXE' + 'BPTLPXJZSRMEBWHJ' + 'LBJSLYYSMDXLCL',
{222}'QKXLHXJRZJMFQHXH' + 'WYWSBHTRXXGLHQHF' + 'NMCYKLDYXZPWLGGS' +
{222}'MTCFPAJJZYLJTYAN' + 'JGBJPLQGDZYQYAXB' + 'KYSECJSZNSLYZH',
{223}'ZXLZCGHPXZHZNYTD' + 'SBCJKDLZAYFMYDLE' + 'BBGQYZKXGLDNDNYS' +
{223}'KJSHDLYXBCGHXYPK' + 'DQMMZNGMMCLGWZSZ' + 'XZJFZNMLZZTHCS',
{224}'YDBDLLSCDDNLKJYK' + 'JSYCJLKOHQASDKNH' + 'CSGANHDAASHTCPLC' +
{224}'PQYBSDMPJLPCJOQL' + 'CDHJJYSPRCHNKNNL' + 'HLYYQYHWZPTCZG',
{225}'WWMZFFJQQQQYXACL' + 'BHKDJXDGMMYDJXZL' + 'LSYGXGKJRYWZWYCL' +
{225}'ZMSSJZLDBYDCPCXY' + 'HLXCHYZJQSQQAGMN' + 'YXPFRKSSBJLYXY',
{226}'SYGLNSCMHCWWMNZJ' + 'JLXXHCHSYD CTXRY' + 'CYXBYHCSMXJSZNPW' +
{226}'GPXXTAYBGAJCXLYS' + 'DCCWZOCWKCCSBNHC' + 'PDYZNFCYYTYCKX',
{227}'KYBSQKKYTQQXFCWC' + 'HCYKELZQBSQYJQCC' + 'LMTHSYWHMKTLKJLY' +
{227}'CXWHEQQHTQHZPQSQ' + 'SCFYMMDMGBWHWLGS' + 'LLYSDLMLXPTHMJ',
{228}'HWLJZYHZJXHTXJLH' + 'XRSWLWZJCBXMHZQX' + 'SDZPMGFCSGLSXYMJ' +
{228}'SHXPJXWMYQKSMYPL' + 'RTHBXFTPMHYXLCHL' + 'HLZYLXGSSSSTCL',
{229}'SLDCLRPBHZHXYYFH' + 'BBGDMYCNQQWLQHJJ' + 'ZYWJZYEJJDHPBLQX' +
{229}'TQKWHLCHQXAGTLXL' + 'JXMSLXHTZKZJECXJ' + 'CJNMFBYCSFYWYB',
{230}'JZGNYSDZSQYRSLJP' + 'CLPWXSDWEJBJCBCN' + 'AYTWGMPABCLYQPCL' +
{230}'ZXSBNMSGGFNZJJBZ' + 'SFZYNDXHPLQKZCZW' + 'ALSBCCJXJYZHWK',
{231}'YPSGXFZFCDKHJGXD' + 'LQFSGDSLQWZKXTMH' + 'SBGZMJZRGLYJBPML' +
{231}'MSXLZJQQHZSJCZYD' + 'JWBMJKLDDPMJEGXY' + 'HYLXHLQYQHKYCW',
{232}'CJMYYXNATJHYCCXZ' + 'PCQLBZWWYTWBQCML' + 'PMYRJCCCXFPZNZZL' +
{232}'JPLXXYZTZLGDLDCK' + 'LYRLZGQTGJHHGJLJ' + 'AXFGFJZSLCFDQZ',
{233}'LCLGJDJCSNCLLJPJ' + 'QDCCLCJXMYZFTSXG' + 'CGSBRZXJQQCTZHGY' +
{233}'QTJQQLZXJYLYLBCY' + 'AMCSTYLPDJBYREGK' + 'JZYZHLYSZQLZNW',
{234}'CZCLLWJQJJJKDGJZ' + 'OLBBZPPGLGHTGZXY' + 'GHZMYCNQSYCYHBHG' +
{234}'XKAMTXYXNBSKYZZG' + 'JZLQJDFCJXDYGJQJ' + 'JPMGWGJJJPKQSB',
{235}'GBMMCJSSCLPQPDXC' + 'DYYKYWCJDDYYGYWR' + 'HJRTGZNYQLDKLJSZ' +
{235}'ZGZQZJGDYKSHPZMT' + 'LCPWNJAFYZDJCNMW' + 'ESCYGLBTZCGMSS',
{236}'LLYXQSXSBSJSBBGG' + 'GHFJLYPMZJNLYYWD' + 'QSHZXTYYWHMCYHYW' +
{236}'DBXBTLMSYYYFSXJC' + 'SDXXLHJHF SXZQHF' + 'ZMZCZTQCXZXRTT',
{237}'DJHNNYZQQMNQDMMG' + 'LYDXMJGDHCDYZBFF' + 'ALLZTDLTFXMXQZDN' +
{237}'GWQDBDCZJDXBZGSQ' + 'QDDJCMBKZFFXMKDM' + 'DSYYSZCMLJDSYN',
{238}'SPRSKMKMPCKLGDBQ' + 'TFZSWTFGGLYPLLJZ' + 'HGJJGYPZLTCSMCNB' +
{238}'TJBQFKTHBYZGKPBB' + 'YMTDSSXTBNPDKLEY' + 'CJNYCDYKZDDHQH',
{239}'SDZSCTARLLTKZLGE' + 'CLLKJLQJAQNBDKKG' + 'HPJTZQKSECSHALQF' +
{239}'MMGJNLYJBBTMLYZX' + 'DCJPLDLPCQDHZYCB' + 'ZSCZBZMSLJFLKR',
{240}'ZJSNFRGJHXPDHYJY' + 'BZGDLJCSEZGXLBLH' + 'YXTWMABCHECMWYJY' +
{240}'ZLLJJYHLGBDJLSLY' + 'GKDZPZXJYYZLWCXS' + 'ZFGWYYDLYHCLJS',
{241}'CMBJHBLYZLYCBLYD' + 'PDQYSXQZBYTDKYYJ' + 'YYCNRJMPDJGKLCLJ' +
{241}'BCTBJDDBBLBLCZQR' + 'PPXJCGLZCSHLTOLJ' + 'NMDDDLNGKAQHQH',
{242}'JHYKHEZNMSHRP QQ' + 'JCHGMFPRXHJGDYCH' + 'GHLYRZQLCYQJNZSQ' +
{242}'TKQJYMSZSWLCFQQQ' + 'XYFGGYPTQWLMCRNF' + 'KKFSYYLQBMQAMM',
{243}'MYXCTPSHCPTXXZZS' + 'MPHPSHMCLMLDQFYQ' + 'XSZYJDJJZZHQPDSZ' +
{243}'GLSTJBCKBXYQZJSG' + 'PSXQZQZRQTBDKYXZ' + 'KHHGFLBCSMDLDG',
{244}'DZDBLZYYCXNNCSYB' + 'ZBFGLZZXSWMSCCMQ' + 'NJQSBDQSJTXXMBLT' +
{244}'XZCLZSHZCXRQJGJY' + 'LXZFJPHYXZQQYDFQ' + 'JJLZZNZJCDGZYG',
{245}'CTXMZYSCTLKPHTXH' + 'TLBJXJLXSCDQXCBB' + 'TJFQZFSLTJBTKQBX' +
{245}'XJJLJCHCZDBZJDCZ' + 'JDCPRNPQCJPFCZLC' + 'LZXBDMXMPHJSGZ',
{246}'GSZZQLYLWTJPFSYA' + 'SMCJBTZYYCWMYTCS' + 'JJLQCQLWZMALBXYF' +
{246}'BPNLSFHTGJWEJJXX' + 'GLLJSTGSHJQLZFKC' + 'GNNDSZFDEQFHBS',
{247}'AQTGYLBXMMYGSZLD' + 'YDQMJJRGBJTKGDHG' + 'KBLQKBDMBYLXWCXY' +
{247}'TTYBKMRTJZXQJBHL' + 'MHMJJZMQASLDCYXY' + 'QDLQCAFYWYXQHZ'
    );
//中文转拼音每次传入一个汉字
function ChnPy(Value: array of char): Char;
begin
  Result := #0;   //#表示ASCII值，#0代表空值
  case Byte(Value[0]) of     //Byte()强制数据转换成二进制
    176:
      case Byte(Value[1]) of
        161..196: Result := 'A';
        197..254: Result := 'B';
      end; {case}
    177:
      Result := 'B';
    178:
      case Byte(Value[1]) of
        161..192: Result := 'B';
        193..205: Result := 'C';
        206: Result := 'S'; //参
        207..254: Result := 'C';
      end; {case}
    179:
      Result := 'C';
    180:
      case Byte(Value[1]) of
        161..237: Result := 'C';
        238..254: Result := 'D';
      end; {case}
    181:
      Result := 'D';
    182:
      case Byte(Value[1]) of
        161..233: Result := 'D';
        234..254: Result := 'E';
      end; {case}
    183:
      case Byte(Value[1]) of
        161: Result := 'E';
        162..254: Result := 'F';
      end; {case}
    184:
      case Byte(Value[1]) of
        161..192: Result := 'F';
        193..254: Result := 'G';
      end; {case}
    185:
      case Byte(Value[1]) of
        161..253: Result := 'G';
        254: Result := 'H';
      end; {case}
    186:
      Result := 'H';
    187:
      case Byte(Value[1]) of
        161..246: Result := 'H';
        247..254: Result := 'J';
      end; {case}
    188..190:
      Result := 'J';
    191:
      case Byte(Value[1]) of
        161..165: Result := 'J';
        166..254: Result := 'K';
      end; {case}
    192:
      case Byte(Value[1]) of
        161..171: Result := 'K';
        172..254: Result := 'L';
      end; {case}
    193:
      Result := 'L';
    194:
      case Byte(Value[1]) of
        161..231: Result := 'L';
        232..254: Result := 'M';
      end; {case}
    195:
      Result := 'M';
    196:
      case Byte(Value[1]) of
        161..194: Result := 'M';
        195..254: Result := 'N';
      end; {case}
    197:
      case Byte(Value[1]) of
        161..181: Result := 'N';
        182..189: Result := 'O';
        190..254: Result := 'P';
      end; {case}
    198:
      case Byte(Value[1]) of
        161..217: Result := 'P';
        218..254: Result := 'Q';
      end; {case}
    199:
      Result := 'Q';
    200:
      case Byte(Value[1]) of
        161..186: Result := 'Q';
        187..245: Result := 'R';
        246..254: Result := 'S';
      end; {case}
    201..202:
      Result := 'S';
    203:
      case Byte(Value[1]) of
        161..249: Result := 'S';
        250..254: Result := 'T';
      end; {case}
    204:
      Result := 'T';
    205:
      case Byte(Value[1]) of
        161..217: Result := 'T';
        218..254: Result := 'W';
      end; {case}
    206:
      case Byte(Value[1]) of
        161..243: Result := 'W';
        244..254: Result := 'X';
      end; {case}
    207..208:
      Result := 'X';
   209:
      case Byte(Value[1]) of
        161..184: Result := 'X';
        185..254: Result := 'Y';
      end; {case}
    210..211:
      Result := 'Y';
    212:
      case Byte(Value[1]) of
        161..208: Result := 'Y';
        209..254: Result := 'Z';
      end; {case}
    213..215:
      Result := 'Z';
    216..247:
      Result := py[Byte(Value[0])][Byte(Value[1]) - 160];
  end; {case}
end;

function SbctoDbc(s:string):string;
var
  nlength,i:integer;
  str,ctmp,c1,c2:string;
  {
 在windows中，中文和全角字符都占两个字节，
 并且使用了ascii　chart  2  (codes  128 - 255 )。
全角字符的第一个字节总是被置为163，
 而第二个字节则是相同半角字符码加上128（不包括空格）。
 如半角a为65，则全角a则是163（第一个字节）、 193 （第二个字节， 128 + 65 ）。
 而对于中文来讲，它的第一个字节被置为大于163，（
 如 ' 阿 ' 为: 176   162 ）,我们可以在检测到中文时不进行转换。
}
begin
 nlength:=length(s);
 if (nlength=0) then
  exit;
 str:='' ;
 SetLength(ctmp, nlength+1 );
 ctmp:=s;
 i:=1;
 while (i<=nlength) do
  begin
   c1:=ctmp[i];
   c2:=ctmp[i+1];
   if (c1=#163) then //如果是全角字符
    begin
     str:=str+chr(ord(c2[1])-128);  //ord()是反回字符的ASCII码值
     inc(i, 2);
     continue ;
    end;

   if (c1>#163) then //如果是汉字
    begin
     str:=str+c1;
     str:=str+c2;
     inc(i, 2);
     continue ;
    end;

   if (c1=#161) and (c2=#161) then //如果是全角空格
    begin
     str:=str+'   ';
     inc(i, 2);
     continue;
    end;
   str:=str+c1;
   inc(i);
  end;

 Result:=str;
end;

function ChnToPY(Value: string): string;
var
  I, L: Integer;
  C: array[0..1] of char;
  R: Char;
begin
  Result := '';
  L := Length(Value);
  I := 1;
  while I <= (L - 1) do
  begin
    if Value[I] < #160 then
    begin
      Result := Result + Value[I];
      Inc(I);
    end
    else
    begin
      C[0] := Value[I];
      C[1] := Value[I + 1];
      R := ChnPY(C);
      if r <> #0 then
        Result := Result + R;
      Inc(I, 2);
    end;
  end;

  if I = L then
    Result := Result + Value[L];
  if Result = '' then
    Result := SbctoDbc(Value);

end;

function ChinessToPinyin(hzchar: string): char;
begin
  result := #0;
  case word(hzchar[1]) shl 8 + word(hzchar[2]) of
    $B0A1..$B0C4: RESULT := 'A';
    $B0C5..$B2C0: RESULT := 'B';
    $B2C1..$B4ED: RESULT := 'C';
    $B4EE..$B6E9: RESULT := 'D';
    $B6EA..$B7A1: RESULT := 'E';
    $B7A2..$B8C0: RESULT := 'F';
    $B8C1..$B9FD: RESULT := 'G';
    $B9FE..$BBF6: RESULT := 'H';
    $BBF7..$BFA5: RESULT := 'J';
    $BFA6..$C0AB: RESULT := 'K';
    $C0AC..$C2E7: RESULT := 'L';
    $C2E8..$C4C2: RESULT := 'M';
    $C4C3..$C5B5: RESULT := 'N';
    $C5B6..$C5BD: RESULT := 'O';
    $C5BE..$C6D9: RESULT := 'P';
    $C6DA..$C8BA: RESULT := 'Q';
    $C8BB..$C8F5: RESULT := 'R';
    $C8F6..$CBF9: RESULT := 'S';
    $CBFA..$CDD9: RESULT := 'T';
    $CDDA..$CEF3: RESULT := 'W';
    $CEF4..$D188: RESULT := 'X';
    $D1B9..$D4D0: RESULT := 'Y';
    $D4D1..$D7F9: RESULT := 'Z';
  end;
end;

end.

