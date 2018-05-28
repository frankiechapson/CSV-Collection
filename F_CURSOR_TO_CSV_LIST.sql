

create or replace function TU_CHAR_NUMBER( I_NUMBER           in number 
                                         , I_DECIMAL_SYMBOL   in char     := '.'
                                         , I_DECIMALS         in number   := 2
                                         , I_THOUSAND_SYMBOL  in char     := ' '
                                         ) return varchar2 deterministic is

/********************************************************************************************************************

    The TU_CHAR_NUMBER is a very simple TO_CHAR function to format numbers.
    In one hand the built-in oracle number formatings are too many, but in the other hand sometimes are few.
    In the most case we need only a nice, and simple number format, but Oracle does not supply it.
    This function gives a solution for this problem.

    sample:
    -------
    TU_CHAR_NUMBER ( -545847587464.22666 )

    result:
    -------
    -545 847 587 464.23
    

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.09 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_STRING    varchar2( 1000 );
    V_FORMAT    varchar2( 1000 );
    V_TMPTH     char                := chr(1);
    V_NUMBER    number              := I_NUMBER;
begin
    if V_NUMBER is not null then
        V_FORMAT := 'FM999,999,999,999,999,999,990.'||trim( rpad( ' ', I_DECIMALS + 1, '9' ) );
        if I_DECIMALS is not null then
            V_STRING := trim( rtrim( to_char( round( V_NUMBER, I_DECIMALS ), V_FORMAT ), nvl( I_DECIMAL_SYMBOL, '.' ) ) );
        else
            V_STRING := trim( rtrim( to_char( V_NUMBER , V_FORMAT ), nvl( I_DECIMAL_SYMBOL, '.' ) ) );
        end if;
        V_STRING := replace( V_STRING, ',', V_TMPTH );
        V_STRING := replace( V_STRING, '.', nvl( I_DECIMAL_SYMBOL, '.' ) );
        V_STRING := replace( V_STRING, V_TMPTH, I_THOUSAND_SYMBOL );
    end if;
    return V_STRING;
exception when others then
    return null;  -- something is wrong
end;
/

---------------------------------------------------------------------------

create or replace function F_CURSOR_TO_CSV_LIST ( I_CURSOR              in sys_refcursor
                                                , I_SEPARATOR           in varchar2   := ','
                                                , I_ENCLOSED_BY         in varchar2   := null
                                                , I_DATE_FORMAT         in varchar2   := 'yyyy.mm.dd'
                                                , I_DECIMAL_SYMBOL      in char       := '.'
                                                , I_DECIMALS            in number     := 2
                                                , I_THOUSAND_SYMBOL     in char       := null
                                                ) return T_STRING_LIST PIPELINED is
/********************************************************************************************************************

    The F_CURSOR_TO_CSV_LIST creates list of CVS strings from the cursor columns and rows.
    It formats the date and number type columns to string.
    Uses the TU_CHAR_NUMBER function!!

    Parameters:
    -----------
    I_CURSOR            the cursor to transform to list of CSV strings
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)
    I_DATE_FORMAT       for date type columns
    I_DECIMAL_SYMBOL    for number formatting
    I_DECIMALS          for number formatting
    I_THOUSAND_SYMBOL   for number formatting

    Sample:
    -------
    declare
        V_DATA      sys_refcursor;
    begin
        open V_DATA for select * from CA_CALENDAR_DAY_CHANGES;
        for L_R in ( select * from table( F_CURSOR_TO_CSV_LIST( V_DATA, ',' , '"' ) ) )
        loop
            dbms_output.put_line( L_R.column_value );
        end loop;
    end;

    Result:
    -------
    "AMERICAN","2016.07.04","H","MON"

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_DATA              sys_refcursor;
    V_CURSOR            integer;
    V_COLUMN_CNT        integer;
    V_DESC              dbms_sql.desc_tab;
    V_STRING            varchar2( 32000 );
    V_NUMBER            number;
    V_DATE              date;
    V_STRING_LIST       T_STRING_LIST := T_STRING_LIST();

begin

    V_DATA   := I_CURSOR;
    V_CURSOR := dbms_sql.to_cursor_number( V_DATA );
    dbms_sql.describe_columns( V_CURSOR, V_COLUMN_CNT, V_DESC );

    for L_I in 1..V_COLUMN_CNT 
    loop
        if V_DESC( L_I ).col_type = 2 then 
            dbms_sql.define_column( V_CURSOR, L_I, V_NUMBER        ); 
        elsif V_DESC( L_I ).col_type = 12 then 
            dbms_sql.define_column( V_CURSOR, L_I, V_DATE          ); 
        else 
            dbms_sql.define_column( V_CURSOR, L_I, V_STRING, 32000 ); 
        end if; 
    end loop;
 
    while dbms_sql.fetch_rows( V_CURSOR ) > 0 
    loop 

        V_STRING_LIST.delete;

        for L_I in 1..V_COLUMN_CNT 
        loop
        
            if V_DESC( L_I ).col_type = 2 then 
                dbms_sql.column_value( V_CURSOR, L_I, V_NUMBER        ); 
                V_STRING := TU_CHAR_NUMBER( I_NUMBER          => V_NUMBER
                                          , I_DECIMAL_SYMBOL  => nvl( I_DECIMAL_SYMBOL, '.' )
                                          , I_DECIMALS        => nvl( I_DECIMALS, 2  )
                                          , I_THOUSAND_SYMBOL => I_THOUSAND_SYMBOL
                                          );
            elsif V_DESC( L_I ).col_type = 12 then 
                dbms_sql.column_value( V_CURSOR, L_I, V_DATE          ); 
                if I_DATE_FORMAT is not null then
                    V_STRING := to_char( V_DATE, I_DATE_FORMAT );
                else
                    V_STRING := to_char( V_DATE );
                end if;
            else 
                dbms_sql.column_value( V_CURSOR, L_I, V_STRING ); 
            end if; 

            V_STRING_LIST.extend;
            V_STRING_LIST( V_STRING_LIST.count ) := V_STRING;

        end loop; 

        V_STRING := F_LIST_TO_CSV ( I_LIST        => V_STRING_LIST
                                  , I_SEPARATOR   => I_SEPARATOR
                                  , I_ENCLOSED_BY => I_ENCLOSED_BY
                                  );
        PIPE ROW( V_STRING );

    end loop; 
 
    dbms_sql.close_cursor( V_CURSOR ); 

    return;

end;
/

