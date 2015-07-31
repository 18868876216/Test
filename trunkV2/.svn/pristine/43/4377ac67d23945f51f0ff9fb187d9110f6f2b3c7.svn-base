echo off
echo ------------------开始ETF Info处理------------------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\ETFInfo.ktr "-param:db=10.19.19.250"
echo ------------------结束ETF Info处理------------------------------------------------------------------------------------
echo ------------------开始ETF Component处理------------------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\ETFComponent.ktr "-param:db=10.19.19.250"
echo ------------------结束ETF Component处理------------------------------------------------------------------------------------