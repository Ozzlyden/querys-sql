--Painel "Contrato de Gestão 2021"
--IGESDF- Atendimento de Urgência com observação até 24 horas em atenção especializada - UPA's - desenvolvimento
SELECT --A.CD_PROCEDIMENTO, a.cd_atendimento,qt_lancada
M.DS_MULTI_EMPRESA EMPRESA, 
 sum (qt_lancada) ATENDIMENTO_DE_URGENCIA,
 '7.087' Meta,
 round(decode( Nvl(Count(*),0), 0, 0, (Nvl(Count(*),0) /7087* 100)),2) || '%' PERC,
 '01/09/2024' DT_IN ,
'18/09/2024' DT_FIM 

 from dbamv.Eve_siasus a--, dbamv.multi_empresas m

INNER JOIN multi_empresas m ON m.cd_multi_empresa = a.cd_multi_empresa

 where 
 --a.cd_multi_empresa = m.cd_multi_empresa
 A.CD_PROCEDIMENTO IN ('0301060029') --ATENDIMENTO DE URGENCIA C/ OBSERVACAO ATE 24 HORAS EM ATENCAO ESPECIALIZADA
 AND M.CD_MULTI_EMPRESA IN ('3','4','5','6','7','8','12','13','14','15','16','17','18')
 and a.dt_eve_siasus BETWEEN To_Date('01/09/2024' ,'DD/MM/YYYY')AND To_Date( '18/09/2024','DD/MM/YYYY' )+ 0.99999 
 AND M.CD_MULTI_EMPRESA = A.CD_MULTI_EMPRESA

 group by m.ds_multi_empresa
ORDER BY 1