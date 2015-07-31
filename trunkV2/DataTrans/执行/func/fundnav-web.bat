echo off
echo ------------------开始基金净值信息处理---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\fundnav.ktr "-param:db=10.19.19.250" "-param:fk=fkFundNavWeb" "-param:url=http://www.fund123.cn" 
echo ------------------结束基金净值信息处理---------------------------------------------------------------------------

echo ------------------开始sp_mfprice_calcall---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\sp_mfprice_calcall.ktr "-param:db=10.19.19.250" "-param:fk=fkFundNavWeb" "-param:url=http://www.fund123.cn" 
echo ------------------结束sp_mfprice_calcall---------------------------------------------------------------------------
