--Painel Gestão de suprimentos
--IGESDF - Medicamentos V6 
SELECT
    a.*
FROM
         (
        SELECT
            a.cd_produto,
            b.cd_sican,
            a.ds_produto,
            cm12,
            (
                CASE
                    WHEN total_iges = 0    THEN
                        0
                    WHEN cm12 = 0          THEN
                        total_iges
                    WHEN cm12 > total_iges THEN
                        0
                    ELSE
                        round((total_iges / cm12), 0)
                END
            )            n_meses,
            a.total_iges,
            a.h_base,
            a.h_santa_maria,
            a.ucad,
            a.upa_cei,
            a.upa_ban,
            a.upa_rec,
            a.upa_sam,
            a.upa_s_seb,
            a.upa_sob,
            a.upa_cei2,
            a.upa_para,
            a.upa_gama,
            a.upa_plan,
            a.upa_riacho2,
            a.upa_v_pires,
            a.upa_braz,
            a.cons_h_base,
            a.cons_h_santa_maria,
            a.cons_ucad,
            a.cons_upa_cei,
            a.cons_upa_ban,
            a.cons_upa_rec,
            a.cons_upa_sam,
            a.cons_upa_s_seb,
            a.cons_upa_sob,
            a.cons_upa_cei2,
            a.cons_upa_para,
            a.cons_upa_gama,
            a.cons_upa_plan,
            a.cons_upa_riacho2,
            a.cons_upa_v_pires,
            a.cons_upa_braz,
            a.cd_categorias,
            a.des_reab_hbase,
            a.des_reab_hrsm,
            a.des_reab_ucad,
            a.des_reab_cei,
            a.des_reab_ban,
            a.des_reab_rec,
            a.des_reab_sam,
            a.des_reab_s_seb,
            a.des_reab_sob,
            a.des_reab_cei2,
            a.des_reab_para,
            a.des_reab_gama,
            a.des_reab_plan,
            a.des_reab_riacho2,
            a.des_reab_v_pires,
            a.des_reab_braz,
            ( 'Todos ' ) prd
        FROM
            (
                SELECT
                    *
                FROM
                         tb_supri_medicamentos a
                    INNER JOIN (
                        SELECT
                            todos
                        FROM
                            (
                                SELECT
                                    cd_produto todos
                                FROM
                                    tb_supri_medicamentos
                            )
                    ) b ON a.cd_produto = b.todos
                WHERE
                        1 = 1
                    AND a.cd_produto IN ( todos )
                    AND ( '%%' IS NULL
                          OR upper(ds_produto) LIKE upper('%%') )
                    AND ( '%%' IS NULL
                          OR upper(ds_produto) LIKE upper('%%') )
                    AND ( a.cd_categorias IN ( 1, 2, 3, 4, 5,
                                               6, 7 ) )
                ORDER BY
                    TO_NUMBER(a.cd_produto)
            )       a,
            produto b
        WHERE
            ( a.cd_produto = b.cd_produto )
        ORDER BY
            total_iges DESC
    ) a
    INNER JOIN produto b ON a.cd_produto = b.cd_produto
WHERE
    b.sn_bloqueio_de_compra = 'N'