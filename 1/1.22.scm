;; 1,000より大きい素数
;; 1009 *** 17 msec
;; 1013 *** 18 msec
;; 1019 *** 17 msec
;; 
;; 10,000より大きい素数
;; 10007 *** 50 msec
;; 10009 *** 51 msec
;; 10037 *** 50 msec
;;
;; 100,000より大きい素数
;; 100003 *** 152 msec
;; 100019 *** 159 msec
;; 100043 *** 152 msec
;; 
;; 1,000,000より大きい素数
;; 1000003 *** 488 msec
;; 1000033 *** 483 msec
;; 1000037 *** 477 msec 
;;
;; ほぼ√nに従った時間がかかっている

(define (search-for-primes a b)
  (define (prime-test n)
    (timed-prime-test n)
    (if (< n b)
	(prime-test (+ n 2))))
    (if (odd? a)
      (prime-test a)
      (prime-test (+ a 1))))
(define (odd? n)
  (not (divides? 2 n)))
;; gauche用runtime (microsecを返す)
(define (runtime)
   (use srfi-11)
   ;; sys-gettimeofdayの１番目の値がaに、2番目の値がbに格納され、計算結果が戻される
   (let-values (((a b) (sys-gettimeofday)))
               (+ (* a 1000000) b)))
(define (timed-prime-test n)
  (newline)
  (display n)
  (start-prime-test n (runtime)))
(define (start-prime-test n start-time)
  (if (prime? n)
      (report-prime (- (runtime) start-time))
      (display " is not prime ")))
(define (report-prime elapsed-time)
  (display " *** ")
  (display elapsed-time)
  (display " msec "))
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
(define (square x)
  (* x x))
