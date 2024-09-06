--Desenvolvimento --HRSM - Agendamentos Serviço x TA (v2)(Atualizado)
SELECT 
    a.CD_TIP_MAR,
    c.ds_tip_mar,
    a.cd_ser_dis,
    b.ds_ser_dis,    
    COUNT(a.CD_ATENDIMENTO) AS atendido,
    (COUNT(a.CD_PACIENTE) - COUNT(a.CD_ATENDIMENTO)) AS falta,
    COUNT(a.CD_PACIENTE) AS total_agendado,
    CASE
        WHEN e.cd_tip_presta = 8 THEN 'MÉDICO'
        ELSE 'NÃO MÉDICO'
    END AS tipo_medico
FROM 
    it_AGENDA_CENTRAL a 
    INNER JOIN dbamv.ser_dis b ON a.cd_ser_dis = b.cd_ser_dis
    INNER JOIN dbamv.tip_mar c ON a.cd_tip_mar = c.cd_tip_mar
    INNER JOIN dbamv.agenda_central d ON a.cd_agenda_central = d.cd_agenda_central
    INNER JOIN dbamv.prestador e ON d.cd_prestador = e.cd_prestador
WHERE 
    a.hr_agenda BETWEEN TO_DATE(@P_DATA_INI) AND TO_DATE(@P_DATA_FIM) + 0.99999
    AND a.CD_TIP_MAR IN (1, 2)
    AND d.tp_agenda = 'A'
    and b.cd_ser_dis IN ({V_CD_SERV})
GROUP BY 
    a.CD_TIP_MAR, 
    c.ds_tip_mar, 
    a.cd_ser_dis, 
    b.ds_ser_dis, 
    e.cd_tip_presta

UNION ALL

SELECT
    3 AS cd_tip_mar,
    'ATENDIMENTO EXTERNO' AS ds_tip_mar,
    a.cd_especialid,
    b.ds_especialid,
    COUNT(*) AS atendido,
    0 AS falta,
    0 AS total_agendado,
    CASE
        WHEN c.cd_tip_presta = 8 THEN 'MÉDICO'
        ELSE 'NÃO MÉDICO'
    END AS tipo_medico
    
FROM
    dbamv.atendime a
    LEFT JOIN dbamv.especialid b ON a.cd_especialid = b.cd_especialid
    LEFT JOIN dbamv.prestador c ON a.cd_prestador = c.cd_prestador
    LEFT JOIN dbamv.pre_med d ON a.cd_atendimento = d.cd_atendimento
WHERE
    a.dt_atendimento BETWEEN TO_DATE(@P_DATA_INI) AND TO_DATE(@P_DATA_FIM) + 0.99999
    AND a.tp_atendimento = 'E'
    AND a.cd_multi_empresa IN (2)
GROUP BY
    a.cd_especialid,
    b.ds_especialid,
    c.cd_tip_presta

ORDER BY 
    3, 
    1
