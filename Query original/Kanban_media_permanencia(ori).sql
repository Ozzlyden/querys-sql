--Painel - Kanban - Média de Permanência - Original
SELECT
 cd_unid_int,
 ds_unid_int,
 total_atendidos,
 total_altas,
 ROUND((total_atendidos / total_altas),2) AS media_permanencia
 
FROM
(SELECT
 cd_unid_int,
 ds_unid_int,
 SUM(sequencia_atendimentos) AS total_atendidos,
 COUNT(nm_paciente) AS total_altas
 
FROM
(SELECT
 a.cd_paciente,
 e.nm_paciente,
 COUNT(a.cd_atendimento) AS sequencia_atendimentos,
 MIN(TO_CHAR(a.dt_atendimento, 'dd/mm/yyyy')) AS Inicio_atenidmento,
 MAX(TO_CHAR(a.dt_atendimento, 'dd/mm/yyyy')) AS fim_atendimento,
 
 DECODE(
 ds_unid_int ,
 'SALA ESTABILIZACAO', 'SALA VERMELHA',
 'SALA ISOLAMENTO', 'SALA AMARELA ISO',
 'SALA OBSERVACAO', 'SALA AMARELA',
 'SALA MEDICACAO', 'SALA VERDE'
 ) AS ds_unid_int,
 MAX(cd_unid_int) AS cd_unid_int
FROM (
 SELECT
 a.cd_paciente,
 a.cd_atendimento,
 a.dt_atendimento,
 a.dt_alta_medica,
 d.ds_unid_int,
 d.cd_unid_int,
 ROW_NUMBER() OVER (PARTITION BY a.cd_paciente ORDER BY a.dt_atendimento) AS row_num
 FROM atendime a
 INNER JOIN (
 SELECT * FROM triagem_atendimento
 WHERE cd_cor_referencia = 11
 ) b ON a.cd_atendimento = b.cd_atendimento
 INNER JOIN DBAMV.leito c ON a.cd_leito = c.cd_leito
 INNER JOIN DBAMV.unid_int d ON c.cd_unid_int = d.cd_unid_int
 INNER JOIN DBAMV.paciente e ON a.cd_paciente = e.cd_paciente
 WHERE a.cd_multi_empresa IN (17) ---------------> UPAVICP <---------------
 --AND a.cd_paciente IN ( 1801769, 6691707)
 AND a.dt_atendimento BETWEEN TO_DATE(  $PgIgesdfDtInicial$ ) AND TO_DATE( $PgIgesdfDtFim$ )+0.99999
 --AND a.cd_leito IS NOT NULL
) a
 INNER JOIN DBAMV.paciente e ON a.cd_paciente = e.cd_paciente
GROUP BY a.cd_paciente, e.nm_paciente, cd_unid_int, ds_unid_int
) a 
group by cd_unid_int, ds_unid_int 
)