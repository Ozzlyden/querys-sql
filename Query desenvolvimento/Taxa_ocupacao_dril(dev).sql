--Taxa de Ocupação Drill
WITH periodo AS (
    SELECT 
        TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY') AS DT_INICIO,
        TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') AS DT_FIM,
        TO_DATE('01/08/2024', 'DD/MM/YYYY') AS data_corte -- Implementação do novo cálculo
    FROM dual
),
pacientes AS (
    SELECT DISTINCT
        a.cd_paciente,
        a.cd_atendimento,
        d.nm_paciente,
        DECODE(
            c.ds_unid_int, 
            'SALA ESTABILIZACAO', 'SALA VERMELHA', 
            'SALA ISOLAMENTO', 'SALA AMARELA ISO',
            'SALA OBSERVACAO', 'SALA AMARELA', 
            'SALA MEDICACAO', 'SALA VERDE',
            'SALA PEDIATRIA', 'SALA PEDIATRIA'
        ) AS unid_int,
        c.cd_unid_int,
        b.ds_leito,
        ROUND(NVL(NVL(a.hr_alta, a.hr_alta_medica),
            TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY')) - a.hr_atendimento, 2) AS qtd_dias_internados
        /*,
        CASE 
            -- Antes da data_corte -> pacientes com triagem referência 11
            WHEN a.dt_atendimento < (SELECT data_corte FROM periodo) THEN 
                CASE 
                    WHEN e.cd_cor_referencia = 11 THEN 1
                    ELSE 0
                END
            -- Após a data_corte -> considerar apenas pacientes em leitos
            ELSE 
                CASE 
                    WHEN b.cd_leito IS NOT NULL THEN 1
                    ELSE 0
                END
        END AS filtro_paciente*/
    FROM
        dbamv.atendime a
    INNER JOIN dbamv.leito b ON a.cd_leito = b.cd_leito
    LEFT JOIN dbamv.unid_int c ON b.cd_unid_int = c.cd_unid_int
    INNER JOIN dbamv.paciente d ON a.cd_paciente = d.cd_paciente
    LEFT JOIN dbamv.triagem_atendimento e ON a.cd_atendimento = e.cd_atendimento
    WHERE
        a.cd_multi_empresa IN (17) -- Filtro de empresa
        --AND b.sn_extra = 'N'
        --AND b.tp_situacao = 'A'
        AND a.dt_atendimento BETWEEN (SELECT DT_INICIO FROM periodo) AND (SELECT DT_FIM FROM periodo) + 0.99999
        AND (
                (a.dt_atendimento < (SELECT data_corte FROM periodo) AND e.cd_cor_referencia = 11)
                OR (a.dt_atendimento >= (SELECT data_corte FROM periodo) AND b.cd_leito IS NOT NULL)
            )
),
resultado AS (
    SELECT 
        cd_paciente,
        cd_atendimento,
        nm_paciente,
        qtd_dias_internados,
        unid_int,
        cd_unid_int,
        ds_leito
    FROM 
        pacientes
   -- WHERE
        --filtro_paciente = 1 -- Aplicar o filtro conforme a regra da data de corte
)

SELECT 
    cd_paciente,
    cd_atendimento,
    nm_paciente,
    qtd_dias_internados,
    unid_int,
    cd_unid_int,
    ds_leito
FROM 
    resultado
WHERE 
    cd_unid_int = #CD_UNID_INT#
ORDER BY 
    cd_paciente