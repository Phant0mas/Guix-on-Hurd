;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2015 Paul van der Walt <paul@denknerd.org>
;;; Copyright © 2016, 2017 David Craven <david@craven.ch>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages idris)
  #:use-module (gnu packages haskell)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages ncurses)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system haskell)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public idris
  (package
    (name "idris")
    (version "0.99")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://hackage.haskell.org/package/"
                    "idris-" version "/idris-" version ".tar.gz"))
              (sha256
               (base32
                "1sd4vy5rx0mp32xj99qijhknkgw4d2rxvz6wiy3pym6kaqmc497i"))))
    (build-system haskell-build-system)
    (inputs
     `(("gmp" ,gmp)
       ("ncurses" ,ncurses)
       ("ghc-aeson" ,ghc-aeson)
       ("ghc-async" ,ghc-async)
       ("ghc-annotated-wl-pprint" ,ghc-annotated-wl-pprint)
       ("ghc-ansi-terminal" ,ghc-ansi-terminal)
       ("ghc-ansi-wl-pprint" ,ghc-ansi-wl-pprint)
       ("ghc-base64-bytestring" ,ghc-base64-bytestring)
       ("ghc-blaze-html" ,ghc-blaze-html)
       ("ghc-blaze-markup" ,ghc-blaze-markup)
       ("ghc-cheapskate" ,ghc-cheapskate)
       ("ghc-fingertree" ,ghc-fingertree)
       ("ghc-fsnotify" ,ghc-fsnotify)
       ("ghc-ieee754" ,ghc-ieee754)
       ("ghc-mtl" ,ghc-mtl)
       ("ghc-network" ,ghc-network)
       ("ghc-optparse-applicative" ,ghc-optparse-applicative)
       ("ghc-parsers" ,ghc-parsers)
       ("ghc-regex-tdfa" ,ghc-regex-tdfa)
       ("ghc-safe" ,ghc-safe)
       ("ghc-split" ,ghc-split)
       ("ghc-tasty" ,ghc-tasty)
       ("ghc-tasty-golden" ,ghc-tasty-golden)
       ("ghc-tasty-rerun" ,ghc-tasty-rerun)
       ("ghc-terminal-size" ,ghc-terminal-size)
       ("ghc-text" ,ghc-text)
       ("ghc-trifecta" ,ghc-trifecta)
       ("ghc-uniplate" ,ghc-uniplate)
       ("ghc-unordered-containers" ,ghc-unordered-containers)
       ("ghc-utf8-string" ,ghc-utf8-string)
       ("ghc-vector-binary-instances" ,ghc-vector-binary-instances)
       ("ghc-vector" ,ghc-vector)
       ("ghc-zip-archive" ,ghc-zip-archive)
       ("ghc-zlib" ,ghc-zlib)))
    (arguments
     `(#:tests? #f ; FIXME: Test suite doesn't run in a sandbox.
       #:configure-flags
       (list (string-append "--datasubdir="
                            (assoc-ref %outputs "out") "/lib/idris"))
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'set-cc-command
           (lambda _
             (setenv "CC" "gcc")
             #t))
         (add-after 'install 'fix-libs-install-location
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (lib (string-append out "/lib/idris"))
                    (modules (string-append lib "/libs")))
               (for-each
                (lambda (module)
                  (symlink (string-append modules "/" module)
                           (string-append lib "/" module)))
                '("prelude" "base" "contrib" "effects" "pruviloj"))))))))
    (native-search-paths
     (list (search-path-specification
            (variable "IDRIS_LIBRARY_PATH")
            (files '("lib/idris")))))
    (home-page "http://www.idris-lang.org")
    (synopsis "General purpose language with full dependent types")
    (description "Idris is a general purpose language with full dependent
types.  It is compiled, with eager evaluation.  Dependent types allow types to
be predicated on values, meaning that some aspects of a program's behaviour
can be specified precisely in the type.  The language is closely related to
Epigram and Agda.")
    (license license:bsd-3)))

;; Idris modules use the gnu-build-system so that the IDRIS_LIBRARY_PATH is set.
(define (idris-default-arguments name)
  `(#:modules ((guix build gnu-build-system)
               (guix build utils)
               (ice-9 ftw)
               (ice-9 match))
    #:phases
    (modify-phases %standard-phases
      (delete 'configure)
      (delete 'build)
      (delete 'check)
      (replace 'install
        (lambda* (#:key inputs outputs #:allow-other-keys)
          (let* ((out (assoc-ref outputs "out"))
                 (idris (assoc-ref inputs "idris"))
                 (idris-bin (string-append idris "/bin/idris"))
                 (idris-libs (string-append idris "/lib/idris/libs"))
                 (module-name (and (string-prefix? "idris-" ,name)
                                   (substring ,name 6)))
                 (ibcsubdir (string-append out "/lib/idris/" module-name))
                 (ipkg (string-append module-name ".ipkg"))
                 (idris-library-path (getenv "IDRIS_LIBRARY_PATH"))
                 (idris-path (string-split idris-library-path #\:))
                 (idris-path-files (apply append
                                          (map (lambda (path)
                                                 (map (lambda (dir)
                                                        (string-append path "/" dir))
                                                      (scandir path))) idris-path)))
                 (idris-path-subdirs (filter (lambda (path)
                                               (and path (match (stat:type (stat path))
                                                           ('directory #t)
                                                           (_ #f))))
                                                    idris-path-files))
                 (install-cmd (cons* idris-bin
                                     "--ibcsubdir" ibcsubdir
                                     "--install" ipkg
                                     (apply append (map (lambda (path)
                                                          (list "--idrispath"
                                                                path))
                                                        idris-path-subdirs)))))
            (setenv "IDRIS_LIBRARY_PATH" idris-libs)
            ;; FIXME: Seems to be a bug in idris that causes a dubious failure.
            (apply system* install-cmd)
            #t))))))

(define-public idris-lightyear
  (let ((commit "6d65ad111b4bed2bc131396f8385528fc6b3678a"))
    (package
      (name "idris-lightyear")
      (version (git-version "0.1" "1" commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/ziman/lightyear")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1pkxnn3ryr0v0cin4nasw7kgkc9dnnpja1nfbj466mf3qv5s98af"))))
      (build-system gnu-build-system)
      (native-inputs
       `(("idris" ,idris)))
      (arguments (idris-default-arguments name))
      (home-page "https://github.com/ziman/lightyear")
      (synopsis "Lightweight parser combinator library for Idris")
      (description "Lightweight parser combinator library for Idris, inspired
by Parsec.  This package is used (almost) the same way as Parsec, except for one
difference: backtracking.")
      (license license:bsd-2))))