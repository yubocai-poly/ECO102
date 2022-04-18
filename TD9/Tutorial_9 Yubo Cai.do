* Yubo Cai
* 13/04/2022
* ECO102 TD4

 clear all



* Exercise 1

	use "/Users/yubocai/Desktop/Ecole Polytechnique/Semester 2/ECO102/TD9/menlog.dta", clear
	isid idlog
	
* Exercise 3

	merge 1:m idlog using "/Users/yubocai/Desktop/Ecole Polytechnique/Semester 2/ECO102/TD9/individu.dta"
	assert _merge == 3 
	drop _merge
	
* Exercise 3.c

	* keep single-households dwellings
	keep if nmen == 1

	* keep couples with their children
	keep if mty1a == "4"
	keep if nlien < "4"

	* keep families with 2 or 3 kids
	keep if mne > 1 & mne < 4

* Exercise 3.c

	* identify twins among kids
	* twins are identified by age - we average two variables of age to avoid rounding error
	gen age = (nag + nag1) / 2
	gen age_kid = age if nlien == "3"
	sort idmen age_kid
	quietly by idmen age_kid:  gen dup = cond(_N == 1, 0, _n)  if age_kid ! = .
	* shows that we have 184 households with twins, among which 5 are triplets
	tab dup

* Exercise 3.d

	* identify families with same gender of first two kids: IV 1
	gen invage = -age
	sort idmen nlien invage
	br idmen nlien age
	bys idmen: gen nobs = _n
	gen girl1 = 1 if nsexe == "2" & nobs == 3
	gen girl2 = 1 if nsexe == "2" & nobs == 4
	egen mgirl1 = sum(girl1), by(idmen)
	egen mgirl2 = sum(girl2), by(idmen)
	gen mgirl_12 = mgirl1 + mgirl2
	tab mgirl_12
	gen same_gender = mgirl_12 != 1
	
	* drop twins if at first birth
	gen twin_first = dup > 0 & dup != . & nobs == 3
	tab twin_first 
	egen hh_twin_first = sum(twin_first), by(idmen) // tag all family members in families with twins
	tab hh_twin_first if nlien == "1"
	drop if hh_twin_first == 1
	
	* identify families with twins after first birth: IV 2
	gen twin = dup > 0 & dup != . & nobs == 5
	egen hh_twin = sum(twin), by(idmen) // tag all family members in families with twins
	*replace hh_twin = hh_twin > 0
	tab hh_twin if nlien == "1"
	tab twin
	br idmen nlien invage dup mne if hh_twin == 1

	* keep mothers in couples with men
	keep if nlien == "1" | nlien == "2"
	gen mother = nsexe == "2"
	egen sum_mother = sum(mother), by(idmen)
	tab sum_mother
	keep if sum_mother == 1

	* keep couples with working ability
	egen min_age = min(nag), by(idmen)
	egen max_age = max(nag), by(idmen)
	keep if min_age > 15 & max_age < 61

	* definitions
	gen large_family = mne1 > 2
	gen mlarge = mother * large_family
	gen mhh_twin = mother * hh_twin
	gen msame_gender = mother * same_gender

	gen non_work = ntravail == "2"
	gen non_work_extended = non_work == 1 | ntpp == "1"

	gen high_diploma = ndiplo > "4"
	gen ln_age = log(nag)
