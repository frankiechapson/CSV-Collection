create or replace function F_LIST_TO_CSV ( I_LIST          in T_STRING_LIST
                                         , I_SEPARATOR     in varchar2   := ','
                                         , I_ENCLOSED_BY   in varchar2   := null
                                         ) return varchar2 is
/********************************************************************************************************************

    The F_LIST_TO_CSV just creates a separator/delimiter separated string from the input 
    optionally enclosed by encloser.

    Parameters:
    -----------
    I_LIST              the string list to transform to CSV string
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)

    Samples:
    -------
    F_LIST_TO_CSV ( T_STRING_LIST( '1', '2', '3,1415' ), ',' )

    F_LIST_TO_CSV ( T_STRING_LIST( '1', '2', '3,1415' ), ',', '"' )


    Results:
    -------
    1,2,3,1415

    "1","2","3,1415"

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_CSV_STRING    varchar2( 32000 );
    V_SEPARATOR     varchar2( 32000 );

begin

    for L_I in 1..I_LIST.count
    loop

        V_CSV_STRING := V_CSV_STRING || V_SEPARATOR || I_ENCLOSED_BY || I_LIST( L_I ) || I_ENCLOSED_BY;
        V_SEPARATOR  := nvl(I_SEPARATOR,',');

    end loop;

    return V_CSV_STRING;

end;
/

