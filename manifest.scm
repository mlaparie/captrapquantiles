;; This "manifest" file can be passed to 'guix package -m' to reproduce
;; the content of your profile.  This is "symbolic": it only specifies
;; package names.  To reproduce the exact same profile, you also need to
;; capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(specifications->manifest
 (list
       ;; Base command line tools for navigating or editing files
       "bash"
       "fish"
       "coreutils"
       "direnv"
       "emacs"
       "emacs-geiser-guile"
       "git"
       "grep"
       "nano"
       "tree"
       "which"

       ;; R and R packages
       "r"
       "r-data-table"
       "r-dplyr"
       "r-ggplot2"
       "r-htmlwidgets"
       "r-lubridate"
       "r-magrittr"
       "r-maps"
       "r-plotly"
       "r-purrr"
       "r-tibble"
       "r-tidyr"))
