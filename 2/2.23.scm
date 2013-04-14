
(define (for-each proc items)
  (cond ((null? items) (newline))
	;; condのelseの式は並びで良い
	(else (proc (car items))
	      (for-each proc (cdr items)))))
(for-each (lambda (x) (newline) (display x))
	  (list 57 321 88))
(for-each (lambda (x) (newline) (display x))
	  ())
