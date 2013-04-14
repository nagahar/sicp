(define (new-if predicate then-clause else-clause)
  (cond (predicate then-clause)
    (else else-clause)))

(define (average x y)
  (/ (+ x y) 2))
(define (square x)
  (* x x))
(define (improve guess x)
  (average guess (/ x guess)))
(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))
(define (sqrt-iter guess x)
  (new-if (good-enough? guess x)
	  guess
	  (sqrt-iter (improve guess x)
		     x)))
(define (sqrt x)
  (sqrt-iter 1.0 x))

(sqrt 9)

;; new-ifを作用順序で評価を行うと、(good-enough? ..)がTRUEであっても、(sqrt-iter...)を完全に展開しようとし、無限ループに入ってしまう。
;; 従って、作用順序の評価ではifは特殊形式である必要がある
