echo off
echo ------------------��ʼ����ֵ��Ϣ����---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\fundnav.ktr "-param:db=10.19.19.250" "-param:fk=fkFundNavWeb" "-param:url=http://www.fund123.cn" 
echo ------------------��������ֵ��Ϣ����---------------------------------------------------------------------------

echo ------------------��ʼsp_mfprice_calcall---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\sp_mfprice_calcall.ktr "-param:db=10.19.19.250" "-param:fk=fkFundNavWeb" "-param:url=http://www.fund123.cn" 
echo ------------------����sp_mfprice_calcall---------------------------------------------------------------------------
