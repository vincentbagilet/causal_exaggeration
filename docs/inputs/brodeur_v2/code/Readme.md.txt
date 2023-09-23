# Methods Matter: P-Hacking and Publication Bias in Causal Analysis in Economics

The data and code in this deposit have been updated after publication of the article.
For changes made, see below and the associated changelog.txt.

(derived from [10.3886/E120246V1](https://doi.org/10.3886/E120246V1))

## Authors

Abel Brodeur, Nikolai Cook and Anthony Heyes

## Description

This document provides a description of the purpose of each data set and program to replicate
Tables and Figures in “Methods Matter: P-Hacking and Publication Bias in Causal Analysis
in Economics” and its online Appendix. Programs are written in Stata, and data sets are
compatible with Stata 15.1, earlier versions may not be supported.

This is the second published version of this document. We would like to thank Peter Pütz (Bielefeld University) for discovering a coding error in the original release of the Data. In the original, coefficients that had been reported as p-values (consisting of less than 5% the sample) were calculated as one-sided rather than two-sided tests. The data sets below have been updated to correct this, and `change1.do` explicitly documents the changes made to the original. This new version also includes new string variables for the coefficients and standard errors. We have also manually checked a number of coefficients with z=2. Any changes are reflected in the new datasets. SEE CHANGELOG.txt (contained in the "code" folder) FOR MORE DETAILS.

### Data folder

The Data folder contains four data sets:

- `Fstat.dta`, in which an observation is an f-statistic in an IV journal article and which is used to produce Figures 5 and A15 and Table A25 in the paper (no change from version 1),
- `MM Data with WP.dta`, in which an observation is a test statistic and which is used to produce Tables A27 and A28 and Figures 6, A19, A20, A21, and A22 (changed from version 1, see changelog.txt),
- `MM Data.dta`, in which an observation is a test statistic and which is used to produce the remaining 
tables and figures (changed from version 1, see changelog.txt),
- `Star Wars Data.dta`, in which an observation is a test statistic and which is used to produce Figures 3a, A1, and A13. This data set was built using the test statistics from ‘Brodeur, et al. Star wars: The empirics strike back. American Economic Journal: Applied Economics 8.1 (2016): 1-32”. In version 1, we kept only coefficients of interest. In this version the same observations are provided, but with the additional variables provided by Brodeur et al. (2016). See changelog.txt for details. 


### Do-files

The Do folder contains seven do-files:

-  `change1.do` is the code that corrects a typo in the initial release of the data. It has already been applied to the current version of the datasets. 
-  `make AK model csv.do` is the code that produces .csv’s which can then be inputted into
the online app at [https://maxkasy.github.io/home/metastudy/](https://maxkasy.github.io/home/metastudy/) (changed from version 1, see changelog.txt),
- `make caliper tables.do` is the code that reproduces Tables 4, A12, A13, A14, A15, A16,
A17, A18, A19, A20, A21, A22, A23, A26, A27, A28, A29, A30, A31, A32, A33 and A35,
-  `make excess coefficients tables.do` is the code that reproduces Tables A23 and A24,
- `make figures.do` is the code that reproduces Figures 1a, 1b, 2, 3a, 3b, 4, 5a, 5b, 6, A1,
A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19,
A20, A21, A22, A23, A26, A27 and A28.
-  `make randomization tables.do` is the code that reproduces Table 3, A3, A4, A5, A6, A7, A8, A9, A10, A11 and A25.
- `make summary tables.do` is the code that reproduces Tables 2, A2 and A34.

Note that Tables 1, 5 and A1 are manually made.

### Reference figures

The figures contained within `/code/figures-reference` were those produced by the authors, for inclusion in the manuscript. All figures generated when running this code capsule are in the `/results` folder (when running on codeocean.com, will appear in the right pane).
 