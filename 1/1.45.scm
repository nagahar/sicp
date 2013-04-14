;; y->x/y**3
(define (fth-root x)
  (fixed-point ((double average-damp) (lambda (y) (/ x (* y y y)))) 1.0))
(fth-root 81)

;; y->x/y**(n-1)
;; 予測：n乗根ではn/2の商の回数平均緩和が必要となる
(define (nth-root x n)
  (fixed-point ((repeated average-damp (quotient n 2))
		(lambda (y) (/ x (fast-expt y (- n 1)))))
	       1.0))
(nth-root 64 6)

(define (fast-expt b n)
  (expt-iter b n 1))
(define (expt-iter b n a)
  (define (even? n)
    (= (remainder n 2) 0))
  (cond ((= n 0) a)
        ((even? n) (expt-iter (square b) (/ n 2) a))
        (else (expt-iter b (- n 1) (* b a)))))
(define (square x)
  (* x x))
(define (double f)
  (lambda (x) (f (f x))))
(define (repeated f n)
  (if (= n 1)
      (lambda (x) (f x))
      (compose f (repeated f (- n 1)))))
(define (compose f g)
  (lambda (x) (f (g x))))
(define (inc n)
  (+ n 1))
(define (square x)
  (* x x))
(define (average-damp f)
  (lambda (x) (average x (f x))))
(define (average a b)
  (/ (+ a b) 2))
(define tolerance 0.00001)
(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
	  next
	  (try next))))
  (try first-guess))
