--HBDF - Cadastros de Pacientes Incompletos Por Dia (Original)
SELECT
    cod,
    nomepac,
    dh_cadastro,
    cpf,
    cns,
    usuariocad,
    tipoatend,
    setor,
    empresa,
    ds_ori_ate,
    ds_ser_dis
FROM
    (
        SELECT
            paciente.cd_paciente              cod,
            paciente.nm_paciente              nomepac,
            paciente.dh_cadastro,
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
                WHEN ds_ori_ate IS NULL AND ds_ser_dis IS NULL THEN 'SEM ATENDIMENTO'
            END                               AS setor,
            paciente.ds_multi_empresa         empresa,
            CASE WHEN ds_ori_ate IS NULL THEN 'SEM ATENDIMENTO' ELSE ds_ori_ate END AS ds_ori_ate,
            CASE WHEN ds_ser_dis IS NULL THEN 'SEM ATENDIMENTO' ELSE ds_ser_dis END AS ds_ser_dis
        FROM
            (--QUERY
                SELECT
                    pac.cd_paciente,
                    pac.nm_paciente,
                    pac.nr_cpf,
                    pac.nr_cns,
                    to_char(pac.dt_cadastro_manual, 'DD/MM/YYYY')
                    || ' '
                    || to_char(pac.hr_cadastro, 'HH24:MI:SS') AS dh_cadastro,
                    u.nm_usuario,
                    e.ds_multi_empresa
                FROM
                         (
                        SELECT
                            p.cd_paciente,
                            p.nm_paciente,
                            p.dt_cadastro_manual,
                            p.hr_cadastro,
                            p.nr_cpf,
                            p.nr_cns,
                            p.nm_usuario,
                            p.cd_multi_empresa,
                            CASE
                                WHEN p.nr_cpf IS NULL THEN
                                    0
                                WHEN p.nr_cns IS NULL THEN
                                    0
                                ELSE
                                    1
                            END AS situacao
                        FROM
                            dbamv.paciente p
                        WHERE
                            trunc(p.dt_cadastro_manual)BETWEEN TO_DATE( $PgIgesdfDtInicial$ ) AND TO_DATE( $PgIgesdfDtFim$ )
                            AND p.cd_multi_empresa IN ($EmpresasIGESDF$) 
                    ) pac
                    JOIN dbasgu.usuarios      u ON pac.nm_usuario = u.cd_usuario
                    JOIN dbamv.multi_empresas e ON pac.cd_multi_empresa = e.cd_multi_empresa
                WHERE
                    pac.situacao = 0
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
                    cd_multi_empresa IN ($EmpresasIGESDF$) 
                GROUP BY
                    cd_paciente
            )              min_atendimento ON paciente.cd_paciente = min_atendimento.cd_paciente
            LEFT JOIN dbamv.atendime atendime ON min_atendimento.cd_atendimento = atendime.cd_atendimento
            LEFT JOIN dbamv.ori_ate  ori ON atendime.cd_ori_ate = ori.cd_ori_ate
            LEFT JOIN dbamv.ser_dis  ser ON atendime.cd_ser_dis = ser.cd_ser_dis
    )
where tipoatend IN ($tpOrigemPapai$) 
and (ds_ser_dis IN ($tpOrigemFilhote$) or ds_ori_ate IN ($tpOrigemFilhote$))