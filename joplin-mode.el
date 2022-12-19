;;; joplin-mode.el --- Major mode for Joplin notes.

;; Copyright (C) 2021 by Johan Vromans

;; Author: Johan Vromans <jv@phoenix.squirrel.nl>
;; Keywords: 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

;;; Commentary:

;; 

(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)

;;; Code:

(define-derived-mode joplin-mode
  markdown-mode "Joplin"
  "Major mode for Joplin notes."
  (if (not (has_joplin_data))
      (setq mode-name "Markdown")
    (set-variable 'require-final-newline nil t)
    (add-hook 'before-save-hook 'joplin-no-final-newline)
    (add-hook 'before-save-hook 'joplin-update-timestamps)
    ))

;; Check for Joplin data.
(defun has_joplin_data ()
  "See if the buffer contains Joplin data."
  (save-excursion
    (goto-char (point-max))
    (looking-back "^type_: [0-9]+\n?")))

;; Update timestamps.
(defun joplin-update-timestamps ()
  "Update timestamps in Joplin metadata."
  (let
      ((ts (format-time-string "%FT%T.%3NZ" nil "Z")))
    (save-excursion
      (goto-char (point-max))
      (search-backward "\n\n")
      (while (re-search-forward "^\\(?:user_\\)?\\(updated_time: \\)[-0-9:A-Z.]+" nil 2)
	(replace-match (concat "\\1" ts)))
      )))

;; Make sure the final "type_: NN" is NOT followed by a newline.
(defun joplin-no-final-newline ()
  "Ensure no final newline."
  (save-excursion
    (goto-char (point-max))
    (backward-char 1)
    (if (looking-at "\n")
	(delete-char 1))
    (set-variable 'require-final-newline nil t)))

;;; joplin-mode.el ends here
