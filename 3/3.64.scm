(load "../stream.scm")
(define (stream-limit s l)
  (let ((v1 (stream-car s))
		(v2 (stream-car (stream-cdr s))))
	(if (< (abs (- v1 v2)) l)
	  v2
	  (stream-limit (stream-cdr s) l))))
(define (sqrt-stream x)
  (define guesses
	(cons-stream 1.0
				 (stream-map (lambda (guess)
							   (sqrt-improve guess x))
							 guesses)))
  guesses)
(define (sqrt-improve guess x)
  (average guess (/ x guess)))
(define (sqrt x tolerance)
  (stream-limit (sqrt-stream x) tolerance))
(define (average x y)
  (/ (+ x y) 2))
(display (sqrt 2 0.001))

