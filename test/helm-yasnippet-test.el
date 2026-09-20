;;; helm-yasnippet-test.el --- test commands of helm-yasnippet -*- lexical-binding: t -*-

;; Copyright (C) 2023 by Shohei YOSHIDA

;; Author: Shohei YOSHIDA <syohex@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'ert)
(require 'helm-c-yasnippet)
(require 'cl-lib)

(ert-deftest regression-issue-28 ()
  "Find major-mode directory with string not regexp.
Detail: https://github.com/emacs-jp/helm-c-yasnippet/pull/28"
  (let ((tmpdir (concat temporary-file-directory "helm-yasnippet/")))
    (delete-directory tmpdir t)
    (cl-loop for dir in '("sh-mode" "fish-mode")
	     do
	     (make-directory (concat tmpdir dir) t))
    (let ((dir (helm-yas-find-recursively "sh-mode" tmpdir 'dir)))
      (should (string= dir (concat tmpdir "sh-mode/"))))
    (delete-directory tmpdir t)))

(ert-deftest helm-yas-prefix-context ()
  "Keep word completion enabled by default, including replacement bounds."
  (should (eq (default-value 'helm-yas-use-prefix) t))
  (with-temp-buffer
    (insert "before paragraph")
    (let ((helm-yas-use-prefix t))
      (should (equal (helm-yas-get-cmp-context) '("paragraph" 8 17)))
      (should (= (point) 17)))))

(ert-deftest helm-yas-no-prefix-context ()
  "Disabling word completion must also disable replacement of that word."
  (with-temp-buffer
    (insert "before paragraph")
    (let ((helm-yas-use-prefix nil))
      (should (equal (helm-yas-get-cmp-context) '("" 17 17)))
      (should (= (point) 17)))))

(ert-deftest helm-yas-prefix-candidates ()
  "Browse all candidates in either display style when prefix use is disabled."
  (dolist (show-key '(nil t))
    (dolist (use-prefix '(nil t))
      (with-temp-buffer
        (insert "unmatched")
        (let* ((helm-yas-display-key-on-candidate show-key)
               (helm-yas-use-prefix use-prefix)
               (context (helm-yas-get-cmp-context))
               (alist '((transformed ("section" . "SECTION")
                                     ("equation" . "EQUATION"))
                        (template-key-alist ("SECTION" . "sec")
                                            ("EQUATION" . "eq"))))
               (candidates (helm-yas-get-transformed-list alist (car context))))
          (should (= (length candidates) (if use-prefix 0 2))))))))

(ert-deftest helm-yas-prefix-insertion ()
  "The source's insertion action must respect the chosen replacement bounds."
  (dolist (use-prefix '(nil t))
    (with-temp-buffer
      (let ((yas-snippet-dirs nil))
        (yas-minor-mode 1))
      (insert "before paragraph")
      (let* ((helm-yas-use-prefix use-prefix)
             (context (helm-yas-get-cmp-context))
             (helm-yas-point-start (nth 1 context))
             (helm-yas-point-end (nth 2 context))
             (helm-yas-cur-snippets-alist nil)
             (helm-yas-display-msg-after-complete nil)
             (action (cdr (assoc "Insert snippet"
                                 (cdr (assq 'action helm-source-yasnippet))))))
        (funcall action "INSERTED")
        (should (equal (buffer-string)
                       (if use-prefix "before INSERTED"
                         "before paragraphINSERTED")))))))

(ert-deftest helm-yas-prefix-active-region ()
  "The option must not change the existing active-region context."
  (dolist (use-prefix '(nil t))
    (with-temp-buffer
      (insert "selected text")
      (set-mark (point-min))
      (let ((mark-active t)
            (helm-yas-use-prefix use-prefix))
        (should (equal (helm-yas-get-cmp-context) '("" 14 14)))
        (should (= (mark) 1))
        (should (= (point) 14))))))

(ert-deftest helm-yas-prefix-empty-context ()
  "Both settings should browse at an empty buffer or after whitespace."
  (dolist (use-prefix '(nil t))
    (dolist (text '("" "paragraph "))
      (with-temp-buffer
        (insert text)
        (let ((helm-yas-use-prefix use-prefix))
          (should (equal (helm-yas-get-cmp-context)
                         (list "" (point) (point)))))))))

;;; helm-yasnippet-test.el ends here
