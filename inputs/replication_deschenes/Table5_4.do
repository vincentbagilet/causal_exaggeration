
#delimit;
set mem 100m;
set matsize 8000;
set maxvar 8000;
set linesize 140;
use DATA1;

*************************************************************************************************;
*************************************************************************************************;
*** Create some variables ***********************************************************************;

gen y=(rtfsale-rtotexp)*1000/fland;

summ dd89 prcp;

gen dry_dd89=    (dry==1)*dd89;
gen dry_dd89_sq= (dry==1)*dd89*dd89;
gen dry_prcp=    (dry==1)*prcp;
gen dry_prcp_sq= (dry==1)*prcp*prcp;

gen irr_dd89=    (dry==0)*dd89;
gen irr_dd89_sq= (dry==0)*dd89*dd89;
gen irr_prcp=    (dry==0)*prcp;
gen irr_prcp_sq= (dry==0)*prcp*prcp;

save indata, replace;
clear;

*************************************************************************************************;
*************************************************************************************************;
*** Prediction from Uniform Scenario ************************************************************;

use indata;
xi: areg y dry_dd89 dry_dd89_sq dry_prcp dry_prcp_sq 
irr_dd89 irr_dd89_sq irr_prcp irr_prcp_sq dry sst* x1-x9 [weight=fland], a(fips) robust;

gen b_dry_dd89=    _coef[dry_dd89];
gen b_dry_dd89_sq= _coef[dry_dd89_sq];
gen b_irr_dd89=    _coef[irr_dd89];
gen b_irr_dd89_sq= _coef[irr_dd89_sq];
gen b_dry_prcp=    _coef[dry_prcp];
gen b_dry_prcp_sq= _coef[dry_prcp_sq];
gen b_irr_prcp=    _coef[irr_prcp];
gen b_irr_prcp_sq= _coef[irr_prcp_sq];

egen m_dry_dd89=mean(dry_dd89), by(fips);
egen m_dry_prcp=mean(dry_prcp), by(fips);
egen m_irr_dd89=mean(irr_dd89), by(fips);
egen m_irr_prcp=mean(irr_prcp), by(fips);

gen dry_dd89_gw=   (dry==1)*dd89_ugw;
gen dry_dd89_7000= (dry==1)*dd89_7000;
gen dry_prcp_gw=   (dry==1)*prcp_ugw;
gen dry_prcp_7000= (dry==1)*prcp_7000;
gen irr_dd89_gw=   (dry==0)*dd89_ugw;
gen irr_dd89_7000= (dry==0)*dd89_7000;
gen irr_prcp_gw=   (dry==0)*prcp_ugw;
gen irr_prcp_7000= (dry==0)*prcp_7000;

gen d_dry_dd89=    dry_dd89_gw-dry_dd89_7000;
gen d_dry_prcp=    dry_prcp_gw-dry_prcp_7000;
gen d_dry_dd89_sq= 2*d_dry_dd89*m_dry_dd89 + d_dry_dd89*d_dry_dd89;
gen d_dry_prcp_sq= 2*d_dry_prcp*m_dry_prcp + d_dry_prcp*d_dry_prcp;
gen d_irr_dd89=    irr_dd89_gw-irr_dd89_7000;
gen d_irr_prcp=    irr_prcp_gw-irr_prcp_7000;
gen d_irr_dd89_sq= 2*d_irr_dd89*m_irr_dd89 + d_irr_dd89*d_irr_dd89;
gen d_irr_prcp_sq= 2*d_irr_prcp*m_irr_prcp + d_irr_prcp*d_irr_prcp;

egen s_dry_dd89=    sum(fland*d_dry_dd89/1000000000), by(year);
egen s_dry_dd89_sq= sum(fland*d_dry_dd89_sq/1000000000), by(year);
egen s_dry_prcp=    sum(fland*d_dry_prcp/1000000000), by(year);
egen s_dry_prcp_sq= sum(fland*d_dry_prcp_sq/1000000000), by(year);
egen s_irr_dd89=    sum(fland*d_irr_dd89/1000000000), by(year);
egen s_irr_dd89_sq= sum(fland*d_irr_dd89_sq/1000000000), by(year);
egen s_irr_prcp=    sum(fland*d_irr_prcp/1000000000), by(year);
egen s_irr_prcp_sq= sum(fland*d_irr_prcp_sq/1000000000), by(year);

summ s_dry_dd89 s_dry_dd89_sq s_dry_prcp s_dry_prcp_sq
s_irr_dd89 s_irr_dd89_sq s_irr_prcp s_irr_prcp_sq, sep(0);

lincom
dry_dd89     * 443.278  +
dry_dd89_sq  * 2580299  +
dry_prcp     * 0.834307 +
dry_prcp_sq  * 33.22887 +
irr_dd89     * 110.8673 +
irr_dd89_sq  * 629172.8 +
irr_prcp     * 0.16529  +
irr_prcp_sq  * 6.039449 ;

clear;




*************************************************************************************************;
*************************************************************************************************;
*** Prediction from Hadley2 Medium-Term Scenario ************************************************;

use indata;
xi: areg y dry_dd89 dry_dd89_sq dry_prcp dry_prcp_sq 
irr_dd89 irr_dd89_sq irr_prcp irr_prcp_sq dry sst* x1-x9 [weight=fland], a(fips) robust;

gen b_dry_dd89=    _coef[dry_dd89];
gen b_dry_dd89_sq= _coef[dry_dd89_sq];
gen b_irr_dd89=    _coef[irr_dd89];
gen b_irr_dd89_sq= _coef[irr_dd89_sq];
gen b_dry_prcp=    _coef[dry_prcp];
gen b_dry_prcp_sq= _coef[dry_prcp_sq];
gen b_irr_prcp=    _coef[irr_prcp];
gen b_irr_prcp_sq= _coef[irr_prcp_sq];

egen m_dry_dd89=mean(dry_dd89), by(fips);
egen m_dry_prcp=mean(dry_prcp), by(fips);
egen m_irr_dd89=mean(irr_dd89), by(fips);
egen m_irr_prcp=mean(irr_prcp), by(fips);

gen dry_dd89_gw=   (dry==1)*dd89_h2_med;
gen dry_dd89_7000= (dry==1)*dd89_7000;
gen dry_prcp_gw=   (dry==1)*prcp_h2_med;
gen dry_prcp_7000= (dry==1)*prcp_7000;
gen irr_dd89_gw=   (dry==0)*dd89_h2_med;
gen irr_dd89_7000= (dry==0)*dd89_7000;
gen irr_prcp_gw=   (dry==0)*prcp_h2_med;
gen irr_prcp_7000= (dry==0)*prcp_7000;

gen d_dry_dd89=    dry_dd89_gw-dry_dd89_7000;
gen d_dry_prcp=    dry_prcp_gw-dry_prcp_7000;
gen d_dry_dd89_sq= 2*d_dry_dd89*m_dry_dd89 + d_dry_dd89*d_dry_dd89;
gen d_dry_prcp_sq= 2*d_dry_prcp*m_dry_prcp + d_dry_prcp*d_dry_prcp;
gen d_irr_dd89=    irr_dd89_gw-irr_dd89_7000;
gen d_irr_prcp=    irr_prcp_gw-irr_prcp_7000;
gen d_irr_dd89_sq= 2*d_irr_dd89*m_irr_dd89 + d_irr_dd89*d_irr_dd89;
gen d_irr_prcp_sq= 2*d_irr_prcp*m_irr_prcp + d_irr_prcp*d_irr_prcp;

egen s_dry_dd89=    sum(fland*d_dry_dd89/1000000000), by(year);
egen s_dry_dd89_sq= sum(fland*d_dry_dd89_sq/1000000000), by(year);
egen s_dry_prcp=    sum(fland*d_dry_prcp/1000000000), by(year);
egen s_dry_prcp_sq= sum(fland*d_dry_prcp_sq/1000000000), by(year);
egen s_irr_dd89=    sum(fland*d_irr_dd89/1000000000), by(year);
egen s_irr_dd89_sq= sum(fland*d_irr_dd89_sq/1000000000), by(year);
egen s_irr_prcp=    sum(fland*d_irr_prcp/1000000000), by(year);
egen s_irr_prcp_sq= sum(fland*d_irr_prcp_sq/1000000000), by(year);

summ s_dry_dd89 s_dry_dd89_sq s_dry_prcp s_dry_prcp_sq
s_irr_dd89 s_irr_dd89_sq s_irr_prcp s_irr_prcp_sq, sep(0);

lincom
dry_dd89    *   450.512  +
dry_dd89_sq *   4006475  +
dry_prcp    *  .6028828  +
dry_prcp_sq *  23.79839  +
irr_dd89    *  99.05617  +
irr_dd89_sq *  793765.3  +
irr_prcp    *  .2819892  +
irr_prcp_sq *   7.13062  ;

clear;




*************************************************************************************************;
*************************************************************************************************;
*** Prediction from Hadley2 Long-Term Scenario **************************************************;

use indata;
xi: areg y dry_dd89 dry_dd89_sq dry_prcp dry_prcp_sq 
irr_dd89 irr_dd89_sq irr_prcp irr_prcp_sq dry sst* x1-x9 [weight=fland], a(fips) robust;

gen b_dry_dd89=    _coef[dry_dd89];
gen b_dry_dd89_sq= _coef[dry_dd89_sq];
gen b_irr_dd89=    _coef[irr_dd89];
gen b_irr_dd89_sq= _coef[irr_dd89_sq];
gen b_dry_prcp=    _coef[dry_prcp];
gen b_dry_prcp_sq= _coef[dry_prcp_sq];
gen b_irr_prcp=    _coef[irr_prcp];
gen b_irr_prcp_sq= _coef[irr_prcp_sq];

egen m_dry_dd89=mean(dry_dd89), by(fips);
egen m_dry_prcp=mean(dry_prcp), by(fips);
egen m_irr_dd89=mean(irr_dd89), by(fips);
egen m_irr_prcp=mean(irr_prcp), by(fips);

gen dry_dd89_gw=   (dry==1)*dd89_h2_long;
gen dry_dd89_7000= (dry==1)*dd89_7000;
gen dry_prcp_gw=   (dry==1)*prcp_h2_long;
gen dry_prcp_7000= (dry==1)*prcp_7000;
gen irr_dd89_gw=   (dry==0)*dd89_h2_long;
gen irr_dd89_7000= (dry==0)*dd89_7000;
gen irr_prcp_gw=   (dry==0)*prcp_h2_long;
gen irr_prcp_7000= (dry==0)*prcp_7000;

gen d_dry_dd89=    dry_dd89_gw-dry_dd89_7000;
gen d_dry_prcp=    dry_prcp_gw-dry_prcp_7000;
gen d_dry_dd89_sq= 2*d_dry_dd89*m_dry_dd89 + d_dry_dd89*d_dry_dd89;
gen d_dry_prcp_sq= 2*d_dry_prcp*m_dry_prcp + d_dry_prcp*d_dry_prcp;
gen d_irr_dd89=    irr_dd89_gw-irr_dd89_7000;
gen d_irr_prcp=    irr_prcp_gw-irr_prcp_7000;
gen d_irr_dd89_sq= 2*d_irr_dd89*m_irr_dd89 + d_irr_dd89*d_irr_dd89;
gen d_irr_prcp_sq= 2*d_irr_prcp*m_irr_prcp + d_irr_prcp*d_irr_prcp;

egen s_dry_dd89=    sum(fland*d_dry_dd89/1000000000), by(year);
egen s_dry_dd89_sq= sum(fland*d_dry_dd89_sq/1000000000), by(year);
egen s_dry_prcp=    sum(fland*d_dry_prcp/1000000000), by(year);
egen s_dry_prcp_sq= sum(fland*d_dry_prcp_sq/1000000000), by(year);
egen s_irr_dd89=    sum(fland*d_irr_dd89/1000000000), by(year);
egen s_irr_dd89_sq= sum(fland*d_irr_dd89_sq/1000000000), by(year);
egen s_irr_prcp=    sum(fland*d_irr_prcp/1000000000), by(year);
egen s_irr_prcp_sq= sum(fland*d_irr_prcp_sq/1000000000), by(year);

summ s_dry_dd89 s_dry_dd89_sq s_dry_prcp s_dry_prcp_sq
s_irr_dd89 s_irr_dd89_sq s_irr_prcp s_irr_prcp_sq, sep(0);

lincom
dry_dd89     *   739.3162  + 
dry_dd89_sq  *    5959966  +
dry_prcp     *   1.793889  +
dry_prcp_sq  *   75.37064  +
irr_dd89     *    176.276  +
irr_dd89_sq  *    1291806  +
irr_prcp     *   .4829867  +
irr_prcp_sq  *    14.8647  ;

lincom
dry_dd89     *   739.3162  + 
dry_dd89_sq  *    5959966  +
dry_prcp     *   1.793889  +
dry_prcp_sq  *   75.37064  ;

lincom
irr_dd89     *    176.276  +
irr_dd89_sq  *    1291806  +
irr_prcp     *   .4829867  +
irr_prcp_sq  *    14.8647  ;

lincom
dry_dd89     *   739.3162  + 
dry_dd89_sq  *    5959966  +
irr_dd89     *    176.276  +
irr_dd89_sq  *    1291806  ;

lincom
dry_prcp     *   1.793889  +
dry_prcp_sq  *   75.37064  +
irr_prcp     *   .4829867  +
irr_prcp_sq  *    14.8647  ;

clear;

! \rm indata.dta;

















