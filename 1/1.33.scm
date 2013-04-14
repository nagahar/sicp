;; filtered-accumelate
(define (filtered-accumelate filter combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (cond ((filter a) (term a))
		      (else null-value)) 
		(filtered-accumelate filter combiner null-value term (next a) next b))))

;; a.
(define (sum-square-prime a b)
  (filtered-accumelate prime? + 0 square a inc b))
(define (square x)
  (* x x))
(define (inc x)
  (+ x 1))
(define (prime? n)
  (= n (smallest-divisor n)))
(define (smallest-divisor n)
  (find-divisor n 2))
(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))
(define (divides? a b)
  (= (remainder b a) 0))

;; b.
(define (product-gcd n)
  (define (prime-gcd? a)
    (= (gcd a n) 1))
  (filtered-accumelate prime-gcd? * 1 identity 1 inc n))
(define (gcd a b)
  (if (= b 0)
      a
      (gcd b (remainder a b))))
(define (identity x) x)
