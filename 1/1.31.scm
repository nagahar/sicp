;; a.
;; product
(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
         (product term (next a) next b))))
;; factorial
(define (factorial x)
  (define (next a) (+ a 1))
  (define (identity a) a)
  (product identity 1 next x))
;; pi/4 recursive
(define (pi-product a b)
  (define (pi-term1 x) (* x x))
  (define (pi-term2 x) (* x (pi-next x)))
  (define (pi-next x) (+ x 2))
  (/ (product pi-term2 a pi-next b) (product pi-term1 (+ a 1) pi-next b)))
  
;; b.
;; product iterative
(define (product term a next b)
  (define (product-iter a result)
    (if (> a b)
      result
      (product-iter (next a) (* (term  a) result))))
  (product-iter a 1))
