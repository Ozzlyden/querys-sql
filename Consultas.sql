--pass: v371v20
select * from dbamv.ser_dis;   --Setores
select * from dbamv.ori_ate;   --Origem atendimento
select * from dbamv.atendime where cd_procedimento = 0301010072 and tp_atendimento = ('E') and cd_multi_empresa = 2 and cd_especialid = 24;  --Atendimento principal
select * from dbasgu.usuarios where cd_usuario like ('%SANDRA.FEITOSA%') ;
select * from dbamv.paciente;  --Paciente
select * from dbamv.agenda_central;  --Agendamento paciente 
select * from dbamv.it_agenda_central;
select * from bdamv.pw_documento_clinico; --Documento clinico (ex: obito)
select * from dbamv.pre_med where cd_atendimento = 0301010072; --Prescricao medicia
select * from dbamv.especialid ;

select * from dbamv.prestador where nm_prestador like ('%THAIS DA SILVA MUNDIM%');  --Pestador      ANDREA JAIME
select * from dbasgu.usuarios where nm_usuario like('%VIVIANE F%'); -- consultar usuario no B;

select * from Eve_siasus;
