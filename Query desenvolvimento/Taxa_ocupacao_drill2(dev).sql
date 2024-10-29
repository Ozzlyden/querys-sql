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
        ROUND(NVL(NVL(a.hr_alta, a.hr_alta_medica), (SELECT DT_FIM FROM periodo)) - a.hr_atendimento, 2) AS qtd_dias_internados
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
sequencia AS (
    SELECT LEVEL AS dia
    FROM dual
    CONNECT BY LEVEL <= (SELECT MAX(CEIL(qtd_dias_internados)) FROM pacientes) 
),
resultado AS (
    SELECT 
        p.cd_paciente,
        p.cd_atendimento,
        p.nm_paciente,
        p.qtd_dias_internados,
        p.unid_int,
        p.cd_unid_int,
        p.ds_leito,
        s.dia
    FROM 
        pacientes p
    INNER JOIN sequencia s ON s.dia <= CEIL(p.qtd_dias_internados) 
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
    cd_paciente, dia
