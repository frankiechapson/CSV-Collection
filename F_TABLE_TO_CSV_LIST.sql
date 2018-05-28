
create or replace function F_TABLE_TO_CSV_LIST ( I_TABLE         in T_STRING_LIST_TAB
                                               , I_SEPARATOR     in varchar2   := ','
                                               , I_ENCLOSED_BY   in varchar2   := null
                                               ) return T_STRING_LIST PIPELINED is
/********************************************************************************************************************

    The F_TABLE_TO_CSV_LIST just creates a separator/delimiter separated string from the input 
    optionally enclosed by encloser.

    Parameters:
    -----------
    I_TABLE             the table of string lists to transform to list of CSV strings
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)

    Samples:
    -------
    F_TABLE_TO_CSV_LIST ( T_STRING_LIST_TAB ( T_STRING_LIST( 'A', 'B', 'C' ), T_STRING_LIST( '1', '2', '3,1415' ) ) , ',', '"' )


    Results:
    -------
    "A","B","C"
    "1","2","3,1415"
    
    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_CSV_STRING    varchar2( 32000 );

begin

    for L_I in 1..I_TABLE.count
    loop

        V_CSV_STRING := F_LIST_TO_CSV ( I_LIST        => I_TABLE ( L_I )
                                      , I_SEPARATOR   => I_SEPARATOR
                                      , I_ENCLOSED_BY => I_ENCLOSED_BY
                                      );
        PIPE ROW( V_CSV_STRING );

    end loop;

    return;

end;
/

