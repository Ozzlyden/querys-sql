--Taxa de Ocupação Drill - Original
SELECT 
    *
FROM  
(SELECT DISTINCT
 a.cd_paciente,
 a.cd_atendimento,
 d.nm_paciente,
 DECODE(c.ds_unid_int, 'SALA ESTABILIZACAO', 'SALA VERMELHA', 'SALA ISOLAMENTO', 'SALA AMARELA ISO',
 'SALA OBSERVACAO', 'SALA AMARELA', 'SALA MEDICACAO', 'SALA VERDE') AS unid_int,
 c.cd_unid_int,
 b.ds_leito
 FROM
 atendime a
 INNER JOIN (
 SELECT
 cd_leito,
 ds_leito,
 cd_unid_int,
 tp_situacao,
 sn_extra
 FROM
 dbamv.leito
 ) b ON a.cd_leito = b.cd_leito
 LEFT JOIN (
 SELECT
 cd_unid_int,
 ds_unid_int
 FROM
 dbamv.unid_int
 ) c ON b.cd_unid_int = c.cd_unid_int
 INNER JOIN (
 SELECT
 nm_paciente,
 cd_paciente
 FROM
 dbamv.paciente
 ) d ON a.cd_paciente = d.cd_paciente
 INNER JOIN (
 SELECT
 cd_triagem_atendimento,
 cd_atendimento,
 cd_cor_referencia
 FROM
 dbamv.triagem_atendimento
 WHERE
 cd_cor_referencia = 11
 ) e ON a.cd_atendimento = e.cd_atendimento
 WHERE
 cd_multi_empresa IN (17) ----------> FILTRO DE EMPRESA <----------
 AND dt_atendimento BETWEEN TO_DATE(#DT_INICIO#) AND TO_DATE(#DT_FIM#) + 0.99999
-- AND c.cd_unid_int IN (113,114,115,116,117) 
 AND b.tp_situacao = 'A'
-- AND b.sn_extra = 'N'
 )
WHERE unid_int = #CD_UNID_INT#
