--pass: v371v20

--PACIENTE / USUARIOS / PESTADOR
select DT_SOLIC_MEDICA from dbamv.atendime; --DT_REVISAO, DT_RETORNO, DT_SOLIC_MEDICA, SN_EM_ATENDIMENTO, SN_CONSULTA_SIASUS, NR_CHAMADA_PAINEL, DT_ULTIMA_UPD_DIAG
select * from dbamv.tip_mar;
select * from dbamv.tip_ate;
select * from dbamv.paciente ;  --Paciete
select * from dbamv.prestador where nm_prestador like ('%GIOVANA%') ;  --Pestador
select * from dbamv.tip_presta ;
select * from dbasgu.usuarios where nm_usuario like('%GIOVANA%'); --usuario
select * from dbamv.prestador_cbo where cd_prestador = 16417;

--PRESCRIÇÃO
select * from dbamv.pre_med;
select * from dbamv.itpre_med;

--AGENDAMENTO
select * from dbamv.it_agenda_central;
select * from dbamv.agenda_central;


--SETORES E ESPECIALIDADES
select * from dbamv.especialid where cd_especialid in(29, 99) ;
select * from dbamv.ori_ate where ds_ori_ate like('%P.S%')and cd_ori_ate in (50,51);   --Origem atendimento
select * from dbamv.ser_dis;   --Setores
select * from dbamv.cbo;

--LEITOS
select * from dbamv.leito;
select * from dbamv.unid_int;
select * from dbamv.triagem_atendimento;
select * from dbamv.mov_int;

--DOCUMENTOS
select * from dbamv.pw_documento_clinico; --Documento clinico (ex: obito)
select * from dbamv.eve_siasus; --Upas faturamento

--SUPRIMENTOS
select * from dbamv.tb_supri_medicamentos;
select * from dbamv.tb_supri_materiais;


--ESTOQUE
select * from dbamv.itsolsai_pro;   
select * from dbamv.solsai_pro;     --Solicitação saida produto
select * from dbamv.itord_pro;
select * from dbamv.ord_com;        --Ordem de Compra
select * from dbamv.sol_com;        --Solicitação de compra
select * from dbamv.fornecedor;     --Fornecedor
select * from dbamv.estoque where /*ds_estoque like '%CAF%'*/ cd_multi_empresa in (2);        --Estoque 
select * from dbamv.itmvto_estoque; --Movimentação Estoque
select * from dbamv.est_pro;        --Estoque produção

select * from dbamv.produto;        --Produto
select * from dbamv.uni_pro;
select * from dbamv.unidade;        --Unidade produto
select * from dbamv.especie;        --Especie
select * from dbamv.classe;         --Classe
select * from dbamv.sub_clas;       --Sub Classe


select * from dbamv.motivo_diverg_atend;
select * from dbamv.ent_pro;        --Entra produto
select * from dbamv.con_pag;
select * from dbamv.itcon_pag;
select * from dbamv.pagcon_pag;


--MANUTENCAO
select * from dbamv.solicitacao_os where cd_oficina = 5 and tp_situacao = 'S'; 
select * from dbamv.oficina; --cd_oficina = 5
select * from dbamv.setor;

select * from dbamv.multi_empresas;


