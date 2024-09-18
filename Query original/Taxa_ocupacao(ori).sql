--Taxa de Ocupação - Original
WITH Resultado AS (
 SELECT
 pacientes.cd_unid_int, 
 unid_int,
 qtd_pacientes,
 leitos_oficiais,
 TO_CHAR(TO_DATE( $PgIgesdfDtFim$  , 'DD/MM/YYYY') - TO_DATE( $PgIgesdfDtInicial$ , 'DD/MM/YYYY')) +1 AS dias_entre_datas,
 ROUND((qtd_pacientes * 100)/ ((TO_CHAR(TO_DATE( $PgIgesdfDtFim$  , 'DD/MM/YYYY') - TO_DATE( $PgIgesdfDtInicial$  , 'DD/MM/YYYY')) +1)*leitos_oficiais),2) AS Taxa_ocupacao,
$PgIgesdfDtInicial$dt_inicio,
$PgIgesdfDtFim$dt_fim
 FROM
 (
 SELECT
 cd_unid_int,
 unid_int,
 COUNT(cd_atendimento) AS qtd_pacientes
 FROM
 (
 SELECT DISTINCT
 a.cd_paciente,
 a.cd_atendimento,
 DECODE(c.ds_unid_int, 'SALA ESTABILIZACAO', 'SALA VERMELHA', 'SALA ISOLAMENTO', 'SALA AMARELA ISO', 'SALA OBSERVACAO', 'SALA AMARELA', 'SALA MEDICACAO', 'SALA VERDE') AS unid_int,
 c.cd_unid_int,
 b.ds_leito
 FROM
 atendime a
 INNER JOIN dbamv.leito b ON a.cd_leito = b.cd_leito
 INNER JOIN dbamv.unid_int c ON b.cd_unid_int = c.cd_unid_int
 INNER JOIN dbamv.paciente d ON a.cd_paciente = d.cd_paciente
 INNER JOIN dbamv.triagem_atendimento e ON a.cd_atendimento = e.cd_atendimento
 WHERE
 a.cd_multi_empresa IN (17) ----------> FILTRO DE EMPRESA <----------
 AND a.dt_atendimento BETWEEN TO_DATE( $PgIgesdfDtInicial$ , 'DD/MM/YYYY') AND TO_DATE($PgIgesdfDtFim$ , 'DD/MM/YYYY') + 0.99999
-- AND c.cd_unid_int IN (113, 114, 115, 116, 117)
 AND e.cd_cor_referencia = 11
 ) Pacientes
 GROUP BY
 cd_unid_int, unid_int
 ) Pacientes
 INNER JOIN
 (
 SELECT
 a.cd_unid_int,
 b.ds_unid_int,
 COUNT(*) AS leitos_oficiais
 FROM
 leito a
 INNER JOIN DBAMV.unid_int b ON a.cd_unid_int = b.cd_unid_int
 INNER JOIN DBAMV.setor c ON b.cd_setor = c.cd_setor
 WHERE
 c.cd_multi_empresa IN (17) ----------> FILTRO DE EMPRESA <----------
 AND a.sn_extra = 'N'
 AND a.tp_situacao = 'A'
 GROUP BY
 a.cd_unid_int, b.ds_unid_int
 ) leitos ON pacientes.cd_unid_int = leitos.cd_unid_int
)
SELECT * FROM Resultado
UNION ALL
SELECT
 0 AS cd_unid_int,
 'TOTAL_PACIENTES' AS unid_int,
 SUM(qtd_pacientes) AS qtd_pacientes_total,
 SUM(leitos_oficiais) AS leitos_oficiais_total,
 0 AS dias_entre_datas_total,
 ROUND((SUM(qtd_pacientes) * 100) / (SUM(leitos_oficiais) * (TO_CHAR(TO_DATE( $PgIgesdfDtFim$ , 'DD/MM/YYYY') - TO_DATE($PgIgesdfDtInicial$ , 'DD/MM/YYYY')) + 1)), 2) AS teste_total,
$PgIgesdfDtInicial$dt_inicio,
$PgIgesdfDtFim$dt_fim
FROM
 Resultado
