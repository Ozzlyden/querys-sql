-- IGESDF - Quantidade de GAE's Abertas por Turno UPAS -v2 - DRILL
-- Acolhimento com Classificação de Risco por Cor
SELECT
    *
FROM
    (
        SELECT
            b.ds_multi_empresa,
            e.cd_paciente,
            e.nm_paciente,
            COUNT(*) AS total,
            
            CASE
                WHEN TO_CHAR(a.dh_pre_atendimento, 'hh24:MI') BETWEEN '06:00' AND '11:59' THEN
                    'MATUTINO'
                WHEN TO_CHAR(a.dh_pre_atendimento, 'hh24:MI') BETWEEN '12:00' AND '17:59' THEN
                    'VESPERTINO'
                WHEN TO_CHAR(a.dh_pre_atendimento, 'hh24:MI') BETWEEN '18:00' AND '23:59' THEN
                    'NOTURNO'
                WHEN TO_CHAR(a.dh_pre_atendimento, 'hh24:MI') BETWEEN '00:00' AND '05:59' THEN
                    'MADRUGADA'
                ELSE
                    TO_CHAR(a.dh_pre_atendimento, 'dd/mm/yyyy hh24:mi:ss')
            END AS turno
        FROM
            dbamv.triagem_atendimento a
        INNER JOIN dbamv.multi_empresas b ON a.cd_multi_empresa = b.cd_multi_empresa
        INNER JOIN dbamv.sacr_cor_referencia d ON d.cd_cor_referencia = a.cd_cor_referencia
        LEFT JOIN dbamv.atendime c ON a.cd_atendimento = c.cd_atendimento 
        INNER JOIN dbamv.paciente e ON e.cd_paciente = c.cd_paciente
        WHERE
            b.ds_multi_empresa = #empresa#
            AND TO_DATE(TO_CHAR(a.dh_pre_atendimento, 'DD/MM/YYYY'), 'DD/MM/YYYY') BETWEEN TO_DATE(#dt_inicial#, 'DD/MM/YYYY') 
            AND TO_DATE(#dt_final#, 'DD/MM/YYYY') + 0.99999
        GROUP BY
            b.ds_multi_empresa,
            e.cd_paciente,
            e.nm_paciente,
            CASE
                WHEN TO_CHAR(a.dh_pre_atendimento, 'hh24:MI') BETWEEN '06:00' AND '11:59' THEN
                    'MATUTINO'
                WHEN TO_CHAR(a.dh_pre_atendimento, 'hh24:MI') BETWEEN '12:00' AND '17:59' THEN
                    'VESPERTINO'
                WHEN TO_CHAR(a.dh_pre_atendimento, 'hh24:MI') BETWEEN '18:00' AND '23:59' THEN
                    'NOTURNO'
                WHEN TO_CHAR(a.dh_pre_atendimento, 'hh24:MI') BETWEEN '00:00' AND '05:59' THEN
                    'MADRUGADA'
                ELSE
                    TO_CHAR(a.dh_pre_atendimento, 'dd/mm/yyyy hh24:mi:ss')
            END
    )
ORDER BY
    1
