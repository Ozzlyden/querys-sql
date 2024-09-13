--IGESDF - Quantidade de GAE's Abertas por Turno UPAS -v2
--Acolhimento com Classificação de Risco por Cor
SELECT
    *
FROM
    (
        SELECT
            b.ds_multi_empresa,
            $PgIgesdfDtInicial$ DT_IN,
            $PgIgesdfDtFim$ DT_FIM, 
            nvl(COUNT(*),0) AS total,
            CASE
                WHEN TO_DATE(to_char(a.dh_pre_atendimento, 'hh24:MI'),
            'hh24:MI') BETWEEN TO_DATE('06:00', 'hh24:MI') AND TO_DATE('11:59', 'hh24:MI') THEN
                    'MATUTINO'
                WHEN TO_DATE(to_char(a.dh_pre_atendimento, 'hh24:MI'),
            'hh24:MI') BETWEEN TO_DATE('12:00', 'hh24:MI') AND TO_DATE('17:59', 'hh24:MI') THEN
                    'VESPERTINO'
                WHEN TO_DATE(to_char(a.dh_pre_atendimento, 'hh24:MI'),
            'hh24:MI') BETWEEN TO_DATE('18:00', 'hh24:MI') AND TO_DATE('23:59', 'hh24:MI') THEN
                    'NOTURNO'
                WHEN TO_DATE(to_char(a.dh_pre_atendimento, 'hh24:MI'),
            'hh24:MI') BETWEEN TO_DATE('00:00', 'hh24:MI') AND TO_DATE('05:59', 'hh24:MI') THEN
                    'MADRUGADA'
                ELSE
                    to_char(a.dh_pre_atendimento, 'dd/mm/yyyy hh24:mi:ss')
            END    turno
        FROM
            dbamv.triagem_atendimento a,
            dbamv.multi_empresas      b,
            dbamv.atendime            c,
            dbamv.sacr_cor_referencia d
        WHERE
                a.cd_multi_empresa = b.cd_multi_empresa
            AND d.cd_cor_referencia = a.cd_cor_referencia
            AND a.cd_multi_empresa IN ( '3', '4', '5', '6', '7','8', '12', '13', '14', '15', '16', '17', '18' )
            --and a.cd_multi_empresa = #empresa#
            AND a.cd_atendimento = c.cd_atendimento (+)
            AND to_char(a.dh_pre_atendimento, 'DD/MM/RRRR') BETWEEN TO_DATE($PgIgesdfDtInicial$) AND TO_DATE($PgIgesdfDtFim$) + 0.99999
            --AND EXISTS ( select X.cd_fila_senha from FILA_SENHA_MULTI_EMPRESAS X WHERE X.cd_fila_senha = a.cd_fila_senha)
            --AND EXISTS ( SELECT X.cd_fila_senha from FILA_SENHA x where x.cd_fila_senha = a.cd_fila_senha and cd_multi_empresa in (17,18))
        GROUP BY
            b.ds_multi_empresa,
            CASE
                    WHEN TO_DATE(to_char(a.dh_pre_atendimento, 'hh24:MI'),
            'hh24:MI') BETWEEN TO_DATE('06:00', 'hh24:MI') AND TO_DATE('11:59', 'hh24:MI') THEN
                        'MATUTINO'
                    WHEN TO_DATE(to_char(a.dh_pre_atendimento, 'hh24:MI'),
            'hh24:MI') BETWEEN TO_DATE('12:00', 'hh24:MI') AND TO_DATE('17:59', 'hh24:MI') THEN
                        'VESPERTINO'
                    WHEN TO_DATE(to_char(a.dh_pre_atendimento, 'hh24:MI'),
            'hh24:MI') BETWEEN TO_DATE('18:00', 'hh24:MI') AND TO_DATE('23:59', 'hh24:MI') THEN
                        'NOTURNO'
                    WHEN TO_DATE(to_char(a.dh_pre_atendimento, 'hh24:MI'),
            'hh24:MI') BETWEEN TO_DATE('00:00', 'hh24:MI') AND TO_DATE('05:59', 'hh24:MI') THEN
                        'MADRUGADA'
                    ELSE
                        to_char(a.dh_pre_atendimento, 'dd/mm/yyyy hh24:mi:ss')
            END
    )
ORDER BY 1