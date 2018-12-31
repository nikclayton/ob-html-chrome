;;; ob-html-chrome.el --- HTML code blocks converted to PNG using Chrome -*- lexical-binding: t -*-

;; Author: Nik Clayton nik@ngo.org.uk
;; URL: http://github.com/nikclayton/ob-html-chrome
;; Version: 1.1
;; Package-Requires: ((emacs "24.4"))
;; Keywords: languages, org, org-babel, chrome, html

;;; Commentary:

;; Org-Babel support for rendering HTML to PNG files using Chrome.
;;
;; This is similar functionality to ob-browser, without the PhantomJS
;; requirement.

;;; Code:
(require 'org)
(require 'ob)
(require 'ob-eval)

(defcustom org-babel-html-chrome-chrome-executable
  ""
  "Full path to Google Chrome."
  :group 'org-babel
  :safe t
  :type 'string)

;; Treat html-chrome SRC blocks like html SRC blocks for editing
(add-to-list 'org-src-lang-modes (quote ("html-chrome" . html)))

(defvar org-babel-default-header-args:html-chrome
  '((:results . "file") (:exports . "both"))
  "Default arguments to use when evaluating a html-chrome SRC block.")

(defun org-babel-execute:html-chrome (body params)
  "Render the HTML in BODY using PARAMS."
  (unless (file-executable-p org-babel-html-chrome-chrome-executable)
    (error "Can not export HTML: `%s' (specified by org-babel-html-chrome-chrome-executable) does not exist or is not executable" org-babel-html-chrome-chrome-executable))
  (let* ((processed-params (org-babel-process-params params))
         (org-babel-temporary-directory default-directory)
         (html-file (org-babel-temp-file "ob-html-chrome" ".html"))
         (url-header-arg (cdr (assoc :url processed-params)))
         (url (if (and url-header-arg
                       (org-file-url-p url-header-arg))
                  url-header-arg
                (concat "file://" (org-babel-process-file-name html-file))))
         (out-file (or (cdr (assoc :file processed-params)) ; :file arg
                       ;; use the #+NAME of block
                       (concat (nth 4 (org-babel-get-src-block-info)) ".png")
                       ;; use the Heading
                       (concat
                        (string-join
                         (mapcar 'downcase
                                 (split-string
                                  (nth 4 (org-heading-components)) " ")) "-")
                        ".png")))
         (flags (cdr (assoc :flags processed-params)))
         (cmd (string-join
               `(,(shell-quote-argument
                   org-babel-html-chrome-chrome-executable)
                 ,@'("--headless" "--disable-gpu" "--enable-logging")
                 ,flags
                 ,(format "--screenshot=%s"
                          (org-babel-process-file-name out-file))
                 ,url)
               " ")))
    (with-temp-file html-file
      (insert body))
    (org-babel-eval cmd "")
    (delete-file html-file)
    out-file))

(defun org-babel-prep-session:html-chrome (session params)
  "Return an error, sessions are not supported."
  (error "ob-html-chrome does not support sessions"))

(provide 'ob-html-chrome)

;;; ob-html-chrome.el ends here
