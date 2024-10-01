--Codigo base Cleiton - Taxa de ocupação leitos
select * from 
    (select leito.cd_unid_int cd_unid_int
,nvl( decode( sign(to_date('18/' || '09/2024' ||' '||(select to_char(sysdate,'hh24:mi') hora from dual) ,
'DD/MM/YYYY HH24:MI:SS') - nvl(trunc(mov_int.dt_lib_mov) + (mov_int.hr_lib_mov - trunc(mov_int.hr_lib_mov)),sysdate)),
1, 'V', dbamv.retorna_situacao_do_leito(to_date('18/' || '09/2024' ||' '||(select to_char(sysdate,'hh24:mi') hora from dual) ,
'DD/MM/YYYY HH24:MI:SS'),leito.cd_leito)), 'V') tp_ocupacao

,decode( sign(to_date('18/' || '09/2024' ||' '||(select to_char(sysdate,'hh24:mi') hora from dual) ,'DD/MM/YYYY HH24:MI:SS') - nvl(trunc(mov_int.dt_lib_mov)
+ (mov_int.hr_lib_mov - trunc(mov_int.hr_lib_mov)),sysdate)), 1, null, atendime.cd_atendimento) cd_atendimento
,leito.cd_leito cd_leito

,decode(leito.sn_extra,'N', leito.cd_leito || ' - Não'
,'S', leito.cd_leito || ' - Sim') sn_extra,

to_date('18/' || '09/2024' ,'dd/mm/yyyy') as dia

from dbamv.leito
,(select max(cd_mov_int) cd_mov_int
,cd_leito
from dbamv.mov_int
where to_date(to_char(mov_int.dt_mov_int,'DD/MM/YYYY') || ' ' ||
to_char(mov_int.hr_mov_int,'HH24:MI'), 'DD/MM/YYYY HH24:MI') <= to_date('18/' || '09/2024' ||' '||(select to_char(sysdate,'hh24:mi') hora from dual) ,'DD/MM/YYYY HH24:MI:SS')
group by cd_leito) ult_mov
,dbamv.mov_int
,dbamv.atendime
where leito.cd_leito = ult_mov.cd_leito(+)
and ult_mov.cd_mov_int = mov_int.cd_mov_int(+)
and mov_int.cd_atendimento = atendime.cd_atendimento(+)
and (trunc(leito.dt_desativacao) is null or trunc(leito.dt_desativacao) > trunc( to_date('18/' || '09/2024' ||' '||(select to_char(sysdate,'hh24:mi') hora from dual) ,'DD/MM/YYYY HH24:MI:SS')) )
and trunc(leito.dt_ativacao) <= trunc( to_date('18/' || '09/2024' ||' '||(select to_char(sysdate,'hh24:mi') hora from dual) ,'DD/MM/YYYY HH24:MI:SS'))
and atendime.cd_multi_empresa(+) = 2
and leito.cd_unid_int in (63)  ) where dia <= sysdate