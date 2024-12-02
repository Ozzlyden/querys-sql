WITH periodo AS (
    SELECT 
        TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY') AS dt_inicio,
        TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') AS dt_fim,
        TO_DATE('28/08/2024', 'DD/MM/YYYY') AS data_corte
    FROM dual
)
SELECT *
FROM (
    SELECT
        cd_unid_int,
        DECODE(
            ds_unid_int, 
            'SALA ESTABILIZACAO', 'SALA VERMELHA', 
            'SALA ISOLAMENTO', 'SALA AMARELA ISO',
            'SALA OBSERVACAO', 'SALA AMARELA', 
            'SALA MEDICACAO', 'SALA VERDE',
            'SALA PEDIATRIA', 'SALA PEDIATRIA'
        ) AS ds_unid_int,
        COUNT(*) AS altas_unid_int,
        cd_mot_alt,
        ds_tip_res,
        COUNT(*) AS total_altas
    FROM (
        SELECT
            cd_atendimento,
            nm_paciente,
            dt_atendimento,
            dt_alta_medica,
            dt_alta,
            ds_unid_int,
            cd_unid_int,
            COALESCE(cd_mot_alt, 0) AS cd_mot_alt,
            COALESCE(ds_tip_res, 'PACIENTE QUE NÃO RECEBERAM ALTA') AS ds_tip_res,
            cd_multi_empresa
        FROM (
            SELECT
                a.cd_atendimento,
                p.nm_paciente,
                dt_atendimento,
                dt_alta_medica,
                dt_alta,
                COALESCE(ds_unid_int, 'SEM UNIDADE DE INTERNACAO') AS ds_unid_int,
                COALESCE(g.cd_unid_int, 0) AS cd_unid_int,
                ds_tip_res,
                a.cd_multi_empresa,
                COALESCE(a.cd_mot_alt, a.cd_tip_res) AS cd_mot_alt
            FROM atendime a
            INNER JOIN dbamv.paciente p ON a.cd_paciente = p.cd_paciente
            INNER JOIN triagem_atendimento c ON a.cd_atendimento = c.cd_atendimento
            LEFT JOIN dbamv.mot_alt d ON a.cd_mot_alt = d.cd_mot_alt
            LEFT JOIN dbamv.tip_res e ON a.cd_tip_res = e.cd_tip_res
            LEFT JOIN dbamv.leito f ON a.cd_leito = f.cd_leito
            LEFT JOIN dbamv.unid_int g ON f.cd_unid_int = g.cd_unid_int
            WHERE a.cd_multi_empresa IN (03)
            --AND  f.sn_extra = 'N' AND  f.tp_situacao = 'A'
            
            AND a.dt_atendimento BETWEEN (SELECT dt_inicio FROM periodo) AND (SELECT dt_fim FROM periodo) + 0.99999
            AND (
                (a.dt_atendimento < (SELECT data_corte FROM periodo) AND c.cd_cor_referencia = 11 )
                OR (a.dt_atendimento >= (SELECT data_corte FROM periodo) AND a.cd_leito IS NOT NULL)
            )
            ORDER BY 3
        )
    )
    GROUP BY cd_unid_int, ds_unid_int, cd_mot_alt, ds_tip_res
)
WHERE cd_unid_int = #ALTAS#