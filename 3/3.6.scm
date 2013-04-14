(define (gen-rand random-init)
  (let ((x random-init))
    (define (generate)
      (set! x (rand-update x))
      x)
    (define (reset s)
      (set! x s)
      x)
    (define (dispatch m)
      (cond ((eq? m 'generate) (generate))
	    ((eq? m 'reset) reset)
	    (else (error "Unknown request -- RAND" m))))
  dispatch))

(define rand (gen-rand 1))
(define (generate-random a b m)
  (lambda (x)
    (modulo (+ (* a x) b) m)))
(define rand-update (generate-random 3 5 13))

(rand 'generate)
((rand 'reset) 10)