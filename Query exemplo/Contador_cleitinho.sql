SELECT
    EXTRACT(DAY FROM contador.data_dia)   AS dia,
    to_char(contador.data_dia, 'mm/yyyy') AS data_filtro,
    CASE
        WHEN unid_int.cd_unid_int = 157 THEN
            TO_NUMBER('00')
        WHEN unid_int.cd_unid_int = 14  THEN
            TO_NUMBER('00')
        ELSE
            unid_int.cd_unid_int
    END                                   AS cd_unid_int,
    CASE
        WHEN unid_int.cd_unid_int = 157 THEN
            '00 - UTI PEDIATRICA'
        WHEN unid_int.cd_unid_int = 14  THEN
            '00 - UTI PEDIATRICA'
        ELSE
            unid_int.ds_unid_int
    END                                   AS unidade,
    atendime.cd_atendimento
FROM
    dbamv.mov_int,
    dbamv.unid_int,
    dbamv.leito,
    dbamv.atendime,
    dbamv.especialid,
    (
        SELECT
            ( TO_DATE('20' || '10/2024') - 1 ) + ROWNUM data_dia
        FROM
            dbamv.cid
        WHERE
            ( TO_DATE('20' || '10/2024') - 1 ) + ROWNUM <= trunc(last_day(TO_DATE('22' || '10/2024')))
    ) contador
WHERE
        trunc(dt_mov_int) <= contador.data_dia - 1
    AND trunc(nvl(dt_lib_mov, sysdate)) > contador.data_dia - 1
    AND tp_mov IN ( 'O', 'I' )
    AND leito.cd_unid_int = unid_int.cd_unid_int
    AND mov_int.cd_atendimento = atendime.cd_atendimento
    AND mov_int.cd_leito = leito.cd_leito
    AND atendime.cd_especialid = especialid.cd_especialid (+)
    AND atendime.cd_multi_empresa = 1
    AND atendime.cd_atendimento = 31