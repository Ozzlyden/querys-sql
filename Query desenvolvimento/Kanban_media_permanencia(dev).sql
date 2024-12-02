--Painel - Kanban - Média de Permanência
SELECT
    cd_unid_int,
    ds_unid_int,
    qtd_atendimentos,
    total_altas,
    qtd_dias_internados,
    --round((qtd_atendimentos / total_altas), 2)    AS media_permanencia_atend,
    --round((qtd_dias_internados / total_altas), 2) AS media_permanencia_internados,
 
 CASE 
 -- Antes da data_corte -> qtd_atendimentos
 WHEN TO_DATE($PgIgesdfDtInicial$)   -- Data inicio
 < TO_DATE('28/08/2024') THEN 
 ROUND((qtd_atendimentos / total_altas), 2) 
 -- Após a data_corte -> qtd dias internados
 ELSE 
 ROUND((qtd_dias_internados / total_altas), 2)
 END AS media_permanencia

FROM
    (
        SELECT
            cd_unid_int,
            ds_unid_int,
            SUM(qtd_dias_internados)    AS qtd_dias_internados,
            SUM(sequencia_atendimentos) AS qtd_atendimentos, --total_atendidos
            COUNT(nm_paciente)          AS total_altas --total_altas 

        FROM
            (
                SELECT
                    a.cd_paciente,
                    e.nm_paciente,
                    COUNT(a.cd_atendimento)                      AS sequencia_atendimentos,
                    MIN(to_char(a.dt_atendimento, 'dd/mm/yyyy')) AS inicio_atenidmento,
                    MAX(to_char(a.dt_atendimento, 'dd/mm/yyyy')) AS fim_atendimento,
                    decode(ds_unid_int, 'SALA ESTABILIZACAO', 'SALA VERMELHA', 'SALA ISOLAMENTO', 'SALA AMARELA ISO',
                           'SALA OBSERVACAO', 'SALA AMARELA', 'SALA MEDICACAO', 'SALA VERDE', 'SALA PEDIATRIA',
                           'SALA PEDIATRIA')                     AS ds_unid_int,
                    MAX(cd_unid_int)                             AS cd_unid_int,
                    SUM(qtd_dias_internados)                     AS qtd_dias_internados
                FROM
                         (
                        SELECT
                            a.cd_paciente,
                            a.cd_atendimento,
                            a.dt_atendimento,
                            a.hr_atendimento,
                            a.hr_alta_medica,
                            a.dt_alta_medica,
                            a.cd_mot_alt,
                            a.cd_leito,
                            d.ds_unid_int,
                            d.cd_unid_int,
                            ROW_NUMBER()
                            OVER(PARTITION BY a.cd_paciente
                                 ORDER BY
                                     a.dt_atendimento
                            )        AS row_num,
                            CEIL(nvl(nvl(a.hr_alta, a.hr_alta_medica),
                                      TO_DATE($PgIgesdfDtFim$,'DD/MM/YYYY')) - a.hr_atendimento   --Data fim
                                  ) AS qtd_dias_internados
                        FROM
                                 atendime a
                            INNER JOIN dbamv.triagem_atendimento b ON a.cd_atendimento = b.cd_atendimento
                            INNER JOIN dbamv.leito               c ON a.cd_leito = c.cd_leito
                            INNER JOIN dbamv.unid_int            d ON c.cd_unid_int = d.cd_unid_int
                            INNER JOIN dbamv.paciente            e ON a.cd_paciente = e.cd_paciente
                        WHERE
                            a.cd_multi_empresa IN ( 03 ) 
                            --AND c.sn_extra = 'N' 
                            --AND c.tp_situacao = 'A'
                            
                            AND a.dt_atendimento BETWEEN TO_DATE($PgIgesdfDtInicial$) AND TO_DATE($PgIgesdfDtFim$) + 0.99999
                            AND (
                                --Filtro Data Implementação
                             ( a.dt_atendimento < TO_DATE('28/08/2024', 'DD/MM/YYYY') 
                                    AND b.cd_cor_referencia = 11 )
                                  OR ( a.dt_atendimento >= TO_DATE('28/08/2024', 'DD/MM/YYYY') 
                                       AND c.cd_leito IS NOT NULL ) )
                            AND ROUND(
                            NVL(NVL(a.hr_alta, a.hr_alta_medica), TO_DATE($PgIgesdfDtFim$, 'DD/MM/YYYY')) - a.hr_atendimento,
                                   2
                                   ) > 0
                    ) a
                    INNER JOIN dbamv.paciente e ON a.cd_paciente = e.cd_paciente
                GROUP BY
                    a.cd_paciente,
                    e.nm_paciente,
                    cd_unid_int,
                    ds_unid_int
            ) a
        GROUP BY
            cd_unid_int,
            ds_unid_int
    )