--IGESDF - Total de Atendimentos (Urgência-Observação até 24hrs-Atenção Especializada Med. - UPA´s)
select b.ds_multi_empresa
, sum(qt_lancada) total
,'7.087' Meta
, round(decode( Nvl(Count(*),0), 0, 0, (Nvl(Count(*),0) /7087* 100)),2) || '%' PERC

from 

eve_siasus a 

inner join multi_empresas b on a.cd_multi_empresa = b.cd_multi_empresa
WHERE a.dt_eve_siasus BETWEEN To_Date($PgIgesdfDtInicial$ ,'DD/MM/YYYY')AND To_Date( $PgIgesdfDtFim$,'DD/MM/YYYY' )+ 0.99999
AND a.cd_procedimento in (0301060029,0301060096)
and b.cd_multi_empresa in ('3','4','5','6','7','8','12','13','14','15','16','17','18')

group by b.ds_multi_empresa
ORDER BY 1
