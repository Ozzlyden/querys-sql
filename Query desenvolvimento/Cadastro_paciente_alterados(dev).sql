SELECT
    pac.cadastros,
    COUNT(*) qtd
FROM
    (
        SELECT
            p.nm_usuario,
            p.cd_multi_empresa,
            CASE
                WHEN p.nr_cpf IS NULL AND p.nr_cns IS NULL AND TRUNC(p.dt_cadastro_manual) != TRUNC (p.dt_ultima_atualizacao) THEN
                    'ALTERADO INCOMPLETOS'
                WHEN p.nr_cpf IS NOT NULL AND p.nr_cns IS NOT NULL AND TRUNC(p.dt_cadastro_manual) != TRUNC (p.dt_ultima_atualizacao) THEN
                    'ALTERADO COMPLETO'
                WHEN p.nr_cpf IS NULL AND p.nr_cns IS NULL AND TRUNC(p.dt_cadastro_manual) = TRUNC (p.dt_ultima_atualizacao) THEN
                    'NÃO ALTERADO INCOMPLETOS'
                WHEN p.nr_cpf IS NOT NULL AND p.nr_cns IS NOT NULL AND TRUNC(p.dt_cadastro_manual) = TRUNC (p.dt_ultima_atualizacao) THEN
                    'NÃO ALTERADO COMPLETOS'
                /*ELSE
                    NULL*/
            END cadastros
        FROM
            dbamv.paciente p
        WHERE
          TRUNC(P.DT_CADASTRO_MANUAL) BETWEEN To_Date($PgIgesdfDtInicial$ ,'dd/mm/yyyy') AND To_Date( $PgIgesdfDtFim$ ,'dd/mm/yyyy')
          AND P.CD_MULTI_EMPRESA  IN ($EmpresasIGESDF$) 
    ) pac
WHERE 
    pac.cadastros IS NOT NULL
GROUP BY
    pac.cadastros