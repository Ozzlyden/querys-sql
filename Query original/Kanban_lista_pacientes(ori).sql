--Painel - Kanban - lista pacientes - Original
WITH etapa_atendimento AS (SELECT
    a.cd_paciente,
    g.nm_paciente,
    a.cd_atendimento,
    TO_CHAR(a.dt_atendimento, 'dd/mm/yyyy') AS dt_atendimento,
    TO_CHAR(a.dt_alta_medica,'dd/mm/yyyy') AS dt_alta_medica,
    ROW_NUMBER() OVER (PARTITION BY a.cd_paciente ORDER BY a.dt_atendimento) AS Numero_linhas,
    DECODE
        (ds_unid_int, 'SALA ESTABILIZACAO', 'SALA VERMELHA', 'SALA ISOLAMENTO', 'SALA AMARELA ISO', 
        'SALA OBSERVACAO', 'SALA AMARELA', 'SALA MEDICACAO', 'SALA VERDE') AS ds_unid_int,
    d.cd_unid_int,
    CASE 
        WHEN a.cd_mot_alt IS NULL THEN a.cd_tip_res ELSE a.cd_mot_alt END AS cd_mot_alt
FROM atendime a
    INNER JOIN (SELECT * FROM triagem_atendimento WHERE cd_cor_referencia = 11 ) b ON a.cd_atendimento = b.cd_atendimento 
    INNER JOIN DBAMV.leito c ON a.cd_leito = c.cd_leito
    INNER JOIN DBAMV.unid_int d ON c.cd_unid_int = d.cd_unid_int
    LEFT JOIN DBAMV.mot_alt e ON a.cd_mot_alt = e.cd_mot_alt
    LEFT JOIN DBAMV.tip_res f ON a.cd_tip_res = f.cd_tip_res
    LEFT JOIN DBAMV.paciente g ON a.cd_paciente = g.cd_paciente
WHERE a.cd_multi_empresa IN (17) ---------------> UPAVP <---------------
--AND a.cd_paciente = 4020599
AND a.dt_atendimento BETWEEN TO_DATE( $PgIgesdfDtInicial$ ) AND TO_DATE(TO_CHAR( $PgIgesdfDtFim$ ))+0.99999
--AND d.cd_unid_int = 114
--AND (CASE WHEN a.cd_mot_alt IS NULL THEN a.cd_tip_res ELSE a.cd_mot_alt END) = 21

),
 blocos_pacientes AS (
 SELECT
 cd_paciente,
 nm_paciente,
 cd_atendimento,
 dt_atendimento,
 dt_atendimento - NUMTODSINTERVAL ((numero_linhas - 1), 'DAY') AS GRP,
 ds_unid_int,
 cd_unid_int
 FROM etapa_atendimento
 )
 SELECT
 cd_paciente,
 nm_paciente,
 MIN(dt_atendimento) AS Inicio_atendimento,
 MAX(dt_atendimento) AS Fim_atendimento,
 COUNT(*) AS qtd_dias_internado,
 ds_unid_int,
 cd_unid_int

 FROM blocos_pacientes
 GROUP BY cd_paciente, nm_paciente,  ds_unid_int, cd_unid_int
 ORDER BY 2,3
