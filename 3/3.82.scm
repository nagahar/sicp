(load "../stream.scm")
(define (random-in-range low high)
  (let ((range (- high low)))
    (use srfi-27)
    (+ low (random-integer range))))
(define (monte-carlo experiment-stream passed failed)
  (define (next passed failed)
	(cons-stream
	  (/ passed (+ passed failed))
	  (monte-carlo
		(stream-cdr experiment-stream) passed failed)))
  (if (stream-car experiment-stream)
	(next (+ passed 1) failed)
	(next passed (+ failed 1))))
(define (estimate-integral p x1 x2 y1 y2)
  (stream-map (lambda (m) (* (- x2 x1) (- y2 y1) m))
			  (monte-carlo (stream-map p
									   (stream-map (lambda (x) (random-in-range x1 x2)) ones)
									   (stream-map (lambda (x) (random-in-range y1 y2)) ones))
						   0.0 0.0)))
(define (c x y) (<= (+ (* x x) (* y y)) 1))
(print (stream-ref (estimate-integral c -1 1 -1 1) 10000))
;; 3.0304969503049697 ~ pi

