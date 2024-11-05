--HRSM - Relatório de Atendimentos Classificação
SELECT
    ds_pergunta_abordagem,
    ds_resposta_abordagem,
    COUNT(*) qtd
FROM
    (
        SELECT
            a.cd_triagem_atendimento,
            a.dh_pre_atendimento,
            a.cd_paciente,
            a.nm_paciente,
            a.cd_atendimento,
            ds_pergunta_abordagem,
            ds_resposta_abordagem
        FROM
                 triagem_atendimento a
            INNER JOIN sacr_perg_resp_abordagem b ON a.cd_triagem_atendimento = b.cd_triagem_atendimento
            INNER JOIN sacr_pergunta_abordagem  c ON b.cd_pergunta_abordagem = c.cd_pergunta_abordagem
            INNER JOIN sacr_resposta_abordagem  d ON b.cd_pergunta_abordagem = d.cd_pergunta_abordagem
                                                    AND b.cd_resposta_abordagem = d.cd_resposta_abordagem
        WHERE
                c.cd_multi_empresa = 2
            AND b.cd_pergunta_abordagem IN ( 1, 4 )
            --AND a.dh_pre_atendimento BETWEEN TO_DATE(@P_DATA_INI) AND TO_DATE(@P_DATA_FIM)+0.99999
            AND a.dh_pre_atendimento BETWEEN TO_DATE('01/06/2024') AND TO_DATE('30/06/2024')+0.99999
    )
GROUP BY
    ds_pergunta_abordagem,
    ds_resposta_abordagem