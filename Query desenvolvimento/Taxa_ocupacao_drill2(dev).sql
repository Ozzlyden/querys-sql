WITH resultado_base AS (
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
        CEIL(NVL(NVL(a.hr_alta, a.hr_alta_medica), TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY')) - a.hr_atendimento) AS qtd_dias_internados
    FROM
        dbamv.atendime a
    LEFT JOIN dbamv.leito b ON a.cd_leito = b.cd_leito
    INNER JOIN dbamv.unid_int c ON b.cd_unid_int = c.cd_unid_int
    INNER JOIN dbamv.paciente d ON a.cd_paciente = d.cd_paciente
    LEFT JOIN dbamv.triagem_atendimento e ON a.cd_atendimento = e.cd_atendimento
    WHERE
        a.cd_multi_empresa IN (03) 
        AND a.dt_atendimento BETWEEN TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY') AND TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') + 0.99999
        AND (
            (a.dt_atendimento < TO_DATE('28/08/2024', 'DD/MM/YYYY') AND e.cd_cor_referencia = 11)
            OR (a.dt_atendimento >= TO_DATE('28/08/2024', 'DD/MM/YYYY') AND b.cd_leito IS NOT NULL)
        )
        AND ROUND(
                  NVL(NVL(a.hr_alta, a.hr_alta_medica), TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY')) - a.hr_atendimento, 2
                  ) >= 0
),
sequencia AS (
    SELECT LEVEL AS dia
    FROM dual
    CONNECT BY LEVEL <= (SELECT MAX(CEIL(qtd_dias_internados)) FROM resultado_base)
),
resultado_drill AS (
    SELECT 
        rb.cd_paciente,
        rb.cd_atendimento,
        rb.nm_paciente,
        rb.qtd_dias_internados,
        rb.unid_int,
        rb.cd_unid_int,
        rb.ds_leito,
        s.dia
    FROM 
        resultado_base rb
    INNER JOIN sequencia s 
        ON s.dia <= CASE 
                        WHEN rb.qtd_dias_internados < 0 THEN 1
                        ELSE CEIL(rb.qtd_dias_internados) 
                    END
)

SELECT 
    cd_paciente,
    cd_atendimento,
    nm_paciente,
    qtd_dias_internados,
    dia,
    unid_int,
    cd_unid_int,
    ds_leito
FROM 
    resultado_drill
WHERE
    cd_unid_int = #CD_UNID_INT#
ORDER BY 
    cd_atendimento, dia
