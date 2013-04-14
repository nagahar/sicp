(define (euler-cf k)
  (+ (cont-frac (lambda (i) 1.0)
		(lambda (i) 
		  (cond ((= (remainder i 3) 1) 1.0)
			((= (remainder i 3) 2) (+ (* 2 (quotient i 3)) 2))
			((= (remainder i 3) 0) 1.0)))
		k)
     2))
(define (cont-frac n d k)
  (define (iter count result)
    (if (= count 0)
      result
      (iter (- count 1) (/ (n count) (+ result (d count))))))
  (iter k 0))

(euler-cf 10)