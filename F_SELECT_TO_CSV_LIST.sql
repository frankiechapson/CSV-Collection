
create or replace function F_SELECT_TO_CSV_LIST ( I_SELECT              in varchar2  
                                                , I_SEPARATOR           in varchar2   := ','
                                                , I_ENCLOSED_BY         in varchar2   := null
                                                , I_DATE_FORMAT         in varchar2   := 'yyyy.mm.dd'
                                                , I_DECIMAL_SYMBOL      in char       := '.'
                                                , I_DECIMALS            in number     := 2
                                                , I_THOUSAND_SYMBOL     in char       := null
                                                ) return T_STRING_LIST PIPELINED is
/********************************************************************************************************************

    The F_SELECT_TO_CSV_LIST creates a CSV string list from the result of the given select statement.
    You can format the columns to string or leave the formatting to the function.
    To formatting the function will use the formatting parameters.

    Parameters:
    -----------
    I_SELECT            the select to transform to list of CSV strings
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)
    I_DATE_FORMAT       default date format for date type fields to convert to string
    I_DECIMAL_SYMBOL    decimal symbol for number to string formatting
    I_DECIMALS          number of decimals for number to string formatting
    I_THOUSAND_SYMBOL   thousand separator for number to string formatting

    Sample:
    -------
    select * from table( F_SELECT_TO_CSV_LIST( 'select * from CA_CALENDAR_DAY_CHANGES order by 1,2', ',', '"' ) ) 

    Result:
    -------
    "AMERICAN","2016.07.04","H","MON"

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_DATA      sys_refcursor;

begin
    open V_DATA for I_SELECT;

    for L_R in ( select * from table( F_CURSOR_TO_CSV_LIST( I_CURSOR          => V_DATA
                                                          , I_SEPARATOR       => I_SEPARATOR    
                                                          , I_ENCLOSED_BY     => I_ENCLOSED_BY    
                                                          , I_DATE_FORMAT     => I_DATE_FORMAT    
                                                          , I_DECIMAL_SYMBOL  => I_DECIMAL_SYMBOL 
                                                          , I_DECIMALS        => I_DECIMALS       
                                                          , I_THOUSAND_SYMBOL => I_THOUSAND_SYMBOL
                                                          )
                                    )
                )
    loop
        PIPE ROW( L_R.COLUMN_VALUE );
    end loop;

    return;

end;
/

