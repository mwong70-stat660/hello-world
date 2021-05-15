/* Import data from URL into sas file. */
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
        out=cgd_raw
        replace
        dbms=csv
    ;
    getnames=yes;
run;


/* Activate SAS output graphics option */
ods html;
ods graphics on;


/* Data preparation */
data cgd_raw;
    drop var1;
    set cgd_raw;


title
"Contents Using the ORDER= Option"
;

/* Explore variable types using contents procedure */
proc contents
        data=cgd_raw
        order=varnum
    ;
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


footnote1 
""
;

/* OR and RR for treatment by status by FREQ procedure */
proc freq
        data=cgd_raw
    ;
    tables
        treat*status
        / chisq relrisk
    ;
    title
        "The Effect of Treatment Levels on Status"
    ;
run;

footnote;


/* 2x2 contingency table by Sex*/
proc freq
        data=cgd_raw
        order=freq
    ;
    tables
        centre
        sex*status*treat
    ;
    title
        "2x2 Contigency table for gender by status and treatment"
    ;
run;
title;


/* Product-Limit Survival Estimates by Treatment*/
proc lifetest
        data=cgd_raw
        notable
        plots=(lls, h)
    ;
    time
        time*status(1)
    ;
    strata
        treat
    ;
    title
        "Product-Limit Survival Estimates"
    ;
    title2
        "Strata=treat(0=placebo 1=Interferon)"
    ;
run;

footnote1 justify=left
"The Product-Limit Survival Estimates graph shows an obvious difference in survival time by treatment levels."
;

footnote2 justify=left
"Stratification by treat(0=Placebo 1=Interferon)."
;

footnote3 justify=left
"Log of hazard function appears to converge slightly."
;

title;
footnote;



/* Product-Limit Survival Estimates by Pattern*/
proc lifetest
        data=cgd_raw
        notable
        plots=(lls, h)
    ;
    time
        time*status(1)
    ;
    strata
        pattern
    ;
/*    title*/
/*        "Product-Limit Survival Estimates by Pattern"*/
/*    ;*/
/*    title2*/
/*        "Strata=pattern(1=x-linked 2=autosomal recessive)"*/
/*    ;*/
run;

footnote1 justify=left
"The Product-Limit Survival Estimates graph shows an obvious difference in survival time by treatment levels."
;

footnote2 justify=left
"Stratification by genetic pattern(1=x-linked 2=autosomal recessive)."
;

footnote3 justify=left
"Log of hazard function appears somewhat linear with slope greater than 1. This suggests that Weibull distribution might not be the best fit since it violates the assumptions."
;

title;
footnote;

/*/* Base-category logit model */*/
/*proc logistic*/
/*        data=cgd_raw*/
/*    ;*/
/*    where*/
/*        status+treat ne 0*/
/*    ;*/
/*    model*/
/*        status=time*/
/*        /link=glogit*/
/*    ;*/
run;


footnote1 justify=left
"Joint tests for full-rank parameterizations of full model. The AIC with covariates is slightly less than AIC without covariates."
;

footnote2 justify=left
"Results from the Type 3 Tests of individual model effects show an effect of interferon (Treat=1) on patient's survival (p<0.0019), but no effect of other variables individually and stratified by Centre."
;

/* Model fit of the full model */
proc phreg
        data=cgd_raw
    ;
    class
        anti(ref="1")
        pattern(ref="1")
        treat(ref="0")
    ;
    model
        time*status(0)=
            age
            anti
            cort
            pattern
            sex
            treat
        /type3
            ties=
            breslow
/*            discrete*/
/*            efron*/
/*            exact*/
    ;
    strata
        centre
    ;
/*    assess ph*/
/*        /resample*/
/*    ;*/
    title
        "Model fit of full model by Centre"
    ;
run;
title;
footnote;


footnote1 justify=left
"Because"
;

/* Model reduction */
proc phreg
        data=cgd_raw
    ;
    class
        anti(ref="1")
        pattern(ref="1")
        treat(ref="0")
    ;
    model
        time*status(0)=
            age
            anti
/*            cort*/
            pattern
            sex
            treat
            / ties=efron
                selection=stepwise
    ;
    strata
        centre
    ;
/*    assess ph*/
/*        /resample*/
/*    ;*/
    title
        "Model reduction"
    ;
run;
title;


title1 justify=left
"Full Model with genetic Pattern effects"
;

proc phreg
        data=cgd_raw
    ;
    model
        time*status(0)=
            age
            anti
            centre
            cort
            sex
            treat
        /ties=
            efron
        ;
    strata
        pattern
    ;
run;
title;


title1 justify=left
"Reduced Model with genetic Pattern effects"
;

proc phreg
        data=cgd_raw
    ;
    class
        pattern
    ;           
    model
        time*status(0)=
            age
/*            anti      *removed first; */
/*            centre    *removed fourth;*/
/*            cort      *removed second; */
/*            sex       *removed third; */
            anti
            centre
            cort
            sex
            treat
/*        /ties=*/
/*            efron*/
/*        selection=*/
/*            backward*/
/*        slstay=0.05*/
        ;
run;
title;


/* Assuming the effects of covariates are the same for all Pattern levels */
proc phreg
        data=cgd_raw
    ;
    class
        treat
    ;
    model
        time*status(0)=
            age
            anti
            centre
            cort
/*            pattern*/
            sex
            treat
    / ties=
            efron
    ;
/*    strata*/
/*        centre*/
/*    ;*/
    assess ph
        / resample
    ;
run;



/* Deactivate SAS output graphics */
ods html close;
ods graphics off;
quit;
