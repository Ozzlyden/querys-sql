---Painel - UPAVP - Drill 2 Kanban Média de Permanência dos Pacientes Motivo de Alta - Original

SELECT
    a.cd_paciente,
    e.nm_paciente,
    COUNT(a.cd_atendimento) AS qdt_dias_internados,
    MIN(TO_CHAR(a.dt_atendimento, 'dd/mm/yyyy')) AS Inicio_atendimento,
    MAX(TO_CHAR(a.dt_alta_medica, 'dd/mm/yyyy')) AS fim_atendimento,
    
    DECODE(
        ds_unid_int ,
        'SALA ESTABILIZACAO', 'SALA VERMELHA',
        'SALA ISOLAMENTO', 'SALA AMARELA ISO',
        'SALA OBSERVACAO', 'SALA AMARELA',
        'SALA MEDICACAO', 'SALA VERDE'
    ) AS ds_unid_int,
    cd_mot_alt,
    ds_mot_alt,
    MAX(cd_unid_int) AS cd_unid_int
FROM (
    SELECT
        a.cd_paciente,
        a.cd_atendimento,
        a.dt_atendimento,
        a.dt_alta_medica,
        d.ds_unid_int,
        d.cd_unid_int,
        CASE
            WHEN a.cd_mot_alt IS NULL THEN a.cd_tip_res
            ELSE a.cd_mot_alt
            END cd_mot_alt,
        CASE
            WHEN ds_mot_alt IS NULL THEN ds_tip_res
            ELSE ds_mot_alt
            END ds_mot_alt,
        ROW_NUMBER() OVER (PARTITION BY a.cd_paciente ORDER BY a.dt_atendimento) AS row_num
        
    FROM atendime a
    INNER JOIN (
        SELECT * FROM triagem_atendimento
        WHERE cd_cor_referencia = 11
    ) b ON a.cd_atendimento = b.cd_atendimento
    INNER JOIN DBAMV.leito c ON a.cd_leito = c.cd_leito
    INNER JOIN DBAMV.unid_int d ON c.cd_unid_int = d.cd_unid_int
    INNER JOIN DBAMV.paciente e ON a.cd_paciente = e.cd_paciente
    LEFT JOIN DBAMV.mot_alt f ON a.cd_mot_alt = f.cd_mot_alt
    LEFT JOIN DBAMV.tip_res g ON a.cd_tip_res = g.cd_tip_res
WHERE a.cd_multi_empresa IN (17) ---------------> UPAVP <---------------
    --AND a.cd_paciente IN ( 1801769, 6691707)
    AND a.dt_atendimento BETWEEN TO_DATE( $PgIgesdfDtInicial$ , 'DD/MM/YYYY') AND TO_DATE( $PgIgesdfDtFim$ )+0.99999
    --AND a.cd_leito IS NOT NULL
) a
    INNER JOIN DBAMV.paciente e ON a.cd_paciente = e.cd_paciente

WHERE cd_mot_alt = #PACIENTES_ALTA#
AND cd_unid_int = #UNIDADE#

GROUP BY a.cd_paciente, e.nm_paciente, cd_unid_int, ds_unid_int, cd_mot_alt, ds_mot_alt
ORDER BY 4