### This R script automatically calculates phenological quantiles from
### Captrap data. Captraps are automated and connected pheromone traps
### developped by Cap2020, used to monitor the phenology of adult Pine
### Processionary Moths, Thaumetopoea pityocampa.
###
### Author: Mathieu Laparie <mathieu.laparie (at) inrae.fr>
### Date: Wed 12 Apr 15:30:12 CEST 2023

# Split data in Years and Sites
library(dplyr)
library(tidyr)
library(readr)
library(fs)

# Read the data from tique.txt
data <- read.delim("data/tique.txt", sep = "\t", stringsAsFactors = TRUE)

# Convert the date column to a Date object
data$date <- as.Date(data$date, format = "%d/%m/%Y")

# Convert instar variables into a single factor variable
data <- data %>%
  pivot_longer(cols = c("nymph", "male", "female"),
               names_to = "Stage",
               values_to = "Count") %>%
  group_by(Stage)

# Group the data by year and site_id
data <- data %>%
  group_by(Year = format(date, "%Y"), site_id) %>%
  ungroup()

# Write CSV files for each site_id within each year
stages <- unique(data$Stage)
years <- unique(data$Year)

for (stage in stages) {
    dir.create(stage, showWarnings = FALSE)
    for (year in years) {
        dir.create(paste0(stage, "/", year, sep = ""), showWarnings = FALSE)
        year_data <- data %>%
            filter(Year == year)
        
        site_ids <- unique(year_data$site_id)
        
        for (site in site_ids) {
            site_data <- year_data %>%
                filter(site_id == site) %>%
                filter(Stage == stage) %>%
                select(Date = date, Count)
            
            csv_filename <- file.path(stage, year, paste0(site, ".csv"))
            write_csv(site_data, csv_filename)
        }
    }
}

#########################
#### FONCTIONNE JUSQU'ICI - On doit rajouter le stade et le niveau de hiérarchie supplémentaire
#########################

# User input to select the raw data files to consider
subfolder <- readline("Year of data to process (leave empty to process all): ")

# Check if input is empty
if (subfolder == "") {
  # Get list of all subdirectories in current directory
  all_subdirs <- list.dirs(".", recursive = TRUE)

  # Filter out all directories that don't match a year format
  subfolders <- grep("\\d{4}", all_subdirs, value = TRUE)
} else {
  subfolders <- subfolder
}

# Libraries
quiet <- suppressPackageStartupMessages
quiet(library(tidyverse))
quiet(library(data.table))
quiet(library(lubridate))

# Data importation
# Create the output folder
dir.create(file.path("Quantiles"), showWarnings = FALSE)

# Delete pre-existing output file, if any, to avoid row duplications
filename <- paste0("Quantiles/quantiles_yday_",
                    ifelse(subfolder == "", "all", subfolder),
                   ".csv")
if (file.exists(filename)) {
    file.remove(filename)
}

# Process the raw files
for (i in subfolders) {
    for (stage in stages) {
        tmp <- list.files(path = paste0(i, sep = ""),
                          pattern = "*.csv$",
                          full.names = TRUE) %>% 
            set_names(nm = substr(basename(.),
                                  1,
                                  nchar(basename(.)) - 4)) %>% 
            map(~ fread(.)) %>% 
            lapply(setnames, c("Date", "Count")) %>%
            lapply(mutate,
                   Date = as.Date(Date, format = "%d/%m/%Y"),
                   Count = as.numeric(Count))

        # Expand rows depending on number of captures per date
        # With Captraps, empty Count cells are actually true "0" if a row was created
        # by the trap for a given date. fread() replaced empty cells by "NA"s, so we
        # can safely omit those since they won't weigh in quantile calculations.
        tmpexpanded <- tmp %>%
            map(~ mutate(.,
                         Trapping_start = yday(min(Date)),
                         Trapping_end = yday(max(Date)),
                         Stage = as.factor(stage))) %>%
            map(~ na.omit(.)) %>%
            map(~ group_by(., Stage)) %>%
            map(~ uncount(., Count))

        # Assign object names
        assign(paste0("d", substr(i, 3, 6)), tmp)
        assign(paste0("d", substr(i, 3, 6), "_exp"), tmpexpanded)

        # Calculate the quantile flight yday for each table
        q <- tmpexpanded %>%
            map(~ mutate(., yday = yday(Date),
                         Q1 = quantile(yday, probs = 0.01),
                         Q5 = quantile(yday, probs = 0.05),
                         Q10 = quantile(yday, probs = 0.10),
                         Q25 = quantile(yday, probs = 0.25),
                         Q50 = quantile(yday, probs = 0.50),
                         Q75 = quantile(yday, probs = 0.75),
                         Q90 = quantile(yday, probs = 0.90),
                         Q95 = quantile(yday, probs = 0.95),
                         Q99 = quantile(yday, probs = 0.99),
                         Year = as.numeric(year(Date)),
                         Stage = Stage,
                         Count = nrow(.))) %>%
            map(~ select(.,
                         c(Year, Stage, Trapping_start, Trapping_end,
                           Count, Q1, Q5, Q10, Q25, Q50,
                           Q75, Q90, Q95, Q99))) %>%
            map(~ unique(.)) %>%
            enframe() %>%
            unnest_longer(., col = everything())

        assign(paste0("quantiles_", substr(i, 3, 6)), q)

        q <- add_column(q$value,
                        Site = as.factor(q$name),
                        .after = "Year") %>%
            pivot_longer(cols = !c("Stage", "Year", "Site",
                                   "Trapping_start",
                                   "Trapping_end",
                                   "Count"),
                         names_to = "Quantile",
                         values_to = "yday"
                         ) %>%
            mutate(Quantile = as.factor(Quantile))
        
        # Export quantiles tables
        fwrite(q,
               file = filename,
               row.names = FALSE,
               append = TRUE)

        print(paste0("# QUANTILES FOR THE '",
                     i,
                     " SUBFOLDER:"))
        options(pillar.sigfig = 4)
        print(q, n = 15)
        print(paste0(length(levels(q$Site)),
                     " site(s) processed for year ",
                     q$Year[1],
                     "."))
    }
}

print("Exporting to .csv…")
print(paste0("Done! If everything went well, 'quantiles_yday_",
             ifelse(subfolder == "", "all", subfolder),
             ".csv' has been created in subfolder 'Quantiles/'."))
