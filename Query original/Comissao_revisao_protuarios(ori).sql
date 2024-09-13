/*--------------------------------------------------------------------------------------
Comissão Revisão Prontuário - Status Pacientes para a Avaliação de Revisão do Prontuário
--------------------------------------------------------------------------------------*/
select distinct
    cd_atendimento,
    cd_paciente,
    nm_paciente,
    dt_atendimento,
dt_nascimento,
idade,
    dt_alta_medica,
    dt_alta,
    tempo_internacao || ' ' || 'Dias' as tempo_internacao,
    ds_unid_int,
    registro_diag,
    registro_alta,
    presenca_medicamento
    
from(
    -- ================================================
    -- INICIO - STATUS PACIENTES E PRONTUÁRIO DETALHADO
    -- ================================================
    select
        atend.cd_atendimento,
        atend.cd_paciente,
        pac.nm_paciente,
        atend.dt_atendimento,
 TO_CHAR(pac.dt_nascimento, 'dd/mm/yyyy') AS dt_nascimento,
 TRUNC(MONTHS_BETWEEN(SYSDATE, dt_nascimento) / 12) AS idade,
        atend.dt_alta_medica,
        atend.dt_alta,
        atend.tempo_internacao,
        mov.cd_leito,
        unid_int.cd_unid_int,
        unid_int.ds_unid_int,
        case
            when log_cid.cd_atendimento is not null
                then 'SIM'
            else 'NÃO'
        end as registro_diag,
        case
            when reg_alta.cd_atendimento is not null
                then 'SIM'
            else 'NÃO'
        end as registro_alta,
        case
            when presc.cd_atendimento is not null
                then 'SIM'
            else 'NÃO'
        end as presenca_medicamento
    
    from(
        -- =====================================
        -- INICIO - ATENDIMENTOS COM ALTA MÉDICA
        -- =====================================
        select
            a.cd_atendimento,
            a.cd_paciente,
            a.dt_atendimento,
            a.dt_alta_medica,
            a.dt_alta,
            (to_date(a.dt_alta_medica) - to_date(a.dt_atendimento)) as tempo_internacao,
            a.cd_leito
            
        from atendime a
        
        where a.cd_multi_empresa = 1 /* HBDF */
            and a.tp_atendimento = 'I' /* apenas internação */
            and to_date(a.dt_alta) between to_date( $PgIgesdfDtInicial$ ) 
                and to_date( $PgIgesdfDtFim$ )+0.99999 /* FILTRO DE DATA */
    -- ==================================
    -- FIM - ATENDIMENTOS COM ALTA MÉDICA
    -- ==================================
    ) atend
        
        join mov_int mov on atend.cd_atendimento = mov.cd_atendimento
    
        join leito on atend.cd_leito = leito.cd_leito
        
        join(
            -- ===================================
            -- INCIO - UNID INT COM FILTRO INTERNO
            -- ===================================
            select
                a.cd_unid_int, a.ds_unid_int
            from unid_int a
                join setor b on a.cd_setor = b.cd_setor
            where b.cd_multi_empresa = 1 /* HBDF */
                and a.cd_unid_int IN ($PgHBDFUnidInternacao$) /*- FILTRO UNID INT -*/
        -- =================================
        -- FIM - UNID INT COM FILTRO INTERNO
        -- =================================
        ) unid_int on leito.cd_unid_int = unid_int.cd_unid_int
        
        left join log_cid on atend.cd_atendimento = log_cid.cd_atendimento
        
        left join(
            -- =================================
            -- INICIO - REGISTROS DE ALTA MÉDICA
            -- PARA COMPROVAÇÃO
            -- =================================
            select
                cd_registro_alta, cd_atendimento, cd_mot_alt
            from pw_registro_alta
            where tp_situacao = 'FECHADA' /* apenas prontuário de alta fechado */
        -- ==============================
        -- FIM - REGISTROS DE ALTA MÉDICA
        -- PARA COMPROVAÇÃO
        -- ==============================
        ) reg_alta on atend.cd_atendimento = reg_alta.cd_atendimento
        
        left join paciente pac on atend.cd_paciente = pac.cd_paciente
        
        left join(
            -- =============================================
            -- INICIO - ITENS DE PRESCRIÇÃO PARA COMPROVAÇÃO
            -- =============================================
            select
                a.cd_pre_med, a.cd_atendimento
            from pre_med a
                join(
                    select
                        cd_pre_med,
                        cd_itpre_med
                    from itpre_med
                    where cd_tip_esq in ('MAT', 'MAV', 'MCC', 'MCE', 'MDA', 'MDC',
                                        'MDN', 'MDO', 'MDU', 'MNP', 'MVE', 'SOR') /* Esquema de prescrição com medicamento */
                        and nvl(sn_cancelado, 'N') = 'N' /* sem cancelados */
                ) b on a.cd_pre_med = b.cd_pre_med
        -- ==========================================
        -- FIM - ITENS DE PRESCRIÇÃO PARA COMPROVAÇÃO
        -- ==========================================
        ) presc on atend.cd_atendimento = presc.cd_atendimento
-- =============================================
-- FIM - STATUS PACIENTES E PRONTUÁRIO DETALHADO
-- =============================================
)

order by
    dt_alta

