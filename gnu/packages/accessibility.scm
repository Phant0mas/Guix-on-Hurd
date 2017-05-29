;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2017 ng0 <ng0@no-reply.pragmatique.xyz>
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

(define-module (gnu packages accessibility)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (gnu packages)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config))

(define-public florence
  (package
    (name "florence")
    (version "0.6.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://sourceforge/florence/florence/" version
                           "/" name "-" version ".tar.bz2"))
       (sha256
        (base32
         "07h9qm22krlwayhzvc391lr23vicw81s48g7rirvx1fj0zyr4aa2"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     `(#:configure-flags (list "--with-xtst"
                               "--without-docs"
                               "--with-notification")))
    (inputs
     `(("libxml2" ,libxml2)
       ("libglade" ,libglade)
       ("librsvg" ,librsvg)
       ("gstreamer" ,gstreamer)
       ("cairo" ,cairo)
       ("gtk+" ,gtk+)
       ("libxtst" ,libxtst)
       ("libxcomposite" ,libxcomposite)
       ("libnotify" ,libnotify)))
    (native-inputs
     `(("gettext-minimal" ,gettext-minimal)
       ("intltool" ,intltool)
       ("pkg-config" ,pkg-config)))
    (home-page "http://florence.sourceforge.net/")
    (synopsis "Extensible, scalable virtual keyboard for X11")
    (description
     "Florence is an extensible scalable virtual keyboard for X11.
It is useful for people who can't use a real hardware keyboard (for
example for people with disabilities), but you must be able to use
a pointing device (as a mouse, a trackball, a touchscreen or opengazer).

Florence stays out of your way when you don't need it: it appears on the
screen only when you need it.  A timer-based auto-click input method is
available to help to click.")
    ;; The documentation is under FDL1.2, but we do not install the
    ;; documentation.
    (license license:gpl2+)))