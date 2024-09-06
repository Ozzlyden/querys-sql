--HBDF - GEAMU - Gestão aba "Total Consulta por Setor" e "Total Itens Prescritos"

--Total Consulta por Setor
select nm_setor
 , count(*) as total 
 from (select distinct a.cd_pre_med
 , c.cd_tip_presc
 , c.cd_tip_presc
 , decode(c.cd_tip_presc,6772,'CONSULTA EM NUTRICAO'
 ,8701,'CONSULTA EM NUTRICAO'
 ,9426,'CONSULTA EM NUTRICAO'
 ,792,'CONSULTA FONOAUDIOLOGICA'
 ,658,'CONSULTA FISIOTERAPIA'
 ,9130,'CONSULTA FISIOTERAPIA'
 ,4476,'CONSULTA EM SERVICO SOCIAL'
 ,4477,'CONSULTA EM PSICOLOGIA'
 ,'668','CONSULTA EM TERAPIA OCUPACIONAL') as item_prescrito
 , d.nm_setor
 from dbamv.pre_med a
 inner join dbamv.atendime b on a.cd_atendimento = b.cd_atendimento
 left join dbamv.itpre_med c on a.cd_pre_med = c.cd_pre_med
 left join dbamv.setor d on a.cd_setor = d.cd_setor
 where a.DT_PRE_MED between TO_DATE( '01/01/2024' ) and TO_DATE( '31/07/2024' ) +0.99999 
 and nvl(c.sn_cancelado,'N') = 'N'
 and a.cd_prestador in (select cd_prestador from dbamv.prestador where cd_tip_presta IN (32) )
 AND c.cd_TIP_PRESC in (6772,8701,792,658,9130,4476,4477,668,9426)
 AND B.CD_MULTI_EMPRESA = 1
 )group by nm_setor
order by 2 desc

;

--Total Itens Prescritos

select especialidade
 ,nvl(item_prescrito,'TOTAL GERAL') as item_prescrito
 ,count(*) as total 
 from (select distinct a.cd_pre_med
 , c.cd_tip_presc
 , c.cd_tip_presc
 , d.ds_tip_presc as item_prescrito
 , decode(e.cd_tip_presta,'1','SERVIÇO SOCIAL','5','FISIOTERAPIA','6','FONOAUDIOLOGIA','9','NUTRIÇÃO','10','PSICOLOGIA','11','TERAPEUTA OCUPACIONAL') as especialidade
 from dbamv.pre_med a
 inner join dbamv.atendime b on a.cd_atendimento = b.cd_atendimento
 inner join dbamv.itpre_med c on a.cd_pre_med = c.cd_pre_med
 left join dbamv.tip_presc d on c.cd_tip_presc = d.cd_tip_presc
 left join dbamv.prestador e on a.cd_prestador = e.cd_prestador
 where a.DT_PRE_MED between TO_DATE( '01/07/2024' ) and TO_DATE( '31/07/2024' ) +0.99999 
 and nvl(c.sn_cancelado,'N') = 'N'
 and c.cd_tip_esq in ('PFI','PFO','PNT','PPS','PSS','PTO')
 and a.cd_prestador in (select cd_prestador from dbamv.prestador where cd_tip_presta IN (32) )
 AND B.CD_MULTI_EMPRESA = 1
 ) group by rollup (especialidade, item_prescrito)
order by 1,3 desc
