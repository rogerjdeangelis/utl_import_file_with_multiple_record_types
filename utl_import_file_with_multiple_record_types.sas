Import file with multiple record types

Same result in SAS and WPS.

   Two Solutions
       1. WPS/SAS Base
       2. WPS/PROC R (you do need to load the entire file into memory)


github
https://github.com/rogerjdeangelis/utl_import_file_with_multiple_record_types

https://tinyurl.com/y8bca5ba
https://stackoverflow.com/questions/50439646/import-file-with-multiple-record-types

Katia profile
https://stackoverflow.com/users/2355634/katia

I have file with mutiple header records and data records.

INPUT  Very simple text file
============================

 "d:/txt/utl_import_file_with_multiple_record_types.txt"

 HAAABBB    ** header record which AAA and BBB categories
 D12345     ** mutiple data records
 D23456

 HCCCDDD    ** header record which CCC and DDD categories
 D67890
 D89645

EXAMPLE OUTPUT
--------------

 WORK.WANT total obs=4

  V1     V2       V3

  AAA    BBB    12345    ** both data records have the same categories
  AAA    BBB    23456

  CCC    DDD    67890
  CCC    DDD    89645


PROCESS
=======

 1. WPS/SAS Base

    data want;

     infile "d:/txt/utl_import_file_with_multiple_record_types.txt" ;

     input #1 @2 v1 $3. @5 v2 $3.
           #2 @2 v3;
     output;

     input @2 v3;
     output;

    run;quit;


 2. WPS/Proc R  (working code)

    rawtext <- readLines("d:/txt/utl_import_file_with_multiple_record_types.txt");

    headers.loc <- which (startsWith(rawtext,"H"));
    values.loc <- which (startsWith(rawtext,"D"));

    values <- substring(rawtext[values.loc],2);

    hv <- sapply(values.loc,FUN=function(x){ max(which( x-headers.loc >0)) });

    want <- data.frame(v1 = substring(rawtext[headers.loc[hv]], 2, 4),
                     v2 = substring(rawtext[headers.loc[hv]], 5, 7),
                     v3 = values);

OUTPUT
======

  WORK.WANTWPS total obs=4

      V1     V2      V3

      AAA    BBB    12345
      AAA    BBB    23456
      CCC    DDD    67890
      CCC    DDD    89645

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data _null_;
 file "d:/txt/utl_import_file_with_multiple_record_types.txt";
 informat typ $1. vars $8.;
 input;
 put _infile_;
cards4;
HAAABBB
D12345
D23456
HCCCDDD
D67890
D89645
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;


%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
data wrk.wantwpsbase;

 infile "d:/txt/utl_import_file_with_multiple_record_types.txt" ;

 input #1 @2 v1 $3. @5 v2 $3.
       #2 @2 v3;
 output;

 input @2 v3;
 output;

run;quit;
');


%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk  sas7bdat "%sysfunc(pathname(work))";
libname hlp  sas7bdat "C:\Progra~1\SASHome\SASFoundation\9.4\core\sashelp";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
rawtext <- readLines("d:/txt/utl_import_file_with_multiple_record_types.txt");

headers.loc <- which (startsWith(rawtext,"H"));
values.loc <- which (startsWith(rawtext,"D"));

values <- substring(rawtext[values.loc],2);

hv <- sapply(values.loc,FUN=function(x){ max(which( x-headers.loc >0)) });

want <- data.frame(v1 = substring(rawtext[headers.loc[hv]], 2, 4),
                 v2 = substring(rawtext[headers.loc[hv]], 5, 7),
                 v3 = values);
endsubmit;
import r=want  data=wrk.wantwps;
run;quit;
');

