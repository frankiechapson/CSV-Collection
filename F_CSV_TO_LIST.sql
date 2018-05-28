
create or replace function F_CSV_TO_LIST ( I_CSV_STRING    in varchar2
                                         , I_SEPARATOR     in varchar2   := ','
                                         , I_ENCLOSED_BY   in varchar2   := null
                                         ) return T_STRING_LIST PIPELINED is
/********************************************************************************************************************

    The F_CSV_TO_LIST is a "smart" string list separated by strings, optionally enclosed by string parser.    
    if the separator/delimiter is between enclosers, then the separator will be the part of the field.
    if the encloser is not closed or not started then the encloser will be the part of the field.

    Parameters:
    -----------
    I_CSV_STRING        the ( delimited and optionally enclosed ) string to parse
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)

    Samples:
    -------
    select * from table( F_CSV_TO_LIST ( '1,2,3,1415', ',' ) )

    select * from table( F_CSV_TO_LIST ( '"1,2","3,1415"', ',' ) )

    select * from table( F_CSV_TO_LIST ( '"1,2","3,1415"', ',', '"' ) )


    Results:
    -------
    1
    2
    3
    1415

    "1
    2"
    "3
    1415"

    1,2 
    3,1415

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_INSIDE            boolean           := false;
    V_CSV               varchar2( 32000 ) := I_CSV_STRING;
    V_FIELD             varchar2( 32000 );
    V_SEPARATOR         varchar2(   300 ) := nvl( I_SEPARATOR, ',' );

begin

    loop

        if V_CSV is null then
            PIPE ROW( V_FIELD );
            exit;
        end if;

        if not V_INSIDE then

            -- did we reach a separator outside?
            if substr( V_CSV , 1 , length( V_SEPARATOR ) ) = V_SEPARATOR  then
                V_CSV    := substr( V_CSV, length( V_SEPARATOR ) + 1 );
                PIPE ROW( V_FIELD );
                V_FIELD  := '';

            -- a new field starts with "enclosed by"
            elsif substr( V_CSV, 1 , length( I_ENCLOSED_BY ) ) = I_ENCLOSED_BY then

                V_CSV    := substr( V_CSV, length( I_ENCLOSED_BY ) + 1 );
                V_INSIDE := true;
                V_FIELD  := I_ENCLOSED_BY;

            -- a new field starts
            else
                V_FIELD  := substr( V_CSV, 1 , 1 );
                V_CSV    := substr( V_CSV, 2 );
                V_INSIDE := true;
            end if;
        
        else  -- inside

            -- did we reach the end of field 
            if ( I_ENCLOSED_BY is null or substr( V_FIELD, 1, length( I_ENCLOSED_BY ) ) != I_ENCLOSED_BY )
                 and substr( V_CSV, 1, length( V_SEPARATOR ) ) = V_SEPARATOR then

                V_CSV    := substr( V_CSV, length( V_SEPARATOR ) + 1 );
                PIPE ROW( V_FIELD );
                V_INSIDE := false;
                V_FIELD  := '';

            -- did we reach the end of field with an "enclosed by"
            elsif      substr( V_CSV , 1                          , length( I_ENCLOSED_BY ) )                = I_ENCLOSED_BY and 
                  nvl( substr( V_CSV , length( I_ENCLOSED_BY ) + 1, length( V_SEPARATOR   ) ), V_SEPARATOR ) = V_SEPARATOR   then

                V_CSV    := substr( V_CSV, length( I_ENCLOSED_BY ) + 1 );
                V_FIELD  := V_FIELD||I_ENCLOSED_BY;
                -- if the field is really enclosed, then we remove the enclose strings
                if substr( V_FIELD, 1, length( I_ENCLOSED_BY ) ) = I_ENCLOSED_BY and
                   substr( V_FIELD, -length( I_ENCLOSED_BY )   ) = I_ENCLOSED_BY then
                    V_FIELD := substr( V_FIELD, length( I_ENCLOSED_BY ) + 1, length( V_FIELD ) - 2 * length( I_ENCLOSED_BY ) );
                end if;
                V_INSIDE := false;
            
            -- just add it to the field
            else
                V_FIELD  := V_FIELD || substr( V_CSV, 1 , 1 );
                V_CSV    := substr( V_CSV, 2 );
            end if;

        end if;

    end loop;

    return;

end;
/

