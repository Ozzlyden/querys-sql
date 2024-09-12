--IGESDF - Quantidade de GAE's Abertas por Turno UPAS -v2 
--Acolhimento com Classificação de Risco por Cor
SELECT * FROM(
SELECT b.ds_multi_empresa 
 , Nvl(Count(*),0) AS Total
 ,CASE 
WHEN To_Date(to_char(a.dh_pre_atendimento, 'hh24:MI'),'hh24:MI') BETWEEN TO_DATE('06:00','hh24:MI') AND TO_DATE('11:59','hh24:MI') THEN 'MATUTINO'
 WHEN To_Date(to_char(a.dh_pre_atendimento, 'hh24:MI'),'hh24:MI') BETWEEN TO_DATE('12:00','hh24:MI') AND TO_DATE('17:59','hh24:MI') THEN 'VESPERTINO'
 WHEN To_Date(to_char(a.dh_pre_atendimento, 'hh24:MI'),'hh24:MI') BETWEEN TO_DATE('18:00','hh24:MI') AND TO_DATE('23:59','hh24:MI') THEN 'NOTURNO'
 WHEN To_Date(to_char(a.dh_pre_atendimento, 'hh24:MI'),'hh24:MI') BETWEEN TO_DATE('00:00','hh24:MI') AND TO_DATE('05:59','hh24:MI') THEN 'MADRUGADA'
 ELSE To_Char(a.dh_pre_atendimento,'dd/mm/yyyy hh24:mi:ss')
END TURNO
 from DBAMV.triagem_atendimento A, 
 DBAMV.MULTI_EMPRESAS B, 
 DBAMV.atendime c,
 DBAMV.SACR_COR_REFERENCIA D
 WHERE a.cd_multi_empresa = b.cd_multi_empresa
 AND D.CD_COR_REFERENCIA = A.CD_COR_REFERENCIA
 and a.cd_multi_empresa IN ('3','4','5','6','7','8','12','13','14','15','16','17','18')
 and a.cd_atendimento = c.cd_atendimento(+)
 and to_char(a.dh_pre_atendimento,'DD/MM/RRRR') BETWEEN To_date($PgIgesdfDtInicial$) AND To_date(  $PgIgesdfDtFim$ ) +0.99999
 --AND EXISTS ( select X.cd_fila_senha from FILA_SENHA_MULTI_EMPRESAS X WHERE X.cd_fila_senha = a.cd_fila_senha)
--AND EXISTS ( SELECT X.cd_fila_senha from FILA_SENHA x where x.cd_fila_senha = a.cd_fila_senha and cd_multi_empresa in (17,18))
group by b.ds_multi_empresa,CASE 
WHEN To_Date(to_char(a.dh_pre_atendimento, 'hh24:MI'),'hh24:MI') BETWEEN TO_DATE('06:00','hh24:MI') AND TO_DATE('11:59','hh24:MI') THEN 'MATUTINO'
 WHEN To_Date(to_char(a.dh_pre_atendimento, 'hh24:MI'),'hh24:MI') BETWEEN TO_DATE('12:00','hh24:MI') AND TO_DATE('17:59','hh24:MI') THEN 'VESPERTINO'
 WHEN To_Date(to_char(a.dh_pre_atendimento, 'hh24:MI'),'hh24:MI') BETWEEN TO_DATE('18:00','hh24:MI') AND TO_DATE('23:59','hh24:MI') THEN 'NOTURNO'
 WHEN To_Date(to_char(a.dh_pre_atendimento, 'hh24:MI'),'hh24:MI') BETWEEN TO_DATE('00:00','hh24:MI') AND TO_DATE('05:59','hh24:MI') THEN 'MADRUGADA'
 ELSE To_Char(a.dh_pre_atendimento,'dd/mm/yyyy hh24:mi:ss')
END

)ORDER BY 1