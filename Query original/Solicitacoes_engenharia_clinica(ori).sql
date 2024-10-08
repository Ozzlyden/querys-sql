--Codigo original - Painel "Total de SOLICITAÇÕES realizadas"
select * from(
select * from (
select a.cd_os, to_char (a.dt_pedido,'dd/mm/rrrr') Abertura, c.nm_setor ,decode (a.cd_oficina, '1','TAPEÇARIA','2','CIVIL','3','ELÉTRICA','4','ELETRÔNICA','6','GÁS MEDICINAL','7','HIDRÁULICA','8','MARCENARIA','9','REFORMA','10','PINTURA','11','LOGICA','12','REFRIGERAÇÃO','13','SERRALHERIA','14','VIDRAÇARIA','33','ESTOFAMENTOS','34','PROJETO','35','MECÂNICA') Oficina, 
a.ds_servico , a.tp_prioridade, To_Char(round(To_Number(Sysdate - a.dt_pedido))) ||' Dia(s) em andamento' dias, 'HBDF' as Local
from solicitacao_os a , OFICINA B, setor c
where A.CD_OFICINA = B.CD_OFICINA
and a.cd_setor = c.cd_setor
AND A.TP_SITUACAO in ('S')
AND B.CD_OFICINA IN (1,2,3,4,6,7,8,9,10,11,12,13,14,33,34,35)
ORDER BY dt_pedido desc )a


union all 

select * from (
select a.cd_os,to_char (a.dt_pedido,'dd/mm/rrrr') Abertura, c.nm_setor , B.DS_OFICINA Oficina, 
a.ds_servico , a.tp_prioridade, To_Char(round(To_Number(Sysdate - a.dt_pedido))) ||' Dia(s) em andamento' dias,'HSOL' as Local
from solicitacao_os a , OFICINA B, setor c
where A.CD_OFICINA = B.CD_OFICINA
and a.cd_setor = c.cd_setor
AND A.TP_SITUACAO in ('S')
and C.CD_MULTI_EMPRESA = 2
AND C.CD_SETOR  IN (1279,1277,1278,1230)
--AND B.CD_OFICINA IN (1,2,3,4,6,7,8,9,10,11,12,13,14,33,34,35)
ORDER BY dt_pedido desc)b
)ORDER BY LOCAL

