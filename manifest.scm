;; What follows is a "manifest" equivalent to the command line you gave.
;; You can store it in a file that you may then pass to any 'guix' command
;; that accepts a '--manifest' (or '-m') option.

(specifications->manifest
 (list
  ;; Base command line tools for navigating or editing files
  "bash"
  "fish"
  "coreutils"
  "direnv"
  "emacs"
  "git"
  "grep"
  "nano"
  "tree"
  "which"

  ;; R and R packages
  "r"
  "r-fs"
  "r-dplyr"
  "r-reader"
  "r-tidyr"
  "r-tidyverse"))
