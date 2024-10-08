--Codigo original - Painel "Total de SOLICITA��ES realizadas"
select * from(
select * from (
select a.cd_os, to_char (a.dt_pedido,'dd/mm/rrrr') Abertura, c.nm_setor ,decode (a.cd_oficina, '1','TAPE�ARIA','2','CIVIL','3','EL�TRICA','4','ELETR�NICA','6','G�S MEDICINAL','7','HIDR�ULICA','8','MARCENARIA','9','REFORMA','10','PINTURA','11','LOGICA','12','REFRIGERA��O','13','SERRALHERIA','14','VIDRA�ARIA','33','ESTOFAMENTOS','34','PROJETO','35','MEC�NICA') Oficina, 
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

