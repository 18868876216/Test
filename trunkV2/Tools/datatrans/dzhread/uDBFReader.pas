unit uDBFReader;

interface

uses
  SysUtils, Classes, uContainerEx;

type
  PDBFHeader = ^TDBFHeader;
  TDBFHeader = packed record
    DBType: Byte;
    M, D, Y: Byte;
    RecCount: Integer;
    HeadLen: Word;
    RecLen: Word;
    Reserved: array[13..32]of Byte;
  end;

  PDBFColumn = ^TDBFColumn;
  TDBFColumn = packed record
    FieldName: array[0..10]of Char;
    FieldType: Char;
    Offset: Integer;
    FieldLen: Byte;
    DecimalPlaces: Byte;
    FieldFlag: Byte;
    AutoNextValue: Word;
    AutoStepValue: Byte;
    Reserved: array[0..9]of Byte;
  end;

type
  TDBFColumns = class(TContnrListEx)
  protected
    /// 判断 Item1与Item2的先后顺序
    ///  Item1排在前则返回小于0
    ///  Item1排在后则返回大于0
    ///  两者相等则返回0
    function QuickSortCompare(const Item1, Item2: Pointer): Integer; override;
    procedure ProcessData(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create(); reintroduce; overload;
    procedure ReadColumn(const AFile: TStream; const TotalLen: Integer);
    function ItemsByName(const AName: String): PDBFColumn;
  end;
type
  TDBFReader = class(TContnrListEx)
  strict private
    FHeader: TDBFHeader;
    FColumns: TDBFColumns;
  protected
    procedure ProcessData(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create(const AFile: TFileName); reintroduce; overload;
    destructor Destroy(); override;
    procedure ReadFile(const AFile: TFileName);
    property Columns: TDBFColumns read FColumns;
    function FieldByName(const Idx: Integer; const AColumn: String): String; overload;
    function FieldByName(const Data: Pointer; const AColumn: String): String; overload;
  end;

implementation
(*
  http://www.cnblogs.com/railgunman/archive/2011/04/17/2019192.html


A DBF file consists of a header record and data records. The header record defines the structure of the table and contains any other information related to the table. The header record starts at file position zero. Data records follow the header, in consecutive bytes, and contain the actual text of the fields.

Note    The data in the data file starts at the position indicated in bytes 8 to 9 of the header record. Data records begin with a delete flag byte. If this byte is an ASCII space (0x20), the record is not deleted. If the first byte is an asterisk (0x2A), the record is deleted. The data from the fields named in the field subrecords follows the delete flag.
The length of a record, in bytes, is determined by summing the defined lengths of all fields. Integers in table files are stored with the least significant byte first.

DBF File Header
Byte offset	      Description
0	                File type:
                    0x02    FoxBASE
                    0x03    FoxBASE+/Dbase III plus, no memo
                    0x30    Visual FoxPro
                    0x31    Visual FoxPro, autoincrement enabled
                    0x43    dBASE IV SQL table files, no memo
                    0x63    dBASE IV SQL system files, no memo
                    0x83    FoxBASE+/dBASE III PLUS, with memo
                    0x8B    dBASE IV with memo
                    0xCB    dBASE IV SQL table files, with memo
                    0xF5    FoxPro 2.x (or earlier) with memo
                    0xFB    FoxBASE
1 - 3	            Last update (YYMMDD)
4 – 7	            Number of records in file
8 – 9	            Position of first data record
10 – 11	          Length of one data record, including delete flag
12 – 27	          Reserved
28	              Table flags:
                    0x01    file has a structural .cdx
                    0x02    file has a Memo field
                    0x04    file is a database (.dbc)
                    This byte can contain the sum of any of the above values. For example, the value 0x03 indicates the table has a structural .cdx and a Memo field.
29	              Code page mark
30 – 31	          Reserved, contains 0x00
32 – n	          Field subrecords
                    The number of fields determines the number of field subrecords. One field subrecord exists for each field in the table.
                    n+1	Header record terminator (0x0D)
                    n+2 to n+264	A 263-byte range that contains the backlink, which is the relative path of an associated database (.dbc) file, information. If the first byte is 0x00, the file is not associated with a database. Therefore, database files always contain 0x00.
                    Field Subrecords Structure
                    Byte offset	Description
0 – 10	          Field name with a maximum of 10 characters. If less than 10, it is padded with null characters (0x00).
11	              Field type:
                    C    –    Character
                    Y    –    Currency
                    N    –    Numeric
                    F    –    Float
                    D    –    Date
                    T    –    DateTime
                    B    –    Double
                    I    –    Integer
                    L    –    Logical
                    M    – Memo
                    G    – General
                    C    –    Character (binary)
                    M    –    Memo (binary)
                    P    –    Picture
12 – 15	          Displacement of field in record
16	              Length of field (in bytes)
17	              Number of decimal places
18	              Field flags:
                    0x01    System Column (not visible to user)
                    0x02    Column can store null values
                    0x04    Binary column (for CHAR and MEMO only)
                    0x06    (0x02+0x04) When a field is NULL and binary (Integer, Currency, and Character/Memo fields)
                    0x0C    Column is autoincrementing
19 - 22	          Value of autoincrement Next value
23	              Value of autoincrement Step value
24 – 31	          Reserved

typedef struct 
{ 
    FILE *fp;

    int         nRecords;

    int   nRecordLength; 
    int   nHeaderLength; 
    int   nFields; 
    int   *panFieldOffset; 
    int   *panFieldSize; 
    int   *panFieldDecimals; 
    char *pachFieldType;

    char *pszHeader;

    int   nCurrentRecord; 
    int   bCurrentRecordModified; 
    char *pszCurrentRecord; 
    
    int   bNoHeader; 
    int   bUpdated; 
} DBFInfo;

-----------------------------------------------------------------------------------------------------------

DBF文件结构分为两大部分：文件结构说明区和数据区。
一、文件结构说明区包括数据库参数区和记录结构表区。数据库参数区占32个字节：

1字节 数据库开始标志（若数据库含DBT文件为80H，否则为03H）
2－4字节 文件建立或修改的日期（YYMMDD 其中YY=日期-1900）
5－8字节 数据库的记录记录数，低字节在前，高字节在后
9－10字节 文件结构说明区长度
11－12字节 每条记录的总长度
12-32字节 保留
    
记录结构表区包括各字段参数，每个字段占32字节：   
1－11字节 字段名   
12 字段类型
13－14 首记录中该字段对应内存地址的偏移量   
15－16 首记录中该字段对应内存地址的段地址   
17 字段长度   
18 字段小数位数   
在所有记录结构表区后是数据库结构结束标志，其中 Foxbase   以0D结束，dBASE   以0D，00   
结束。   
二、数据库数据区每条记录按字段依次存放，没有分隔符，也没有终止符，每条记录以删除标志   
20H开始，若该记录被删除，则该标志为2AH 即“*”。   
数据库的最后一个字节为结束标志1AH。
*)

{ TDBFReader }

constructor TDBFReader.Create(const AFile: TFileName);
begin
  inherited Create();
  ReadFile(AFile);
end;

destructor TDBFReader.Destroy;
begin
  if Assigned(FColumns) then
    FColumns.Free;
  inherited;
end;

function TDBFReader.FieldByName(const Idx: Integer;
  const AColumn: String): String;
begin
  Result := FieldByName(Items[Idx], AColumn);
end;

function TDBFReader.FieldByName(const Data: Pointer;
  const AColumn: String): String;
var
  FColumn: PDBFColumn;
  FData: PChar;
begin
  Result := '';
  if Assigned(Data) then
  begin
    FColumn := FColumns.ItemsByName(AColumn);
    if Assigned(FColumn) then
    begin
      FData := PChar(Integer(Data) + FColumn.Offset);
      Result := FData;
      if Length(Result) > FColumn.FieldLen then
        SetLength(Result, FColumn.FieldLen);
    end;
  end;
end;

procedure TDBFReader.ProcessData(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Action = lnDeleted then
    FreeMem(Ptr);
end;

procedure TDBFReader.ReadFile(const AFile: TFileName);
var
  FFile: TFileStream;
  I: Integer;
  FPtr: Pointer;
begin
  FFile := TFileStream.Create(AFile, fmOpenRead);
  try
    Clear;

    FFile.Read(FHeader, SizeOf(FHeader));

    if FColumns = nil then
      FColumns := TDBFColumns.Create();
    FColumns.ReadColumn(FFile, FHeader.HeadLen);

    FFile.Position := FHeader.HeadLen;
    for I := 0 to FHeader.RecCount - 1 do
    begin
      FPtr := AllocMem(FHeader.RecLen);
      FFile.Read(FPtr^, FHeader.RecLen);
      Add(FPtr);
    end;
  finally
    FFile.Free;
  end;
end;

{ TDBFColumns }

constructor TDBFColumns.Create();
begin
  inherited Create;
  Sorted := True;
  Duplicates := dupeIgnore;
end;

function TDBFColumns.ItemsByName(const AName: String): PDBFColumn;
var
  FColumn: TDBFColumn;
  FData: Pointer;
begin
  Result := nil;
  StrPLCopy(FColumn.FieldName, AName, 10);
  if Find(@FColumn, FData) then
    Result := FData;
end;

procedure TDBFColumns.ProcessData(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Action = lnDeleted then
    FreeMem(Ptr);
end;

function TDBFColumns.QuickSortCompare(const Item1, Item2: Pointer): Integer;
begin
  Result := SORT_DEF_NUM;
  if Assigned(Item1) and Assigned(Item2) then
    Result := CompareText(PDBFColumn(Item1).FieldName, PDBFColumn(Item2).FieldName);
end;

procedure TDBFColumns.ReadColumn(const AFile: TStream; const TotalLen: Integer);
const
  SizeOfCol = SizeOf(TDBFColumn);
var
  FPos: Int64;
  FP: PDBFColumn;
begin
  Clear;
  FPos := AFile.Position;
  while FPos < TotalLen do
  begin
    FP := AllocMem(SizeOfCol);
    AFile.Read(FP^, SizeOfCol);
    Add(FP);
    FPos := AFile.Position + SizeOfCol;
  end;
end;

end.
