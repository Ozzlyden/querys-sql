--HRSM - Monitoramento do Tempo de Espera - desenvolvimento
SELECT
    *
FROM
    (
        SELECT
            decode(a.tp_atendimento, 'A', 'AMBULATÓRIO', 'I', 'INTERNAÇÃO',
                   'E', 'EXTERNO', 'U', 'URGÊNCIA')                           AS tipo_atendimento,
            a.cd_atendimento                                                  AS atendimento,
            b.descricao_cbo,
            b.nm_prestador                                                    AS prestador,
            c.nm_paciente                                                     AS paciente,
            fn_retorna_hr_min_seg(nvl(a.hr_alta, sysdate) - a.hr_atendimento) AS tempo_espera,
            CASE
                WHEN nvl(a.dt_alta, a.dt_alta_medica ) IS NULL THEN
                    'Não'
                ELSE
                    'Sim'
            END                                                               AS sn_alta
        FROM
            dbamv.atendime a
            LEFT JOIN (
                SELECT
                    c.cd_prestador,
                    c.nm_prestador,
                    LISTAGG(' - ' || d.ds_cbos) WITHIN GROUP(
                    ORDER BY
                        c.cd_prestador
                    ) AS descricao_cbo
                FROM
                    (
                        SELECT DISTINCT
                            a.cd_prestador,
                            a.nm_prestador,
                            b.cd_cbo
                        FROM
                            prestador     a
                            LEFT JOIN prestador_cbo b ON a.cd_prestador = b.cd_prestador
                        WHERE
                                cd_tip_presta = 3
                            AND b.cd_multi_empresa = 2
                            AND a.tp_situacao = 'A'
                    )   c
                    LEFT JOIN cbo d ON c.cd_cbo = d.cd_cbos
                GROUP BY
                    c.cd_prestador,
                    c.nm_prestador
            )              b ON a.cd_prestador = b.cd_prestador
            LEFT JOIN paciente       c ON a.cd_paciente = c.cd_paciente
        WHERE
                trunc(a.dt_atendimento) = trunc(TO_DATE(sysdate))
            AND a.cd_multi_empresa = 2
            AND a.cd_especialid IN ( 29, 99, 31, 64, 90, 96, 98 ) --adicionado 31, 64, 90, 96, 98 
            AND a.tp_atendimento = 'A'
        UNION ALL
        SELECT
            decode(a.tp_atendimento, 'A', 'AMBULATÓRIO', 'I', 'INTERNAÇÃO',
                   'E', 'EXTERNO', 'U', 'URGÊNCIA')                           AS tipo_atendimento,
            a.cd_atendimento                                                  AS atendimento,
            b.descricao_cbo,
            b.nm_prestador                                                    AS prestador,
            c.nm_paciente                                                     AS paciente,
            fn_retorna_hr_min_seg(nvl(a.hr_alta, sysdate) - a.hr_atendimento) AS tempo_espera,
            CASE
                WHEN nvl(a.dt_alta, a.dt_alta_medica ) IS NULL THEN
                    'Não'
                ELSE
                    'Sim'
            END                                                               AS sn_alta
        FROM
            dbamv.atendime a
            LEFT JOIN (
                SELECT
                    c.cd_prestador,
                    c.nm_prestador,
                    LISTAGG(' - ' || d.ds_cbos) WITHIN GROUP(
                    ORDER BY
                        c.cd_prestador
                    ) AS descricao_cbo
                FROM
                    (
                        SELECT DISTINCT
                            a.cd_prestador,
                            a.nm_prestador,
                            b.cd_cbo
                        FROM
                            prestador     a
                            LEFT JOIN prestador_cbo b ON a.cd_prestador = b.cd_prestador
                        WHERE
                                cd_tip_presta = 3
                            AND b.cd_multi_empresa = 2
                            AND a.tp_situacao = 'A'
                    )   c
                    LEFT JOIN cbo d ON c.cd_cbo = d.cd_cbos
                GROUP BY
                    c.cd_prestador,
                    c.nm_prestador
            )              b ON a.cd_prestador = b.cd_prestador
            LEFT JOIN paciente       c ON a.cd_paciente = c.cd_paciente
        WHERE
                trunc(a.dt_atendimento) = trunc(TO_DATE(sysdate))
            AND a.cd_multi_empresa = 2
            AND a.cd_ori_ate IN ( 50, 51, 59, 83, 90, 250, 389, 391, 392, 393, 394, 395, 398 ) --adicionado: 59, 83, 90, 250, 389, 391, 392, 393, 394, 395, 398 
            AND a.tp_atendimento IN ( 'U', 'E' )
    )
WHERE
    sn_alta = 'Não'
ORDER BY
    6 DESC,
    1,
    2 ASC