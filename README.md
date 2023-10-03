# An R script to batch calculate phenological quantiles from Captrap automated traps csv files

## How to use
1. Place `quantiles.R` in a directory structured in year subfolders, each containing csv files downloaded from the Captrap web interface, like this:

```
.
├── 2019
│   ├── avignon.csv
│   ├── erquy.csv
│   ├── orleans.csv
│   ├── re_ouest.csv
│   ├── serre_poncon.csv
├── 2020
│   ├── avignon.csv
│   ├── erquy.csv
│   ├── re_ouest.csv
├── quantiles.R
└── README.md
```

2. Start R (stock) or Rstudio, and source `quantiles.R` from the GUI (`File > Source file…`) or from the R console:

```r
source("/path/to/quantiles.R")
```

You will be prompted to enter the year you want to process, *i.e.*, the subfolder for which the quantiles must be calculated. With the example file structure above, valid answers would be "2019" and "2020" without the quotes, and would all generate their own output file containing quantile data inside a `Quantiles/` subfolder. The answer to that prompt can also be left empty, in which case all year subfolders found will be processed at once, and quantile data will be summarized in a single output file.

Alternatively, to skip the interactive prompt completely, you can run `Rscript /path/to/quantiles.R` directly in your shell (`cmd.exe`, `Bash`, `Fish`, *etc.*) without entering R, in which case all years will be processed without waiting for user input.

Below is an example of the first 15 lines of an output file for year 2019 (except it is displayed here as tab-separated instead of comma-separated):

```csv
Year Site    Trapping_start Trapping_end Moth_count Quantile yday
2019 avignon            199          287         51 Q1       199  
2019 avignon            199          287         51 Q5       211.5
2019 avignon            199          287         51 Q10      218  
2019 avignon            199          287         51 Q25      220  
2019 avignon            199          287         51 Q50      223  
2019 avignon            199          287         51 Q75      229  
2019 avignon            199          287         51 Q90      246  
2019 avignon            199          287         51 Q95      280  
2019 avignon            199          287         51 Q99      287  
2019 erquy              171          323          8 Q1       200  
2019 erquy              171          323          8 Q5       200  
2019 erquy              171          323          8 Q10      200  
2019 erquy              171          323          8 Q25      221  
2019 erquy              171          323          8 Q50      233  
2019 erquy              171          323          8 Q75      235.2
```

## Demonstration
[![asciicast](https://asciinema.org/a/37MJZHX1s4li8OIIJcA1uLnqj.svg)](https://asciinema.org/a/37MJZHX1s4li8OIIJcA1uLnqj)

### Clarification on 0 or missing values in Captrap raw data
- If a row is missing (no row for the date), then the trap did not send data that day, which does not inform on whether some captures occurred. This is a true "NA".
- If a row with a date exists but there is no count data in the second column, then the trap successfully communicated that day (battery or GPS coordinates for example), but no catch was detected. This is a true "0".
- If a row with a date exists and count data is "0", then some activity was detected in the sensor but it was not attributed to the target species by the algorithm. This is a true "0", unless the trap is not properly parametrized.
