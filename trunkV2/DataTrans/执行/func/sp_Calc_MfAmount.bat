echo off
echo ------------------��ʼsp_Calc_MfAmount---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\sp_Calc_MfAmount.ktr "-param:db=10.19.19.250" "-param:fk=fkFundNav" "-param:url=http://www.fund123.cn" 
echo ------------------����sp_Calc_MfAmount---------------------------------------------------------------------------