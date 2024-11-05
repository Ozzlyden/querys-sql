--pass: v371v20

--PACIENTE / USUARIOS / PESTADOR
select * from dbamv.atendime where cd_atendimento IN (6336088,6290962 );  --Atendimento principal
select * from dbamv.paciente ;  --Paciete
select * from dbamv.prestador where nm_prestador like ('%DANIEL G%') ;  --Pestador
select * from dbamv.tip_presta ;
select * from dbasgu.usuarios where nm_usuario like('%MARCIA RO%'); --usuario
select * from dbamv.prestador_cbo where cd_prestador = 16417;

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
select * from dbamv.pre_med where cd_atendimento = 0301010072; --Prescricao medicia
select * from dbamv.itpre_med;
select * from dbamv.agenda_central;  --Agendamento paciente 
select * from dbamv.it_agenda_central;
select * from dbamv.eve_siasus; --Upas faturamento

--ESTOQUE
select * from dbamv.itsolsai_pro;   
select * from dbamv.solsai_pro;     --Solicitação saida produto
select * from dbamv.itord_pro;
select * from dbamv.ord_com;        --Ordem de Compra
select * from dbamv.fornecedor;     --Fornecedor
select * from dbamv.produto;        --Produto
select * from dbamv.estoque;        --Estoque 
select * from dbamv.especie;        --Especie
select * from dbamv.motivo_diverg_atend;
select * from dbamv.ent_pro;
select * from dbamv.uni_pro;

--MANUTENCAO
select * from dbamv.solicitacao_os where cd_oficina = 5 and tp_situacao = 'S'; 
select * from dbamv.oficina; --cd_oficina = 5
select * from dbamv.setor;

select * from dbamv.multi_empresas;


