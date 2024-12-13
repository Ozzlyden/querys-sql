SELECT
    e.ds_multi_empresa,
    cadastros,
    COUNT (*) qtd
FROM
    ( SELECT
          p.nm_usuario
          ,p.cd_multi_empresa
          ,CASE
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
          Dbamv.paciente p
      WHERE
          TRUNC(p.dt_cadastro_manual) BETWEEN TO_DATE('01/01/2023' /*$PgIgesdfDtInicial$*/ ,'dd/mm/yyyy') AND TO_DATE('16/08/2024' /*$PgIgesdfDtFim$*/ ,'dd/mm/yyyy')
          AND p.cd_multi_empresa  IN (1,2/*$EmpresasIGESDF$*/) 
    ) pac
    ,dbamv.multi_empresas e
WHERE
    pac.cd_multi_empresa = e.cd_multi_empresa
    AND pac.cadastros IS NOT NULL
    --AND pac.cadastros = 0
GROUP BY
    e.ds_multi_empresa,cadastros
ORDER BY 
    qtd desc