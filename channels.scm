(list (channel
       (name 'guix-cran)
       (url "https://github.com/guix-science/guix-cran.git")
       (branch "master")
       (commit
        "1ed42cfb38f41522d97752e6fba004f5ab55bc81"))
      (channel
       (name 'guix)
       (url "https://codeberg.org/guix/guix-mirror")
       (branch "master")
       (commit
        "0edbe5d44bf196569ab2bedf6f085e91d69abfd1")
       (introduction
        (make-channel-introduction
         "c91e27c60864faa229198f6f0caf620275c429a2"
         (openpgp-fingerprint
          "510A 8628 E2A7 7678 8F8C  709C 4BC0 2592 5FF8 F4D3")))))
