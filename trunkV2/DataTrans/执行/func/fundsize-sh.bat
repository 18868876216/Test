echo off
echo ------------------开始基金规模处理------------------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\fundsize-sh.ktr "-param:db=10.19.19.250"
echo ------------------结束基金规模处理------------------------------------------------------------------------------------