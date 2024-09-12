--Painel "Contrato de Gestão 2021"
--IGESDF- Atendimento de Urgência com observação até 24 horas em atenção especializada - UPA's - DRILL
SELECT 
    a.cd_atendimento,
    c.nm_paciente,
    a.dt_eve_siasus AS data_item_lancamento,
    a.cd_procedimento,
    Sum (a.qt_lancada) as total
FROM 
    dbamv.Eve_siasus a, paciente c, multi_empresas b
WHERE a.cd_procedimento IN ('0301060029') -- ATENDIMENTO DE URGENCIA C/ OBSERVACAO ATE 24 HORAS EM ATENCAO ESPECIALIZADA
    and a.cd_paciente = c.cd_paciente
    and a.cd_multi_empresa = b.cd_multi_empresa
    AND b.cd_multi_empresa IN ('3','4','5','6','7','8','12','13','14','15','16','17','18')
    AND a.dt_eve_siasus BETWEEN To_Date('01/06/2024', 'DD/MM/YYYY') AND To_Date('30/06/2024', 'DD/MM/YYYY') + 0.99999
    and b.ds_multi_empresa = #empresa#
GROUP BY 
    a.cd_atendimento,
    c.nm_paciente,
    a.dt_eve_siasus,
    a.cd_procedimento,
    a.qt_lancada
ORDER BY 
    a.cd_atendimento;
