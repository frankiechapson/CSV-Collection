
create or replace function F_CSV_FILE_TO_TABLE ( I_DIRECTORY     in varchar2
                                               , I_FILE_NAME     in varchar2
                                               , I_SEPARATOR     in varchar2   := ','
                                               , I_ENCLOSED_BY   in varchar2   := null
                                               ) return T_STRING_LIST_TAB PIPELINED is
/********************************************************************************************************************

    The F_CSV_FILE_TO_TABLE creates CSV (string list) table from the file, specified by the parameters.
    The SEPARATOR and the ENCLOSED belong to the CSV strings and not to the lines. The lines could end with CR+LF or only LF (optionally).
    The DIRECTORY is an Oracle and not OS directory!

    Samples:
    -------
    select * from table( F_CSV_FILE_TO_TABLE ( 'FILEIO', 'WEATHER_DATA_1000_20160512_151722.csv', ';', null ) )

    Results:
    -------
    T_STRING_LIST('WEATHER_DATA','1','2016.05.12','15:17:28','ERDF')
    T_STRING_LIST('2010.12.31','90900','H1','7,70')
    T_STRING_LIST('2011.01.01','90900','NH3','10,20')
    T_STRING_LIST('2011.11.01','13711','H1','4,90')
    T_STRING_LIST('2011.11.01','15310','NH3','4,10')
    ....


    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.16 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_FILE              bfile;
    V_BLOB              blob;
    V_STRING_LIST       T_STRING_LIST := T_STRING_LIST();

begin

    V_FILE := bfilename( I_DIRECTORY, I_FILE_NAME );
    dbms_lob.open( V_FILE, dbms_lob.lob_readonly );

    dbms_lob.createtemporary( V_BLOB, true );
    dbms_lob.open( V_BLOB, dbms_lob.lob_readwrite );
    dbms_lob.loadfromfile( dest_lob => V_BLOB, src_lob  => V_FILE, amount => dbms_lob.getlength( V_FILE ) );
    dbms_lob.close( V_BLOB );
    dbms_lob.fileclose( V_FILE );

    for L_R in ( select * from table( F_BLOB_TO_LIST ( V_BLOB ) ) )
    loop
        V_STRING_LIST.extend;
        V_STRING_LIST( V_STRING_LIST.count ) := L_R.COLUMN_VALUE;
    end loop;

    for L_R in ( select * from table( F_CSV_LIST_TO_TABLE ( V_STRING_LIST, nvl(I_SEPARATOR,','), I_ENCLOSED_BY ) ) )
    loop
        PIPE ROW( L_R.COLUMN_VALUE );
    end loop;

    return;

exception when others then

    if dbms_lob.fileisopen( V_FILE ) = 1 then
        dbms_lob.fileclose( V_FILE );
    end if;

    raise;

end;
/