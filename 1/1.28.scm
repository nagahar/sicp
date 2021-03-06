(define (expmod base exp m)
  (define (check-mod? n)
    (cond ((or (= n 1) (= n (- m 1))) n)
	  ((= (remainder (square n) m) 1) 0)
	  (else n)))
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder (square (check-mod? (expmod base (/ exp 2) m)))
                    m))
        (else
         (remainder (* base (expmod base (- exp 1) m))
                    m))))
(define (even? n)
  (= (remainder n 2) 0))

(define (miller-rabin-test n)
  (define (try-it a)
    (= (expmod a (- n 1) n) 1))
  (try-it (+ 1 (random (- n 1)))))
(define (fast-prime? n times)
  (cond ((= times 0) #t)
	((miller-rabin-test n) (fast-prime? n (- times 1)))
	(else #f)))
(define (random n)
  (use srfi-27)
  (random-integer n))
(define (square x)
  (* x x))

(fast-prime? 1009 5)
(fast-prime? 1013 5)
(fast-prime? 1019 5)
(fast-prime? 10007 5)
(fast-prime? 10009 5)
(fast-prime? 10037 5)
(fast-prime? 100003 5)
(fast-prime? 100019 5)
(fast-prime? 100043 5)
(fast-prime? 1000003 5)
(fast-prime? 1000033 5)
(fast-prime? 1000037 5)
(fast-prime? 561 5)
(fast-prime? 1105 5)
(fast-prime? 1729 5)
(fast-prime? 2465 5)
(fast-prime? 2821 5)
(fast-prime? 6601 5)
