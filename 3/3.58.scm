(load "../stream.scm")
(define (expand num den radix)
  (cons-stream
	(quotient (* num radix) den)
	(expand (remainder (* num radix) den) den radix)))

(define s1 (expand 1 7 10))
(define s2 (expand 3 8 10))
(show-stream s1 5)
;; 1 4 2 8 5
(show-stream s2 5)
;; 3 7 5 0 0

