echo off
echo ------------------��ʼWindͣ����Ϣ����---------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file D:\trunkV2\DataTrans\kettle\stocktp.ktr "-param:db=10.19.19.250" "-param:fk=fkWindStopInfo" "-param:url=http://wwtnews.windin.com/corpeventsweb/StockCalendar.aspx" 
echo ------------------����Windͣ����Ϣ����---------------------------------------------------------------------------