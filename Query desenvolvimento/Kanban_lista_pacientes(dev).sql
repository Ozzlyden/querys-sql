WITH periodo AS (
    SELECT 
        TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY') AS dt_inicio,
        TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') AS dt_fim,
        TO_DATE('01/08/2024', 'DD/MM/YYYY') AS data_corte
    FROM dual
),
etapa_atendimento AS (
    SELECT
        a.cd_paciente,
        g.nm_paciente,
        a.cd_atendimento,
        TO_CHAR(a.dt_atendimento, 'dd/mm/yyyy') AS dt_atendimento,
        TO_CHAR(a.dt_alta_medica, 'dd/mm/yyyy') AS dt_alta_medica,
        ROW_NUMBER() OVER(PARTITION BY a.cd_paciente ORDER BY a.dt_atendimento) AS numero_linhas,
        DECODE(
            ds_unid_int, 
            'SALA ESTABILIZACAO', 'SALA VERMELHA', 
            'SALA ISOLAMENTO', 'SALA AMARELA ISO',
            'SALA OBSERVACAO', 'SALA AMARELA', 
            'SALA MEDICACAO', 'SALA VERDE',
            'SALA PEDIATRIA', 'SALA PEDIATRIA'
        ) AS ds_unid_int,
        d.cd_unid_int,
        COALESCE(a.cd_mot_alt, a.cd_tip_res) AS cd_mot_alt
    FROM atendime a
    INNER JOIN triagem_atendimento b ON a.cd_atendimento = b.cd_atendimento
    INNER JOIN dbamv.leito c ON a.cd_leito = c.cd_leito
    INNER JOIN dbamv.unid_int d ON c.cd_unid_int = d.cd_unid_int
    LEFT JOIN dbamv.mot_alt e ON a.cd_mot_alt = e.cd_mot_alt
    LEFT JOIN dbamv.tip_res f ON a.cd_tip_res = f.cd_tip_res
    LEFT JOIN dbamv.paciente g ON a.cd_paciente = g.cd_paciente
    WHERE a.cd_multi_empresa IN (17)
    AND a.dt_atendimento BETWEEN (SELECT dt_inicio FROM periodo) AND (SELECT dt_fim FROM periodo) + 0.99999
    AND (
        (a.dt_atendimento < (SELECT data_corte FROM periodo) AND b.cd_cor_referencia = 11)
        OR (a.dt_atendimento >= (SELECT data_corte FROM periodo) AND a.cd_leito IS NOT NULL)
    )
)
SELECT *
FROM etapa_atendimento
ORDER BY ds_unid_int, dt_atendimento
