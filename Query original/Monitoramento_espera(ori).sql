--HRSM - Monitoramento do Tempo de Espera - Original
select * from (
select decode(a.tp_atendimento,'A','AMBULATÓRIO','I','INTERNAÇÃO','E','EXTERNO','U','URGÊNCIA') as tipo_atendimento
 ,a.cd_atendimento as atendimento
 ,b.descricao_cbo
 ,b.nm_prestador as prestador
 ,c.nm_paciente as paciente
 ,fn_retorna_hr_min_seg(nvl(a.hr_alta,sysdate) - a.hr_atendimento) as tempo_espera
 ,case when a.dt_alta is null then 'Não' else 'Sim' end as sn_alta
 from dbamv.atendime a
 left join (select c.cd_prestador
 ,c.nm_prestador
 ,LISTAGG(' - ' ||d.ds_cbos ) WITHIN GROUP (ORDER BY c.cd_prestador) AS descricao_cbo 
 from (select distinct 
 a.cd_prestador
 ,a.nm_prestador
 ,b.cd_cbo
 from prestador a
 left join prestador_cbo b on a.cd_prestador = b.cd_prestador 
 where cd_tip_presta = 3
 and b.cd_multi_empresa = 2
 and a.tp_situacao = 'A') c
 left join cbo d on c.cd_cbo = d.cd_cbos
 group by c.cd_prestador, c.nm_prestador
 ) b on a.cd_prestador = b.cd_prestador
 left join paciente c on a.cd_paciente = c.cd_paciente
 where trunc(a.dt_atendimento) = trunc(to_date(sysdate))
 and a.cd_multi_empresa = 2
 and a.cd_especialid in (29,99)
 and a.tp_atendimento = 'A'

union all

select decode(a.tp_atendimento,'A','AMBULATÓRIO','I','INTERNAÇÃO','E','EXTERNO','U','URGÊNCIA') as tipo_atendimento
 ,a.cd_atendimento as atendimento
 ,b.descricao_cbo
 ,b.nm_prestador as prestador
 ,c.nm_paciente as paciente
 ,fn_retorna_hr_min_seg(nvl(a.hr_alta,sysdate) - a.hr_atendimento) as tempo_espera
 ,case when a.dt_alta is null then 'Não' else 'Sim' end as sn_alta
 from dbamv.atendime a
 left join (select c.cd_prestador
 ,c.nm_prestador
 ,LISTAGG(' - ' ||d.ds_cbos ) WITHIN GROUP (ORDER BY c.cd_prestador) AS descricao_cbo 
 from (select distinct 
 a.cd_prestador
 ,a.nm_prestador
 ,b.cd_cbo
 from prestador a
 left join prestador_cbo b on a.cd_prestador = b.cd_prestador 
 where cd_tip_presta = 3
 and b.cd_multi_empresa = 2
 and a.tp_situacao = 'A') c
 left join cbo d on c.cd_cbo = d.cd_cbos
 group by c.cd_prestador, c.nm_prestador
 ) b on a.cd_prestador = b.cd_prestador
 left join paciente c on a.cd_paciente = c.cd_paciente
 where trunc(a.dt_atendimento) = trunc(to_date(sysdate))
 and a.cd_multi_empresa = 2
 and a.cd_ori_ate in (50,51)
 and a.tp_atendimento in ('U','E')
 ) where sn_alta = 'Não'
 order by 6 desc, 1, 2 asc