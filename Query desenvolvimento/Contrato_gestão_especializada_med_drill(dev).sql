--Painel "Contrato de Gestão 2021"
--IGESDF- Atendimento de Urgência com observação até 24 horas em atenção especializada Med - UPA's - DRILL
select 
 a.cd_atendimento,
 c.nm_paciente,
 a.dt_eve_siasus AS data_item_lancamento,
 a.cd_procedimento,
 sum (a.qt_lancada) as total

from 
eve_siasus a, paciente c, multi_empresas b

WHERE a.cd_multi_empresa = b.cd_multi_empresa
and a.cd_paciente = c.cd_paciente
and a.dt_eve_siasus BETWEEN To_Date('01/01/2024' ,'DD/MM/YYYY')AND To_Date( '31/01/2024','DD/MM/YYYY' )+ 0.99999
AND a.cd_procedimento in (0301060029,0301060096)
and b.ds_multi_empresa = #empresa#

group by a.cd_atendimento,
 c.nm_paciente,
 a.dt_eve_siasus,
 a.cd_procedimento, 
 a.qt_lancada
ORDER BY a.cd_atendimento