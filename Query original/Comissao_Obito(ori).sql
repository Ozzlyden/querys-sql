select emp.ds_multi_empresa as empresa
      ,atend.cd_atendimento
      ,pct.nm_paciente
      ,to_char(pct.dt_nascimento,'dd/mm/yyyy') as dt_nascimento
      ,trunc(((atend.dt_atendimento) - nvl(pct.dt_nascimento,atend.dt_atendimento)) / 365.25) as idade
      ,pct.tp_sexo
      ,pct.ds_endereco|| '-' ||pct.nm_bairro || '-' || cidade.nm_cidade as endereco
      ,pct.nm_mae as nome_mae
      ,to_char(atend.dt_atendimento,'dd/mm/yyyy') as data_atendimento
      ,dt_alta_medica as data_obito
      ,nvl(mot_alta.ds_mot_alt,res_alta.ds_tip_res) as mot_alt_medic
      ,nvl(mot_alta_ate.ds_mot_alt,res_alta_ate.ds_tip_res) as motivo_alta_hosp
      ,doc.resultado
      ,atend.nr_declaracao_obito
      ,reg_alta.cd_cid || ' - ' || cid.ds_cid AS cid
      ,nvl(nvl(unid.ds_unid_int,setor.nm_setor),lei.ds_leito) as local_obito
      ,doc.obs_obito
      ,doc.diag_ini_obs
      ,doc.diag_def_obs
      ,doc.dh_fechamento
      ,doc.qtd
  from (select cd_atendimento
              ,cd_paciente
              ,dt_atendimento
              ,dt_alta
              ,dt_alta_medica
              ,cd_multi_empresa
              ,nr_declaracao_obito
              ,cd_mot_alt
              ,cd_tip_res
              ,cd_leito
          from dbamv.atendime
          where nvl(dt_alta_medica, dt_alta) between to_date($PgIgesdfDtInicial$) and to_date($PgIgesdfDtFim$) + 0.99999
            and cd_multi_empresa in ($PgEmpresasIgesDF$)
            and cd_tip_res = 8 
        
        union all
        
        select  cd_atendimento
               ,cd_paciente
               ,dt_atendimento
               ,dt_alta
               ,dt_alta_medica
               ,cd_multi_empresa
               ,nr_declaracao_obito
               ,cd_mot_alt
               ,cd_tip_res
               ,cd_leito
          from dbamv.atendime
          where nvl(dt_alta_medica, dt_alta) between to_date($PgIgesdfDtInicial$) 
            and to_date($PgIgesdfDtFim$) + 0.99999
            and cd_multi_empresa in ($PgEmpresasIgesDF$)
            and cd_mot_alt in (select cd_mot_alt from dbamv.mot_alt where ds_mot_alt like '%BITO%')) atend 
  left join ( select cd_atendimento
                    ,cd_documento_clinico
                    ,cd_cid
                    ,cd_cid_obito
                    ,cd_setor_obito
                    ,cd_mot_alt
                from pw_registro_alta
                where cd_documento_clinico in (select cd_documento_clinico 
                                                 from (select cd_atendimento
                                                             ,max(cd_documento_clinico) as cd_documento_clinico
                                                         from pw_registro_alta
                                                         where cd_mot_alt in (8,41,42,43,65,67)
                                                           and tp_situacao = 'FECHADA'
                                                        group by cd_atendimento))
             ) reg_alta on atend.cd_atendimento = reg_alta.cd_atendimento 
  inner join dbamv.paciente pct on atend.cd_paciente = pct.cd_paciente
  inner join dbamv.multi_empresas emp on atend.cd_multi_empresa = emp.cd_multi_empresa
  left join dbamv.cidade cidade on pct.cd_cidade = cidade.cd_cidade
  left join dbamv.mot_alt mot_alta on reg_alta.cd_mot_alt = mot_alta.cd_mot_alt
  left join dbamv.tip_res res_alta on reg_alta.cd_mot_alt = res_alta.cd_tip_res
  left join dbamv.mot_alt mot_alta_ate on atend.cd_mot_alt = mot_alta_ate.cd_mot_alt
  left join dbamv.tip_res res_alta_ate on atend.cd_mot_alt = res_alta_ate.cd_tip_res
  left join dbamv.cid cid on reg_alta.cd_cid_obito = cid.cd_cid
  left join dbamv.setor setor on reg_alta.cd_setor_obito = setor.cd_setor
  left join dbamv.leito lei on atend.cd_leito = lei.cd_leito
  left join dbamv.unid_int unid on lei.cd_unid_int = unid.cd_unid_int
  left join (select pdc.cd_atendimento
                   ,obito.resultado
                   ,diag_ini.diag_ini_obs
                   ,diag_def.diag_def_obs
                   ,obs.obs_obito
                   ,pdc.cd_documento_clinico
                   ,pdc.dh_fechamento 
                   ,ROW_NUMBER() OVER (PARTITION BY pdc.cd_atendimento ORDER BY pdc.cd_documento_clinico desc) qtd
               from (select a.cd_documento_clinico
                           ,b.cd_editor_registro as cd_registro
                           ,a.cd_prestador
                           ,a.cd_atendimento
                           ,a.dh_fechamento
                      from pw_documento_clinico a
                      join pw_editor_clinico b on a.cd_documento_clinico = b.cd_documento_clinico
                      where b.cd_documento in (1002, 1029,1194) --------------- DOCUMENTOS VINCULADOS ---------------
                      and a.tp_status = 'FECHADO'
                        ) pdc
              left join(select decode(to_char(ec.ds_identificador),'rb_questao_obito_j_1','ÓBITO JUSTIFICADO' --------- Documento 1029
                                                                  ,'Metadado_P_277367_1', 'ÓBITO JUSTIFICADO' --------- Documento 1194
                                                                  ,'Metadado_P_277369_1', 'ÓBITO A ESCLARECER' --------- Documento 1194
                                                                  ,'rb_questao_obito_i_1','ÓBITO A ESCLARECER') as resultado, --------- Documento 1029
                               to_char(erc.cd_registro) as cd_registro
                          from editor_registro_campo erc,
                               editor_campo ec
                          where erc.cd_campo = ec.cd_campo
                            and ec.ds_identificador in ('rb_questao_obito_j_1','rb_questao_obito_i_1','Metadado_P_277367_1','Metadado_P_277369_1')
                            and to_char(erc.lo_valor) = 'true'
                         ) obito on pdc.cd_registro = obito.cd_registro
              left join( select RTRIM(SUBSTR(erc.lo_valor, 1, 300)) as diag_ini_obs
                              , ec.ds_identificador
                              , erc.cd_registro as cd_registro
                           from editor_registro_campo erc,
                                editor_campo ec
                           where erc.cd_campo = ec.cd_campo
                             and ec.ds_identificador in ('ct_diag_inicial_1' ------- Documento 1002
                                                        ,'Metadado_P_228042_1'  ------- Documento 1029
                                                        ,'Metadado_P_277371_1')
                        ) diag_ini on pdc.cd_registro = diag_ini.cd_registro
              left join( select RTRIM(SUBSTR(erc.lo_valor, 1, 300)) as diag_def_obs
                              , ec.ds_identificador
                              , to_char(erc.cd_registro) as cd_registro
                           from editor_registro_campo erc,
                                editor_campo ec
                           where erc.cd_campo = ec.cd_campo
                             and ec.ds_identificador in ('ct_diag_definitivo_1' -------- Documento 1002
                                                        ,'Metadado_P_228044_1' -------- Documento 1029
                                                        ,'Metadado_P_277373_1')
                        ) diag_def on pdc.cd_registro = diag_def.cd_registro
              left join( select RTRIM(SUBSTR(erc.lo_valor, 1, 300)) obs_obito,
                                to_char(erc.cd_registro) as cd_registro
                           from editor_registro_campo erc,
                                editor_campo ec
                           where erc.cd_campo = ec.cd_campo
                             and ec.ds_identificador in ('Metadado_P_220007_1' ------ Documento 1002
                                                        ,'Metadado_P_226911_1' ------ Documento 1029
                                                        ,'Metadado_P_277309_1' ------ Documento 1049
                                                         )
                        ) obs on pdc.cd_registro = obs.cd_registro
             ) doc on atend.cd_atendimento = doc.cd_atendimento
order by 1, 3