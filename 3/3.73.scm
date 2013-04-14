(load "../stream.scm")
(define (integral integrand initial-value dt)
  (define int
	(cons-stream initial-value
				 (add-streams (scale-stream integrand dt)
							  int)))
  int)
(define (RC R C dt)
  (if (= C 0)
	(begin
	  (error "C must be non-zero")
	  (lambda (i v0) '()))
	(lambda (i v0)
	  (add-streams
		(scale-stream (integral i v0 dt) (/ 1 C))
		(scale-stream i R)))))

(define RC1 (RC 5 1 0.5))

(show-stream (RC1 ones 0) 5)
;; 5 5.5 6.0 6.5 7.0

