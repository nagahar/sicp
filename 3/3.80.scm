
(load "../stream.scm")
(define (integral delayed-integrand initial-value dt)
  (define int
	(cons-stream initial-value
				 (let ((integrand (force delayed-integrand)))
				   (add-streams (scale-stream integrand dt)
								int))))
  int)
(define (solve f y0 dt)
  (define y (integral (delay dy) y0 dt))
  (define dy (stream-map f y))
  y)
(define (solve-2nd f dt y0 dy0)
  (define y (integral (delay dy) y0 dt))
  (define dy (integral (delay ddy) dy0 dt))
  (define ddy (stream-map f dy y))
  y)
(define (RLC R L C dt)
  (if (or (= C 0) (= L 0))
	(begin
	  (error "C and L must be non-zero")
	  (lambda (vC0 iL0) '()))
	(lambda (vC0 iL0)
	  (begin
		(define vC (integral (delay dvC) vC0 dt))
		(define iL (integral (delay diL) iL0 dt))
		(define dvC (scale-stream iL (/ -1 C)))
		(define diL (add-streams (scale-stream iL (- (/ R L)))
								 (scale-stream vC (/ 1 L))))
		(stream-map (lambda (v i) (cons v i)) vC iL)))))

(define RLC1 (RLC 1 1 0.2 0.1))

(show-stream (RLC1 10 0) 5)
;; (10 . 0) (10.0 . 1.0) (9.5 . 1.9) (8.55 . 2.66) (7.220000000000001 . 3.249)

