--HBDF - Cadastros de Pacientes Incompletos Por Dia - dev
SELECT
    cod,
    nomepac,
    dh_cadastro,
    cpf,
    cns,
    usuariocad,
    tipoatend,
    setor,
    empresa,
    ds_ori_ate,
    ds_ser_dis
FROM
    (
        SELECT
            paciente.cd_paciente              cod,
            paciente.nm_paciente              nomepac,
            paciente.dh_cadastro,
            paciente.nr_cpf                   cpf,
            paciente.nr_cns                   cns,
            paciente.nm_usuario               usuariocad,
            nvl(atendime.tp_atendimento, 'A') tipoatend,
            ori.cd_ori_ate,
            CASE
                WHEN atendime.tp_atendimento IN ( 'A', 'U', 'E' ) THEN
                    ori.ds_ori_ate
                WHEN atendime.tp_atendimento = 'I' THEN
                    ori.ds_ori_ate
                    || ' '
                    || ser.ds_ser_dis
                WHEN ds_ori_ate IS NULL
                     AND ds_ser_dis IS NULL THEN
                    'SEM ATENDIMENTO'
            END                               AS setor,
            paciente.ds_multi_empresa         empresa,
            CASE
                WHEN ds_ori_ate IS NULL THEN
                    'SEM ATENDIMENTO'
                ELSE
                    ds_ori_ate
            END                               AS ds_ori_ate,
            CASE
                WHEN ds_ser_dis IS NULL THEN
                    'SEM ATENDIMENTO'
                ELSE
                    ds_ser_dis
            END                               AS ds_ser_dis
        FROM
            (--QUERY
                SELECT
                    pac.cd_paciente,
                    pac.nm_paciente, 
                    pac.nr_cpf,
                    pac.nr_cns,
                    to_char(pac.dt_cadastro_manual, 'DD/MM/YYYY')
                    || ' '
                    || to_char(pac.hr_cadastro, 'HH24:MI:SS') AS dh_cadastro,
                    u.nm_usuario,
                    e.ds_multi_empresa
                FROM
                         (
                        SELECT
                            p.cd_paciente,
                            p.nm_paciente,
                            p.dt_cadastro_manual,
                            p.hr_cadastro,
                            p.nr_cpf,
                            p.nr_cns,
                            p.nm_usuario,
                            p.cd_multi_empresa,
                            CASE
                                WHEN p.nr_cpf IS NULL THEN
                                    0
                                WHEN p.nr_cns IS NULL THEN
                                    0
                                ELSE
                                    1
                            END AS situacao
                        FROM
                            dbamv.paciente p
                        WHERE
                            trunc(p.dt_cadastro_manual) BETWEEN TO_DATE('01/01/2023') AND TO_DATE('16/08/2024')
                            AND p.cd_multi_empresa IN ( 1, 2 )
                    ) pac
                    JOIN dbasgu.usuarios      u ON pac.nm_usuario = u.cd_usuario
                    JOIN dbamv.multi_empresas e ON pac.cd_multi_empresa = e.cd_multi_empresa
                WHERE
                    pac.situacao = 0
                ORDER BY
                    e.ds_multi_empresa,
                    u.nm_usuario
            )              paciente
            LEFT JOIN (
                SELECT
                    MIN(cd_atendimento) AS cd_atendimento,
                    cd_paciente
                FROM
                    dbamv.atendime
                WHERE
                    cd_multi_empresa IN ( 1, 2 )
                GROUP BY
                    cd_paciente
            )              min_atendimento ON paciente.cd_paciente = min_atendimento.cd_paciente
            LEFT JOIN dbamv.atendime atendime ON min_atendimento.cd_atendimento = atendime.cd_atendimento
            LEFT JOIN dbamv.ori_ate  ori ON atendime.cd_ori_ate = ori.cd_ori_ate
            LEFT JOIN dbamv.ser_dis  ser ON atendime.cd_ser_dis = ser.cd_ser_dis
    )
WHERE
    tipoatend IN ( 'A', 'E', 'I', 'U' )
    AND ( ds_ser_dis IN ( 'INFECTOLOGIA', 'MEDICINA DO TRABALHO/OCUPACION', 'PNEUMOLOGIA', 'PSICOLOGIA', 'URODINAMICA',
                          'TEF', 'PNEUMOLOGIA- FIBROSE CISTICA', 'AUDIOMETRIA + 65 ANOS', 'POTENCIAL EVOCADO AUDITIVO', 'AVALIACAO P/ DIAG. DEFIC. AUDI'
                          ,
                          'DILATACAO DE URETRA', 'OFTAMOLOGIA/PARECER ENDOCRINO', 'OFTAMOLOGIA/FOTOCOAGULACAO', 'DOADOR DE RIM (ACOMPANHAMENTO)'
                          , 'ENDOCRINO OBESIDADE POS OPERAT',
                          'USG VIAS URINARIAS', 'OFTAMOLOGIA/MAPEAMENTO RETINA', 'LARINGOTRAQUEOSCOPIA', 'BIOPSIA DE LARINGE', 'CLÍNICA DA DOR'
                          ,
                          'IODOTERAPIA DE CARCINOMA 250', 'NEXOS INTERCLÍNICA', 'CLINICA DA DOR', 'NEUROCIRURGIA TUMOR', 'TOXINA BOTULINICA'
                          ,
                          'ANESTESIOLOGIA', 'ONCOLOGIA CLÍNICA', 'GASTROENTEROLOGIA', 'GERIATRIA', 'NEUROLOGIA',
                          'PATOLOGIA CLINICA MEDICINA LAB', 'RADIOLOGIA DIAG POR IMAGEM', 'RADIOTERAPIA', 'FISIOTERAPIA', 'FONOAUDIOLOGIA'
                          ,
                          'NEUROCIRURGIA TRIAGEM', 'NUTRIÇÃO- FIBROSE CISTICA', 'CERATOSCOPIA', 'ODONTOLOGIA PAC.ESP.', 'ENDOCRINO OBESIDADE PRE OPERAT'
                          ,
                          'TUMOR NA HIPOFISE NEUROCIRURG', 'TRAQUEOSTOMIZADOS ADULTO', 'TRAQUEOSTOMIZADOS INFANTIL', 'TESTE DE ERECAO - TEFI'
                          , 'MEDICINA DO TRABALHO',
                          'GINECOLOGIA', 'IODOTERAPIA DE CARCINOMA DIFER', 'OFTALMOLOGIA/CATARATA', 'NEUROCIRURGIA FUNCIONAL', 'CARDIOLOGIA'
                          ,
                          'CIRURGIA DE CABEÇA E PESCOÇO', 'DERMATOLOGIA', 'HEMATOLOGIA E HEMOTERAPIA', 'ODONTOLOGIA', 'AUDIOMETRIA ATE 7 ANOS'
                          ,
                          'POTENCIAL EVOCADO BERA ACIMA 5', 'MICROSCOPIA ESPECULAR CORNEA', 'TERAPIA OCUPACIONAL', 'OFTAMOLOGIA/ESTRABISMO'
                          , 'ODONTOPEDIATRIA',
                          'TRIAGEM  RADIOLOGIA INTERVENC.', 'DOADOR POTENCIAL', 'ECO DOPPLER  COLORIDO DE VASOS', 'PARECER NEXO CAUSAL'
                          , 'NEUROCIRURGIA BASE DE CRANIO',
                          'CIRURGIA GERAL', 'CIRURGIA VASCULAR', 'COLOPROCTOLOGIA', 'MASTOLOGIA', 'PATOLOGIA',
                          'MASTO-BIÓPSIA MAMA', 'LITOTRIPSIA', 'FISIOTERAPIA - FIBROSE CISTICA', 'CIRURGIA BUCO MAXILO FACIAL', 'CONSULTA EM AUDIOMETRIA'
                          ,
                          'NEUROLOGIA - TAP', 'OFTAMOLOGIA/OCT', 'PNEUMOLOGIA - GASOMETRIA', 'ESTOMATOLOGIA', 'FISIATRIA',
                          'ECOGRAFIA CERVICAL', 'OFTAMOLOGIA/RETINOGRAFIA COLOR', 'CONSULTA EM VIDEOLARINGOSCOPIA', 'CIRURGIA DO TRAUMA'
                          , 'CONSULTA EM CIRURG. ONCOLÓGICA',
                          'ULTRA SONOGRAFIA GLOBO OCULAR', 'OFTAMOLOGIA/VITRECTOMIA', 'OFTALMOLOGIA/NEURO', 'ALERGIA E IMUNOLOGIA', 'CLINICA MEDICA'
                          ,
                          'ENDOSCOPIA', 'NEUROCIRURGIA', 'REUMATOLOGIA', 'MASTOLOGIA- TRIAGEM SISREG', 'MASTO-POS CIRURGICO',
                          'TRIAGEM FISIOTERAPIA', 'GASTRO - FIBROSE CISTICA', 'TESTE DE CAMINHADA FISIO', 'AUDIOMETRIA 8 A 64 ANOS', 'TESTES AUDITIVOS-PAC'
                          ,
                          'EMISSOES OTOAUCUSTICAS-EOA', 'PNEUMOLOGIA NEXO INTERCLÍNICA', 'ENDOSCOPIA RESPIRATÓRIA', 'BIOPSIA DE PROSTATA'
                          , 'OFTAMOLOGIA/PLASTICA OCULAR',
                          'CONSULTA PRÉ OPERATÓRIO', 'DISFUNÇÃO TEMPOROMANDIBULAR', 'BUCO MAXILO FACIAL', 'ECOGRAFIA PROSTATA', 'PUNÇAO LOMBAR'
                          ,
                          'SERVIÇO SOCIAL', 'ORTODONTIA-ANOMA CRANIOFACIAIS', 'BRONCOSCOPIA', 'VIDEOLARINGOSCOPIA', 'CUIDADOS PALIATIVOS'
                          ,
                          'TRATAMENTO DE HIPERTIREO GRAVE', 'NEUROCIRURGIA VASCULAR', 'TRAQUEOSCOPIA', 'ORTODONTIA - CONSULTA', 'CIRURGIA PEDIATRICA'
                          ,
                          'CIRURGIA PLASTICA', 'MEDICINA FISICA REABILITAÇÃO', 'NEFROLOGIA', 'OFTALMOLOGIA', 'PEDIATRIA',
                          'NUTRIÇÃO', 'CANCEROLOGISTA CIRIRGICO', 'CISTOSCOPIA', 'UROFLUXOMETRIA', 'BIOPSIA DE  PROSTATA',
                          'GINECOLOGIA ONCOLOGICA', 'PAQUIMETRIA ULTRASSONICA', 'IMUNOLOGIA E URTICARIA CRONICA', 'ACUPUNTURIATRIA', 'ATEND. FONO - TELEMEDICINA'
                          ,
                          'OFTAMOLOGIA/RETINA GERAL', 'VASCULAR (VARIZES | ESPUMA)', 'BIOPSIA GUIADA (TC/RM/US/RX)', 'ATEND. ONCOLOGICOS CONTINUADOS'
                          , 'TRATAMENTO DE HIPERTIREOIDISMO',
                          'VIDEOENDOSCOPIA NASAL', 'OFTALMOLOGIA/CORNEA', 'BIOMETRIA ULTRASSONICA', 'OCIRURGIA NERVO PERIFERICO', 'CURATIVOS'
                          ,
                          'CIRURGIA ONCOLOGICA', 'CIRURGIA TORACICA', 'MEDICINA NUCLEAR', 'ORTOPEDIA E TRAUMATOLOGIA', 'PSIQUIATRIA',
                          'UROLOGIA', 'ONCOLOGISTA CLINICO', 'DILATACAO URETRAL', 'CAMPIMETRIA', 'ECOGRAFIA APARELHO URINARIO',
                          'NEUROLOGIA-TRIAGEM', 'PNEUMO AMBULATÓRIO DE EGRESSOS', 'OFTAMOLOGIA/DMRI', 'BIOPSIA DE MEDULA OSSEA', 'FARMACIA CLINICA'
                          ,
                          'ENDODONTIA', 'ECOGRAFIA INGUINAL', 'OFTALMOLOGIA/GLAUCOMA', 'CIRURGIA CARDIACA', 'CIRURGIA DO APARELHO DIGESTIVO'
                          ,
                          'ENDOCRINOLOGIA E METABOLOGIA', 'OTORRINOLARINGOLOGIA', 'ENFERMAGEM', 'ASSISTENCIA SOCIAL', 'ASSISTENCIA FARMACÊUTICA'
                          ,
                          'USG UROLOGIA', 'CIRURGIÃO DENTISTA', 'TERAPIA GRUPO - TO', 'TRIAGEM AMBULATORIO PSICOLOGIA', 'ADMINISTRAÇÃO DE MEDICAMENTOS'
                          ,
                          'CPRE', 'HEMODINAMICA', 'TRIAGEM UROLOGIA', 'CISTOSCOPIA E/OU URETEROSCOPIA', 'ASSISTENCIA ESPECIALIZADA',
                          'VISITA PRE ANESTESICA', 'OFTALMOLOGIA /PTERIGIO', 'OFTALMOLOGIA/UVEITE', 'NEUROCIRURGIA GERAL', 'SEM ATENDIMENTO'
                          ,
                          'UPA-EXTERNO', 'NEFROLOGIA - HRSM', 'RX DIAGNOSE-UPA SAO SEBASTIAO', 'HRSM - ANATOMIA PATOLOGICA', 'EXAMES LABORATÓRIO - HB'
                          ,
                          'EXAMES IMAGEM/' )
          OR ds_ori_ate IN ( 'INFECTOLOGIA', 'MEDICINA DO TRABALHO/OCUPACION', 'PNEUMOLOGIA', 'PSICOLOGIA', 'URODINAMICA',
                             'TEF', 'PNEUMOLOGIA- FIBROSE CISTICA', 'AUDIOMETRIA + 65 ANOS', 'POTENCIAL EVOCADO AUDITIVO', 'AVALIACAO P/ DIAG. DEFIC. AUDI'
                             ,
                             'DILATACAO DE URETRA', 'OFTAMOLOGIA/PARECER ENDOCRINO', 'OFTAMOLOGIA/FOTOCOAGULACAO', 'DOADOR DE RIM (ACOMPANHAMENTO)'
                             , 'ENDOCRINO OBESIDADE POS OPERAT',
                             'USG VIAS URINARIAS', 'OFTAMOLOGIA/MAPEAMENTO RETINA', 'LARINGOTRAQUEOSCOPIA', 'BIOPSIA DE LARINGE', 'CLÍNICA DA DOR'
                             ,
                             'IODOTERAPIA DE CARCINOMA 250', 'NEXOS INTERCLÍNICA', 'CLINICA DA DOR', 'NEUROCIRURGIA TUMOR', 'TOXINA BOTULINICA'
                             ,
                             'ANESTESIOLOGIA', 'ONCOLOGIA CLÍNICA', 'GASTROENTEROLOGIA', 'GERIATRIA', 'NEUROLOGIA',
                             'PATOLOGIA CLINICA MEDICINA LAB', 'RADIOLOGIA DIAG POR IMAGEM', 'RADIOTERAPIA', 'FISIOTERAPIA', 'FONOAUDIOLOGIA'
                             ,
                             'NEUROCIRURGIA TRIAGEM', 'NUTRIÇÃO- FIBROSE CISTICA', 'CERATOSCOPIA', 'ODONTOLOGIA PAC.ESP.', 'ENDOCRINO OBESIDADE PRE OPERAT'
                             ,
                             'TUMOR NA HIPOFISE NEUROCIRURG', 'TRAQUEOSTOMIZADOS ADULTO', 'TRAQUEOSTOMIZADOS INFANTIL', 'TESTE DE ERECAO - TEFI'
                             , 'MEDICINA DO TRABALHO',
                             'GINECOLOGIA', 'IODOTERAPIA DE CARCINOMA DIFER', 'OFTALMOLOGIA/CATARATA', 'NEUROCIRURGIA FUNCIONAL', 'CARDIOLOGIA'
                             ,
                             'CIRURGIA DE CABEÇA E PESCOÇO', 'DERMATOLOGIA', 'HEMATOLOGIA E HEMOTERAPIA', 'ODONTOLOGIA', 'AUDIOMETRIA ATE 7 ANOS'
                             ,
                             'POTENCIAL EVOCADO BERA ACIMA 5', 'MICROSCOPIA ESPECULAR CORNEA', 'TERAPIA OCUPACIONAL', 'OFTAMOLOGIA/ESTRABISMO'
                             , 'ODONTOPEDIATRIA',
                             'TRIAGEM  RADIOLOGIA INTERVENC.', 'DOADOR POTENCIAL', 'ECO DOPPLER  COLORIDO DE VASOS', 'PARECER NEXO CAUSAL'
                             , 'NEUROCIRURGIA BASE DE CRANIO',
                             'CIRURGIA GERAL', 'CIRURGIA VASCULAR', 'COLOPROCTOLOGIA', 'MASTOLOGIA', 'PATOLOGIA',
                             'MASTO-BIÓPSIA MAMA', 'LITOTRIPSIA', 'FISIOTERAPIA - FIBROSE CISTICA', 'CIRURGIA BUCO MAXILO FACIAL', 'CONSULTA EM AUDIOMETRIA'
                             ,
                             'NEUROLOGIA - TAP', 'OFTAMOLOGIA/OCT', 'PNEUMOLOGIA - GASOMETRIA', 'ESTOMATOLOGIA', 'FISIATRIA',
                             'ECOGRAFIA CERVICAL', 'OFTAMOLOGIA/RETINOGRAFIA COLOR', 'CONSULTA EM VIDEOLARINGOSCOPIA', 'CIRURGIA DO TRAUMA'
                             , 'CONSULTA EM CIRURG. ONCOLÓGICA',
                             'ULTRA SONOGRAFIA GLOBO OCULAR', 'OFTAMOLOGIA/VITRECTOMIA', 'OFTALMOLOGIA/NEURO', 'ALERGIA E IMUNOLOGIA'
                             , 'CLINICA MEDICA',
                             'ENDOSCOPIA', 'NEUROCIRURGIA', 'REUMATOLOGIA', 'MASTOLOGIA- TRIAGEM SISREG', 'MASTO-POS CIRURGICO',
                             'TRIAGEM FISIOTERAPIA', 'GASTRO - FIBROSE CISTICA', 'TESTE DE CAMINHADA FISIO', 'AUDIOMETRIA 8 A 64 ANOS'
                             , 'TESTES AUDITIVOS-PAC',
                             'EMISSOES OTOAUCUSTICAS-EOA', 'PNEUMOLOGIA NEXO INTERCLÍNICA', 'ENDOSCOPIA RESPIRATÓRIA', 'BIOPSIA DE PROSTATA'
                             , 'OFTAMOLOGIA/PLASTICA OCULAR',
                             'CONSULTA PRÉ OPERATÓRIO', 'DISFUNÇÃO TEMPOROMANDIBULAR', 'BUCO MAXILO FACIAL', 'ECOGRAFIA PROSTATA', 'PUNÇAO LOMBAR'
                             ,
                             'SERVIÇO SOCIAL', 'ORTODONTIA-ANOMA CRANIOFACIAIS', 'BRONCOSCOPIA', 'VIDEOLARINGOSCOPIA', 'CUIDADOS PALIATIVOS'
                             ,
                             'TRATAMENTO DE HIPERTIREO GRAVE', 'NEUROCIRURGIA VASCULAR', 'TRAQUEOSCOPIA', 'ORTODONTIA - CONSULTA', 'CIRURGIA PEDIATRICA'
                             ,
                             'CIRURGIA PLASTICA', 'MEDICINA FISICA REABILITAÇÃO', 'NEFROLOGIA', 'OFTALMOLOGIA', 'PEDIATRIA',
                             'NUTRIÇÃO', 'CANCEROLOGISTA CIRIRGICO', 'CISTOSCOPIA', 'UROFLUXOMETRIA', 'BIOPSIA DE  PROSTATA',
                             'GINECOLOGIA ONCOLOGICA', 'PAQUIMETRIA ULTRASSONICA', 'IMUNOLOGIA E URTICARIA CRONICA', 'ACUPUNTURIATRIA'
                             , 'ATEND. FONO - TELEMEDICINA',
                             'OFTAMOLOGIA/RETINA GERAL', 'VASCULAR (VARIZES | ESPUMA)', 'BIOPSIA GUIADA (TC/RM/US/RX)', 'ATEND. ONCOLOGICOS CONTINUADOS'
                             , 'TRATAMENTO DE HIPERTIREOIDISMO',
                             'VIDEOENDOSCOPIA NASAL', 'OFTALMOLOGIA/CORNEA', 'BIOMETRIA ULTRASSONICA', 'OCIRURGIA NERVO PERIFERICO', 'CURATIVOS'
                             ,
                             'CIRURGIA ONCOLOGICA', 'CIRURGIA TORACICA', 'MEDICINA NUCLEAR', 'ORTOPEDIA E TRAUMATOLOGIA', 'PSIQUIATRIA'
                             ,
                             'UROLOGIA', 'ONCOLOGISTA CLINICO', 'DILATACAO URETRAL', 'CAMPIMETRIA', 'ECOGRAFIA APARELHO URINARIO',
                             'NEUROLOGIA-TRIAGEM', 'PNEUMO AMBULATÓRIO DE EGRESSOS', 'OFTAMOLOGIA/DMRI', 'BIOPSIA DE MEDULA OSSEA', 'FARMACIA CLINICA'
                             ,
                             'ENDODONTIA', 'ECOGRAFIA INGUINAL', 'OFTALMOLOGIA/GLAUCOMA', 'CIRURGIA CARDIACA', 'CIRURGIA DO APARELHO DIGESTIVO'
                             ,
                             'ENDOCRINOLOGIA E METABOLOGIA', 'OTORRINOLARINGOLOGIA', 'ENFERMAGEM', 'ASSISTENCIA SOCIAL', 'ASSISTENCIA FARMACÊUTICA'
                             ,
                             'USG UROLOGIA', 'CIRURGIÃO DENTISTA', 'TERAPIA GRUPO - TO', 'TRIAGEM AMBULATORIO PSICOLOGIA', 'ADMINISTRAÇÃO DE MEDICAMENTOS'
                             ,
                             'CPRE', 'HEMODINAMICA', 'TRIAGEM UROLOGIA', 'CISTOSCOPIA E/OU URETEROSCOPIA', 'ASSISTENCIA ESPECIALIZADA'
                             ,
                             'VISITA PRE ANESTESICA', 'OFTALMOLOGIA /PTERIGIO', 'OFTALMOLOGIA/UVEITE', 'NEUROCIRURGIA GERAL', 'SEM ATENDIMENTO'
                             ,
                             'UPA-EXTERNO', 'NEFROLOGIA - HRSM', 'RX DIAGNOSE-UPA SAO SEBASTIAO', 'HRSM - ANATOMIA PATOLOGICA', 'EXAMES LABORATÓRIO - HB'
                             ,
                             'EXAMES IMAGEM/' ) )