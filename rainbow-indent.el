;;; rainbow-indent.el --- Colorize indentation based on depth -*- lexical-binding: t; -*-

;; Copyright (C) 2014 Jason Feng

;; Authors: Jason Feng
;; URL: http://github.com/funkenblatt/rainbow-indent/
;; Version: 0.0.1

;; This file will probably never be part of GNU Emacs

;;; Commentary:

;; The default color scheme isn't really a rainbow, more of a grayscale gradient,
;; so perhaps "rainbow" indents are a bit of a misnomer.
;;
;; Better color schemes can be defined as elisp functions taking a single parameter
;; `depth', and assigned to the variable `rainbow-indent-color-function'.  Grayscale
;; happens to work for me, so I haven't bothered adding any others.
;;
;; This is mostly useful for indentation-based languages like coffeescript or
;; python.
;; 
;; The best way to use this library is probably to add the rainbow-mode-hook to
;; whatever major mode hook you're using.

;; Note that rainbow-mode-hook requires lexical-binding to work and will thus
;; only work on Emacs 24 or later.

;;; Code:

(defun rainbow-indent-hexcolor (r g b)
  (apply 'concat "#" (mapcar (lambda (x) (format "%02x" x)) (list r g b))))

(defun rainbow-indent-grayscale (depth)
  "A discretized gradient that fades in from white."
  (let ((c (* (- 15 (/ (min depth 30) 2)) #x11)))
    (rainbow-indent-hexcolor c c c)))

(defun rainbow-indent-blackscale (depth)
  "A discretized gradient that fades out from black."
  (let ((c (* (/ (min depth 30) 2) #x11)))
    (rainbow-indent-hexcolor c c c)))

(defun rainbow-indent-ForestTheme (depth)
  "A discretized gradient that fades out from the initial color (43, 51, 57)."
  (let* ((initial-color '(43 51 57))
         (max-depth 30)
         (scale-factor (/ (min depth max-depth) 2))
         (r (min 255 (+ (nth 0 initial-color) (* scale-factor #x11))))
         (g (min 255 (+ (nth 1 initial-color) (* scale-factor #x11))))
         (b (min 255 (+ (nth 2 initial-color) (* scale-factor #x11)))))
    (rainbow-indent-hexcolor r g b)))


;; (defvar rainbow-indent-color-function 'rainbow-indent-grayscale)
(defvar rainbow-indent-color-function 'rainbow-indent-ForestTheme)

(defun rainbow-indent-line ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (when (looking-at "^ +")
      (dotimes (i (length (match-string 0)))
        (set-text-properties
         (+ i (line-beginning-position))
         (+ i (line-beginning-position) 1)
         `(font-lock-face 
           (:background ,(funcall rainbow-indent-color-function i))
           rear-nonsticky t))))))

(defun rainbow-indent-all ()
  "Rainbow indent ALL the THINGS."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (rainbow-indent-line)
      (forward-line))))

(defun rainbow-indent-hook ()
  "This is a hook you should add to some mode hook or other in order to
get fancy rainbow indentation.  For example:

  (add-hook 'coffee-mode-hook 'rainbow-indent-hook)"
  (let ((indent-fn indent-line-function))
    (rainbow-indent-all)
    (set-buffer-modified-p nil)
    (setq indent-line-function
          (lambda (&rest args)
            (apply indent-fn args)
            (rainbow-indent-line)))))
(defun rainbow-indent-clear-line ()
  "Clear rainbow indentation from the current line."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (when (looking-at "^ +")
      (remove-text-properties
       (line-beginning-position)
       (line-end-position)
       '(font-lock-face nil)))))

(defun rainbow-indent-clear ()
  "Clear rainbow indentation from the entire buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (rainbow-indent-clear-line)
      (forward-line))))
(add-hook 'org-mode-hook 'rainbow-indent-hook)

(provide 'rainbow-indent)

;;; rainbow-indent.el ends here
