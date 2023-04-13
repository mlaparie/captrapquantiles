### This R script automatically calculates phenological quantiles from
### Captrap data. Captraps are automated and connected pheromone traps
### developped by Cap2020, used to monitor the phenology of adult Pine
### Processionary Moths, Thaumetopoea pityocampa.
###
### Author: Mathieu Laparie <mathieu.laparie (at) inrae.fr>
### Date: Wed 12 Apr 15:30:12 CEST 2023

# User input to select the raw data files to consider
subfolder <- readline("Year of data to process (leave empty to process all): ")

# Check if input is empty
if (subfolder == "") {
  # Get list of all subdirectories in current directory
  all_subdirs <- list.dirs(".", recursive = FALSE)

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

# Process the raw files
for (i in subfolders) {
    tmp <- list.files(path = i,
                      pattern = "*.csv$",
                      full.names = TRUE) %>% 
        set_names(nm = substr(basename(.),
                              1,
                              nchar(basename(.)) - 4)) %>% 
        map(~ fread(.)) %>% 
        lapply(setnames, c("Date", "Count")) %>%
        lapply(mutate, Date = as.Date(Date, format = "%d/%m/%Y"),
               Moth_count = as.numeric(Count))

# Expand rows depending on number of captures per date
# With Captraps, empty Count cells are actually true "0" if a row was created
# by the trap for a given date. fread() replaced empty cells by "NA"s, so we
# can safely omit those since they won't weigh in quantile calculations.
    tmpexpanded <- tmp %>%
        map(~ mutate(., Trapping_start = yday(min(Date)),
                     Trapping_end = yday(max(Date)))) %>%
        map(~ na.omit(.)) %>%
        map(~ uncount(., Moth_count))

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
                     Moth_count = nrow(.))) %>%
        map(~ select(.,
                     c(Year, Trapping_start, Trapping_end,
                       Moth_count, Q1, Q5, Q10, Q25, Q50,
                       Q75, Q90, Q95, Q99))) %>%
        map(~ unique(.)) %>%
        enframe() %>%
        unnest_longer(., col = everything())

    assign(paste0("quantiles_", substr(i, 3, 6)), q)

    q <- add_column(q$value,
                    Site = as.factor(q$name),
                    .after = "Year") %>%
        pivot_longer(cols = !c("Year", "Site", "Trapping_start",
                               "Trapping_end", "Moth_count"),
                     names_to = "Quantile",
                     values_to = "yday"
                     ) %>%
        mutate(Quantile = as.factor(Quantile))
    
# Export quantiles tables
    fwrite(q,
           file = paste0("Quantiles/quantiles_yday_",
                         ifelse(subfolder == "", "all", subfolder),
                             ".csv"),
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

print("Exporting to .csv…")
print(paste0("Done! If everything went well, 'quantiles_yday_",
             ifelse(subfolder == "", "all", subfolder),
             ".csv' has been created in subfolder 'Quantiles/'."))
