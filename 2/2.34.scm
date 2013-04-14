(define (horner-eval x coefficient-sequence)
  (accumulate (lambda (this-coeff highter-terms)
		(+ (* highter-terms x) this-coeff))
	      0
	      coefficient-sequence))
(horner-eval 2 (list 1 3 0 5 0 1))