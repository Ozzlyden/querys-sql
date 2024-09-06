--Painel "Contrato de Gestão 2021"
--IGESDF- Atendimento de Urgência com observação até 24 horas em atenção especializada - UPA's - DRILL
SELECT 
    a.cd_atendimento,
    p.nm_paciente,
    a.dt_eve_siasus,
    a.cd_procedimento,
    Sum (a.qt_lancada) as total
FROM 
    dbamv.Eve_siasus a
JOIN 
    dbamv.multi_empresas m ON a.cd_multi_empresa = m.cd_multi_empresa
JOIN 
    paciente p ON a.cd_paciente = p.cd_paciente
WHERE 
    a.cd_procedimento IN ('0301060029') -- ATENDIMENTO DE URGENCIA C/ OBSERVACAO ATE 24 HORAS EM ATENCAO ESPECIALIZADA
    AND m.cd_multi_empresa IN ('3','4','5','6','7','8','12','13','14','15','16','17','18')
    AND a.dt_eve_siasus BETWEEN To_Date('01/06/2024', 'DD/MM/YYYY') AND To_Date('30/06/2024', 'DD/MM/YYYY') + 0.99999
GROUP BY 
    a.cd_atendimento,
    p.nm_paciente,
    a.dt_eve_siasus,
    a.cd_procedimento,
    a.qt_lancada
ORDER BY 
    a.cd_atendimento;
