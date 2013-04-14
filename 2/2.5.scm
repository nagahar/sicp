(define (cons a b)
  (* (expt 2 a) (expt 3 b)))
(define (car x)
  (fact 2 x 0))
(define (cdr x)
  (fact 3 x 0))
(define (fact p x n)
    (if (= (remainder x p) 1)
	n
	(fact p (/ x p) (+ n 1))))
(car (cons 0 3))
(cdr (cons 0 3))



