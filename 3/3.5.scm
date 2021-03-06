(define (estimate-integral p x1 x2 y1 y2 trials)
  (define (p-test)
    (p (random-in-range x1 x2) (random-in-range y1 y2)))
  (* (monte-carlo trials p-test) (* (- x2 x1) (- y2 y1))))
(define (monte-carlo trials experiment)
  (define (iter trials-remaining trials-passed)
    (cond ((= trials-remaining 0)
           (/ trials-passed trials))
          ((experiment)
           (iter (- trials-remaining 1) (+ trials-passed 1)))
          (else
           (iter (- trials-remaining 1) trials-passed))))
  (iter trials 0))
(define (random-in-range low high)
  (let ((range (- high low)))
    (use srfi-27)
    (+ low (random-integer range))))

(define (c x y) (<= (+ (* x x) (* y y)) 1))
(estimate-integral c -1 1 -1 1 1000.0)

