(load "../stream.scm")
(define s (cons-stream 1 (add-streams s s)))
(show-stream s 4)
;; (1 2 4 8 ...)
