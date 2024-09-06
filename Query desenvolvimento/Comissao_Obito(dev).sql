--IGESDF - Comissão de Óbitos - Relatório Detalhado de Óbitos por Empresa v5 - Teste
SELECT
    ate.empresa,
    a.cd_atendimento atend,
    CASE 
        WHEN ate.cd_atendimento IS NULL THEN 'NÃO CONFORME'
        ELSE 'CONFORME'
    END AS status,
    a.nm_paciente paciente,
    a.dt_nascimento,
    a.idade,
    a.tp_sexo Sexo,
    a.endereco Endereço,
    a.nome_mae Nome_mae,
    ate.data_atendimento,
    ate.data_obito,
    a.cd_prestador Prestador,
    a.nm_prestador,
    ate.mot_alt_medic,
    ate.motivo_alta_hosp, 
    ate.nr_declaracao_obito,
    ate.cid,
    ate.local_obito,
    a.obs_obito,
    a.diag_ini_obs,
    a.diag_def_obs,
    a.dh_fechamento,
    a.resultado,
    a.qtd 
FROM
    (
        SELECT
            pdc.cd_atendimento,
            obito.resultado,
            diag_ini.diag_ini_obs,
            diag_def.diag_def_obs,
            obs.obs_obito,
            pdc.cd_prestador,
            pdc.nm_prestador,
            pdc.cd_documento_clinico,
            pdc.dh_fechamento,
            ROW_NUMBER() OVER(PARTITION BY pdc.cd_atendimento ORDER BY pdc.cd_documento_clinico DESC) AS qtd,
            pdc.tp_status,
            pdc.nm_paciente,
            pdc.dt_nascimento,
            pdc.idade,
            pdc.tp_sexo,
            pdc.endereco,
            pdc.nome_mae
        FROM
            (
                SELECT
                    e.nm_paciente,
                    TO_CHAR(e.dt_nascimento, 'dd/mm/yyyy') AS dt_nascimento,
                    TRUNC((c.dt_atendimento - NVL(e.dt_nascimento, c.dt_atendimento)) / 365.25) AS idade,
                    e.tp_sexo,
                    e.ds_endereco || '-' || e.nm_bairro || ' - ' || cidade.nm_cidade AS endereco,
                    e.nm_mae AS nome_mae,
                    a.cd_documento_clinico,
                    b.cd_editor_registro AS cd_registro,
                    a.cd_prestador,
                    d.nm_prestador,
                    a.cd_atendimento,
                    a.dh_fechamento,
                    a.tp_status
                FROM 
                    pw_documento_clinico a
                    JOIN pw_editor_clinico b ON a.cd_documento_clinico = b.cd_documento_clinico
                    JOIN atendime c ON a.cd_atendimento = c.cd_atendimento
                    JOIN prestador d ON a.cd_prestador = d.cd_prestador
                    JOIN paciente e ON c.cd_paciente = e.cd_paciente
                    LEFT JOIN dbamv.cidade cidade ON e.cd_cidade = cidade.cd_cidade
                WHERE
                    b.cd_documento IN (1002, 1029, 1194)
                    AND a.dh_documento BETWEEN TO_DATE('01/07/2024', 'DD/MM/YYYY') AND TO_DATE('31/07/2024', 'DD/MM/YYYY') + INTERVAL '1' SECOND
                    AND a.tp_status = 'FECHADO'
                    AND a.cd_atendimento IN (
                        SELECT cd_atendimento
                        FROM atendime
                        WHERE cd_multi_empresa = 18
                    )
            ) pdc
            LEFT JOIN (
                SELECT
                    DECODE(
                        TO_CHAR(ec.ds_identificador),
                        'rb_questao_obito_j_1', 'ÓBITO JUSTIFICADO',
                        'Metadado_P_277367_1', 'ÓBITO JUSTIFICADO',
                        'Metadado_P_277369_1', 'ÓBITO A ESCLARECER',
                        'rb_questao_obito_i_1', 'ÓBITO A ESCLARECER'
                    ) AS resultado,
                    TO_CHAR(erc.cd_registro) AS cd_registro
                FROM
                    editor_registro_campo erc
                    JOIN editor_campo ec ON erc.cd_campo = ec.cd_campo
                WHERE
                    ec.ds_identificador IN ('rb_questao_obito_j_1', 'rb_questao_obito_i_1', 'Metadado_P_277367_1', 'Metadado_P_277369_1')
                    AND TO_CHAR(erc.lo_valor) = 'true'
            ) obito ON pdc.cd_registro = obito.cd_registro
            LEFT JOIN (
                SELECT
                    RTRIM(SUBSTR(erc.lo_valor, 1, 300)) AS diag_ini_obs,
                    ec.ds_identificador,
                    TO_CHAR(erc.cd_registro) AS cd_registro
                FROM
                    editor_registro_campo erc
                    JOIN editor_campo ec ON erc.cd_campo = ec.cd_campo
                WHERE
                    ec.ds_identificador IN ('ct_diag_inicial_1', 'Metadado_P_228042_1', 'Metadado_P_277371_1')
            ) diag_ini ON pdc.cd_registro = diag_ini.cd_registro
            LEFT JOIN (
                SELECT
                    RTRIM(SUBSTR(erc.lo_valor, 1, 300)) AS diag_def_obs,
                    ec.ds_identificador,
                    TO_CHAR(erc.cd_registro) AS cd_registro
                FROM
                    editor_registro_campo erc
                    JOIN editor_campo ec ON erc.cd_campo = ec.cd_campo
                WHERE
                    ec.ds_identificador IN ('ct_diag_definitivo_1', 'Metadado_P_228044_1', 'Metadado_P_277373_1')
            ) diag_def ON pdc.cd_registro = diag_def.cd_registro
            LEFT JOIN (
                SELECT
                    RTRIM(SUBSTR(erc.lo_valor, 1, 300)) AS obs_obito,
                    TO_CHAR(erc.cd_registro) AS cd_registro
                FROM
                    editor_registro_campo erc
                    JOIN editor_campo ec ON erc.cd_campo = ec.cd_campo
                WHERE
                    ec.ds_identificador IN ('Metadado_P_220007_1', 'Metadado_P_226911_1', 'Metadado_P_277309_1')
            ) obs ON pdc.cd_registro = obs.cd_registro
    ) a
    LEFT JOIN (
        SELECT
            emp.ds_multi_empresa AS empresa,
            atend.cd_atendimento,
            TO_CHAR(atend.dt_atendimento, 'dd/mm/yyyy') AS data_atendimento,
            atend.dt_alta_medica AS data_obito,
            NVL(mot_alta.ds_mot_alt, res_alta.ds_tip_res) AS mot_alt_medic,
            NVL(mot_alta_ate.ds_mot_alt, res_alta_ate.ds_tip_res) AS motivo_alta_hosp,
            atend.nr_declaracao_obito,
            reg_alta.cd_cid,
            cid.ds_cid AS cid,
            NVL(NVL(unid.ds_unid_int, setor.nm_setor), lei.ds_leito) AS local_obito
        FROM
            (
                SELECT
                    cd_atendimento,
                    cd_paciente,
                    dt_atendimento,
                    dt_alta,
                    dt_alta_medica,
                    cd_multi_empresa,
                    nr_declaracao_obito,
                    cd_mot_alt,
                    cd_tip_res,
                    cd_leito
                FROM
                    dbamv.atendime
                WHERE
                    NVL(dt_alta_medica, dt_alta) BETWEEN TO_DATE('01/07/2024', 'DD/MM/YYYY') AND TO_DATE('31/07/2024', 'DD/MM/YYYY') + INTERVAL '1' SECOND
                    AND cd_multi_empresa = 18
                    AND cd_tip_res = 8
                UNION ALL
                SELECT
                    cd_atendimento,
                    cd_paciente,
                    dt_atendimento,
                    dt_alta,
                    dt_alta_medica,
                    cd_multi_empresa,
                    nr_declaracao_obito,
                    cd_mot_alt,
                    cd_tip_res,
                    cd_leito
                FROM
                    dbamv.atendime
                WHERE
                    NVL(dt_alta_medica, dt_alta) BETWEEN TO_DATE('01/07/2024', 'DD/MM/YYYY') AND TO_DATE('31/07/2024', 'DD/MM/YYYY') + INTERVAL '1' SECOND
                    AND cd_multi_empresa = 18
                    AND cd_mot_alt IN (
                        SELECT cd_mot_alt
                        FROM dbamv.mot_alt
                        WHERE ds_mot_alt LIKE '%BITO%'
                    )
            ) atend
            LEFT JOIN (
                SELECT
                    cd_atendimento,
                    cd_documento_clinico,
                    cd_cid,
                    cd_cid_obito,
                    cd_setor_obito,
                    cd_mot_alt
                FROM
                    pw_registro_alta
                WHERE
                    cd_documento_clinico IN (
                        SELECT cd_documento_clinico
                        FROM (
                            SELECT
                                cd_atendimento, MAX(cd_documento_clinico) AS cd_documento_clinico
                            FROM
                                pw_registro_alta
                            WHERE
                                cd_mot_alt IN (8, 41, 42, 43, 65, 67)
                                AND tp_situacao = 'FECHADA'
                            GROUP BY
                                cd_atendimento
                        )
                    )
            ) reg_alta ON atend.cd_atendimento = reg_alta.cd_atendimento
            INNER JOIN dbamv.paciente pct ON atend.cd_paciente = pct.cd_paciente
            INNER JOIN dbamv.multi_empresas emp ON atend.cd_multi_empresa = emp.cd_multi_empresa
            LEFT JOIN dbamv.mot_alt mot_alta ON reg_alta.cd_mot_alt = mot_alta.cd_mot_alt
            LEFT JOIN dbamv.tip_res res_alta ON reg_alta.cd_mot_alt = res_alta.cd_tip_res
            LEFT JOIN dbamv.mot_alt mot_alta_ate ON atend.cd_mot_alt = mot_alta_ate.cd_mot_alt
            LEFT JOIN dbamv.tip_res res_alta_ate ON atend.cd_mot_alt = res_alta_ate.cd_tip_res
            LEFT JOIN dbamv.cid cid ON reg_alta.cd_cid_obito = cid.cd_cid
            LEFT JOIN dbamv.setor setor ON reg_alta.cd_setor_obito = setor.cd_setor
            LEFT JOIN dbamv.leito lei ON atend.cd_leito = lei.cd_leito
            LEFT JOIN dbamv.unid_int unid ON lei.cd_unid_int = unid.cd_unid_int
    ) ate ON a.cd_atendimento = ate.cd_atendimento
