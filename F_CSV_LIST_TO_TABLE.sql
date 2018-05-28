
create or replace function F_CSV_LIST_TO_TABLE ( I_CSV_LIST      in T_STRING_LIST
                                               , I_SEPARATOR     in varchar2   := ','
                                               , I_ENCLOSED_BY   in varchar2   := null
                                               ) return T_STRING_LIST_TAB PIPELINED is
/********************************************************************************************************************

    The F_CSV_LIST_TO_TABLE just creates a separator/delimiter separated string from the input 
    optionally enclosed by encloser.

    Parameters:
    -----------
    I_TABLE             the tabke of string lists to transform to list of CSV string
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)

    Samples:
    -------
    F_CSV_LIST_TO_TABLE ( T_STRING_LIST ( 'A,B,C', '1,2,"3,1415"' ), ',' ,'"' )


    Results:
    -------
    T_STRING_LIST('A','B','C')
    T_STRING_LIST('1','2','3,1415')
    
    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_CSV_LIST    T_STRING_LIST := T_STRING_LIST();

begin

    for L_I in 1..I_CSV_LIST.count
    loop

        V_CSV_LIST.delete;
        for L_R in ( select * from table( F_CSV_TO_LIST ( I_CSV_STRING  => I_CSV_LIST( L_I ) 
                                                        , I_SEPARATOR   => I_SEPARATOR
                                                        , I_ENCLOSED_BY => I_ENCLOSED_BY
                                                        )
                                        )
                    )
        loop
            V_CSV_LIST.extend;
            V_CSV_LIST( V_CSV_LIST.count ) := L_R.COLUMN_VALUE;
        end loop;
        PIPE ROW( V_CSV_LIST );

    end loop;

    return;

end;
/

