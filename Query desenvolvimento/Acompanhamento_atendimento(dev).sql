--Painel assistencial medicamentos / HBDF - Status paciente
SELECT
    dt_atendimento,
    dt_alta_medica,
    dt_alta,
    cd_atendimento,
    nm_paciente,
    dt_nascimento,
    consulta_status,
    prescricao_medicacao,
    cd_atendime,
    exame_laboratorio,
    retorno_consulta
FROM
    (
        SELECT
            to_char(a.dt_atendimento, 'dd/mm/yyyy') AS dt_atendimento,
            to_char(a.dt_alta_medica, 'dd/mm/yyyy') AS dt_alta_medica,
            to_char(a.dt_alta, 'dd/mm/yyyy')        AS dt_alta,
            a.cd_atendimento                        AS cd_atendimento,
            obter_iniciais(c.nm_paciente)           AS nm_paciente,
            to_char(c.dt_nascimento, 'dd/mm/yyyy')  AS dt_nascimento,
            CASE
                WHEN b.dh_processo IS NOT NULL THEN
                    'EM ATENDIMENTO'
                
                WHEN a.dt_alta_medica IS NOT NULL  
                     OR a.dt_alta IS NOT NULL THEN
                    'FINALIZADO'
                ELSE
                    'AGUARDANDO'
            END                                     AS consulta_status,
            CASE
                /*WHEN a.hr_agenda BETWEEN sysdate - 1 AND sysdate AND sn_em_atendimento = 'N' THEN
                     'AGUARDANDO RETORNO'
                WHEN a.hr_agenda BETWEEN sysdate - 1 AND sysdate AND falta = 'N' THEN
                    'EM ATENDIMENTO'
                WHEN hr_fim_agenda IS NOT NULL OR atendido = 'S' THEN
                    'ATENDIMENTO REALIZADO'
                ELSE
                    NULL*/
                
                --CONSULTA DE RETORNO
                WHEN a.dt_atendimento BETWEEN sysdate - 1 AND sysdate AND sn_em_atendimento = 'N' AND cd_tip_mar = 2 THEN
                    'AGUARDANDO RETORNO'
                WHEN a.dt_atendimento BETWEEN sysdate - 1 AND sysdate AND cd_tip_mar = 2 THEN
                    'EM ATENDIMENTO'
                WHEN a.dt_atendimento BETWEEN sysdate - 1 AND sysdate AND cd_tip_mar = 2 AND a.dt_alta_medica IS NOT NULL
                    OR a.dt_alta IS NOT NULL THEN
                    'ATENDIMENTO REALIZADO'
                ELSE
                    NULL
                
            END                                     AS retorno_consulta,
                
            ( 
                SELECT
                    CASE
                        WHEN total_presc = total_presc_htitconsta THEN
                            'MEDICADO'
                        ELSE
                            'AGUARDANDO'
                    END
                FROM
                    (
                        SELECT
                            presc.cd_atendimento AS cd_atendimento,
                            total_presc,
                            total_presc_htitconsta
                        FROM
                                 (
                                SELECT
                                    cd_atendimento,
                                    COUNT(cd_itpre_med) AS total_presc
                                FROM
                                    (
                                        SELECT
                                            cd_itpre_med,
                                            cd_tip_esq,
                                            cd_tip_presc,
                                            a.cd_pre_med,
                                            cd_tip_fre,
                                            pre.cd_atendimento
                                        FROM
                                                 itpre_med a
                                            INNER JOIN (
                                                SELECT
                                                    *
                                                FROM
                                                    dbamv.pre_med
                                                WHERE
                                                    dt_pre_med BETWEEN sysdate - 1 AND sysdate
                                            ) pre ON a.cd_pre_med = pre.cd_pre_med
                                        WHERE
                                                nvl(sn_cancelado, 'N') = 'N'
                                            AND cd_tip_esq IN ( 'MNP', 'MVE', 'MDA', 'MAT', 'MCE',
                                                                'MCC', 'MDC', 'MAV', 'MEO', 'MEA',
                                                                'MGS', 'MDN', 'MDU', 'MDO' )
                                    )
                                GROUP BY
                                    cd_atendimento
                            ) presc
                            INNER JOIN (
                                SELECT
                                    cd_atendimento,
                                    COUNT(cd_itpre_med) AS total_presc_htitconsta
                                FROM
                                    hritpre_med
                                WHERE
                                    dh_medicacao BETWEEN sysdate - 1 AND sysdate
                                GROUP BY
                                    cd_atendimento
                            ) htitconsta ON presc.cd_atendimento = htitconsta.cd_atendimento
                        WHERE
                            a.cd_atendimento = presc.cd_atendimento
                    )
            )                                       AS prescricao_medicacao
        FROM
            atendime a
            LEFT JOIN (
                SELECT
                    cd_atendimento,
                    cd_tipo_tempo_processo,
                    dh_processo
                FROM
                    dbamv.sacr_tempo_processo
                WHERE
                    cd_atendimento IS NOT NULL
                    AND cd_tipo_tempo_processo = 30
            )        b ON a.cd_atendimento = b.cd_atendimento
            INNER JOIN (
                SELECT
                    cd_paciente,
                    nm_paciente,
                    dt_nascimento
                FROM
                    dbamv.paciente
            )        c ON a.cd_paciente = c.cd_paciente
            /*LEFT JOIN ( 
                SELECT
                    ac.cd_agenda_central,
                    ac.cd_atendimento,
                    ac.cd_paciente,
                    ac.hr_agenda,
                    ac.hr_fim,
                    ac.sn_atendido AS atendido,
                    agc.dt_agenda,
                    agc.hr_inicio,
                    agc.hr_fim AS hr_fim_agenda,
                    agc.sn_falta AS falta
                FROM
                    dbamv.it_agenda_central ac
                    INNER JOIN dbamv.agenda_central agc ON ac.cd_agenda_central = agc.cd_agenda_central
            )       d ON a.cd_atendimento = d.cd_atendimento*/
        WHERE
                a.cd_multi_empresa = 1
            AND a.tp_atendimento = 'U'
            AND a.dt_atendimento BETWEEN sysdate - 1 AND sysdate
            AND a.cd_procedimento <> 0301060029
    ) atend
    LEFT JOIN (
        SELECT
            cd_atendimento AS cd_atendime,
            CASE
                WHEN total_presc = total_itped_lab THEN
                    'RESULTADO DISPONIVEL'
                ELSE
                    'AGUARDANDO'
            END            exame_laboratorio
        FROM
            (
                SELECT
                    total_itpresc.cd_atendimento,
                    total_presc,
                    total_itped_lab
                FROM
                         (
                        SELECT
                            cd_atendimento,
                            COUNT(cd_itpre_med) AS total_presc
                        FROM
                            (
                                SELECT
                                    cd_itpre_med,
                                    cd_tip_esq,
                                    cd_tip_presc,
                                    a.cd_pre_med,
                                    cd_tip_fre,
                                    pre.cd_atendimento
                                FROM
                                         itpre_med a
                                    INNER JOIN (
                                        SELECT
                                            *
                                        FROM
                                            dbamv.pre_med
                                        WHERE
                                            dt_pre_med BETWEEN sysdate - 1 AND sysdate
                                    ) pre ON a.cd_pre_med = pre.cd_pre_med
                                WHERE
                                        nvl(sn_cancelado, 'N') = 'N'
                                    AND cd_tip_esq IN ( 'EXL', 'EXE' )
                            )
                        GROUP BY
                            cd_atendimento
                    ) total_itpresc
                    INNER JOIN (
                        SELECT
                            cd_atendimento,
                            COUNT(cd_itped_lab) AS total_itped_lab
                        FROM
                            (
                                SELECT
                                    a.cd_ped_lab,
                                    a.cd_atendimento,
                                    a.cd_pre_med,
                                    b.cd_itped_lab
                                FROM
                                         ped_lab a
                                    INNER JOIN dbamv.itped_lab b ON a.cd_ped_lab = b.cd_ped_lab
                                    INNER JOIN dbamv.pre_med   c ON a.cd_pre_med = c.cd_pre_med
                                    INNER JOIN dbamv.atendime  c ON a.cd_atendimento = c.cd_atendimento
                                WHERE
                                        b.sn_laudo_cadastrado = 'S'
                                    AND c.dt_pre_med BETWEEN sysdate - 1 AND sysdate
                                    AND c.cd_multi_empresa = 1
                            )
                        GROUP BY
                            cd_atendimento
                    ) total_itped_lab ON total_itpresc.cd_atendimento = total_itped_lab.cd_atendimento
            )
    ) exa ON atend.cd_atendimento = exa.cd_atendime
WHERE
    nvl(dt_alta_medica, dt_alta) IS NULL