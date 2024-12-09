SELECT
--tl = total
COUNT(dt_cadastro_manual) AS tl_cadastro_manual,
--COUNT(cadastro.hr_cadastro)        AS tl_cadastro,
COUNT(CASE WHEN situacao = 0 THEN 0 END)AS tl_cpf_incompletos,
COUNT(CASE WHEN situacao = 1 THEN 1 END) AS tl_cns_incompletos,
--COUNT(CASE WHEN pac.situacao = 2 THEN 2 END) AS tl_id_incompletos,
COUNT(CASE WHEN situacao = 3 THEN 3 END) AS tl_doc_completos,

--SETOR e ATENDIMENTO
SUM(CASE WHEN ds_ori_ate = 'SEM ATENDIMENTO' THEN 1 ELSE 0 END)AS tl_ate_incompletos,
SUM(CASE WHEN ds_ser_dis = 'SEM ATENDIMENTO' THEN 1 ELSE 0 END)AS tl_ser_incompletos,
SUM(CASE WHEN ds_ori_ate = 'SEM ATENDIMENTO' AND ds_ser_dis = 'SEM ATENDIMENTO' THEN 1 ELSE 0 END)AS tl_ate_ser_incompletos,
SUM(CASE WHEN ds_ori_ate IS NOT NULL AND ds_ser_dis IS NOT NULL THEN 1 ELSE 0 END)AS tl_ate_ser_completo,

--CADASTROS ALTERADOS             
SUM(CASE WHEN cadastros_alterados = 'CADASTRO ALTERADO' THEN 1 ELSE 0 END) AS tl_cadastros_alterados,
SUM(CASE WHEN cadastros_alterados = 'CADASTRO NÃO ALTERADO' THEN 1 ELSE 0 END) AS tl_cadastros_nao_alterados,
SUM(CASE WHEN cadastros_alterados = 'INCONSISTENCIA' THEN 1 ELSE 0 END) AS tl_cadastros_inconsistentes,
            
--CADASTROS ALTERADOS
SUM(CASE WHEN situacao IN (0,1) 
    AND ds_ori_ate IS NULL OR ds_ser_dis IS NULL
    AND TRUNC (dt_cadastro_manual) != TRUNC(dt_ultima_atualizacao) THEN 1 ELSE 0 END) AS cad_alt_incompletos,
SUM(CASE WHEN situacao = 3 
    AND ds_ori_ate IS NOT NULL 
    AND ds_ser_dis IS NOT NULL
    AND TRUNC (dt_cadastro_manual) != TRUNC(dt_ultima_atualizacao) THEN 1 ELSE 0 END) AS cad_alt_completos,
            
--CADASTROS NAO ALTERADOS
SUM(CASE WHEN situacao IN (0,1) 
    AND ds_ori_ate IS NULL OR ds_ser_dis IS NULL
    AND TRUNC (dt_cadastro_manual) = TRUNC(dt_ultima_atualizacao) 
    OR dt_ultima_atualizacao IS NULL THEN 1 ELSE 0 END) AS cad_nao_alt_incompletos,
SUM(CASE WHEN cadastro.situacao = 3 
    AND ds_ori_ate IS NOT NULL 
    AND ds_ser_dis IS NOT NULL
    AND TRUNC (dt_cadastro_manual) = TRUNC(dt_ultima_atualizacao) 
    OR dt_ultima_atualizacao IS NULL THEN 1 ELSE 0 END) AS cad_nao_alt_completos
FROM(
    SELECT
        paciente.cd_paciente              cod,
        paciente.nm_paciente              nomepac,
        paciente.dt_cadastro_manual,
        paciente.dh_cadastro,
        paciente.dt_ultima_atualizacao,
        paciente.nr_cpf                   cpf,
        paciente.nr_cns                   cns,
        paciente.nm_usuario               usuariocad,
        nvl(atendime.tp_atendimento, 'A') tipoatend,
        ori.cd_ori_ate,
        CASE
            WHEN atendime.tp_atendimento IN ( 'A', 'U', 'E' ) THEN 
                ori.ds_ori_ate 
            WHEN atendime.tp_atendimento = 'I' THEN
                ori.ds_ori_ate
                || ' '
                || ser.ds_ser_dis
            WHEN ds_ori_ate IS NULL
                 AND ds_ser_dis IS NULL THEN
                'SEM ATENDIMENTO'
        END                               AS setor,
        paciente.ds_multi_empresa         empresa,
        COALESCE(ori.ds_ori_ate, 'SEM ATENDIMENTO') AS ds_ori_ate,
        COALESCE(ser.ds_ser_dis, 'SEM ATENDIMENTO') AS ds_ser_dis,
        situacao,
        cadastros_alterados
    FROM
        (
            SELECT
                pac.cd_paciente,
                pac.nm_paciente,
                pac.nr_cpf,
                pac.nr_cns,
                pac.dt_cadastro_manual,
                to_char(pac.dt_cadastro_manual, 'DD/MM/YYYY')
                || ' '
                || to_char(pac.hr_cadastro, 'HH24:MI:SS') AS dh_cadastro,
                pac.dt_ultima_atualizacao,
                u.nm_usuario,
                e.ds_multi_empresa,
                situacao,
                cadastros_alterados
            FROM
                     (
                    SELECT
                        p.cd_paciente,
                        p.nm_paciente,
                        p.dt_cadastro_manual,
                        p.hr_cadastro,
                        p.dt_ultima_atualizacao,
                        p.nr_cpf,
                        p.nr_identidade,
                        p.nr_cns,  
                        p.nm_usuario,
                        p.cd_multi_empresa,
                        p.nm_usuario_ultima_atualizacao, 
                        
                        CASE
                            WHEN p.nr_cpf IS NULL THEN 0
                            WHEN p.nr_cns IS NULL THEN 1
                            --WHEN p.nr_identidade IS NULL THEN 2
                            ELSE 3
                        END AS situacao,
                        CASE
                            WHEN TRUNC(p.dt_cadastro_manual) != TRUNC (p.dt_ultima_atualizacao) THEN
                                'CADASTRO ALTERADO'
                            WHEN TRUNC (p.dt_cadastro_manual) = TRUNC(p.dt_ultima_atualizacao) OR p.dt_ultima_atualizacao IS NULL THEN
                                'CADASTRO NÃO ALTERADO'
                            ELSE
                                'INCONSISTENCIA'
                            END AS cadastros_alterados
                    FROM
                        dbamv.paciente p
                    WHERE
                        trunc(p.dt_cadastro_manual) BETWEEN TO_DATE('01/01/2023') AND TO_DATE('16/08/2024')
                        AND p.cd_multi_empresa IN ( 1, 2 )
                ) pac
                JOIN dbasgu.usuarios      u ON pac.nm_usuario = u.cd_usuario
                JOIN dbamv.multi_empresas e ON pac.cd_multi_empresa = e.cd_multi_empresa
            WHERE
                1 = 1
                /*situacao IN(0, 1)*/
                --pac.situacao = 0
            ORDER BY
                e.ds_multi_empresa,
                u.nm_usuario   
        )              paciente
        LEFT JOIN (
            SELECT
                MIN(cd_atendimento) AS cd_atendimento,
                cd_paciente
            FROM
                dbamv.atendime
            WHERE
                cd_multi_empresa IN ( 1, 2 )
            GROUP BY
                cd_paciente
        )              min_atendimento ON paciente.cd_paciente = min_atendimento.cd_paciente
        LEFT JOIN dbamv.atendime atendime ON min_atendimento.cd_atendimento = atendime.cd_atendimento
        LEFT JOIN dbamv.ori_ate  ori ON atendime.cd_ori_ate = ori.cd_ori_ate
        LEFT JOIN dbamv.ser_dis  ser ON atendime.cd_ser_dis = ser.cd_ser_dis
    )   cadastro