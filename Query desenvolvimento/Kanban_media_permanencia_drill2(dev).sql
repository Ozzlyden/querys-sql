SELECT
    a.cd_paciente,
    e.nm_paciente,
    COUNT(a.cd_atendimento) AS qdt_atendimentos,
    SUM(a.qtd_dias_internados) AS qtd_dias_internados,
    MIN(TO_CHAR(a.dt_atendimento, 'dd/mm/yyyy')) AS Inicio_atendimento,
    MAX(TO_CHAR(a.dt_alta_medica, 'dd/mm/yyyy')) AS fim_atendimento,
    
    DECODE(
        ds_unid_int ,
        'SALA ESTABILIZACAO', 'SALA VERMELHA',
        'SALA ISOLAMENTO', 'SALA AMARELA ISO',
        'SALA OBSERVACAO', 'SALA AMARELA',
        'SALA MEDICACAO', 'SALA VERDE',
        'SALA PEDIATRIA', 'SALA PEDIATRIA'
    ) AS ds_unid_int,
    cd_mot_alt,
    ds_mot_alt,
    MAX(cd_unid_int) AS cd_unid_int
FROM (
    SELECT
        a.cd_paciente,
        e.nm_paciente,
        a.cd_atendimento,
        a.dt_atendimento,
        a.dt_alta_medica,
        d.ds_unid_int,
        d.cd_unid_int,
        CASE
            WHEN a.cd_mot_alt IS NULL THEN a.cd_tip_res
            ELSE a.cd_mot_alt
            END cd_mot_alt,
        CASE
            WHEN ds_mot_alt IS NULL THEN ds_tip_res
            ELSE ds_mot_alt
            END ds_mot_alt,
        ROW_NUMBER() OVER (PARTITION BY a.cd_paciente ORDER BY a.dt_atendimento) AS row_num,
        CEIL(NVL(NVL(a.hr_alta, a.hr_alta_medica), TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY')) - a.hr_atendimento) AS qtd_dias_internados -- Calculando os dias internados
        
    FROM atendime a
    INNER JOIN DBAMV.triagem_atendimento b ON a.cd_atendimento = b.cd_atendimento
    INNER JOIN DBAMV.leito c ON a.cd_leito = c.cd_leito
    INNER JOIN DBAMV.unid_int d ON c.cd_unid_int = d.cd_unid_int
    INNER JOIN DBAMV.paciente e ON a.cd_paciente = e.cd_paciente
    LEFT JOIN DBAMV.mot_alt f ON a.cd_mot_alt = f.cd_mot_alt
    LEFT JOIN DBAMV.tip_res g ON a.cd_tip_res = g.cd_tip_res
WHERE a.cd_multi_empresa IN (17) 
    AND a.dt_atendimento BETWEEN TO_DATE( $PgIgesdfDtInicial$ , 'DD/MM/YYYY') AND TO_DATE( $PgIgesdfDtFim$ )+0.99999
     AND (
        --Aplicar a lógica da data de corte
        (a.dt_atendimento < TO_DATE('01/08/2024', 'DD/MM/YYYY') AND b.cd_cor_referencia = 11)
        OR (a.dt_atendimento >= TO_DATE('01/08/2024', 'DD/MM/YYYY') AND a.cd_leito IS NOT NULL)
      )
) a
    INNER JOIN DBAMV.paciente e ON a.cd_paciente = e.cd_paciente

WHERE cd_mot_alt = #PACIENTES_ALTA#
AND cd_unid_int = #UNIDADE#

GROUP BY a.cd_paciente, e.nm_paciente, cd_unid_int, ds_unid_int, cd_mot_alt, ds_mot_alt
ORDER BY 4