unit uDataLayerProtocol;     //  数据层协议

interface

uses
  SysUtils, Windows;

const
  MARKE_MASK = $F000; // 掩码
  MARKE_MIDDLE_MASK = $0F00; //
  MARKE_DETAIL_MASK = $00FF; //

{$REGION '<<股票>>'}
  STOCK_MARKET = $1000; // 股票
  SH_Bourse = $0100; // 上海
  SZ_Bourse = $0200; // 深圳
  SYSBK_BOURSE = $0400; // 系统板块
  USERDEF_BOURSE = $0800; // 定义（自选股或者自定义板块）
  KIND_INDEX = $0000; // 指数
  KIND_STOCKA = $0001; // A股
  KIND_STOCKB = $0002; // B股
  KIND_BOND = $0003; // 债券
  KIND_FUND = $0004; // 基金
  KIND_THREEBOAD = $0005; // 三板
  KIND_SMALLSTOCK = $0006; // 中小盘股
  KIND_PLACE = $0007; // 配售
  KIND_LOF = $0008; // LOF
  KIND_ETF = $0009; // ETF
  KIND_QuanZhen = $000A; // 权证
  KIND_OtherIndex = $000E; // 第三方行情分类，如:中信指数
  SC_Others = $000F; // 其他
  KIND_USERDEFINE = $0010; // 定义指数
{$ENDREGION}
{$REGION '<<港股>>'}
  HK_MARKET = $2000; // 港股分类
  HK_BOURSE = $0100; // 主板市场
  GE_BOURSE = $0200; // 创业板市场(Growth Enterprise Market)
  INDEX_BOURSE = $0300; // 指数市场
  HK_KIND_INDEX = $0000; // 港指
  HK_KIND_FUTURES_INDEX = $0001; // 期指
  KIND_Option = $0002; // 港股期权
  HK_SYSBK_BOURSE = $0400; // 港股板块(H股指数成份股，恒生指数成份股）。
  HK_USERDEF_BOURSE = $0800; // 自定义（自选股或者自定义板块）
  HK_KIND_BOND = $0000; // 债券
  HK_KIND_MulFund = $0001; // 一揽子认股证
  HK_KIND_FUND = $0002; // 基金
  KIND_WARRANTS = $0003; // 认股证
  KIND_JR = $0004; // 金融
  KIND_ZH = $0005; // 综合
  KIND_DC = $0006; // 地产
  KIND_LY = $0007; // 旅游
  KIND_GY = $0008; // 工业
  KIND_GG = $0009; // 公用
  KIND_QT = $000A; // 其它
{$ENDREGION}
{$REGION '<<期货>>'}
  FUTURES_MARKET = $4000; // 期货
  DALIAN_BOURSE = $0100; // 大连
  KIND_BEAN = $0001; // 连豆
  KIND_YUMI = $0002; // 大连玉米
  KIND_SHIT = $0003; // 大宗食糖
  KIND_DZGY = $0004; // 大宗工业1
  KIND_DZGY2 = $0005; // 大宗工业2
  KIND_DOUYOU = $0006; // 连豆油
  SHANGHAI_BOURSE = $0200; // 上海
  KIND_METAL = $0001; // 上海金属
  KIND_RUBBER = $0002; // 上海橡胶
  KIND_FUEL = $0003; // 上海燃油
  KIND_GUZHI = $0004; // 股指期货
  KIND_GOLD = $0005; // 上海黄金
  ZHENGZHOU_BOURSE = $0300; // 郑州
  KIND_XIAOM = $0001; // 郑州小麦
  KIND_MIANH = $0002; // 郑州棉花
  KIND_BAITANG = $0003; // 郑州白糖
  KIND_PTA = $0004; // 郑州PTA
  KIND_CZY = $0005; // 菜籽油
{$ENDREGION}

  WP_MARKET = $5000; // 外盘
  WH_MARKET = $8000; // 外汇

  //K线请求的周期类型 BEGIN
  PERIOD_TYPE_DAY = $0010; //分析周期：日
  PERIOD_TYPE_HISDAY = $0020; //分析周期：日
  PERIOD_TYPE_MINUTE0 = $0000; //分笔成交
  PERIOD_TYPE_MINUTE1 = $00C0; //分析周期：1分钟
  PERIOD_TYPE_MINUTE5 = $0030; //分析周期：5分钟
  PERIOD_TYPE_MINUTE15 = $0040; //分析周期：15分钟
  PERIOD_TYPE_MINUTE30 = $0050; //分析周期：30分钟
  PERIOD_TYPE_MINUTE60 = $0060; //分析周期：60分钟
  PERIOD_TYPE_MINUTE120 = $00B0; //
  PERIOD_TYPE_WEEK = $0080; //分析周期：周
  PERIOD_TYPE_MONTH = $0090; //分析周期：月/* K线请求的周期类型 END*/
  //////////////////////////////////////////////////////////////////////////
const
  CODE_LENGTH = 6; // 股票代码长度
  STOCK_NAME_SIZE = 16; // 股票名称长度
  PYJC_MAX_LENGTH = 16; // 股票拼音长度
  BranchNo_Size = 10; //营业部长度
  FundAccount_Size = 20; // 帐号长度
  RSACookie_Size = 1024; //动态口令cookie长度
  Password_Size = 20; //密码长度
  LENGTH_TITLE = 100; //标题长度
  TrendData_Size = 241; //当时数据个数

type
  /// <summary>
  /// 行情程序通讯消息头
  /// </summary>
  THeader = packed record   //record要求编译时字对齐，packed record不要求
    Msg: Integer;
    Size: Integer;
  end;

  TCode = array[0..CODE_LENGTH - 1] of Char;
  /// <summary>
  /// 证券代码信息
  /// </summary>
  TCodeInfo = packed record
    CodeType: SmallInt; // 证券类型
    Code: TCode; // 证券代码
  end;
  pCodeInfo = ^TCodeInfo;

  TCodes = array of TCodeInfo;

  /// <summary>
  /// 键盘精灵  消息
  /// </summary>
  TKeyBoardMsg = packed record
    Code: TCodeInfo;
    LeftBottom: TPoint;
  end;

  //结构体版本信息
  TStructVer = packed record
    m_cSize: word; // 结构体长度  ？？？
    m_nVersion: word; // 版本号
  end;

  PStructVer = ^TStructVer;

  {  //Windows msg传送
    TWindowsMessage = packed record
      Wnd: THandle; // 消息接收窗口
      Msg: Integer; // 消息(包括：鼠标、键盘等)
      wParam: Integer; // 消息参数1
      lParam: Integer; // 消息参数2
    end;     }

    // 外部代码信息返回
  TStockUserInfo = packed record
    XXX: Integer; // CPP virtual method, Ironic?
    StockInfo: TCodeInfo;
    StockName: array[0..STOCK_NAME_SIZE - 1] of Char;
    StockPYJC: array[0..PYJC_MAX_LENGTH - 1] of Char;
    PrevClose: Integer; // 昨收
    DayVol5: Cardinal; // 5日量
  end;
  pStockUserInfo = ^TStockUserInfo;

  // 各股票其他数据
  TStockOtherData = packed record
    m_nTime: Integer; // 现在时间
    m_lCurrent: Integer; // 现在总手
    m_lOutside: Integer; // 外盘
    m_lInside: Integer; // 内盘
    m_lKaiCang: Integer; // 今开仓,深交所股票单笔成交数,港股交易宗数
    m_lPingCang: Integer; // 今平仓
  end;

  pStockOtherData = ^TStockOtherData;

  // 实时数据
  THSStockRealTime = packed record
    m_lOpen: Integer; // 今开盘
    m_lMaxPrice: Integer; // 最高价
    m_lMinPrice: Integer; // 最低价
    m_lNewPrice: Integer; // 最新价
    m_lTotal: Integer; // 成交量(单位:股)
    m_fAvgPrice: Single; // 成交金额

    m_lBuyPrice1: Integer; // 买一价
    m_lBuyCount1: Integer; // 买一量
    m_lBuyPrice2: Integer; // 买二价
    m_lBuyCount2: Integer; // 买二量
    m_lBuyPrice3: Integer; // 买三价
    m_lBuyCount3: Integer; // 买三量
    m_lBuyPrice4: Integer; // 买四价
    m_lBuyCount4: Integer; // 买四量
    m_lBuyPrice5: Integer; // 买五价
    m_lBuyCount5: Integer; // 买五量

    m_lSellPrice1: Integer; // 卖一价
    m_lSellCount1: Integer; // 卖一量
    m_lSellPrice2: Integer; // 卖二价
    m_lSellCount2: Integer; // 卖二量
    m_lSellPrice3: Integer; // 卖三价
    m_lSellCount3: Integer; // 卖三量
    m_lSellPrice4: Integer; // 卖四价
    m_lSellCount4: Integer; // 卖四量
    m_lSellPrice5: Integer; // 卖五价
    m_lSellCount5: Integer; // 卖五量

    m_nHand: Integer; // 每手股数	(是否可放入代码表中？？？？）
    m_lNationalDebtRatio: Integer; // 国债利率,基金净值
  end;

  pHSStockRealTime = ^THSStockRealTime;

  // 实时数据(新版)
  THSStockRealTime_Ext = packed record
    StructVer: TStructVer;
    m_lOpen: Integer; // 今开盘
    m_lMaxPrice: Integer; // 最高价
    m_lMinPrice: Integer; // 最低价
    m_lNewPrice: Integer; // 最新价
    m_lTotal: Integer; // 成交量(单位:股)
    m_fAvgPrice: Single; // 成交金额

    m_lBuyPrice1: Integer; // 买一价
    m_lBuyCount1: Integer; // 买一量
    m_lBuyPrice2: Integer; // 买二价
    m_lBuyCount2: Integer; // 买二量
    m_lBuyPrice3: Integer; // 买三价
    m_lBuyCount3: Integer; // 买三量
    m_lBuyPrice4: Integer; // 买四价
    m_lBuyCount4: Integer; // 买四量
    m_lBuyPrice5: Integer; // 买五价
    m_lBuyCount5: Integer; // 买五量

    m_lSellPrice1: Integer; // 卖一价
    m_lSellCount1: Integer; // 卖一量
    m_lSellPrice2: Integer; // 卖二价
    m_lSellCount2: Integer; // 卖二量
    m_lSellPrice3: Integer; // 卖三价
    m_lSellCount3: Integer; // 卖三量
    m_lSellPrice4: Integer; // 卖四价
    m_lSellCount4: Integer; // 卖四量
    m_lSellPrice5: Integer; // 卖五价
    m_lSellCount5: Integer; // 卖五量

    m_nHand: Integer; // 每手股数	(是否可放入代码表中？？？？）
    m_lNationalDebtRatio: Integer; // 国债利率,基金净值

    m_lExt1: integer; // 目前只在ETF时有用，为其IOPV值（例如510050时为510051的最新价）
    m_lStopFlag: integer; // 停盘标志。0：正常，1：停盘
    m_lOther: array[0..2] of integer;
  end;

  //实时数据(新版扩充数据)
  THSStockRealTime_Other = packed record
    m_lExt1: integer; // 目前只在ETF时有用，为其IOPV值（例如510050时为510051的最新价）
    m_lStopFlag: integer; // 停盘标志。0：正常，1：停盘
    m_lOther: array[0..2] of integer;
  end;

  pHSStockRealTime_Other = ^THSStockRealTime_Other;

  // Level-2 股票实时行情
  THSStockLevel2RealTime = packed record
    m_lBuyPrice6: Integer; // 买一价
    m_lBuyCount6: Integer; // 买一量
    m_lBuyPrice7: Integer; // 买二价
    m_lBuyCount7: Integer; // 买二量
    m_lBuyPrice8: Integer; // 买三价
    m_lBuyCount8: Integer; // 买三量
    m_lBuyPrice9: Integer; // 买四价
    m_lBuyCount9: Integer; // 买四量
    m_lBuyPrice10: Integer; // 买五价
    m_lBuyCount10: Integer; // 买五量

    m_lSellPrice6: Integer; // 卖一价
    m_lSellCount6: Integer; // 卖一量
    m_lSellPrice7: Integer; // 卖二价
    m_lSellCount7: Integer; // 卖二量
    m_lSellPrice8: Integer; // 卖三价
    m_lSellCount8: Integer; // 卖三量
    m_lSellPrice9: Integer; // 卖四价
    m_lSellCount9: Integer; // 卖四量
    m_lSellPrice10: Integer; // 卖五价
    m_lSellCount10: Integer; // 卖五量

    m_lTickCount: Cardinal; // 成交笔数
    m_fBuyTotal: Single; // 委托买入总量
    WeightedAvgBidPx: Single; // 加权平均委买价格
    AltWeightedAvgBidPx: Single;
    m_fSellTotal: Single; // 委托卖出总量
    WeightedAvgOfferPx: Single; // 加权平均委卖价格
    AltWeightedAvgOfferPx: Single;
    m_IPOV: Single; // ETF IPOV
    m_Time: Cardinal; // 时间戳
  end;

  pHSStockLevel2RealTime = ^THSStockLevel2RealTime;

  THSHKStockReal = packed record
    case Boolean of
      True: (m_lYield: Integer); // 周息率 股票相关
      False: (m_lOverFlowPrice: Integer); // 溢价% 认股证相关
      // 认购证的溢价＝（认股证现价×兑换比率＋行使价－相关资产现价）/相关资产现价×100
      // 认沽证的溢价＝（认股证现价×兑换比率－行使价＋相关资产现价）/相关资产现价×100
  end;

  // 港股实时
  THSHKStockRealTime = packed record
    m_lOpen: Integer; // 今开盘
    m_lMaxPrice: Integer; // 最高价
    m_lMinPrice: Integer; // 最低价
    m_lNewPrice: Integer; // 最新价

    m_lTotal: Cardinal; // 成交量（股）
    m_fAvgPrice: Single; // 成交金额(元)

    m_lBuyPrice: Integer; // 买价
    m_lSellPrice: Integer; // 卖价

    m_lHSHK: THSHKStockReal; //

    m_lBuyCount1: Integer; // 买一量
    m_lBuyCount2: Integer; // 买二量
    m_lBuyCount3: Integer; // 买三量
    m_lBuyCount4: Integer; // 买四量
    m_lBuyCount5: Integer; // 买五量

    m_lSellCount1: Integer; // 卖一量
    m_lSellCount2: Integer; // 卖二量
    m_lSellCount3: Integer; // 卖三量
    m_lSellCount4: Integer; // 卖四量
    m_lSellCount5: Integer; // 卖五量

    m_lSellOrder1: Word; // 卖一盘数
    m_lSellOrder2: Word; // 卖二盘数
    m_lSellOrder3: Word; // 卖三盘数
    m_lSellOrder4: Word; // 卖四盘数
    m_lSellOrder5: Word; // 卖五盘数

    m_lBuyOrder1: Word; // 买一盘数
    m_lBuyOrder2: Word; // 买二盘数
    m_lBuyOrder3: Word; // 买三盘数
    m_lBuyOrder4: Word; // 买四盘数
    m_lBuyOrder5: Word; // 买五盘数

    m_lIEP: Integer; // 参考平衡价
    m_lIEV: Integer; // 参考平衡量

    // 主推分笔当前成交对盘类型？？？？
    m_lMatchType: Integer; // 对盘分类
  end;

  // 指标类实时数据
  THSIndexRealTime = packed record
    m_lOpen: Integer; // 今开盘
    m_lMaxPrice: Integer; // 最高价
    m_lMinPrice: Integer; // 最低价
    m_lNewPrice: Integer; // 最新价
    m_lTotal: Integer; // 成交量

    m_fAvgPrice: Single; // 成交金额
    m_nRiseCount: SmallInt; // 上涨家数
    m_nFallCount: SmallInt; // 下跌家数
    m_nTotalStock1: Integer; //* 对于综合指数：所有股票 - 指数 对于分类指数：本类股票总数 */
    m_lBuyCount: Integer; // 委买数
    m_lSellCount: Integer; // 委卖数

    m_nType: SmallInt; // 指数种类：0-综合指数 1-A股 2-B股
    m_nLead: SmallInt; // 领先指标
    m_nRiseTrend: SmallInt; // 上涨趋势
    m_nFallTrend: SmallInt; // 下跌趋势
    m_nNo2: array[0..4] of SmallInt; // 保留
    m_nTotalStock2: SmallInt; //* 对于综合指数：A股 + B股         对于分类指数：0 * /
    m_lADL: Integer; // ADL 指标
    m_lNo3: array[0..2] of Integer; // 保留
    m_nHand: Integer; // 每手股数
  end;

  // 期货行情
  THSQHRealTime = packed record
    m_lOpen: Integer; // 今开盘
    m_lMaxPrice: Integer; // 最高价
    m_lMinPrice: Integer; // 最低价
    m_lNewPrice: Integer; // 最新价

    m_lTotal: Cardinal; // 成交量(单位:合约单位)
    m_lChiCangLiang: Integer; // 持仓量(单位:合约单位)

    m_lBuyPrice1: Integer; // 买一价
    m_lBuyCount1: Integer; // 买一量
    m_lSellPrice1: Integer; // 卖一价
    m_lSellCount1: Integer; // 卖一量
    m_lPreJieSuanPrice: Integer; // 昨结算价
    //m_nHand;				// 每手股数
    //long 		m_lPreCloseChiCang;		// 昨持仓量(单位:合约单位)
    m_lJieSuanPrice: Integer; // 现结算价
    m_lCurrentCLOSE: Integer; // 今收盘
    m_lHIS_HIGH: Integer; // 史最高
    m_lHIS_LOW: Integer; // 史最低
    m_lUPPER_LIM: Integer; // 涨停板
    m_lLOWER_LIM: Integer; // 跌停板
    m_nHand: Integer; // 每手股数
    m_lPreCloseChiCang: Integer; // 昨持仓量(单位:合约单位)
    m_lLongPositionOpen: Integer; // 多头开(单位:合约单位)
    m_lLongPositionFlat: Integer; // 多头平(单位:合约单位)
    m_lNominalOpen: Integer; // 空头开(单位:合约单位)
    m_lNominalFlat: Integer; // 空头平(单位:合约单位)
    m_lPreClose: Integer; // 前天收盘????
  end;

  // 外汇行情数据
  THSWHRealTime = packed record
    m_lOpen: Integer; // 今开盘(1/10000元)
    m_lMaxPrice: Integer; // 最高价(1/10000元)
    m_lMinPrice: Integer; // 最低价(1/10000元)
    m_lNewPrice: Integer; // 最新价(1/10000元)

    m_lBuyPrice: Integer; // 买价(1/10000元)
    m_lSellPrice: Integer; // 卖价(1/10000元)
  end;

  //单个分时走势数据
  TPriceVolItem_Ext = packed record
    StructVer: TStructVer;
    m_lNewPrice: integer; // 最新价
    m_lTotal: cardinal; // 成交量(在外汇时，是跳动量)
    m_lExt1: integer; // 目前只在ETF时有用，为其IOPV值（例如510050时为510051的最新价）
    m_lStopFlag: integer; // 停盘标志。0：正常，1：停盘
  end;

  THSPrivateKey = packed record
    m_pCode: TCodeInfo; // 商品代码
  end;

  TDataHead = packed record
    m_nType: word; // 请求类型，与请求数据包一致
    m_nIndex: char; // 请求索引，与请求数据包一致
    m_cSrv: char; // 服务器使用
    m_lKey: integer; // 一级标识，通常为窗口句柄
    m_nPrivateKey: THSPrivateKey; // 二级标识
  end;

{$REGION '<<股指期货买卖盘>>'}
  THSQHMaiMaiRealTime = packed record
    m_lBuyPrice1: Integer; // 买一价
    m_lBuyCount1: Cardinal; // 买一量
    m_lBuyPrice2: Integer; // 买二价
    m_lBuyCount2: Cardinal; // 买二量
    m_lBuyPrice3: Integer; // 买三价
    m_lBuyCount3: Cardinal; // 买三量
    m_lBuyPrice4: Integer; // 买四价
    m_lBuyCount4: Cardinal; // 买四量
    m_lBuyPrice5: Integer; // 买五价
    m_lBuyCount5: Cardinal; // 买五量

    m_lSellPrice1: Integer; // 卖一价
    m_lSellCount1: Cardinal; // 卖一量
    m_lSellPrice2: Integer; // 卖二价
    m_lSellCount2: Cardinal; // 卖二量
    m_lSellPrice3: Integer; // 卖三价
    m_lSellCount3: Cardinal; // 卖三量
    m_lSellPrice4: Integer; // 卖四价
    m_lSellCount4: Cardinal; // 卖四量
    m_lSellPrice5: Integer; // 卖五价
    m_lSellCount5: Cardinal; // 卖五量
  end;

  // 股指期货买卖盘数据
  THQMaiMaiRealTimeData = packed record
    m_ciStockCode: TCodeInfo;
    m_sQHMaiMaiRealTime: THSQHMaiMaiRealTime;
  end;

  // 股指期货实时行情数据
  THSRealTimeSIF = packed record
    Future: THSQHRealTime; // 一档行情
    SIF: THSQHMaiMaiRealTime; // 五档行情
  end;
{$ENDREGION}

  THSRealTimeData = packed record
    case Byte of
      1: (DataStock: THSStockRealTime;
        DataLevel2: THSStockLevel2RealTime;
        DataStockExt: THSStockRealTime_Other); // 股票
      2: (DataIndex: THSIndexRealTime); // 指数
      3: (DataHKStock: THSHKStockRealTime); // 港股
      4: (DataFuture: THSQHRealTime); // 期货
      5: (DataWH: THSWHRealTime); // 外汇
      6: (DataSIF: THSRealTimeSIF); // 股指期货
  end;

  PStockRealTime = ^THSStockRealTime;

  // 实时行情数据
  TRealTimeData = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    m_othData: TStockOtherData; // 实时其它数据
    m_Data: THSRealTimeData;
  end;

  PRealTimeData = ^TRealTimeData;

  // 实时行情数据(新版)
  TRealTimeDataEx = packed record
    StructVer: TStructVer;
    m_ciStockCode: TCodeInfo; // 股票代码
    m_othData: TStockOtherData; // 实时其它数据
    m_Data: THSRealTimeData;
  end;

  //当日分时请求
  TTrendRequest = packed record
    codeinfo: TCodeInfo;
    ReqHandle: integer;
  end;

  TStrategyInfo = packed record
    nID: SmallInt; //监控ID
    FundAccount: array[0..19] of Char;
    CodeInfo: TCodeInfo;
    CodeName: array[0..9] of Char; // 证券名称
    ExpName: array[0..9] of Char; //公式名称
    nPeriodType: SmallInt; // 指标周期 参考 BaseDefine.h中的PERIOD_TYPE_DAY等
    nPeriodNumber: SmallInt; // 任意周期时，指定周期
    nStatus: SmallInt; // 监控状态
    nBuyTimes: SmallInt; // 买入次数，达到限制次数后不再发送买入请求
    nMaxBuyTimes: SmallInt; // 买入次数，达到次数后不再发送买入请求。-1表示不控制
    nSellTimes: SmallInt; // 卖出次数，达到次数后不再发送卖出请求
    nMaxSellTimes: SmallInt; // 卖出次数，达到次数后不再发送卖出请求。-1表示不控制
    nTrigTimes: SmallInt; // 连续触发次数，连续触发m_nMaxTrigTimes次后，进行交易
    nMaxTrigTimes: SmallInt; //  触发次数上限，达到此上限则触发交易
    nDuration: SmallInt; // 触发持续时间（秒），触发后m_nDuration秒内仍然触发，则进行
    nGap: SmallInt; //连续委托间隔
    nLastTrigTime: Integer; //上次触发的时间
    nFuQuan: SmallInt; //是否复权
    nSize: SmallInt; // 公式及数据个数
    pData: Pointer; // 监控相关数据（包括原始数据、监控结果和计算公式）
  end;

  PStrategyInfo = ^TStrategyInfo;

  TEntrustTrig = packed record
    nID: SmallInt;
    FundAccount: array[0..19] of Char;
    CodeInfo: TCodeInfo;
    nBS: SmallInt;
    nTime: Integer;
    RealTime: PStockRealTime; //PRealTimeData;
    pParam: Pointer;
  end;

  //策略交易控制
  TStrategyControl = packed record
    FundAccount: array[0..19] of Char;
    nControlType: SmallInt;
    StrategyInfo: PStrategyInfo;
  end;

  //当日分时走势数据
  TAnsTrendData_Ext = packed record
    m_dhHead: TDataHead; // 数据报头
    m_nHisLen: smallint; // 分时数据个数
    m_nAlignment: smallint; // 为了4字节对齐而添加的字段
    m_othData: TStockOtherData; // 实时其它数据
    m_nowData: THSStockRealTime_Ext; // 实时基本数据
    m_pHisData: array[0..TrendData_Size - 1] of TPriceVolItem_Ext; // 历史分时数据
  end;
  PAnsTrendData_Ext = ^TAnsTrendData_Ext;

  //盘后分析数据
  TStockCompDayDataEx = packed record
    m_lDate: Integer; // 日期
    m_lOpenPrice: Integer; // 开
    m_lMaxPrice: Integer; // 高
    m_lMinPrice: Integer; // 低
    m_lClosePrice: Integer; // 收
    m_lMoney: Integer; // 成交金额
    m_lTotal: Integer; // 成交量
    m_lNationalDebtRatio: Integer; // 国债利率(单位为0.1分),基金净值(单位为0.1分), 无意义时，须将其设为0 2004年2月26日加入
  end;
  PStockCompDayDataEx = ^TStockCompDayDataEx;
  
  TAnsDayDataEx = packed record
    DataHead: TDataHead; //数据头
    m_nSize: Integer; //日线数据个数
    DayDataEx: TStockCompDayDataEx;
  end;
  PAnsDayDataEx = ^TAnsDayDataEx;

  PSmallInt = ^smallint;

  // Level-2 实时行情数据
  TRealTimeLevel2Data = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    //add by LL: 2008-11-18 行情定义变化
    m_othData: TStockOtherData; // 实时其它数据
    m_Data: THSStockRealTime;
    m_DataLevel2: THSStockLevel2RealTime;
  end;

  // 涨跌停数据
  TSeverCalculateData = packed record
    m_ciStockCode: TCodeInfo;
    m_fUpPrice: Single;
    m_fDownPrice: Single;
  end;

  // 客户端分发数据
  TDispatchData = packed record
    m_ciStockCode: TCodeInfo; // 股票代码
    m_suiStockInfo: TStockUserInfo;
    m_othData: TStockOtherData; // 实时其它数据
    m_DataValid: Boolean; // 实时行情是否有效
    m_Data: THSRealTimeData; // 实时行情
    m_CalcValid: Boolean; // 涨跌停是否有效
    m_Calc: TSeverCalculateData; // 涨跌停
    //add by LL: 2008-12-11 数据接收者需要知道是否level2数据,帮增加
    m_IsLevel2: boolean; //是否level2数据
  end;

  PDispatchData = ^TDispatchData;

  // 股票快速下单
  TTradeStockInfo = packed record
    Price: Single; // 价格
    Amount: Cardinal; // 数量
  end;

  // 期货快速下单
  TTradeFutureInfo = packed record
    Price: Single; // 价格
    Amount: Cardinal; // 数量
  end;

  // 快速下单
  TTradeInfo = packed record
    Direct: Byte; // 买卖方向 : 0.Buy; 1.Sell
    CodeInfo: TStockUserInfo;
    case Byte of
      1: (StockData: TTradeStockInfo);
      2: (FutureData: TTradeFutureInfo);
  end;

  //登录结果
  TLoginResult = packed record
    Result: integer;
    BranchNo: array[0..BranchNo_Size - 1] of char; // 营业部
    FuncAccount: array[0..FundAccount_Size - 1] of char; //资金帐号
    UserType: integer; //用户类别
    RSACookie: array[0..RSACookie_Size - 1] of char; //动态口令cookie
    //Password: array[0..Password_Size - 1] of char; //密码
  end;

  TServiceCheck = packed record
    BranchNo: array[0..BranchNo_Size - 1] of char; // 营业部
    FuncAccount: array[0..FundAccount_Size - 1] of char; //资金帐号
    Password: array[0..Password_Size - 1] of char; //密码
    RSACookie: array[0..RSACookie_Size - 1] of char; //动态口令cookie
  end;

  //查询资产,目前返回人民币资产总额
  TTodayProperty = packed record
    TodayProperty: double;
  end;

  //组合委托
  TGroupData = packed record
    Handle: integer;
    StockInfo: TDispatchData;
  end;

  //外部调用参数
  TCallParam = packed record
    //参数类型
    ParamType: integer;
    //参数
    Param: pointer;
  end;
  pCallParam = ^TCallParam;

  TDataParam = packed record
    //显示标题
    Title: array[0..LENGTH_TITLE] of char;
    data: pointer;
  end;
  pDataParam = ^TDataParam;

  TRequestData = packed record
    Version: Integer;
    Len: Integer;
    ModuleID: Integer;
    FunctionID: Word;
    ServerType: Integer;
    ReqSize: Word;
    PrivateKey: TCodeInfo;
    Option: Integer;
    ReqData: Pointer;
  end;
  PRequestData = ^TRequestData;

  TAnswerData = packed record
    Version: Integer;
    Len: Integer;
    ModuleID: Integer;
    FunctionID: Word;
    ServerType: Integer;
    AnsSize: Word;
    PrivateKey: TCodeInfo;
    Option: Integer;
    AnsData: Pointer;
  end;
  PAnswerData = ^TAnswerData;

  TConnectInfo = packed record
    ServerType: Integer; //服务器类型
    ServerName: array[0..31] of Char; //服务器名称
    ServerAddress: array[0..31] of Char; //服务器IP
    ServerProt: Integer; //端口
    ConnStatus: Integer; //连接状态
    ConnDescription: array[0..1023] of Char; //连接描述
  end;
  PConnectInfo = ^TConnectInfo;

  TReqDayData = packed record
    m_nPeriodNum: smallint; // 周期长度,服务器不用
    m_nSize: smallint; // 本地数据当前已经读取数据起始个数,服务器不用
    m_lBeginPosition: Integer; // 起始个数，-1 表示当前位置。 （服务器端已经返回的个数）
    m_nDay: smallint; // 申请的个数
    m_cPeriod: smallint; // 周期类型
    m_ciCode: TCodeInfo; // 申请的股票代码
  end;
  PReqDayData = ^TReqDayData;

const
  SizeHeader = SizeOf(THeader);
  SizeCodeInfo = SizeOf(TCodeInfo);
  SizeKeyBoardMsg = SizeOf(TKeyBoardMsg);
  SizeStockUserInfo = SizeOf(TStockUserInfo);

  SizeRealTimeData = SizeOf(TRealTimeData);
  SizeRealTimeLevel2Data = SizeOf(TRealTimeLevel2Data);
  SizeStockOtherData = SizeOf(TStockOtherData);
  SizeStockRealTime = SizeOf(THSStockRealTime);
  SizeStockLevel2RealTime = SizeOf(THSStockLevel2RealTime);
  SizeHKStockRealTime = SizeOf(THSHKStockRealTime);
  SizeIndexRealTime = SizeOf(THSIndexRealTime);
  SizeHQRealTime = SizeOf(THSQHRealTime);
  SizeWHRealTime = SizeOf(THSWHRealTime);

  SizeSIFRealTimeData = SizeOf(THQMaiMaiRealTimeData);
  SizeSIFRealTime = SizeOf(THSQHMaiMaiRealTime);

  SizeSeverCalculateData = SizeOf(TSeverCalculateData);

  SizeTradeStockInfo = SizeOf(TTradeStockInfo);
  SizeTradeFutureInfo = SizeOf(TTradeFutureInfo);
  SizeTradeInfo = SizeOf(TTradeInfo);

  SizeDispatchData = SizeOf(TDispatchData);
  SizeLoginResult = SizeOf(TLoginResult);
  SizeServiceCheck = SizeOf(TServiceCheck);
  SizeTodayProperty = SizeOf(TTodayProperty);

  SizeGroupData = SizeOf(TGroupData);

  SizeStructVer = SizeOf(TStructVer);
  SizeDataHead = SizeOf(TDataHead);
  SizeTrendRequest = SizeOf(TTrendRequest);
  SizePriceVolItem_Ext = SizeOf(TPriceVolItem_Ext);
  SizeHSStockRealTime_Ext = SizeOf(THSStockRealTime_Ext);
  SizeAnsTrendData_Ext = Sizeof(TAnsTrendData_Ext);
  SizeHSStockRealTime_Other = SizeOf(THSStockRealTime_Other);

type
  // 快速下单接口
  IFastTrade = interface
    ['{A317F211-FD79-4E25-A81E-C1B85660F979}']
    procedure FastTrade(const TradeInfo: TTradeInfo);
  end;

  // 买卖方向
  TBSDirection = (bsdBuy, bsdSell, bsdSJBuy, bsdSJSell, bsLightningBuy, bsLightningSell);
  // 指数
function IsIndex(const CodeType: SmallInt): Boolean;
// 股指期货
function IsSIF(const CodeType: SmallInt): Boolean;
// 上海黄金
function IsGOLD(const CodeType: SmallInt): Boolean;
//上海债券
function IsHZ(const CodeType: SmallInt): Boolean;
//深圳债券
function IsSZ(const CodeType: SmallInt): Boolean;
//股票是否没有指定市场
function StockNoMarket(ACodeType: SmallInt): boolean;

implementation

function IsIndex(const CodeType: SmallInt): Boolean;
begin
  Result := CodeType = (STOCK_MARKET or USERDEF_BOURSE or KIND_INDEX);
end;

function IsSIF(const CodeType: SmallInt): Boolean;
begin
  Result := CodeType = (FUTURES_MARKET or SHANGHAI_BOURSE or KIND_GUZHI);
end;

function IsGOLD(const CodeType: SmallInt): Boolean;
begin
  Result := CodeType = (FUTURES_MARKET or SHANGHAI_BOURSE or KIND_GOLD);
end;

function IsHZ(const CodeType: SmallInt): Boolean;
begin
  Result := CodeType = (STOCK_MARKET or SH_Bourse or KIND_BOND);
end;

function IsSZ(const CodeType: SmallInt): Boolean;
begin
  Result := CodeType = (STOCK_MARKET or SZ_Bourse or KIND_BOND);
end;

function StockNoMarket(ACodeType: SmallInt): boolean;
begin
  Result := ((ACodeType and MARKE_MASK) = STOCK_MARKET) and
    ((ACodeType and MARKE_MIDDLE_MASK) = 0);
end;

end.

