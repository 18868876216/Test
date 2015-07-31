echo off
echo ------------------¿ªÊ¼sp_mfprice_calcall---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\sp_mfprice_calcall.ktr "-param:db=10.19.19.250" "-param:fk=fkFundNav" "-param:url=http://www.fund123.cn" 
echo ------------------½áÊøsp_mfprice_calcall---------------------------------------------------------------------------