-- IDENTIFICAÇÃO DOS VALORES INCORRETOS ENTRE "HBDF - GEAMU - Gestão" e "HBDF - Farmácia Clínica"
SELECT a.*,
       tv.ds_unid_int,
       tv.dados,
       tv.mes,
       tv.contador
FROM (

    --TOTAL CONSULTA POR PRODUTIVIDADE
    SELECT DISTINCT
        a.cd_pre_med,
        TO_NUMBER(d.cd_procedimento_sia) AS cd_procedimento_sia,
        'CONSULTA FARMACIA' AS item_prescrito
    FROM dbamv.pre_med a
    INNER JOIN dbamv.atendime b ON a.cd_atendimento = b.cd_atendimento
    LEFT JOIN dbamv.itpre_med c ON a.cd_pre_med = c.cd_pre_med
    LEFT JOIN dbamv.tip_presc d ON c.cd_tip_presc = d.cd_tip_presc
    WHERE a.dt_pre_med BETWEEN TO_DATE('01/07/2024', 'DD/MM/YYYY') AND TO_DATE('31/07/2024', 'DD/MM/YYYY') + 0.99999
    AND NVL(c.sn_cancelado, 'N') = 'N'
    AND a.cd_prestador IN (
        SELECT cd_prestador
        FROM dbamv.prestador
        WHERE cd_tip_presta = 32
    )
    AND c.cd_tip_esq = 'PFC'
    AND d.cd_procedimento_sia IS NOT NULL
    AND b.cd_multi_empresa = 1
    ORDER BY cd_procedimento_sia DESC
) a
LEFT JOIN (

    --PAINEL GERENCIAL - Mes/ano
    SELECT DISTINCT
        ds_unid_int,
        '2 - Total Visitas com Prescrição' AS dados,
        EXTRACT(MONTH FROM hr_pre_med) AS mes,
        cd_pre_med,
        cd_pre_med AS contador
    FROM (
        SELECT
            pre_med.cd_unid_int,
            unid_int.ds_unid_int,
            pre_med.cd_atendimento,
            pre_med.cd_pre_med,
            pre_med.hr_pre_med
        FROM (
            -- INICIO - PRESCRIÇÕES DETALHADO
            SELECT
                a.cd_pre_med,
                a.cd_atendimento,
                a.hr_pre_med,
                a.cd_unid_int
            FROM pre_med a
            JOIN prestador b ON a.cd_prestador = b.cd_prestador
            WHERE TO_CHAR(a.dt_pre_med, 'yyyy') = 2024
            AND EXTRACT(MONTH FROM a.dt_pre_med) = 7
            AND b.cd_prestador IN (19664, 19578, 14909, 22080, 18570, 19616, 20778, 20751, 18544, 19696, 22618, 17482, 21931, 19837, 19583, 22606, 21056, 15481, 18543, 22082, 22609, 19882, 21669, 21923, 21866, 1559, 17066, 17480, 22608, 22624, 21274, 21968, 16786, 22623, 22796)
            AND a.cd_unid_int IN (170, 23, 157, 24, 26, 68, 11, 10, 4, 9, 8, 7, 6, 5, 3, 2, 12, 1, 171, 172, 173, 25, 174, 21, 22, 19, 20, 13, 18, 16, 15, 14, 17, 27, 28, 29)
        ) pre_med
        JOIN (
            -- INICIO - ITENS DA PRESCRIÇÃO DETALHADO
            SELECT
                a.cd_itpre_med,
                a.cd_pre_med,
                a.cd_tip_presc,
                b.ds_tip_presc,
                a.cd_tip_fre,
                c.ds_tip_fre,
                a.qt_itpre_med,
                a.ds_itpre_med
            FROM itpre_med a
            LEFT JOIN tip_presc b ON a.cd_tip_presc = b.cd_tip_presc
            LEFT JOIN tip_fre c ON a.cd_tip_fre = c.cd_tip_fre
            WHERE NVL(a.sn_cancelado, 'N') = 'N'
            AND a.cd_tip_esq = 'PFC'
        ) itpre_med ON pre_med.cd_pre_med = itpre_med.cd_pre_med
        JOIN (
            -- INICIO - DADOS PACIENTE E TIPO ATENDIMENTO
            SELECT
                cd_atendimento
            FROM atendime 
            WHERE cd_multi_empresa = 1
        ) atendime ON pre_med.cd_atendimento = atendime.cd_atendimento
        LEFT JOIN unid_int ON pre_med.cd_unid_int = unid_int.cd_unid_int
    ) total_visitas
) tv ON a.cd_pre_med = tv.cd_pre_med
ORDER BY
    tv.ds_unid_int,
    tv.mes,
    tv.contador
