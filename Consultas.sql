--pass: v371v20

--PACIENTE E USUARIOS
select * from dbamv.atendime where cd_atendimento = 6199334;  --Atendimento principal
select * from dbamv.paciente;  --Paciete
select * from dbamv.prestador where nm_prestador like ('%MARCIA RO%') ;  --Pestador
select * from dbasgu.usuarios where nm_usuario like('%MARCIA RO%'); --usuario
select * from prestador_cbo where cd_prestador = 16417;

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
DBAMV.RETORNA_SITUACAO_DO_LEITO; --Funcação 

--DOCUMENTOS
select * from bdamv.pw_documento_clinico; --Documento clinico (ex: obito)
select * from dbamv.pre_med where cd_atendimento = 0301010072; --Prescricao medicia
select * from dbamv.agenda_central;  --Agendamento paciente 
select * from dbamv.it_agenda_central;
select * from dbamv.eve_siasus; --Upas faturamento

select * from SACR_CLASSIFICACAO;
select * from SACR_COR_REFERENCIA;

select * from solicitacao_os where cd_oficina = 5 and tp_situacao = 'S'; 
select * from oficina; --cd_oficina = 5
select * from setor;

select * from multi_empresas;
