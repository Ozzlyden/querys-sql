/*--------------------------------------------------------------------------------------
Comissão Revisão Prontuário - Status Pacientes para a Avaliação de Revisão do Prontuário
--------------------------------------------------------------------------------------*/
SELECT DISTINCT
    cd_atendimento,
    cd_paciente,
    nm_paciente,
    dt_atendimento,
    dt_nascimento,
    idade,
    dt_alta_medica,
    dt_alta,
    tempo_internacao || ' ' || 'Dias' AS tempo_internacao,
    ds_unid_int,
    ds_especialid,
    registro_diag,
    registro_alta,
    presenca_medicamento
FROM
    (
 -- ================================================
 -- INICIO - STATUS PACIENTES E PRONTUÁRIO DETALHADO
 -- ================================================
        SELECT
            atend.cd_atendimento,
            atend.cd_paciente,
            pac.nm_paciente,
            atend.dt_atendimento,
            to_char(pac.dt_nascimento, 'dd/mm/yyyy')           AS dt_nascimento,
            trunc(months_between(sysdate, dt_nascimento) / 12) AS idade,
            atend.dt_alta_medica,
            atend.dt_alta,
            atend.tempo_internacao,
            mov.cd_leito,
            atend.cd_prestador,
            atend.nm_prestador,
            atend.cd_especialid,
            atend.ds_especialid,
            unid_int.cd_unid_int,
            unid_int.ds_unid_int,
            CASE
                WHEN log_cid.cd_atendimento IS NOT NULL THEN
                    'SIM'
                ELSE
                    'NÃO'
            END                                                AS registro_diag,
            CASE
                WHEN reg_alta.cd_atendimento IS NOT NULL THEN
                    'SIM'
                ELSE
                    'NÃO'
            END                                                AS registro_alta,
            CASE
                WHEN presc.cd_atendimento IS NOT NULL THEN
                    'SIM'
                ELSE
                    'NÃO'
            END                                                AS presenca_medicamento
        FROM
                 (
 -- =====================================
 -- INICIO - ATENDIMENTOS COM ALTA MÉDICA
 -- =====================================
                SELECT
                    a.cd_atendimento,
                    a.cd_paciente,
                    a.dt_atendimento,
                    a.dt_alta_medica,
                    a.dt_alta,
                    ( TO_DATE(a.dt_alta_medica) - TO_DATE(a.dt_atendimento) ) AS tempo_internacao,
                    a.cd_leito,
                    a.cd_prestador,
                    c.nm_prestador,
                    a.cd_especialid,
                    b.ds_especialid
                FROM
                    atendime a
                    LEFT JOIN dbamv.especialid b ON a.cd_especialid = b.cd_especialid
                    LEFT JOIN dbamv.prestador c ON a.cd_prestador = c.cd_prestador
                WHERE
                        a.cd_multi_empresa = 1 /* HBDF */
                    AND a.tp_atendimento = 'I' /* apenas internação */
                    AND TO_DATE(a.dt_alta) BETWEEN TO_DATE($PgIgesdfDtInicial$) AND TO_DATE($PgIgesdfDtFim$) + 0.99999 /* FILTRO DE DATA */
 -- ==================================
 -- FIM - ATENDIMENTOS COM ALTA MÉDICA
 -- ==================================
            ) atend
            JOIN mov_int  mov ON atend.cd_atendimento = mov.cd_atendimento
            JOIN leito ON atend.cd_leito = leito.cd_leito
            JOIN (
 -- ===================================
 -- INCIO - UNID INT COM FILTRO INTERNO
 -- ===================================
                SELECT
                    a.cd_unid_int,
                    a.ds_unid_int
                FROM
                         unid_int a
                    JOIN setor b ON a.cd_setor = b.cd_setor
                WHERE
                        b.cd_multi_empresa = 1 /* HBDF */
                    AND a.cd_unid_int IN ( $PgHBDFUnidInternacao$) /*- FILTRO UNID INT -*/
 -- =================================
 -- FIM - UNID INT COM FILTRO INTERNO
 -- =================================
            )        unid_int ON leito.cd_unid_int = unid_int.cd_unid_int
            LEFT JOIN log_cid ON atend.cd_atendimento = log_cid.cd_atendimento
            LEFT JOIN (
 -- =================================
 -- INICIO - REGISTROS DE ALTA MÉDICA
 -- PARA COMPROVAÇÃO
 -- =================================
                SELECT
                    cd_registro_alta,
                    cd_atendimento,
                    cd_mot_alt
                FROM
                    pw_registro_alta
                WHERE
                    tp_situacao = 'FECHADA' /* apenas prontuário de alta fechado */
 -- ==============================
 -- FIM - REGISTROS DE ALTA MÉDICA
 -- PARA COMPROVAÇÃO
 -- ==============================
            )        reg_alta ON atend.cd_atendimento = reg_alta.cd_atendimento
            LEFT JOIN paciente pac ON atend.cd_paciente = pac.cd_paciente
            LEFT JOIN (
 -- =============================================
 -- INICIO - ITENS DE PRESCRIÇÃO PARA COMPROVAÇÃO
 -- =============================================
                SELECT
                    a.cd_pre_med,
                    a.cd_atendimento
                FROM
                         pre_med a
                    JOIN (
                        SELECT
                            cd_pre_med,
                            cd_itpre_med
                        FROM
                            itpre_med
                        WHERE
                            cd_tip_esq IN ( 'MAT', 'MAV', 'MCC', 'MCE', 'MDA',
                                            'MDC', 'MDN', 'MDO', 'MDU', 'MNP',
                                            'MVE', 'SOR' ) /* Esquema de prescrição com medicamento */
                            AND nvl(sn_cancelado, 'N') = 'N' /* sem cancelados */
                    ) b ON a.cd_pre_med = b.cd_pre_med
 -- ==========================================
 -- FIM - ITENS DE PRESCRIÇÃO PARA COMPROVAÇÃO
 -- ==========================================
            )        presc ON atend.cd_atendimento = presc.cd_atendimento
-- =============================================
-- FIM - STATUS PACIENTES E PRONTUÁRIO DETALHADO
-- =============================================
    )
ORDER BY
    dt_alta