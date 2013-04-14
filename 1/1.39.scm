(define (tan-cf x k)
  (cont-frac (lambda (i) (cond ((= i 1) x)
			       (else (- (* x x)))))
	     (lambda (i) (- (* 2 i) 1))
	     k))
(define (cont-frac n d k)
  (define (iter count result)
    (if (= count 0)
      result
      (iter (- count 1) (/ (n count) (+ result (d count))))))
  (iter k 0))

