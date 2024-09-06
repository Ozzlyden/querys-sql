--HRSM - Agendamentos Serviço x TA
SELECT
A_cd_tip_mar
,A_ds_tip_mar
,A_CD_SER_DIS
,A_DS_SER_DIS
,B_CD_SER_DIS
,B_DS_SER_DIS
,B_ATENDIDO
,(A_TOTAL_AGENDADO - B_ATENDIDO) FALTA
,A_TOTAL_AGENDADO
FROM
(SELECT
A.cd_tip_mar A_cd_tip_mar
,A.ds_tip_mar A_ds_tip_mar
,A.CD_SER_DIS A_CD_SER_DIS
,A.DS_SER_DIS A_DS_SER_DIS
,A.TOTAL_AGENDADO A_TOTAL_AGENDADO
,NVL(B.CD_SER_DIS, A.CD_SER_DIS) B_CD_SER_DIS
,NVL(B.DS_SER_DIS, A.DS_SER_DIS) B_DS_SER_DIS
,NVL(B.QT_ATENDE,TO_NUMBER('0')) B_ATENDIDO

FROM
(
SELECT
            cd_tip_mar,
            ds_tip_mar,
            ds_ser_dis,
            cd_ser_dis,
            SUM(TOTAL_AGENDADO)TOTAL_AGENDADO
        FROM
                ( SELECT
    tm.cd_tip_mar,
    ds_tip_mar,
    sd.ds_ser_dis,
    sd.cd_ser_dis,
    COUNT(sd.cd_ser_dis) total_agendado
FROM
         paciente p
    INNER JOIN it_agenda_central it ON p.cd_paciente = it.cd_paciente
    INNER JOIN agenda_central    ac ON it.cd_agenda_central = ac.cd_agenda_central
    INNER JOIN tip_mar           tm ON it.cd_tip_mar = tm.cd_tip_mar
    INNER JOIN ser_dis           sd ON it.cd_ser_dis = sd.cd_ser_dis
WHERE
    ac.cd_multi_empresa = 2
                    and it.hr_agenda between to_date(@P_DATA_INI) and to_date(@P_DATA_FIM)+0.99999
                    and it.cd_paciente is not null
                    and ac.tp_agenda = 'A'
                    and tm.cd_tip_mar in (1,2)
                    and it.cd_ser_dis IN ({V_CD_SERV})
                GROUP BY tm.cd_tip_mar, ds_tip_mar, sd.ds_ser_dis, sd.cd_ser_dis) 
        group by cd_tip_mar, ds_tip_mar, ds_ser_dis, cd_ser_dis)A

LEFT JOIN
        (SELECT
            cd_tip_mar
            ,DS_TIP_MAR
            ,CD_SER_DIS
            ,DS_SER_DIS
            ,SUM(QT_ATENDE) QT_ATENDE
            
        FROM
        (SELECT
           sd.cd_ser_dis CD_SER_DIS
            ,sd.ds_ser_dis DS_SER_DIS
            ,tm.cd_tip_mar CD_TIP_MAR
            ,tm.ds_tip_mar DS_TIP_MAR
            ,COUNT(*) QT_ATENDE
        FROM atendime at
            inner join ser_dis sd on at.cd_ser_dis = sd.cd_ser_dis
            inner join tip_mar tm on at.cd_tip_mar = tm.cd_tip_mar
            
        WHERE 
            at.DT_ATENDIMENTO between to_date(@P_DATA_INI) and to_date(@P_DATA_FIM)+0.99999
            and at.CD_MULTI_EMPRESA = 2
            and sd.cd_ser_dis IN ({V_CD_SERV})
            and tm.cd_tip_mar in (1,2)
        
        group by  SD.CD_SER_DIS ,SD.DS_SER_DIS ,tm.CD_TIP_MAR ,tm.DS_TIP_MAR
        
        )

group by cd_tip_mar, DS_TIP_MAR, CD_SER_DIS, DS_SER_DIS)B ON A.cd_tip_mar = B.cd_tip_mar and a.cd_ser_dis = b.cd_ser_dis
)

ORDER BY 4,1