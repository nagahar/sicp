(define (iterative-improve enough? improve)
  (lambda (guess)
    (if (enough? guess)
	guess
	((iterative-improve enough? improve) (improve guess)))))

;; sqrt
(define (sqrt x)
  (define (square x)
    (* x x))
  (define (average x y)
    (/ (+ x y) 2))
  ((iterative-improve (lambda (i) (< (abs (- 1 (/ (square i) x))) 0.001))
		      (lambda (i) (average i (/ x i)))) 1.0))
(sqrt 9)

;; fixed-point
;; 近似点が手前にずれる
(define (fixed-point f first-guess)
  (define tolerance 0.00001)
  ((iterative-improve (lambda (x) (< (abs (- x (f x))) tolerance)) f)
   first-guess))
(fixed-point cos 1.0)
