///logfile
log using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/log_Football.smcl", append

///import csv files
#delimit;
import delimited "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player.csv";
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player.dta";
clear;

import delimited "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_Attributes.csv";
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_Attributes.dta";
#delimit;
clear;

import delimited "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Country.csv";
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Country.dta";
clear;

import delimited "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Team.csv";
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Team.dta";
clear;

import delimited "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Team_Attributes.csv";
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Team_Attributes.dta";
clear;

import delimited "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Match.csv";
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Match.dta";
clear;

import delimited "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/League.csv";
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/League.dta";
clear;

import excel "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/50Transfers.xlsx", sheet("Sheet1") cellrange(A1:G51) firstrow;
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/50transfers.dta", replace;
clear;

///Time-invariant characteristics
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player.dta"

gen double birthdaytime = clock(birthday, "YMDhms")
format birthdaytime %tc //format birthday with seconds

generate birthdaytime1=dofc(birthdaytime) //seconds dropped
format birthdaytime1 %td

gen birthyear=year(birthdaytime1) //extract birthyear
format birthdaytime1 %td

save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player.dta", replace

///Collapse time-variant characteristics to quarterly averages
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_Attributes.dta"

drop gk_* //drop goalkeeper information

#delimit;
merge m:1 player_api_id using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player.dta", 
keepusing (player_name birthyear height weight) nogenerate; //merge time-invariant variables

gen double dateinfo = clock(date, "YMDhms")
format dateinfo %tc //with seconds

generate dateinfo1=dofc(dateinfo) //seconds dropped
format dateinfo1 %td

gen yearinfo=year(dateinfo1) //extract year of information
format yearinfo %ty

generate quarterinfo=qofd(dofc(dateinfo)) //extract quarter of information
format quarterinfo %tq

ds, has(type string) //list string variables
foreach x of varlist preferred_foot attacking_work_rate defensive_work_rate {
	encode `x', generate(`x'_num)
	label list `x'_num
}

replace preferred_foot_num = 0 if preferred_foot_num==1 //left foot is zero
replace preferred_foot_num = 1 if preferred_foot_num==2 //right foot is one

generate age=yearinfo-birthyear

#delimit;
collapse (mean) overall_rating potential crossing finishing heading_accuracy short_passing volleys 
dribbling curve free_kick_accuracy long_passing ball_control acceleration sprint_speed agility 
reactions balance shot_power jumping stamina strength long_shots aggression interceptions positioning 
vision marking standing_tackle sliding_tackle 
preferred_foot_num attacking_work_rate_num defensive_work_rate_num yearinfo 
height weight birthyear age,
by (player_api_id quarterinfo); //collapse to quarterly means

#delimit;
merge m:1 player_api_id using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player.dta", 
keepusing (player_name) nogenerate; //rematch playername

save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_Attributes.dta"

#delimit;
collapse (mean) overall_rating potential crossing finishing heading_accuracy short_passing volleys 
dribbling curve free_kick_accuracy long_passing ball_control acceleration sprint_speed agility 
reactions balance shot_power jumping stamina strength long_shots aggression interceptions positioning 
vision marking standing_tackle sliding_tackle
preferred_foot_num attacking_work_rate_num defensive_work_rate_num quarterinfo
height weight birthyear age, 
by (player_api_id yearinfo); //collapse to yearly means

#delimit;
merge m:1 player_api_id using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player.dta", 
keepusing (player_name) nogenerate; //rematch playername

save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgyr.dta"
clear

////match to team variables: home and away team id
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Match.dta"

gen double dateinfo = clock(date, "YMDhms")
format dateinfo %tc //with seconds

generate dateinfo1=dofc(dateinfo) //seconds dropped
format dateinfo1 %td

gen yearinfo=year(dateinfo1) //extract year of information
format yearinfo %ty

generate quarterinfo=qofd(dofc(dateinfo)) //extract quarter of information
format quarterinfo %tq

replace home_player_y1=home_player_1 if home_player_y1==1
replace home_player_y1=home_player_2 if home_player_y1==2
replace home_player_y1=home_player_3 if home_player_y1==3

replace home_player_y2=home_player_1 if home_player_y2==1
replace home_player_y2=home_player_2 if home_player_y2==2
replace home_player_y2=home_player_3 if home_player_y2==3

replace home_player_y3=home_player_3 if home_player_y3==3
replace home_player_y3=home_player_4 if home_player_y3==4
replace home_player_y3=home_player_5 if home_player_y3==5

replace home_player_y4=home_player_3 if home_player_y4==3
replace home_player_y4=home_player_4 if home_player_y4==4
replace home_player_y4=home_player_5 if home_player_y4==5

replace home_player_y5=home_player_3 if home_player_y5==3
replace home_player_y5=home_player_4 if home_player_y5==4
replace home_player_y5=home_player_5 if home_player_y5==5
replace home_player_y5=home_player_6 if home_player_y5==6
replace home_player_y5=home_player_7 if home_player_y5==7
replace home_player_y5=home_player_8 if home_player_y5==8

replace home_player_y6=home_player_3 if home_player_y6==3
replace home_player_y6=home_player_4 if home_player_y6==4
replace home_player_y6=home_player_5 if home_player_y6==5
replace home_player_y6=home_player_6 if home_player_y6==6
replace home_player_y6=home_player_7 if home_player_y6==7
replace home_player_y6=home_player_8 if home_player_y6==8
replace home_player_y6=home_player_8 if home_player_y6==9

replace home_player_y7=home_player_3 if home_player_y7==3
replace home_player_y7=home_player_4 if home_player_y7==4
replace home_player_y7=home_player_5 if home_player_y7==5
replace home_player_y7=home_player_6 if home_player_y7==6
replace home_player_y7=home_player_7 if home_player_y7==7
replace home_player_y7=home_player_8 if home_player_y7==8
replace home_player_y7=home_player_9 if home_player_y7==9

replace home_player_y8=home_player_3 if home_player_y8==3
replace home_player_y8=home_player_4 if home_player_y8==4
replace home_player_y8=home_player_5 if home_player_y8==5
replace home_player_y8=home_player_6 if home_player_y8==6
replace home_player_y8=home_player_7 if home_player_y8==7
replace home_player_y8=home_player_8 if home_player_y8==8
replace home_player_y8=home_player_9 if home_player_y8==9
replace home_player_y8=home_player_10 if home_player_y8==10

replace home_player_y9=home_player_1 if home_player_y9==1
replace home_player_y9=home_player_2 if home_player_y9==2
replace home_player_y9=home_player_3 if home_player_y9==3
replace home_player_y9=home_player_4 if home_player_y9==4
replace home_player_y9=home_player_5 if home_player_y9==5
replace home_player_y9=home_player_6 if home_player_y9==6
replace home_player_y9=home_player_7 if home_player_y9==7
replace home_player_y9=home_player_8 if home_player_y9==8
replace home_player_y9=home_player_9 if home_player_y9==9
replace home_player_y9=home_player_10 if home_player_y9==10

replace home_player_y10=home_player_3 if home_player_y10==3
replace home_player_y10=home_player_4 if home_player_y10==4
replace home_player_y10=home_player_5 if home_player_y10==5
replace home_player_y10=home_player_6 if home_player_y10==6
replace home_player_y10=home_player_7 if home_player_y10==7
replace home_player_y10=home_player_8 if home_player_y10==8
replace home_player_y10=home_player_9 if home_player_y10==9
replace home_player_y10=home_player_10 if home_player_y10==10
replace home_player_y10=home_player_11 if home_player_y10==11 

replace home_player_y11=home_player_1 if home_player_y11==1
replace home_player_y11=home_player_2 if home_player_y11==2
replace home_player_y11=home_player_3 if home_player_y11==3
replace home_player_y11=home_player_4 if home_player_y11==4
replace home_player_y11=home_player_5 if home_player_y11==5
replace home_player_y11=home_player_6 if home_player_y11==6
replace home_player_y11=home_player_7 if home_player_y11==7
replace home_player_y11=home_player_8 if home_player_y11==8
replace home_player_y11=home_player_9 if home_player_y11==9
replace home_player_y11=home_player_10 if home_player_y11==10
replace home_player_y11=home_player_11 if home_player_y11==11
//replace homeplayer field position indicators with player_api_id


save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"

rename home_player_y1 player_api_id
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
//match if player was a gk in a homematch of a team in a matching quarter, only observations that are matched from master
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

#delimit;
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y1  
rename home_player_y2 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y2  
rename home_player_y3 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y3  
rename home_player_y4 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y4  
rename home_player_y5 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y5  
rename home_player_y6 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y6  
rename home_player_y7 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y7  
rename home_player_y8 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y8  
rename home_player_y9 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y9  
rename home_player_y10 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y10  
rename home_player_y11 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta",
keepusing (home_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta"
rename player_api_id home_player_y11  
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta", replace
clear

///same for away team id
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Match.dta"
replace away_player_y1=away_player_1 if away_player_y1==1
replace away_player_y1=away_player_2 if away_player_y1==2
replace away_player_y1=away_player_3 if away_player_y1==3

replace away_player_y2=away_player_1 if away_player_y2==1
replace away_player_y2=away_player_2 if away_player_y2==2
replace away_player_y2=away_player_3 if away_player_y2==3

replace away_player_y3=away_player_3 if away_player_y3==3
replace away_player_y3=away_player_4 if away_player_y3==4
replace away_player_y3=away_player_5 if away_player_y3==5

replace away_player_y4=away_player_3 if away_player_y4==3
replace away_player_y4=away_player_4 if away_player_y4==4
replace away_player_y4=away_player_5 if away_player_y4==5

replace away_player_y5=away_player_3 if away_player_y5==3
replace away_player_y5=away_player_4 if away_player_y5==4
replace away_player_y5=away_player_5 if away_player_y5==5
replace away_player_y5=away_player_6 if away_player_y5==6
replace away_player_y5=away_player_7 if away_player_y5==7
replace away_player_y5=away_player_8 if away_player_y5==8

replace away_player_y6=away_player_3 if away_player_y6==3
replace away_player_y6=away_player_4 if away_player_y6==4
replace away_player_y6=away_player_5 if away_player_y6==5
replace away_player_y6=away_player_6 if away_player_y6==6
replace away_player_y6=away_player_7 if away_player_y6==7
replace away_player_y6=away_player_8 if away_player_y6==8
replace away_player_y6=away_player_8 if away_player_y6==9

replace away_player_y7=away_player_3 if away_player_y7==3
replace away_player_y7=away_player_4 if away_player_y7==4
replace away_player_y7=away_player_5 if away_player_y7==5
replace away_player_y7=away_player_6 if away_player_y7==6
replace away_player_y7=away_player_7 if away_player_y7==7
replace away_player_y7=away_player_8 if away_player_y7==8
replace away_player_y7=away_player_9 if away_player_y7==9

replace away_player_y8=away_player_3 if away_player_y8==3
replace away_player_y8=away_player_4 if away_player_y8==4
replace away_player_y8=away_player_5 if away_player_y8==5
replace away_player_y8=away_player_6 if away_player_y8==6
replace away_player_y8=away_player_7 if away_player_y8==7
replace away_player_y8=away_player_8 if away_player_y8==8
replace away_player_y8=away_player_9 if away_player_y8==9
replace away_player_y8=away_player_10 if away_player_y8==10

replace away_player_y9=away_player_1 if away_player_y9==1
replace away_player_y9=away_player_2 if away_player_y9==2
replace away_player_y9=away_player_3 if away_player_y9==3
replace away_player_y9=away_player_4 if away_player_y9==4
replace away_player_y9=away_player_5 if away_player_y9==5
replace away_player_y9=away_player_6 if away_player_y9==6
replace away_player_y9=away_player_7 if away_player_y9==7
replace away_player_y9=away_player_8 if away_player_y9==8
replace away_player_y9=away_player_9 if away_player_y9==9
replace away_player_y9=away_player_10 if away_player_y9==10

replace away_player_y10=away_player_3 if away_player_y10==3
replace away_player_y10=away_player_4 if away_player_y10==4
replace away_player_y10=away_player_5 if away_player_y10==5
replace away_player_y10=away_player_6 if away_player_y10==6
replace away_player_y10=away_player_7 if away_player_y10==7
replace away_player_y10=away_player_8 if away_player_y10==8
replace away_player_y10=away_player_9 if away_player_y10==9
replace away_player_y10=away_player_10 if away_player_y10==10
replace away_player_y10=away_player_11 if away_player_y10==11 

replace away_player_y11=away_player_1 if away_player_y11==1
replace away_player_y11=away_player_2 if away_player_y11==2
replace away_player_y11=away_player_3 if away_player_y11==3
replace away_player_y11=away_player_4 if away_player_y11==4
replace away_player_y11=away_player_5 if away_player_y11==5
replace away_player_y11=away_player_6 if away_player_y11==6
replace away_player_y11=away_player_7 if away_player_y11==7
replace away_player_y11=away_player_8 if away_player_y11==8
replace away_player_y11=away_player_9 if away_player_y11==9
replace away_player_y11=away_player_10 if away_player_y11==10
replace away_player_y11=away_player_11 if away_player_y11==11
//replace awayplayer field position indicators with player_api_id


save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"

rename away_player_y1 player_api_id
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
//match if player was a gk in a awaymatch of a team in a matching quarter, only observations that are matched from master
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

#delimit;
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y1  
rename away_player_y2 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y2  
rename away_player_y3 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y3  
rename away_player_y4 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y4  
rename away_player_y5 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y5  
rename away_player_y6 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y6  
rename away_player_y7 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y7  
rename away_player_y8 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y8  
rename away_player_y9 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y9  
rename away_player_y10 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y10  
rename away_player_y11 player_api_id 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta"
#delimit;
merge m:m player_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta",
keepusing (away_team_api_id) assert (match master) nogenerate; 
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"
rename player_api_id away_player_y11  
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta", replace
clear

//combining team id
generate team_api_id=home_team_api_id
replace team_api_id=away_team_api_id if team_api_id==.
replace team_api_id=home_team_api_id if team_api_id==.

///player position
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_Match.dta" //homeposition
#delimit;
collapse (firstnm) home_player_y* yearinfo,
by(home_team_api_id quarterinfo); //collapse to first instance of player by quarter

#delimit;
rename home_team_api_id team_api_id;
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_qtrposition.dta", replace;
clear

#delimit;
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta";
merge m:m team_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/homeplayer_qtrposition.dta",
keepusing (home_player_y*) assert (match master) nogenerate;
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

#delimit;
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_Match.dta"; ///awayposition
collapse (firstnm) away_player_y* yearinfo,
by(away_team_api_id quarterinfo); //collapse to first instance of player by quarter

#delimit;
rename away_team_api_id team_api_id;
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_qtrposition.dta", replace;
clear

#delimit;
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta";
merge m:m team_api_id quarterinfo using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/awayplayer_qtrposition.dta",
keepusing (away_player_y*) assert (match master) nogenerate;
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace
clear

generate position=0
replace position=1 if player_api_id==home_player_y1 | player_api_id==away_player_y1 //gk
#delimit;
replace position=2 if player_api_id==home_player_y2 | player_api_id==away_player_y2
					| player_api_id==home_player_y3 | player_api_id==away_player_y3
					| player_api_id==home_player_y4 | player_api_id==away_player_y4
					| player_api_id==home_player_y5 | player_api_id==away_player_y5; //defense
replace position=3 if player_api_id==home_player_y6 | player_api_id==away_player_y6
					| player_api_id==home_player_y7 | player_api_id==away_player_y7
					| player_api_id==home_player_y8 | player_api_id==away_player_y8; //midfield
replace position=4 if player_api_id==home_player_y9 | player_api_id==away_player_y9
					| player_api_id==home_player_y10 | player_api_id==away_player_y10
					| player_api_id==home_player_y11 | player_api_id==away_player_y11; //striker
replace position=. if position==0
drop home_player_y* away_player_y*
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_avgqtr.dta", replace


///set player panels by quarter, fill missing values
#delimit;
collapse (firstnm) overall_rating potential crossing finishing heading_accuracy 
short_passing volleys dribbling curve free_kick_accuracy long_passing ball_control 
acceleration sprint_speed reactions agility balance shot_power jumping stamina strength 
long_shots aggression interceptions positioning vision marking standing_tackle 
preferred_foot_num attacking_work_rate_num defensive_work_rate_num yearinfo 
height weight birthyear age player_name team_api_id position,
by(player_api_id quarterinfo);

drop if player_api_id==.
tsset player_api_id quarterinfo
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_nmqtr.dta";

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_nmqtr.dta"
bysort player_api_id quarterinfo: keep if _n==_N ///keep only first instance within a quarter

tsset player_api_id quarterinfo


tsspell team_api_id, fcond(team_api_id != team_api_id[_n-1])

egen nspells = max(_spell), by(player_api_id)

egen tmax = max(quarterinfo), by(player_api_id _spell)

egen tmin = min(quarterinfo), by(player_api_id _spell)

gen duration = tmax - tmin

gen lastduration = duration if _spell==nspells & _end==1


foreach x of varlist overall_rating potential crossing finishing heading_accuracy short_passing volleys dribbling curve free_kick_accuracy long_passing ball_control acceleration sprint_speed reactions agility balance shot_power jumping stamina strength long_shots aggression interceptions positioning vision marking standing_tackle preferred_foot_num attacking_work_rate_num defensive_work_rate_num yearinfo height weight birthyear age team_api_id position {
	by player_api_id, sort: replace `x' = `x'[_n-1] if `x'==.
} 
///replace missing values within panel from previous values

foreach x of varlist overall_rating potential crossing finishing heading_accuracy short_passing volleys dribbling curve free_kick_accuracy long_passing ball_control acceleration sprint_speed reactions agility balance shot_power jumping stamina strength long_shots aggression interceptions positioning vision marking standing_tackle preferred_foot_num attacking_work_rate_num defensive_work_rate_num yearinfo height weight birthyear age team_api_id position {
	by player_api_id, sort: replace `x' = `x'[_n+1] if `x'==.
} 
///replace remaining missing values within panel from following values

/////lagged variables
foreach x of varlist overall_rating potential crossing finishing heading_accuracy short_passing volleys dribbling curve free_kick_accuracy long_passing ball_control acceleration sprint_speed reactions agility balance shot_power jumping stamina strength long_shots aggression interceptions positioning vision marking standing_tackle {
	generate `x'_l1=L1.`x'
	generate `x'_l2=L2.`x'
	generate `x'_l3=L3.`x'
	generate `x'_l4=L4.`x'
	generate `x'_yearchange=`x'-`x'_l4
} 

foreach x of varlist attacking_work_rate_num defensive_work_rate_num {
	generate `x'_l1=L1.`x'
	generate `x'_l2=L2.`x'
	generate `x'_l3=L3.`x'
	generate `x'_l4=L4.`x'
}

generate attack_yearchange=attacking_work_rate_num-attacking_work_rate_num_l4
generate defense_yearchange=defensive_work_rate_num-defensive_work_rate_num_l4

///adding markers for players in most expensive transfer list
generate top50=0

foreach x of varlist player_api_id {
replace top50=1  if `x'==22543 
replace top50=1  if `x'==24235
replace top50=1  if `x'==25759
replace top50=1  if `x'==30853
replace top50=1  if `x'==30893
replace top50=1  if `x'==31921 
replace top50=1  if `x'==35724 
replace top50=1  if `x'==36378 
replace top50=1  if `x'==37412 
replace top50=1  if `x'==40636 
replace top50=1  if `x'==41044 
replace top50=1  if `x'==41468 
replace top50=1  if `x'==46509 
replace top50=1  if `x'==49677 
replace top50=1  if `x'==51360 
replace top50=1  if `x'==52133 
replace top50=1  if `x'==80562 
replace top50=1  if `x'==128864 
replace top50=1  if `x'==129391 
replace top50=1  if `x'==148315 
replace top50=1  if `x'==159833 
replace top50=1  if `x'==164684 
replace top50=1  if `x'== 169193 
replace top50=1  if `x'== 169200 
replace top50=1  if `x'== 181276 
replace top50=1  if `x'== 215299 
replace top50=1  if `x'== 246575 
replace top50=1  if `x'== 248453 
replace top50=1  if `x'== 263653 
replace top50=1  if `x'== 292462 
replace top50=1  if `x'== 413557 
replace top50=1  if `x'== 488139 
replace top50=1  if `x'== 530859
}

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/50transfers.dta"
rename Player player_name
#delimit;
merge m:m player_name using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player.dta",
keepusing (player_api_id) assert(match master) nogenerate;
///take player_api_id 

drop if F==. 
replace player_api_id=169200 if regexm(player_name, "De Bruyne") ////case sensitive not matched
//drop players not in top50

foreach x of varlist FeeM F{
	egen `x'num = sieve(`x'), char(0123456789.) //keeps only characters specified in char
	destring `x'num, replace
}

rename FeeMnum poundsfee
rename F eurofee

#delimit
merge m:m player_api_id using "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_nmqtr.dta",
nogenerate;

drop if R==.
replace top50==1

rename Year transferyear
generate eurofeeuse=.
replace eurofeeuse=eurofee if transferyear==yearinfo

drop if yearinfo>transferyear ///keeping only information in years leading up to transfer
save "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/50transfers_panel.dta"

bysort R quarterinfo: keep if _n==_N ///keep only first instance within a quarter; only relevant for Kaka

tsset R quarterinfo

foreach x of varlist overall_rating potential crossing finishing heading_accuracy short_passing volleys dribbling curve free_kick_accuracy long_passing ball_control acceleration sprint_speed reactions agility balance shot_power jumping stamina strength long_shots aggression interceptions positioning vision marking standing_tackle preferred_foot_num attacking_work_rate_num defensive_work_rate_num yearinfo height weight birthyear age team_api_id position {
	by R, sort: replace `x' = `x'[_n+1] if `x'==.
}

tsspell team_api_id, fcond(team_api_id != team_api_id[_n-1])

egen nspells = max(_spell), by(R)

egen tmax = max(quarterinfo), by(R _spell)

egen tmin = min(quarterinfo), by(R _spell)

gen duration = tmax - tmin

gen lastduration = duration if _spell==nspells & _end==1

/////lagged variables
foreach x of varlist overall_rating potential crossing finishing heading_accuracy short_passing volleys dribbling curve free_kick_accuracy long_passing ball_control acceleration sprint_speed reactions agility balance shot_power jumping stamina strength long_shots aggression interceptions positioning vision marking standing_tackle attacking_work_rate_num defensive_work_rate_num {
	generate `x'_l1=L1.`x'
	generate `x'_l2=L2.`x'
	generate `x'_l3=L3.`x'
	generate `x'_l4=L4.`x'
	generate `x'_yearchange=`x'-`x'_l4
} 


 

 


generate transferquarter=0
replace transferquarter=225 if transferyear==2016
replace transferquarter=221 if transferyear==2015
replace transferquarter=217 if transferyear==2014
replace transferquarter=213 if transferyear==2013
replace transferquarter=209 if transferyear==2012
replace transferquarter=205 if transferyear==2011
replace transferquarter=201 if transferyear==2010
replace transferquarter=197 if transferyear==2009
format transferquarter %tq
generate t=transferquarter-quarterinfo

xtset R t 

foreach x of varlist lastduration {
	by player_api_id, sort: replace `x' = `x'[_n+1] if `x'==.
}

///regression: all variables
#delimit;
xtreg eurofee preferred_foot_num height age weight position lastduration 
overall_rating_l1 overall_rating_yearchange potential_l1 potential_yearchange 
crossing_l1 crossing_yearchange finishing_l1 finishing_yearchange heading_accuracy_l1 
heading_accuracy_yearchange short_passing_l1 short_passing_yearchange volleys_l1 
volleys_yearchange dribbling_l1 dribbling_yearchange curve_l1 curve_yearchange 
free_kick_accuracy_l1 free_kick_accuracy_yearchange long_passing_l1 
long_passing_yearchange ball_control_l1 ball_control_yearchange acceleration_l1 
acceleration_yearchange sprint_speed_l1 sprint_speed_yearchange reactions_l1 
reactions_yearchange agility_l1 agility_yearchange balance_l1 balance_yearchange 
shot_power_l1 shot_power_yearchange jumping_l1 jumping_yearchange stamina_l1 
stamina_yearchange strength_l1 strength_yearchange long_shots_l1 long_shots_yearchange 
aggression_l1 aggression_yearchange interceptions_l1 interceptions_yearchange positioning_l1 
positioning_yearchange vision_l1 vision_yearchange marking_l1 marking_yearchange standing_tackle_l1 
standing_tackle_yearchange attacking_work_rate_num_l1 attack_yearchange 
defensive_work_rate_num_l1 defense_yearchange,
re vce(robust);
///overfitted by availability of lastduration

///regresion: categorical age and position variables, no lastduration
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/50transfers_panel.dta"
#delimit;
xtreg eurofee preferred_foot_num height i.age weight i.position 
overall_rating_l1 overall_rating_yearchange potential_l1 potential_yearchange 
crossing_l1 crossing_yearchange finishing_l1 finishing_yearchange heading_accuracy_l1 
heading_accuracy_yearchange short_passing_l1 short_passing_yearchange volleys_l1 
volleys_yearchange dribbling_l1 dribbling_yearchange curve_l1 curve_yearchange 
free_kick_accuracy_l1 free_kick_accuracy_yearchange long_passing_l1 
long_passing_yearchange ball_control_l1 ball_control_yearchange acceleration_l1 
acceleration_yearchange sprint_speed_l1 sprint_speed_yearchange reactions_l1 
reactions_yearchange agility_l1 agility_yearchange balance_l1 balance_yearchange 
shot_power_l1 shot_power_yearchange jumping_l1 jumping_yearchange stamina_l1 
stamina_yearchange strength_l1 strength_yearchange long_shots_l1 long_shots_yearchange 
aggression_l1 aggression_yearchange interceptions_l1 interceptions_yearchange positioning_l1 
positioning_yearchange vision_l1 vision_yearchange marking_l1 marking_yearchange standing_tackle_l1 
standing_tackle_yearchange attacking_work_rate_num_l1 attack_yearchange 
defensive_work_rate_num_l1 defense_yearchange,
re vce(robust);

///regresion: categorical age and position variables, no lastduration, only significant player characteristics at 20% level
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/50transfers_panel.dta"
#delimit;
xtreg eurofee preferred_foot_num height i.age weight i.position 
potential_l1 potential_yearchange 
crossing_l1 heading_accuracy_l1 short_passing_l1 dribbling_l1 curve_yearchange 
free_kick_accuracy_l1 reactions_l1  agility_l1 agility_yearchange balance_l1 balance_yearchange
shot_power_yearchange
strength_l1 aggression_l1 marking_l1 standing_tackle_l1 attacking_work_rate_num_l1 attack_yearchange 
defensive_work_rate_num_l1,
re vce(robust);

use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_nmqtr.dta"
xtset player_api_id quarterinfo

drop eurofee
predict eurofee if position>1 ///predict values using results from previous regression, only non-goalkeepers

#delimit;
tabulate player_name quarterinfo if top50==0 & eurofee!=. & eurofee>100 & quarterinfo>221, 
summarize (eurofee) means;



///regresion: categorical age and position variables, interacted lastduration, only significant player characteristics at 20% level
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/50transfers_panel.dta"
#delimit;
xtreg eurofee preferred_foot_num height weight i.position 
potential_l1 potential_yearchange 
crossing_l1 heading_accuracy_l1 short_passing_l1 dribbling_l1 curve_yearchange 
free_kick_accuracy_l1 reactions_l1  agility_l1 agility_yearchange balance_l1 balance_yearchange
shot_power_yearchange
strength_l1 aggression_l1 marking_l1 standing_tackle_l1 attacking_work_rate_num_l1 attack_yearchange 
defensive_work_rate_num_l1 c.lastduration##i.age,
re vce(robust);

clear
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_nmqtr.dta"
xtset player_api_id quarterinfo

drop eurofee
predict eurofee if position>1 ///predict values using results from previous regression, only non-goalkeepers

#delimit;
tabulate player_name quarterinfo if top50==0 & eurofee!=. & eurofee>200 & quarterinfo>223, 
summarize (eurofee) means;

///regresion: categorical age and position variables, interacted lastduration, only significant player characteristics at 20% level
///using this one for final predictions
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/50transfers_panel.dta"
#delimit;
xtreg eurofee preferred_foot_num height i.position potential_yearchange 
crossing_l1 short_passing_l1 dribbling_l1 
free_kick_accuracy_l1  agility_l1
shot_power_yearchange
c.lastduration##i.age,
re vce(robust);

note: 20.age#c.lastduration omitted because of collinearity
note: 21.age#c.lastduration omitted because of collinearity
note: 25.age#c.lastduration omitted because of collinearity
note: 29.age#c.lastduration omitted because of collinearity
note: 30.age#c.lastduration omitted because of collinearity

Random-effects GLS regression                   Number of obs      =        76
Group variable: R                               Number of groups   =         6

R-sq:  within  = 0.0000                         Obs per group: min =         5
       between = 0.9998                                        avg =      12.7
       overall = 0.9954                                        max =        28

                                                Wald chi2(6)       =         .
corr(u_i, X)   = 0 (assumed)                    Prob > chi2        =         .

                                               (Std. Err. adjusted for 6 clusters in R)
---------------------------------------------------------------------------------------
                      |               Robust
              eurofee |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
----------------------+----------------------------------------------------------------
   preferred_foot_num |  -15.67799   8.420907    -1.86   0.063    -32.18266    .8266874
               height |   6.064453   1.301222     4.66   0.000     3.514105    8.614801
           4.position |   16.71355   7.098591     2.35   0.019     2.800566    30.62653
 potential_yearchange |   -.593731   .4619228    -1.29   0.199    -1.499083    .3116211
          crossing_l1 |    .672426   .2408221     2.79   0.005     .2004233    1.144429
     short_passing_l1 |   .6981327    .343013     2.04   0.042     .0258397    1.370426
         dribbling_l1 |  -.9278676   .4089411    -2.27   0.023    -1.729377   -.1263577
free_kick_accuracy_l1 |    .370331    .121526     3.05   0.002     .1321444    .6085175
           agility_l1 |   .3869307   .2387318     1.62   0.105    -.0809751    .8548364
shot_power_yearchange |   .4906563   .0973798     5.04   0.000     .2997954    .6815171
         lastduration |  -1.864576   .1523377   -12.24   0.000    -2.163152   -1.565999
                      |
                  age |
                  20  |   9.045633   2.080279     4.35   0.000     4.968362     13.1229
                  21  |   18.40352   3.941874     4.67   0.000     10.67759    26.12945
                  22  |   5.871019   10.01729     0.59   0.558    -13.76251    25.50455
                  23  |    3.15277   10.55608     0.30   0.765    -17.53677    23.84231
                  24  |   7.962508   9.280609     0.86   0.391    -10.22715    26.15217
                  25  |   11.13177    8.49944     1.31   0.190    -5.526825    27.79037
                  26  |   7.352406     7.9821     0.92   0.357    -8.292222    22.99704
                  27  |   .5025948   7.906183     0.06   0.949    -14.99324    15.99843
                  28  |   4.287741   7.290224     0.59   0.556    -10.00083    18.57632
                  29  |   5.038929   7.218941     0.70   0.485    -9.109936    19.18779
                  30  |   5.856945   8.048548     0.73   0.467    -9.917919    21.63181
                      |
   age#c.lastduration |
                  20  |          0  (omitted)
                  21  |          0  (omitted)
                  22  |   .3758794   .2340625     1.61   0.108    -.0828747    .8346336
                  23  |   .3652974   .2343966     1.56   0.119    -.0941115    .8247063
                  24  |   .2604229   .1177179     2.21   0.027        .0297    .4911458
                  25  |          0  (omitted)
                  26  |  -.0314923    .040799    -0.77   0.440    -.1114569    .0484723
                  27  |   .2383855    .059264     4.02   0.000     .1222301    .3545409
                  28  |  -.0016968   .0693265    -0.02   0.980    -.1375742    .1341807
                  29  |          0  (omitted)
                  30  |          0  (omitted)
                      |
                _cons |  -1086.144   213.5472    -5.09   0.000    -1504.689   -667.5992
----------------------+----------------------------------------------------------------
              sigma_u |          0
              sigma_e |  5.544e-15
                  rho |          0   (fraction of variance due to u_i)
---------------------------------------------------------------------------------------

clear
use "/Users/risap/Documents/JobApplications/EuraNova/Code_cleanedup/Player_nmqtr.dta"
xtset player_api_id quarterinfo

drop eurofee
predict eurofee if position>1 &top50==0 ///predict values using results from previous regression, only non-goalkeepers and non-most expensive players

#delimit;
tabulate player_name quarterinfo if top50==0 & eurofee!=. & eurofee>130 & quarterinfo>223, 
summarize (eurofee) means;



















