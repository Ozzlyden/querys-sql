--Painel Gestão de suprimentos
--IGESDF - Medicamentos V6 
select a.* from (select a.cd_produto
,b.cd_sican
,a.ds_produto
,cm12
,(case when total_iges = 0 THEN 0
 when cm12 = 0 THEN total_iges
 when cm12 > total_iges then 0
 else round((total_iges/cm12),0) end)n_meses

,a.total_iges
,a.h_base
,a.h_santa_maria
,a.ucad
,a.upa_cei
,a.upa_ban
,a.upa_rec
,a.upa_sam
,a.upa_s_seb
,a.upa_sob
,a.upa_cei2
,a.upa_para
,a.upa_gama
,a.upa_plan
,a.upa_riacho2
,a.upa_v_pires
,a.upa_braz
,a.cons_h_base
,a.cons_h_santa_maria
,a.cons_ucad
,a.cons_upa_cei
,a.cons_upa_ban
,a.cons_upa_rec
,a.cons_upa_sam
,a.cons_upa_s_seb
,a.cons_upa_sob
,a.cons_upa_cei2
,a.cons_upa_para
,a.cons_upa_gama
,a.cons_upa_plan
,a.cons_upa_riacho2
,a.cons_upa_v_pires
,a.cons_upa_braz
,a.cd_categorias
,a.des_reab_hbase
,a.des_reab_hrsm
,a.des_reab_ucad
,a.des_reab_cei
,a.des_reab_ban
,a.des_reab_rec
,a.des_reab_sam
,a.des_reab_s_seb
,a.des_reab_sob
,a.des_reab_cei2
,a.des_reab_para
,a.des_reab_gama
,a.des_reab_plan
,a.des_reab_riacho2
,a.des_reab_v_pires
,a.des_reab_braz
,('#produto# ') prd


from (select * from TB_SUPRI_MEDICAMENTOS A
inner join (select todos from (select cd_produto todos from TB_SUPRI_MEDICAMENTOS))b on a.cd_produto = b.todos
WHERE 1=1

and a.cd_produto in (#produto# )

and ('%%' IS NULL OR upper(ds_produto) like upper('%%'))
and (#DsProduto# IS NULL  OR upper(ds_produto) like upper(#DsProduto#))
and  ( a.cd_categorias  IN (#cdcategorias#) )ORDER BY TO_NUMBER(a.cd_produto) ) a
,produto b
where (a.cd_produto = b.cd_produto)

ORDER BY  TOTAL_IGES desc) a
inner join produto b on a.cd_produto = b.cd_produto
where  b.sn_bloqueio_de_compra = 'N'