echo off
echo ------------------��ʼETF Info����------------------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\ETFInfo.ktr "-param:db=10.19.19.250"
echo ------------------����ETF Info����------------------------------------------------------------------------------------
echo ------------------��ʼETF Component����------------------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\ETFComponent.ktr "-param:db=10.19.19.250"
echo ------------------����ETF Component����------------------------------------------------------------------------------------