(define (make-accumulator sum)
  (lambda (x)
    (set! sum (+ sum x))))

(define A (make-accumulator 5))
(define B (make-accumulator 5))
(A 10)
(B 10)