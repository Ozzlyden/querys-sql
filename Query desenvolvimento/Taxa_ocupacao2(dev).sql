WITH resultado AS (
    SELECT
        pacientes.cd_unid_int,
        unid_int,
        CEIL(qtd_dias_internados) AS qtd_pacientes,
        leitos_oficiais,
        qtd_dias_internados,
        (TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') - TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY')) + 1 AS dias_entre_datas,
        
        CASE 
            WHEN TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY') < TO_DATE('28/08/2024', 'DD/MM/YYYY') THEN 
                ROUND(
                    (qtd_pacientes * 100) / (leitos_oficiais * ((TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') - TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY')) + 1)),
                2)
            ELSE 
                ROUND(
                    (qtd_dias_internados * 100) / (leitos_oficiais * ((TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') - TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY')) + 1)),
                2)
        END AS taxa_ocupacao,
              
        $PgIgesdfDtInicial$  dt_inicio,
        $PgIgesdfDtFim$  dt_fim
    FROM
        (
            SELECT
                cd_unid_int,
                unid_int,
                SUM(qtd_dias_internados) AS qtd_pacientes,
                SUM(qtd_dias_internados) AS qtd_dias_internados
            FROM
                (
                    SELECT DISTINCT
                        a.cd_paciente,
                        a.cd_atendimento,
                        DECODE(c.ds_unid_int, 'SALA ESTABILIZACAO', 'SALA VERMELHA', 'SALA ISOLAMENTO', 'SALA AMARELA ISO',
                               'SALA OBSERVACAO', 'SALA AMARELA', 'SALA MEDICACAO', 'SALA VERDE', 'SALA PEDIATRIA', 'SALA PEDIATRIA') AS unid_int,
                        c.cd_unid_int,
                        b.ds_leito,
                        CEIL(NVL(NVL(a.hr_alta, a.hr_alta_medica),
                                      TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY')) - a.hr_atendimento) AS qtd_dias_internados
                    FROM
                        atendime a
                        INNER JOIN dbamv.leito b ON a.cd_leito = b.cd_leito
                        INNER JOIN dbamv.unid_int c ON b.cd_unid_int = c.cd_unid_int
                        INNER JOIN dbamv.paciente d ON a.cd_paciente = d.cd_paciente
                        INNER JOIN dbamv.triagem_atendimento e ON a.cd_atendimento = e.cd_atendimento
                    WHERE
                        a.cd_multi_empresa IN (03) 
                         --AND b.sn_extra = 'N' 
                         --AND b.tp_situacao = 'A'                  
                        AND a.dt_atendimento BETWEEN TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY') AND TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') + 0.99999
                        AND (
                            (a.dt_atendimento < TO_DATE('28/08/2024', 'DD/MM/YYYY') AND e.cd_cor_referencia = 11)
                            OR (a.dt_atendimento >= TO_DATE('28/08/2024', 'DD/MM/YYYY') AND b.cd_leito IS NOT NULL)
                        )
                        AND ROUND(
                             NVL(NVL(a.hr_alta, a.hr_alta_medica), TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY')) - a.hr_atendimento, 2) >= 0
                ) pacientes
            GROUP BY
                cd_unid_int,
                unid_int
        ) pacientes
        INNER JOIN (
            SELECT
                a.cd_unid_int,
                b.ds_unid_int,
                COUNT(*) AS leitos_oficiais
            FROM
                leito a
                INNER JOIN dbamv.unid_int b ON a.cd_unid_int = b.cd_unid_int
                INNER JOIN dbamv.setor c ON b.cd_setor = c.cd_setor
            WHERE
                c.cd_multi_empresa IN (03)
                AND a.sn_extra = 'N'
                AND a.tp_situacao = 'A'
            GROUP BY
                a.cd_unid_int,
                b.ds_unid_int
        ) leitos ON pacientes.cd_unid_int = leitos.cd_unid_int
)
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
    SUM(qtd_dias_internados) AS qtd_dias_internados_total,
    0 AS dias_entre_datas_total,
    ROUND((SUM(qtd_pacientes) * 100) / (SUM(leitos_oficiais) * ((TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY') - TO_DATE($PgIgesdfDtInicial$, 'DD/MM/YYYY')) + 1)), 2) AS taxa_ocupacao_total,
    $PgIgesdfDtInicial$ dt_inicio,
    $PgIgesdfDtFim$ dt_fim
FROM
    resultado
