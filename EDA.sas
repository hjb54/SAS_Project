* EDA Code: Titanic Survival Analysis ;
/*  */
/* DATA & SORTING */
/*  */
data titanic;
    infile "/home/u64127570/sasuser.v94/titanic-passengers.csv" dlm=";" dsd missover firstobs=2; *most finicky dataset ever;
    length Name $ 60; 
    input PassengerId : Survived $ : Pclass : Name $ : Sex $ : Age : SibSp : Parch : Ticket $ : Fare; *keeps everything seperated so missing values can be dealt with;
run;

data titanic2; *dealing with missing values, replacing with -99 to easily sort out when using;
    set titanic;
    if Age = "" then Age = -99;
    if SibSp = "" then SibSp = -99;
    if Parch = "" then Parch = -99;
    if Fare = "" then Fare = -99;
run;

*sorted data set by survival;
proc sort data = titanic2 out= tit_surv;
	by Survived;
run;

data tit_surv01;
    set tit_surv;
    if Survived = 'Yes' then SurvivedNum = 1;
    else if Survived = 'No' then SurvivedNum = 0;
run;


*sorted data set by sex;
proc sort data = titanic2 out= tit_sex;
	by Sex;
run;

*sorted data set by pclass;
proc sort data = titanic2 out= tit_class;
	by Pclass;
run;
data tit_class;
    set tit_class;
    if Survived = 'Yes' then surv_num = 1;
    else if Survived = 'No' then surv_num = 0;
run;

*sorted data set by fare;
proc sort data = titanic2 out= tit_fare;
	by Fare;
run;

*making fare groups for corr calculations;

data fare_groups;
	set tit_fare;
	length faregroup $10; 
    do i = 0 to 520 by 5; /*sas for loop */
        if fare >= i and fare < i + 5 then faregroup = cats(i, '-', i + 5);
    end;
run;
*changing from qual to quant data;
data fare_groups;
    set fare_groups;
    if Survived = 'Yes' then surv_num = 1;
    else if Survived = 'No' then surv_num = 0;
run;

*repeating the above for age;
data age_groups;
	set titanic2;
	where Age ne -99;
	length agegroup $10; 
    do i = 0 to 90 by 3; *sas for loop;
        if age >= i and age < i + 3 then agegroup = cats(i, '-', i + 3);
    end;
run;
*changing from qual to quant data;
data age_groups;
    set age_groups;
    if Survived = 'Yes' then surv_num = 1;
    else if Survived = 'No' then surv_num = 0;
run;

/*  */
/* HBAR and VBAR charts */
/*  */
proc gchart data=tit_surv;
	title "Distribution of Age and Class by Survival";
    by Survived;
    vbar Age/ group= Pclass; *vbar version- I prefer this one, easier to see the differences in distrubution;
    where Age ne -99;
run;

proc gchart data=tit_surv;
	title "Distribution of Age and Class by Survival";
    by Survived;
    hbar Age/subgroup= Pclass; *hbar version;
    where Age ne -99;
run;

proc gchart data = tit_surv;
	title "Distribution of Sex and Class by Survival";
	by Survived;
	vbar Sex/group = Pclass; *vbar version;
	where Age ne -99;
run;

proc gchart data = tit_surv;
	title "Distribution of Sex and Class by Survival";
	by Survived;
	hbar Sex/subgroup = Pclass; *hbar version- I prefer this one, too much whitespace in the vbar and easier to see sex distribution;
	where Age ne -99;
run; 

/*  */
/* Pie Charts */
/*  */
proc gchart data = tit_surv;
	title "Survival Pie Chart";
	pie Survived;
run;

proc gchart data = tit_sex;
	title "Survival Pie Chart by Sex";
	pie Survived/group= sex;
run;

proc gchart data = tit_class;
	title "Survival Pie Chart by Class";
	pie Survived/group= Pclass;
run;

/*  */
/* Stats */
/*  */
proc freq data = tit_sex ;
	title "Distribution of Survival and Class by Sex";
	table Survived*Pclass;
	by Sex;
run;

proc freq data = tit_class ;
	title "Distribution of Survival and Age by Class";
	where Age ne -99;
	table Survived*Age;
	by Pclass;
run;

proc freq data = tit_sex ;
	title "Distribution of Survival and Age by Sex";
	where Age ne -99;
	table Survived*Age;
	by Sex;
run;

proc univariate data = tit_surv noprint; * this makes 2 graphs, survived(yes) and survived(no), trying something we haven't used in class;
	title "Fare by Survival Status";
	class Survived;
	where Fare ne -99;
	histogram Fare/normal midpoints= (0 to 525 by 5);
	inset mean= "Average"(6.3) std="Standard Dev"(4.3) skewness="Skew"(5.3) kurtosis = "Kurt"(5.3)  /pos = NE;
run;

proc univariate data = tit_surv noprint; * this makes 2 graphs, survived(yes) and survived(no), trying something we haven't used in class;
	title "Fare by Survival Status and Sex";
	class Survived Sex;
	where Fare ne -99;
	histogram Fare/normal midpoints= (0 to 525 by 5);
	inset mean= "Average"(6.3) std="Standard Dev"(4.3) skewness="Skew"(5.3) kurtosis = "Kurt"(5.3)  /pos = NE;
run;
/* proc sgplot data= titanic2; */
/*     series x=survived y= fare / group=Survived; */
/*     xaxis label="Survival Status"; */
/*     yaxis label="Fare"; */
/*     xaxis discreteorder=data; */
/*     keylegend / location=inside position=NW across=1; */
/* run; */
/* ^ looks even worse, trying another thing */
/*  */
/* proc sgpanel data=titanic2; */
/*     panelby Survived / columns=1 spacing=5; *seperates panels by survival status, side by side for better comparison; */
/*     vbar Age / response=Fare stat=mean; *looking at age and fare, states avg fare per age; */
/*     where Age ne -99 and Fare ne -99; */
/*     colaxis label="Age" values= (0 to 81 by 2); */
/*     rowaxis label="Mean Fare"; *doesnt actually do calculations, so univaraite wins. leaving for future reference; */
/* run; */

proc univariate data = tit_surv noprint; * this makes 2 graphs, survived(yes) and survived(no);
	title "Age by Survival Status";
	class Survived;
	where Age ne -99;
	histogram Age/normal midpoints= (0 to 81 by 2);
	inset mean= "Average"(6.3) std="Standard Dev"(4.3) skewness="Skew"(5.3) kurtosis = "Kurt"(5.3)  /pos = NE;
run;

proc univariate data = tit_surv noprint; * this makes 4 graphs, survived(yes):M F and survived(no): M F;
	title "Age by Survival Status and Sex";
	class Survived Sex;
	where Age ne -99;
	histogram Age/normal midpoints= (0 to 81 by 2);
	inset mean= "Average"(6.3) std="Standard Dev"(4.3) skewness="Skew"(5.3) kurtosis = "Kurt"(5.3)  /pos = NE;
run;

/*  */
/* *everything below is to make a correlation graph of fare and survival percent; */
/*  */
proc means data=fare_groups noprint;
    class faregroup;
    var surv_num;
    output out=summary sum=surv_c n=tot_c;
run;

data per;
    set summary;
    if _TYPE_ = 1;*total per group instead of entire dataset;
    surv_per= (surv_c/tot_c) * 100;
run;
*got sorting errors even tho it should be sorted, resorting;
proc sort data=fare_groups;
    by FareGroup;
run;

proc sort data=per;
    by FareGroup;
run;

data fare_groups_per;
    merge fare_groups(in=a) per(in=b); *merge;
    by faregroup; 
    if a; *only fare_groups vars kept; 
run;
/* proc print data=fare_groups_per; */
/*     var faregroup surv_c tot_c surv_per; */
/* run; */

proc corr data = fare_groups_per plots=scatter;
	title "Fare vs Percent Survival";
	var fare surv_per;
run;

/*  */
/* correlation graph for age vs percent survival by sex */
/*  */
proc sort data = age_groups;
	by sex;
run;

proc means data=age_groups noprint;
    class agegroup;
    var surv_num;
    by sex;
    output out=summary sum=surv_c n=tot_c;
run;

data per;
    set summary;
    if _TYPE_ = 1;*total per group instead of entire dataset;
    surv_per= (surv_c/tot_c) * 100;
run;
*got sorting errors even tho it should be sorted, resorting;
proc sort data=age_groups;
    by ageGroup;
run;

proc sort data=per;
    by ageGroup;
run;

data age_groups_per;
    merge age_groups(in=a) per(in=b); *merge;
    by agegroup; 
    if a; *only age_groups vars kept; 
run;

proc sort data = age_groups_per;
	by sex;
run;

proc corr data = age_groups_per plots=scatter;
	title "Age vs Percent Survival";
	where Age ne -99;
	var age surv_per;
	by sex;
run;

/*  */
/* correlation graph class vs percent survival */
/*  */
proc means data=tit_class noprint;
    class Pclass;
    var surv_num;
    output out=summary sum=surv_c n=tot_c;
run;

data per;
    set summary;
    if _TYPE_ = 1;*total per group instead of entire dataset;
    surv_per= (surv_c/tot_c) * 100;
run;

proc sort data = tit_class;
	by pclass;
run;

proc sort data = per;
	by pclass;
run;

data class_per;
    merge tit_class(in=a) per(in=b); *merge;
    by pclass; 
    if a; *only tit_class vars kept; 
run;

proc corr data = class_per plots=scatter;
	title "Class vs Percent Survival";
	var pclass surv_per;
run;

*same but by sex----- NOT WORKING, more datapoints on Female than expected, messing up calculations. only happening to Female. Attempts to debug havent worked;
/* proc sort data = tit_class; */
/* 	by sex; */
/* run; */
/*  */
/* proc means data=tit_class noprint; */
/*     class Pclass; */
/*     var surv_num; */
/*     by sex; */
/*     output out=summary sum=surv_c n=tot_c; */
/* run; */
/* data per; */
/*     set summary; */
/*     if _TYPE_ = 1;*total per group instead of entire dataset; */
/*     surv_per= (surv_c/tot_c) * 100; */
/* run; */
/*  */
/* proc sort data = tit_class; */
/* 	by pclass; */
/* run; */
/*  */
/* proc sort data = per; */
/* 	by pclass; */
/* run; */
/*  */
/* data class_per_g; */
/*     merge tit_class(in=a) per(in=b); *merge; */
/*     by pclass;  */
/*     if a; *only tit_class vars kept;  */
/* run; */
/*  */
/* proc sort data = class_per_g; */
/* 	by sex; */
/* run; */
/*  */
/* proc corr data = class_per_g plots = scatter; */
/* 	title "Class vs Percent Survival by Sex"; */
/* 	var pclass surv_per; */
/* 	by sex; */
/* run; */


data titanic_dummy;
set titanic;
run;

/* Data pre processing, replaced missing age values for the mean, used one-hot encoding to
transform categorical variables such as survival and sex to binary attributes so the model can
properly evaluate them*/

PROC MEANS DATA=titanic_dummy NOPRINT;
 VAR age;
 OUTPUT OUT=mean_age MEAN=mean_age;
RUN;

DATA titanic_imputed;
 IF _N_ = 1 THEN SET mean_age; 
 SET titanic_dummy;
 IF age = . THEN age = mean_age;
RUN;


DATA titanic_encoded;
 SET titanic_imputed;
 IF sex = 'male' THEN sex_encoded = 1;
 ELSE sex_encoded = 0;
RUN;

Data full_encoded;
	set titanic_encoded;
	if Survived = 'Yes' then survived_encoded = 1;
	else survived_encoded = 0;
run;


/* ran PCA here to determine how many components to use for logistic regression model.
age was the first principle component, accounting for about 35% of covariance based on passenger surviving
You can see in the covariance matrix that age, fare, pclass, and sex account for 90% of variance (these four variables
account for roughly 91% of the variability) which is a good threshold to evaluate the model at so I only used
those four in the model. */
proc princomp data=full_encoded out=pca_out ;
   var  sex_encoded fare Pclass Age sibsp;
run;

/* logistic model displaying sex, here we notice that fare is statistically insignificant in the model*/

PROC LOGISTIC DATA=full_encoded plots = (effect roc);
 MODEL survived_encoded (EVENT='1') = sex_encoded age Pclass fare ;
 output out=pred_data pred=predicted;
RUN;

/*  logistic regression model displaying age*/

proc logistic data=full_encoded plots = (effect);
 model survived_encoded (event='1') = age sex_encoded Pclass ;
 output out=pred_data pred=predicted;
run;

/* logistic model displaying Pclass*/

proc logistic data=full_encoded plots = effect;
 model survived_encoded (EVENT='1') =  Pclass age sex_encoded ;
 output out=pred_data2 pred=predicted2;
run;


