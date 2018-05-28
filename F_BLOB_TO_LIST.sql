
create or replace function F_BLOB_TO_LIST ( I_BLOB         in blob
                                          ) return T_STRING_LIST PIPELINED is
/********************************************************************************************************************

    The F_BLOB_TO_LIST creates list of lines from the BLOB input parameter.
    It can manage LF or CR+LF line delimiters.
  

    Sample:
    -------
    select * from table( F_BLOB_TO_LIST ( clob_to_blob( 'hello'||chr(13)||chr(10)||'bello' ) ) )

    Result:
    -------
    hello
    bello

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.16 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_LINE          varchar2( 32000 );
    V_OFFSET        number  :=     1;
    V_AMOUNT        number  :=  4000;
    V_LENGTH        number;
    V_BUFFER        varchar2( 32000 );
    V_STRING_LIST   T_STRING_LIST := T_STRING_LIST();

begin
    -- check
    V_LENGTH  := dbms_lob.getlength( I_BLOB );

    if V_LENGTH > 0 then

        while V_OFFSET < V_LENGTH loop

            -- get the next part of blob
            V_BUFFER := utl_raw.cast_to_varchar2( dbms_lob.substr( I_BLOB, V_AMOUNT, V_OFFSET ) );
            V_BUFFER := replace( V_BUFFER, chr( 13 ), null );

            -- crate a list from it
            V_STRING_LIST.delete;
            for L_R in ( select * from table( F_CSV_TO_LIST( V_BUFFER, chr( 10 ), null ) ) )
            loop
                V_STRING_LIST.extend;
                V_STRING_LIST( V_STRING_LIST.count ) := L_R.COLUMN_VALUE;
            end loop;

            -- go through the list elements
            for L_I in 1..V_STRING_LIST.count 
            loop
                V_LINE := V_LINE || V_STRING_LIST( L_I );
                if L_I < V_STRING_LIST.count then  -- the last row should be truncated
                    PIPE ROW( V_LINE );
                    V_LINE := '';
                end if;
            end loop;

            V_OFFSET := V_OFFSET + V_AMOUNT;

        end loop;

        -- put out the last one as well    
        if V_LINE is not null then
            PIPE ROW( V_LINE );
        end if;

    end if;

    return;

end;
/
