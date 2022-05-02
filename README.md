# CodingWithOmop

## Analyst
### A.1. Preparing CohortDiagnostics
The aim here is to prepare the code to run cohort diagnostics for a set of study-specicific cohort definitions. If you don't currently have a project that needs phenotypes, please choose definitions related to: 1) dementia, 2) COVID-19, 3) cancer. The purpose of this is not really to get to the final study cohorts, but to give you experience on setting up and interpreting the results from cohort diagnostics, so don't procrastinate on finding the perfect set of codes before running cohort diagnostics.

Steps:
1) Develop the required concept sets, either by running CodelistGenerator (https://oxford-pharmacoepi.github.io/CodelistGenerator/) or by taking a concept set from a previous study (https://github.com/oxford-pharmacoepi/OmopConceptSetLibrary). Note, there are other options to go about this but by using these two new tools, you can help find bugs or areas where documentation is lacking (in which case please open an issue on the respective github repos).
2) Build cohort definitions using the concept sets, adding the required cohort logic (probably taking first event in history, with no eligibility criteria other than the initial event, and cohort end date being end of observation period - but this could differ depending on the study in question).
3) Take the code from this Dementia CohortDiagnostics (https://github.com/oxford-pharmacoepi/DementiaDusCohortDiagnostics - download rather than fork), and switch out the existing cohort definitions to your ones. 
4) Upload to this github repo by creating a branch (with the option and your name as the name, e.g. "A1_EdBurn") and open a pull request. I would suggest that you use github desktop to help with this. 
5) Persuade someone else to do a code review who then has the responsibility to accept your pull request.
6) Persuade someone else to run the cohort diagnostics 
7) Review the results - would you make any changes to your definition based on your results?


### A.2. Write a study specific script 


## Developer 
### Option D.1. Contributing to CodelistGenerator


### Option D.2. Build a package 

