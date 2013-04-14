;; a.
;; accumelate recursive
(define (accumelate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
		(accumelate combiner null-value term (next a) next b))))
;; sum
(define (sum term a next b)
  (accumelate + 0 term a next b))
;; product
(define (product term a next b)
  (accumelate * 1 term a next b))
(define (sum-cubes a b)
  (define (inc n) (+ n 1))
  (define (cube x) (* x x x))
  (sum cube a inc b))
(define (pi-product a b)
  (define (pi-term1 x) (* x x))
  (define (pi-term2 x) (* x (pi-next x)))
  (define (pi-next x) (+ x 2))
  (/ (product pi-term2 a pi-next b) (product pi-term1 (+ a 1) pi-next b)))

;; b.
;; accumulate iterative
(define (accumelate combiner null-value term a next b)
  (define (accumelate-iter a result)
    (if (> a b)
	result
	(accumelate-iter (next a) (combiner (term a) null-value))))
  (accumelate-iter a null-value))
