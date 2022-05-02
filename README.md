# CodingWithOmop

## Analyst
### A.1. Preparing CohortDiagnostics
The aim here is to prepare the code to run cohort diagnostics for a set of study-specicific cohort definitions. If you don't currently have a project that needs phenotypes, you could choose definitions related to: 1) dementia, 2) COVID-19, 3) cancer. The purpose of this exercise is not necessarily to get the final study cohort definitions, but to give you experience on setting up and interpreting the results from cohort diagnostics.

Steps:
1) Develop the required concept sets, either by running CodelistGenerator (https://oxford-pharmacoepi.github.io/CodelistGenerator/) or by taking a concept set from a previous study (https://github.com/oxford-pharmacoepi/OmopConceptSetLibrary). Note, there are other options to go about this but by using these two new tools, you can help find bugs or areas where documentation is lacking (in which case please open an issue on the respective github repos).
2) Build cohort definitions using the concept sets, adding the required cohort logic (e.g. taking first event in history, with no eligibility criteria other than the initial event, and cohort end date being end of observation period - but this could differ depending on the study in question).
3) Take the code from this Dementia CohortDiagnostics (https://github.com/oxford-pharmacoepi/DementiaDusCohortDiagnostics - download rather than fork), and switch out the existing cohort definitions to your ones. 
4) Upload to this github repo by creating a branch (with the option and your name as the name, e.g. "A1_EdBurn") and open a pull request. I would suggest that you use github desktop to help with this. 
5) Persuade someone to do a code review and accept your pull request.
6) Persuade someone to run the cohort diagnostics 
7) Review the results - would you make any changes to your definition based on your results?


### A.2. Write custom code to characterise a cohort 
The aim here is to prepare some code to further characterise patients in a cohort in a results table in the omop cdm (taking them to be in the standard cohort table format - whether creator by CohortGenerator or otherwise). For example, this could code could be to produce a table 1 based on characteristics relative to cohort start date (e.g. age, sex, prior observation time, etc), or it could be a figure like a histogram (e.g. age at cohort entry, time between cohort start and end date, etc).

Steps: 
1) Develop the code yourself (if you don't have access to a live database, you could do this with Eunomia https://github.com/OHDSI/Eunomia)
2) Upload the code to this github in the same way as in step 4) in A.1. above
3) Persuade someone to do a code review and accept your pull request.
4) Persuade someone to run the code and return results (make sure there is no results with counts of less than 5)
5) Review the results - would you make any changes to your code based on the results?


## Developer 
### Option D.1. Contributing to CodelistGenerator
The aim here is to act as a contributor to the Codelistgenerator package (https://oxford-pharmacoepi.github.io/CodelistGenerator/). This does not necessarily involve any programming as, for example, queries relating to the documentation would be very helpful.

Steps: 
1) Read through the package vignettes (https://oxford-pharmacoepi.github.io/CodelistGenerator/articles/Introduction_to_CodelistGenerator.html and https://oxford-pharmacoepi.github.io/CodelistGenerator/articles/Options_for_CodelistGenerator.html)
2) Install the package and run an example
3) Perform code review. Fork the package, and work through through the main functions locally. 
4) Can you add any tests? Add and open a pull request for review.
5) Could you add to the existing vignettes or add a new one (e.g. examples for medications and procedures would be nice to have)
6) Do you have any queries about whether something is unclear, might be a bug, or do you see possibilities for improvement to existing functions or possible extensions? Open an issue to discuss. After discussion, you could work on the code and open a pull request for review.

### Option D.2. Build a package 
This could take a lot of different forms, but my sugestion would be - creating themes for common types of plots. See bbplot https://github.com/bbc/bbplot, https://github.com/hrbrmstr/hrbrthemes, https://github.com/AtherEnergy/ggTimeSeries, https://github.com/delabj/ggCyberPunk for some inspiration. The idea would be to have functions like "+ gg_pde_time_series()" which formats a time series plot, "+ gg_pde_ps()" which formats a propensity score distribution plot.

Steps: 
1) Work on creating a function locally 
2) Put function into a package with only that function using devtools::create_package(). See https://r-pkgs.org/index.html for many more instructions. For now, just work on the package locally. Can you run for an example?
3) Push to github, and persuade someone to do an initial code review. Are they able to install the package and run your example?
4) Start addding tests, etc. 
