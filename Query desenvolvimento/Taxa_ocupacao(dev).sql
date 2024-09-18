--Painel "UPAS - VICENTE PIRES - Painel de Gestão" - Taxa de Ocupação - desenvolvimento
WITH resultado AS (
    SELECT
        pacientes.cd_unid_int,
        pacientes.unid_int,
        pacientes.qtd_pacientes,
        leitos.leitos_oficiais,
        TO_DATE('30/08/2024', 'DD/MM/YYYY') - TO_DATE('01/08/2024', 'DD/MM/YYYY') + 1 AS dias_entre_datas,
        ROUND((pacientes.qtd_dias_internados * 100) / (leitos.leitos_oficiais * (TO_DATE('30/08/2024', 'DD/MM/YYYY') - TO_DATE('01/08/2024', 'DD/MM/YYYY') + 1)), 2) AS taxa_ocupacao,
        pacientes.qtd_dias_internados,
        '01/08/2024' AS dt_inicio,  -- Data da implementação Vicente Pires '01/08/2024'
        '30/08/2024' AS dt_fim
    FROM
        (
            -- Subselect para calcular a quantidade de dias ocupados pelos pacientes
            SELECT
                cd_unid_int,
                unid_int,
                SUM(dia_internacao) as qtd_dias_internados,
                --SUM(ROUND(a.dt_alta - a.dt_atendimento)) AS qtd_dias_internados, -- Somatório dos dias ocupados por cada paciente
                COUNT(cd_atendimento) AS qtd_pacientes
            FROM
                (
                    SELECT DISTINCT
                        a.cd_paciente,
                        a.cd_atendimento,
                        ROUND(a.dt_alta - a.dt_atendimento) AS dia_internacao, -- Calcula o número de dias entre dt_alta e dt_atendimento
                        TO_CHAR(a.dt_atendimento, 'DD/MM/YYYY') AS dt_atendimento,
                        /*to_char(round(TO_NUMBER(a.dt_alta - a.dt_atendimento)))
                        || ' Dia(s) Internado'          as        dt_internacao,*/
                        a.dt_alta,
                        decode(c.ds_unid_int, 'SALA ESTABILIZACAO', 'SALA VERMELHA', 'SALA ISOLAMENTO', 'SALA AMARELA ISO',
                               'SALA OBSERVACAO', 'SALA AMARELA', 'SALA MEDICACAO', 'SALA VERDE') AS unid_int,
                        c.cd_unid_int,
                        b.ds_leito
                    FROM
                        atendime a
                        INNER JOIN dbamv.leito b ON a.cd_leito = b.cd_leito
                        INNER JOIN dbamv.unid_int c ON b.cd_unid_int = c.cd_unid_int
                        INNER JOIN dbamv.paciente d ON a.cd_paciente = d.cd_paciente
                        INNER JOIN dbamv.triagem_atendimento e ON a.cd_atendimento = e.cd_atendimento
                    WHERE
                        a.cd_multi_empresa IN (17) -- Filtro de empresa
                        AND a.dt_atendimento BETWEEN TO_DATE('01/08/2024', 'DD/MM/YYYY') AND TO_DATE('30/08/2024', 'DD/MM/YYYY') + 0.99999
                        AND e.cd_cor_referencia = 11
                ) pacientes
            GROUP BY
                cd_unid_int,
                unid_int
        ) pacientes
        INNER JOIN (
            -- Subselect para calcular a quantidade de leitos oficiais
            SELECT
                a.cd_unid_int,
                b.ds_unid_int,
                COUNT(*) AS leitos_oficiais
            FROM
                leito a
                INNER JOIN dbamv.unid_int b ON a.cd_unid_int = b.cd_unid_int
                INNER JOIN dbamv.setor c ON b.cd_setor = c.cd_setor
            WHERE
                c.cd_multi_empresa IN (17) -- Filtro de empresa
                AND a.sn_extra = 'N'
                AND a.tp_situacao = 'A'
            GROUP BY
                a.cd_unid_int,
                b.ds_unid_int
        ) leitos ON pacientes.cd_unid_int = leitos.cd_unid_int
)

-- Seleção final, incluindo o cálculo total
SELECT
    *
FROM
    resultado
UNION ALL
SELECT
    0 AS cd_unid_int,
    'TOTAL_PACIENTES' AS unid_int,
    SUM(qtd_pacientes) AS qtd_pacientes_total,
    SUM(leitos_oficiais) AS leitos_oficiais_total,
    0 AS dias_entre_datas_total,
    ROUND((SUM(qtd_dias_internados) * 100) / (SUM(leitos_oficiais) * (TO_DATE('30/08/2024', 'DD/MM/YYYY') - TO_DATE('01/08/2024', 'DD/MM/YYYY') + 1)), 2) AS taxa_ocupacao_total,
    SUM(qtd_dias_internados) AS qtd_dias_internados_total, 
    '01/08/2024' AS dt_inicio,
    '30/08/2024' AS dt_fim
FROM
    resultado