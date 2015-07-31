echo off
echo ------------------开始基金净值信息处理---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\fundnav-multi.ktr "-param:db=10.19.19.110" "-param:fk=fkFundNavToDB" 
echo ------------------结束基金净值信息处理---------------------------------------------------------------------------
