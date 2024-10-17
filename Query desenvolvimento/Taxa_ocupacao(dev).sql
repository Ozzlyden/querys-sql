WITH periodo AS (
    SELECT 
        TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY') AS dt_inicio,
        TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') AS dt_fim,
        TO_DATE('01/08/2024', 'DD/MM/YYYY') AS data_corte -- Implementação do novo calculo
    FROM dual
),
leitos_oficiais AS (
    -- Calcula a quantidade de leitos oficiais
    SELECT
        a.cd_unid_int,
        DECODE(
            b.ds_unid_int, 
            'SALA ESTABILIZACAO', 'SALA VERMELHA', 
            'SALA ISOLAMENTO', 'SALA AMARELA ISO',
            'SALA OBSERVACAO', 'SALA AMARELA', 
            'SALA MEDICACAO', 'SALA VERDE',
            'SALA PEDIATRIA', 'SALA PEDIATRIA'
        ) AS unid_int,
        COUNT(*) AS leitos_oficiais
    FROM
        dbamv.leito a
    INNER JOIN dbamv.unid_int b ON a.cd_unid_int = b.cd_unid_int
    INNER JOIN dbamv.setor c ON b.cd_setor = c.cd_setor
    WHERE 
        c.cd_multi_empresa = (17) -- Filtro de empresa
        AND a.sn_extra = 'N'
        AND a.tp_situacao = 'A'
        AND (TRUNC(a.dt_desativacao) IS NULL OR TRUNC(a.dt_desativacao) > (SELECT dt_fim FROM periodo))
        AND TRUNC(a.dt_ativacao) <= (SELECT dt_fim FROM periodo)
    GROUP BY
        a.cd_unid_int,
        b.ds_unid_int
),
movimentacao_pacientes AS (
    -- Calcula os dias de ocupação por paciente com base na movimentação entre leitos
    SELECT
        b.cd_unid_int,
        DECODE(
            c.ds_unid_int, 
            'SALA ESTABILIZACAO', 'SALA VERMELHA', 
            'SALA ISOLAMENTO', 'SALA AMARELA ISO',
            'SALA OBSERVACAO', 'SALA AMARELA', 
            'SALA MEDICACAO', 'SALA VERDE',
            'SALA PEDIATRIA', 'SALA PEDIATRIA'
        ) AS unid_int,
        COUNT(DISTINCT a.cd_atendimento) AS qtd_pacientes,
        ROUND(
            SUM(
                CASE 
                    WHEN i.dt_lib_mov IS NULL THEN (SELECT dt_fim FROM periodo) - i.dt_mov_int
                    ELSE i.dt_lib_mov - i.dt_mov_int
                END
            ), 2
        ) AS qtd_dias_internados -- Soma os dias ocupados entre movimentações e arredonda
    FROM
        dbamv.atendime a
    INNER JOIN dbamv.leito b ON a.cd_leito = b.cd_leito
    INNER JOIN dbamv.unid_int c ON b.cd_unid_int = c.cd_unid_int
    INNER JOIN dbamv.triagem_atendimento e ON a.cd_atendimento = e.cd_atendimento
    INNER JOIN dbamv.mov_int i ON a.cd_atendimento = i.cd_atendimento
    WHERE
        a.cd_multi_empresa = (17) -- Filtro de empresa
        AND a.dt_atendimento BETWEEN (SELECT dt_inicio FROM periodo) AND (SELECT dt_fim FROM periodo) + 0.99999
        AND (
            -- Antes da data_corte, aplicar filtro de cor de referência 11
            (a.dt_atendimento < (SELECT data_corte FROM periodo) AND e.cd_cor_referencia = 11)
            -- Após a data_corte, considerar apenas pacientes em leitos
            OR (a.dt_atendimento >= (SELECT data_corte FROM periodo) AND b.cd_leito IS NOT NULL)
        )
    GROUP BY
        b.cd_unid_int,
        c.ds_unid_int
),
resultado AS (
    SELECT
        p.cd_unid_int,
        l.unid_int,
        l.leitos_oficiais,
        p.qtd_pacientes,
        p.qtd_dias_internados,
        (SELECT dt_inicio FROM periodo) AS dt_inicio,
        (SELECT dt_fim FROM periodo) AS dt_fim,
        CASE 
            -- Antes da data_corte -> usar fórmula do Código Original
            WHEN (SELECT dt_inicio FROM periodo) < (SELECT data_corte FROM periodo) THEN 
                ROUND(
                    (p.qtd_pacientes * 100) / (
                        ((SELECT dt_fim FROM periodo) - (SELECT dt_inicio FROM periodo) + 1) * l.leitos_oficiais
                    ), 
                    2
                )
            -- Após a data_corte -> usar fórmula pela qtd dias internados
            ELSE 
                ROUND(
                    (p.qtd_dias_internados * 100) / (
                        l.leitos_oficiais * ((SELECT dt_fim FROM periodo) - (SELECT dt_inicio FROM periodo) + 1)
                    ), 
                    2
                )
        END AS taxa_ocupacao
    FROM 
        movimentacao_pacientes p
    INNER JOIN 
        leitos_oficiais l 
        ON p.cd_unid_int = l.cd_unid_int 
        AND p.unid_int = l.unid_int  
)
-- Seleção final, incluindo o cálculo total
SELECT
    cd_unid_int,
    unid_int,
    qtd_pacientes,
    leitos_oficiais,
    qtd_dias_internados,
    taxa_ocupacao,
    dt_inicio,
    dt_fim
FROM
    resultado
UNION ALL
SELECT
    0 AS cd_unid_int,
    'TOTAL_PACIENTES' AS unid_int,
    SUM(qtd_pacientes) AS qtd_pacientes_total,
    SUM(leitos_oficiais) AS leitos_oficiais_total,
    SUM(qtd_dias_internados) AS qtd_dias_internados_total,
    CASE 
        -- Antes da data_corte -> usar fórmula do Código Original
        WHEN (SELECT dt_inicio FROM periodo) < (SELECT data_corte FROM periodo) THEN 
            ROUND(
                (SUM(qtd_pacientes) * 100) / (
                    SUM(leitos_oficiais) * (
                        (SELECT dt_fim FROM periodo) - (SELECT dt_inicio FROM periodo) + 1
                    )
                ), 
                2
            )
        -- Após a data_corte -> usar fórmula pela qtd dias internados
        ELSE 
            ROUND(
                (SUM(qtd_dias_internados) * 100) / (
                    SUM(leitos_oficiais) * (
                        (SELECT dt_fim FROM periodo) - (SELECT dt_inicio FROM periodo) + 1
                    )
                ), 
                2
            )
    END AS taxa_ocupacao_total,
    (SELECT dt_inicio FROM periodo) AS dt_inicio,
    (SELECT dt_fim FROM periodo) AS dt_fim
FROM
    resultado,
    periodo 
GROUP BY
    periodo.dt_inicio, 
    periodo.dt_fim
