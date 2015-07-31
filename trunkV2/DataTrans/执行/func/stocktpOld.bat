echo off
echo ------------------开始东方财富1停牌信息处理---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\stocktp.ktr "-param:db=10.19.19.250" "-param:fk=fkEastSzStopInfo" "-param:url=http://stock.eastmoney.com/news/cjyts.html" 
echo ------------------结束东方财富1停牌信息处理---------------------------------------------------------------------------
echo ------------------开始东方财富2停牌信息处理---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\stocktp.ktr "-param:db=10.19.19.250" "-param:fk=fkEastStopInfo" "-param:url=http://stock.eastmoney.com/news/cjyts.html" 
echo ------------------结束东方财富2停牌信息处理---------------------------------------------------------------------------
echo ------------------开始上交所停牌信息处理------------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\stocktp.ktr "-param:db=10.19.19.250" "-param:fk=fkShStopInfo" "-param:url=http://www.sse.com.cn/sseportal/webapp/datapresent/querytradetipsnew" 
echo ------------------结束上交所停牌信息处理------------------------------------------------------------------------------
echo ------------------开始深交所停牌信息处理------------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\stocktp.ktr "-param:db=10.19.19.250" "-param:fk=fkSzStopInfo" "-param:url=http://www.szse.cn/main/disclosure/news/tfpts/" 
echo ------------------结束深交所停牌信息处理------------------------------------------------------------------------------
