create or replace function F_SELECT_ROWS_TO_CSV ( I_SELECT              in varchar2  
                                                , I_SEPARATOR           in varchar2   := ','
                                                , I_ENCLOSED_BY         in varchar2   := null
                                                ) return varchar2 is
/********************************************************************************************************************

    The F_SELECT_ROWS_TO_CSV function returns with a CSV generated from the exactly one column of the select statement.
    Similar to LISTAGG function.

    Parameters:
    -----------
    I_SELECT            the select to transform to CSV string
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)


    Sample:
    -------
    select CODE, F_SELECT_ROWS_TO_CSV( 'select NAME from CA_WEEK_DAYS where CALENDAR_TYPE_CODE='''||CALENDAR_TYPE_CODE||'''' ) as WEEK_DAYS from CA_CALENDARS

    Result:
    -------
    CODE        WEEK_DAYS
    AMERICAN	Friday,Monday,Saturday,Sunday,Thursday,Tuesday,Wednesday
    HUNGARIAN	Friday,Monday,Saturday,Sunday,Thursday,Tuesday,Wednesday
    SAUIDI	    Gathering day,Second day,Day of Rest,First day,Fifth day,Third day,Fourth day

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/


    V_CURSOR            sys_refcursor;
    V_STRING            varchar2( 32000 ) := '';
    V_CSV_STRING        varchar2( 32000 ) := '';
    V_SEPARATOR         varchar2( 32000 );

begin

    open V_CURSOR for I_SELECT;
    loop

        fetch V_CURSOR into V_STRING;
        exit when V_CURSOR%notfound;

        V_CSV_STRING := V_CSV_STRING || V_SEPARATOR || I_ENCLOSED_BY || V_STRING || I_ENCLOSED_BY;
        V_SEPARATOR  := nvl(I_SEPARATOR,',');

    end loop;

    close V_CURSOR;

    return V_CSV_STRING;

end;
/
