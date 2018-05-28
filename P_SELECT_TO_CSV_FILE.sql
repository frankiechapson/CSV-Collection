
create or replace procedure P_SELECT_TO_CSV_FILE ( I_SELECT              in varchar2  
                                                 , I_DIRECTORY           in varchar2
                                                 , I_FILE_NAME           in varchar2
                                                 , I_SEPARATOR           in varchar2   := ','
                                                 , I_ENCLOSED_BY         in varchar2   := null
                                                 , I_DATE_FORMAT         in varchar2   := 'yyyy.mm.dd'
                                                 , I_DECIMAL_SYMBOL      in char       := '.'
                                                 , I_DECIMALS            in number     := 2
                                                 , I_THOUSAND_SYMBOL     in char       := null
                                                 ) is
/********************************************************************************************************************

    The P_SELECT_TO_CSV_FILE procedure creates a CSV file from the given select statement.
    Similar to the F_SELECT_TO_CSV_LIST you can convert the various data types to string in the
    column list of the select, or use automatic conversion as specified in parameters.

    Parameters:
    -----------
    I_SELECT            the select to transform to CSV file
    I_DIRECTORY         Oracle directory for the target file
    I_FILE_NAME         File name of the target file
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)
    I_DATE_FORMAT       default date format for date type fields to convert to string
    I_DECIMAL_SYMBOL    decimal symbol for number to string formatting
    I_DECIMALS          number of decimals for number to string formatting
    I_THOUSAND_SYMBOL   thousand separator for number to string formatting


    Sample:
    -------
    begin
        P_SELECT_TO_CSV_FILE( 'select * from CA_CALENDAR_DAY_CHANGES order by 1,2'
                            , 'FILEIO'
                            , 'CA_CALENDAR_DAY_CHANGES.csv'
                            , ';'
                            , '"' 
                            );
    end;

    Result:
    -------
    cat CA_CALENDAR_DAY_CHANGES.csv

    "AMERICAN";"2016.07.04";"H";"MON"

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/

    V_FILE              utl_file.file_type;

begin

    V_FILE := utl_file.fopen_nchar( I_DIRECTORY, I_FILE_NAME, 'W');

    for L_R in ( select * from table( F_SELECT_TO_CSV_LIST( I_SELECT          => I_SELECT
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
        utl_file.put_line_nchar( V_FILE, L_R.COLUMN_VALUE );
    end loop;

    utl_file.fclose ( V_FILE );

exception when others then

    utl_file.fclose( V_FILE );

    raise;

end;
/

