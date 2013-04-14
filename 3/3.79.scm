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

