
# CSV collection

## Oracle PL/SQL solutions to manage delimited (CSV) data 

Here is a collection of Oracle PL/SQL functions to manage deilimited data. 

**CSV means here not only Comma but any other Separated Values!**

This is a right order of install

1. T_STRING_LIST.sql
2. F_SELECT_ROWS_TO_CSV.sql
3. F_CSV_TO_LIST.sql
4. F_BLOB_TO_LIST.sql
5. F_CSV_LIST_TO_TABLE.sql
6. F_CSV_FILE_TO_TABLE.sql
7. F_LIST_TO_CSV.sql
8. F_TABLE_TO_CSV_LIST.sql
9. F_CURSOR_TO_CSV_LIST.sql
10. F_SELECT_TO_CSV_LIST.sql
11. P_SELECT_TO_CSV_FILE.sql


## Description of functions:

### F_SELECT_ROWS_TO_CSV

The **F_SELECT_ROWS_TO_CSV** function returns a CSV string generated from the exactly one column of the select statement.
Similar to **LISTAGG** function.

Parameters:

-    *I_SELECT*            the select to transform to CSV string
-    *I_SEPARATOR*         the field separator/delimiter
-    *I_ENCLOSED_BY*       the optional encloser (both left and right)

Sample:

    select CODE, F_SELECT_ROWS_TO_CSV( 'select NAME from CA_WEEK_DAYS where CALENDAR_TYPE_CODE='''||CALENDAR_TYPE_CODE||'''' ) as WEEK_DAYS from CA_CALENDARS

Result:

    CODE        WEEK_DAYS
    AMERICAN    Friday,Monday,Saturday,Sunday,Thursday,Tuesday,Wednesday
    HUNGARIAN   Friday,Monday,Saturday,Sunday,Thursday,Tuesday,Wednesday
    SAUIDI      Gathering day,Second day,Day of Rest,First day,Fifth day,Third day,Fourth day

-------------------------------------

### F_CSV_TO_LIST

The **F_CSV_TO_LIST** is a "smart" string list separated by strings, optionally enclosed by string parser.    

If the separator/delimiter is between enclosers, then the separator will be the part of the field.

If the encloser is not closed or not started then the encloser will be the part of the field.

Parameters:

-    *I_CSV_STRING*        the ( delimited and optionally enclosed ) string to parse
-    *I_SEPARATOR*         the field separator/delimiter
-    *I_ENCLOSED_BY*       the optional encloser (both left and right)

Samples:

    select * from table( F_CSV_TO_LIST ( '1,2,3,1415', ',' ) )

    select * from table( F_CSV_TO_LIST ( '"1,2","3,1415"', ',' ) )

    select * from table( F_CSV_TO_LIST ( '"1,2","3,1415"', ',', '"' ) )


Results:

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


-------------------------------------

### F_BLOB_TO_LIST

The **F_BLOB_TO_LIST** creates list of lines from the BLOB input parameter.
It can manage LF or CR+LF line delimiters too.
  
Sample:

    select * from table( F_BLOB_TO_LIST ( clob_to_blob( 'hello'||chr(13)||chr(10)||'bello' ) ) )

Result:

    hello
    bello


------------------------------------

### F_CSV_LIST_TO_TABLE

The **F_CSV_LIST_TO_TABLE** just creates a separator/delimiter separated string from the input optionally enclosed by encloser.

Parameters:

-    *I_TABLE*             the table of string lists to transform to list of CSV string
-    *I_SEPARATOR*         the field separator/delimiter
-    *I_ENCLOSED_BY*       the optional encloser (both left and right)

Sample:

    F_CSV_LIST_TO_TABLE ( T_STRING_LIST ( 'A,B,C', '1,2,"3,1415"' ), ',' ,'"' )


Result:

    T_STRING_LIST('A','B','C')
    T_STRING_LIST('1','2','3,1415')
    

------------------------------------

### F_CSV_FILE_TO_TABLE

The **F_CSV_FILE_TO_TABLE** creates CSV (string list) table from the file, specified by the parameters.

The SEPARATOR and the ENCLOSED belong to the CSV strings and not to the lines. The lines could end with CR+LF or only LF (optionally).

The DIRECTORY is an Oracle and not OS directory!

Sample:

    select * from table( F_CSV_FILE_TO_TABLE ( 'FILEIO', 'WEATHER_DATA_1000_20160512_151722.csv', ';', null ) )

Result:

    T_STRING_LIST('WEATHER_DATA','1','2016.05.12','15:17:28')
    T_STRING_LIST('2010.12.31','90900','A','7,70')
    T_STRING_LIST('2011.01.01','90900','B','10,20')
    T_STRING_LIST('2011.11.01','13711','A','4,90')
    T_STRING_LIST('2011.11.01','15310','B','4,10')
    ....

------------------------------------

### F_LIST_TO_CSV

The **F_LIST_TO_CSV** just creates a separator/delimiter separated string from the input optionally enclosed by encloser.

Parameters:

-    *I_LIST*              the string list to transform to CSV string
-    *I_SEPARATOR*         the field separator/delimiter
-    *I_ENCLOSED_BY*       the optional encloser (both left and right)

Samples:

    F_LIST_TO_CSV ( T_STRING_LIST( '1', '2', '3,1415' ), ',' )

    F_LIST_TO_CSV ( T_STRING_LIST( '1', '2', '3,1415' ), ',', '"' )


Results:

    1,2,3,1415

    "1","2","3,1415"


--------------------------------------

### F_TABLE_TO_CSV_LIST

The **F_TABLE_TO_CSV_LIST** just creates a separator/delimiter separated strings from the input optionally enclosed by encloser.

Parameters:

-    *I_TABLE*             the table of string lists to transform to list of CSV strings
-    *I_SEPARATOR*         the field separator/delimiter
-    *I_ENCLOSED_BY*       the optional encloser (both left and right)

Sample:

    F_TABLE_TO_CSV_LIST ( T_STRING_LIST_TAB ( T_STRING_LIST( 'A', 'B', 'C' ), T_STRING_LIST( '1', '2', '3,1415' ) ) , ',', '"' )


Result:

    "A","B","C"
    "1","2","3,1415"
    


----------------------------------

### F_CURSOR_TO_CSV_LIST
    
The **F_CURSOR_TO_CSV_LIST** creates list of CVS strings from the cursor columns and rows.

It formats the date and number type columns to string.

Uses the **TU_CHAR_NUMBER** function! Included!

Parameters:

-    *I_CURSOR*            the cursor to transform to list of CSV strings
-    *I_SEPARATOR*         the field separator/delimiter
-    *I_ENCLOSED_BY*       the optional encloser (both left and right)
-    *I_DATE_FORMAT*       for date type columns
-    *I_DECIMAL_SYMBOL*    for number formatting
-    *I_DECIMALS*          for number formatting
-    *I_THOUSAND_SYMBOL*   for number formatting

Sample:

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

    "AMERICAN","2016.07.04","H","MON"



----------------------------------

### F_SELECT_TO_CSV_LIST

The **F_SELECT_TO_CSV_LIST** creates a CSV string list from the result of the given select statement.

You can format the columns to string or leave the formatting to the function.

To formatting the function will use the formatting parameters.

Parameters:

-    *I_SELECT*            the select to transform to list of CSV strings
-    *I_SEPARATOR*         the field separator/delimiter
-    *I_ENCLOSED_BY*       the optional encloser (both left and right)
-    *I_DATE_FORMAT*       default date format for date type fields to convert to string
-    *I_DECIMAL_SYMBOL*    decimal symbol for number to string formatting
-    *I_DECIMALS*          number of decimals for number to string formatting
-    *I_THOUSAND_SYMBOL*   thousand separator for number to string formatting

Sample:

    select * from table( F_SELECT_TO_CSV_LIST( 'select * from CA_CALENDAR_DAY_CHANGES order by 1,2', ',', '"' ) ) 

Result:

    "AMERICAN","2016.07.04","H","MON"


-------------------------------

### P_SELECT_TO_CSV_FILE

The **P_SELECT_TO_CSV_FILE** procedure creates a CSV file from the given select statement.

Similar to the F_SELECT_TO_CSV_LIST you can convert the various data types to string in the column list of the select, or use automatic conversion as specified in parameters.

Parameters:

-    *I_SELECT*            the select to transform to CSV file
-    *I_DIRECTORY*         Oracle directory for the target file
-    *I_FILE_NAME*         File name of the target file
-    *I_SEPARATOR*         the field separator/delimiter
-    *I_ENCLOSED_BY*       the optional encloser (both left and right)
-    *I_DATE_FORMAT*       default date format for date type fields to convert to string
-    *I_DECIMAL_SYMBOL*    decimal symbol for number to string formatting
-    *I_DECIMALS*          number of decimals for number to string formatting
-    *I_THOUSAND_SYMBOL*   thousand separator for number to string formatting


Sample:

    begin
        P_SELECT_TO_CSV_FILE( 'select * from CA_CALENDAR_DAY_CHANGES order by 1,2'
                            , 'FILEIO'
                            , 'CA_CALENDAR_DAY_CHANGES.csv'
                            , ';'
                            , '"' 
                            );
    end;

Result:

    cat CA_CALENDAR_DAY_CHANGES.csv

    "AMERICAN";"2016.07.04";"H";"MON"


-------------------------------

