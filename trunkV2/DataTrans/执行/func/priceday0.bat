echo off
echo ------------------开始上海日线处理------------------------------------------------------------------------------------
rem call d:\yttrans\data-integration\pan.bat /file d:\yttrans\kettle\dayline.ktr "-param:sc=SH" "-param:db=172.34.0.205"
echo ------------------结束上海日线处理------------------------------------------------------------------------------------
echo ------------------开始深圳日线处理------------------------------------------------------------------------------------

rem call d:\yttrans\data-integration\pan.bat /file d:\yttrans\kettle\dayline.ktr "-param:sc=SZ" "-param:db=172.34.0.205"
echo ------------------结束深圳日线处理------------------------------------------------------------------------------------
echo ------------------开始中金所日线处理----------------------------------------------------------------------------------
call d:\yttrans\data-integration\pan.bat /file d:\yttrans\kettle\dayline0.ktr "-param:sc=SF" "-param:db=172.34.0.205" -"param:fk=fkFutuDay"
echo ------------------结束中金所日线处理----------------------------------------------------------------------------------
echo ------------------开始大智慧基金净值日线处理--------------------------------------------------------------------------

rem call d:\yttrans\data-integration\pan.bat /file d:\yttrans\kettle\dayline.ktr "-param:sc=B$" "-param:db=172.34.0.205"
echo ------------------结束大智慧基金净值日线处理--------------------------------------------------------------------------
echo ------------------开始Fund123基金净值日线处理-------------------------------------------------------------------------

rem call d:\yttrans\data-integration\pan.bat /file d:\yttrans\kettle\dayline.ktr "-param:sc=B$" "-param:db=172.34.0.205" -"param:fk=fkFun123NavInfo"
echo ------------------结束Fund123基金净值日线处理-------------------------------------------------------------------------
