# Data for flowchart construction, modified from: https://estech.shinyapps.io/prisma_flowdiagram/_w_c09908a3/PRISMA.csv
csv_data <- "data,node,box,description,boxtext,tooltips,url,n
NA,node4,prevstud,Grey title box; Previous studies,Previous studies,Grey title box; Previous studies,prevstud.html,0
previous_studies,node5,box1,Studies included in previous version of review,Studies included in previous version of review,Studies included in previous version of review,previous_studies.html,0
previous_reports,NA,box1,Reports of studies included in previous version of review,Reports of studies included in previous version of review,NA,previous_reports.html,0
NA,node6,newstud,Yellow title box; Identification of new studies via databases,Identification of new studies via databases,Yellow title box; Identification of new studies via databases,newstud.html,0
database_results,node7,box2,Records identified from: Databases,Databases,Records identified from: databases,database_results.html,1697
database_specific_results,NA,box2,Records identified from: specific databases,Specific Databases,NA,database_results.html,\"Embase, 650; PubMed, 497; OpenAlex, 550\"
register_results,NA,box2,Records identified from: Registers,Registers,NA,NA,NA
register_specific_results,NA,box2,Records identified from: specific registers,Specific Registers,NA,database_results.html,0
NA,node16,othstud,Grey title box; Identification of new studies via other methods,Identification of new studies via other methods,Grey title box; Identification of new studies via other methods,othstud.html,0
website_results,node17,box11,Records identified from: Websites,Backward (ascendant) citations,Records identified from: Websites Organisations and Citation Searching,website_results.html,344
organisation_results,NA,box11,Records identified from: Organisations,Organisations,NA,NA,NA
citations_results,node17,box11,Records identified from: Citation searching,Forward (descendant) citations,NA,citations_results.html,453
duplicates,node8,box3,Duplicate records,Duplicate records,Duplicate records,duplicates.html,568
excluded_automatic,NA,box3,Records marked as ineligible by automation tools,Records marked as ineligible by automation tools,NA,NA,NA
excluded_other,NA,box3,Records removed for other reasons,Records removed for other reasons,NA,NA,2
records_screened,node9,box4,Records screened (databases),Records screened,Records screened (databases),records_screened.html,1127
records_excluded,node10,box5,Records excluded (databases),Records excluded by ASReview,Records excluded (databases),records_excluded.html,943
dbr_sought_reports,node11,box6,Records screened by reviewers (databases),Records screened by reviewers,Records screened by reviewers (databases),dbr_sought_reports.html,184
dbr_notretrieved_reports,node12,box7,Reports not retrieved (databases),Reports labelled not relevant,Reports not retrieved (databases),dbr_notretrieved_reports.html,133
other_sought_reports,node18,box12,Reports sought for retrieval (other),Records screened by reviewers,Reports sought for retrieval (other),other_sought_reports.html,42
other_notretrieved_reports,node19,box13,Reports not retrieved (other),Records labelled not relevant,Reports not retrieved (other),other_notretrieved_reports.html,34
dbr_assessed,node13,box8,Reports assessed for eligibility (databases),Full-text reports assessed for eligibility,Reports assessed for eligibility (databases),dbr_assessed.html,51
dbr_excluded,node14,box9,Reports excluded (databases),Reports excluded,Reports excluded (databases),dbrexcludedrecords.html,\"Not probability of causation, 7; Outcome not lung cancer, 7; No quantitative exposure-response, 14\"
other_assessed,node20,box14,Reports assessed for eligibility (other),Full-text reports assessed for eligibility,Reports assessed for eligibility (other),other_assessed.html,8
other_excluded,node21,box15,Reports excluded (other),Reports excluded,Reports excluded (other),other_excluded.html,\"Outcome not lung cancer, 5\"
new_studies,node15,box10,Studies included via database search,Studies included via database search,Studies included via database search,new_studies.html,23
new_reports,NA,box10,Studies included via citations,Studies included via citations,NA,NA,3
total_studies,node22,box16,Total studies included in review,Total studies included in review,Total studies included in review,total_studies.html,23
total_reports,NA,box16,Reports of total included studies,Reports of total included studies,NA,NA,0
identification,node1,identification,Blue identification box,Identification,Blue identification box,identification.html,0
screening,node2,screening,Blue screening box,Screening,Blue screening box,screening.html,0
included,node3,included,Blue included box,Included,Blue included box,included.html,0"

# Write the CSV data to a file
writeLines(csv_data, paste0(tempfolder,"/prisma_data.csv"))

# Read the data using PRISMA_data function
prisma_data <- PRISMA_data(read.csv(paste0(tempfolder,"/prisma_data.csv"), stringsAsFactors = FALSE))

# Create the flow diagram
flow_diagram <- PRISMA_flowdiagram(
  data = prisma_data,
  interactive = FALSE,
  previous = FALSE,
  other = TRUE,
  detail_databases = TRUE,
  detail_registers = FALSE,
  fontsize = 12,
  font = "Aptos"
)
