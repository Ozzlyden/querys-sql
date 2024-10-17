--Painel -UPAVP - Drill Kanban Média de Permanência dos Pacientes Motivo de Alta - Origem
SELECT
*
FROM(SELECT 
 cd_unid_int
 , DECODE(
 ds_unid_int ,
 'SALA ESTABILIZACAO', 'SALA VERMELHA',
 'SALA ISOLAMENTO', 'SALA AMARELA ISO',
 'SALA OBSERVACAO', 'SALA AMARELA',
 'SALA MEDICACAO', 'SALA VERDE'
 ) AS ds_unid_int

 , COUNT(*) altas_unid_int
 , cd_mot_alt
 , ds_tip_res 
 , COUNT(*) total_altas
FROM
(SELECT cd_atendimento
 , nm_paciente
 , dt_atendimento
 , dt_alta_medica
 , dt_alta
 , ds_unid_int
 , cd_unid_int
 , CASE WHEN cd_mot_alt IS NULL THEN 0 ELSE cd_mot_alt END cd_mot_alt
 , CASE WHEN ds_tip_res IS NULL THEN 'PACIENTE QUE NÃO RECEBERAM ALTA' ELSE ds_tip_res END ds_tip_res
 , cd_multi_empresa
 FROM (SELECT a.cd_atendimento
 , p.nm_paciente
 , dt_atendimento
 , dt_alta_medica
 , dt_alta
 , CASE WHEN ds_unid_int IS NULL THEN 'SEM UNIDADE DE INTERNACAO' ELSE ds_unid_int END ds_unid_int
 , CASE WHEN g.cd_unid_int IS NULL THEN 0 ELSE g.cd_unid_int END cd_unid_int
 , ds_tip_res
 , a.cd_multi_empresa
 ,CASE WHEN a.cd_mot_alt IS NULL THEN a.cd_tip_res ELSE a.cd_mot_alt end as cd_mot_alt
 FROM atendime a
 INNER JOIN DBAMV.paciente p ON a.cd_paciente = p.cd_paciente
 INNER JOIN (SELECT * FROM DBAMV.triagem_atendimento WHERE cd_cor_referencia = 11) c ON a.cd_atendimento = c.cd_atendimento
 LEFT JOIN DBAMV.mot_alt d ON a.cd_mot_alt = d.cd_mot_alt
 LEFT JOIN DBAMV.tip_res e ON a.cd_tip_res = e.cd_tip_res
 LEFT JOIN (SELECT * FROM DBAMV.leito /*WHERE tp_situacao = 'A' AND sn_extra = 'N'*/) f ON a.cd_leito = f.cd_leito
 LEFT JOIN DBAMV.unid_int g ON f.cd_unid_int = g.cd_unid_int
 ) WHERE 1=1
 AND cd_multi_empresa IN (17) ----------> FILTRO DE EMPRESA <----------
 AND dt_atendimento between to_date( $PgIgesdfDtInicial$ ) AND to_date( $PgIgesdfDtFim$ ) + 0.99999 /*- FILTRO de Data -*/ 
 
 ORDER BY 3
 )
GROUP BY cd_unid_int, ds_unid_int, cd_mot_alt
 , ds_tip_res 
)
WHERE 1=1
AND cd_unid_int = #ALTAS#
