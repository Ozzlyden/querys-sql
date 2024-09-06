--Painel "Contrato de Gestão 2021"
--IGESDF- Atendimento de Urgência com observação até 24 horas em atenção especializada Med - UPA's - DRILL
select 
 a.cd_atendimento,
 p.nm_paciente,
 a.dt_eve_siasus,
 a.cd_procedimento,
 sum (a.qt_lancada) as total

from 
eve_siasus a

inner join multi_empresas b on a.cd_multi_empresa = b.cd_multi_empresa
inner join paciente p on a.cd_paciente = p.cd_paciente
WHERE a.dt_eve_siasus BETWEEN To_Date('01/01/2024' ,'DD/MM/YYYY')AND To_Date( '31/01/2024','DD/MM/YYYY' )+ 0.99999
AND a.cd_procedimento in (0301060029,0301060096)
and b.cd_multi_empresa in ('3','4','5','6','7','8','12','13','14','15','16','17','18')

group by a.cd_atendimento,
 p.nm_paciente,
 a.dt_eve_siasus,
 a.cd_procedimento,
 a.qt_lancada
ORDER BY 1