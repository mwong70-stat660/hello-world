/* Import data from URL into sas file */
filename cgd temp;
proc http
        out=cgd
        url="https://raw.githubusercontent.com/mwong70-stat660/hello-world/main/data/cgd.csv"
        method="get"
    ;
run;

options validvarname=any;
proc import
        file=cgd
        out=work.cgd
        replace
        dbms=csv
    ;
    getnames=no;
run;



ods html;
ods graphics on;



/* Explore variable types using contents procedure */
proc contents
        data=cgd
        order=varnum
    ;
    title 'Contents Using the ORDER= Option';
run;
title;

/* Exploratory analysis using lifetest procedure */
* non parametric;
/*
proc lifetest <options>;
    time var < *censor(list) > ;
    by variables ;
    freq variable ;
    id variables ;
    strata variable <(list)> ;
    survival options ;
    test variables ; 
run;
*/

proc lifetest
        data=cgd plots=(s,ls,lls);
        time 


ods html close;
ods graphics off;
quit;
