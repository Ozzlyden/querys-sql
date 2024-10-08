--Solicitações Engenharia Clinica - Desenvolvimento
--HBDF - Solicitações Realizadas Engenharia Clinica
SELECT
    *
FROM
    (
        SELECT
            a.cd_os, --Ordem de Serviço 
           /* decode(
                a.tp_situacao,        
                'S', 'SOLICITACAO'  
            ) AS situacao,*/
            to_char(a.dt_pedido, 'dd/mm/yyyy') AS abertura, --data abertura
            /*CASE 
                -- Quando a situação for cancelada, mostrar "CANCELADO"
                WHEN a.tp_situacao = 'D' THEN 'CANCELADO'
                -- Quando a data de fechamento for NULL, mostrar "andamento"
                WHEN a.dt_usuario_fecha_os IS NULL THEN 'NAO FECHADO'
                -- Caso contrário, exibir a data de fechamento formatada
                ELSE to_char(a.dt_usuario_fecha_os, 'dd/mm/yyyy')
            END AS fechamento,*/
            c.nm_setor,
            decode(a.cd_oficina, '5', 'ENGENHARIA CLINICA') AS oficina,
            a.ds_servico, --ocorrencia
            a.tp_prioridade, 
            to_char(round(TO_NUMBER(sysdate - a.dt_pedido))) || ' Dia(s) em andamento' AS dias, --tempo de espera
            decode(a.cd_multi_empresa, '1', 'HBDF', '2', 'HRSM') AS local
        FROM
            solicitacao_os a
        INNER JOIN oficina b ON a.cd_oficina = b.cd_oficina
        INNER JOIN setor c ON a.cd_setor = c.cd_setor
        WHERE
            b.cd_oficina IN (5)
            AND A.TP_SITUACAO in ('S')
        ORDER BY
            a.dt_pedido DESC
    )
ORDER BY
    abertura
