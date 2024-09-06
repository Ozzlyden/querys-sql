--Painel "Contrato de Gestão 2021"
--IGESDF- Atendimento de Urgência com observação até 24 horas em atenção especializada - UPA's - DRILL
SELECT M.DS_MULTI_EMPRESA EMPRESA, 
 sum (qt_lancada) ATENDIMENTO_DE_URGENCIA,
 '7.087' Meta,
 round(decode( Nvl(Count(*),0), 0, 0, (Nvl(Count(*),0) /7087* 100)),2) || '%' PERC

 from dbamv.Eve_siasus a, 
 dbamv.multi_empresas m

 where a.cd_multi_empresa = m.cd_multi_empresa
 AND A.CD_PROCEDIMENTO IN ('0301060029') --ATENDIMENTO DE URGENCIA C/ OBSERVACAO ATE 24 HORAS EM ATENCAO ESPECIALIZADA
 AND M.CD_MULTI_EMPRESA IN ('3','4','5','6','7','8','12','13','14','15','16','17','18')
 and a.dt_eve_siasus BETWEEN  To_Date($PgIgesdfDtInicial$ ,'DD/MM/YYYY')AND To_Date( $PgIgesdfDtFim$,'DD/MM/YYYY' )+ 0.99999 

 group by m.ds_multi_empresa
ORDER BY 1