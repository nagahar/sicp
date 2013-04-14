;; log(10**3)=3*log10
;; log(10**6)=6*log10
;; 上式より、2倍と予想する
;; 実際はほぼ3倍になっている
;; 'cause 10**6の方は剰余、2乗計算での数が大きいため、計算時間が長くかかっている

;; femat-test
;; 1009 *** 60 msec 
;; 1013 *** 46 msec 
;; 1019 *** 48 msec 
;; 10007 *** 55 msec 
;; 10009 *** 57 msec 
;; 10037 *** 57 msec 
;; 100003 *** 122 msec 
;; 100019 *** 161 msec 
;; 100043 *** 124 msec 
;; 1000003 *** 166 msec 
;; 1000033 *** 164 msec 
;; 1000037 *** 174 msec

;(timed-prime-test 1009)
;(timed-prime-test 1013)
;(timed-prime-test 1019)
;(timed-prime-test 10007)
;(timed-prime-test 10009)
;(timed-prime-test 10037)
;(timed-prime-test 100003)
;(timed-prime-test 100019)
;(timed-prime-test 100043)
;(timed-prime-test 1000003)
;(timed-prime-test 1000033)
;(timed-prime-test 1000037)
 
(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder (square (expmod base (/ exp 2) m))
                    m))
        (else
         (remainder (* base (expmod base (- exp 1) m))
                    m))))
(define (fermat-test n)
  (define (try-it a)
    (= (expmod a n n) a))
  (try-it (+ 1 (random (- n 1)))))
(define (random n)
  (use srfi-27)
  (random-integer n))
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
  (if (fast-prime? n 1)
      (report-prime (- (runtime) start-time))
      (display " is not prime ")))
(define (report-prime elapsed-time)
  (display " *** ")
  (display elapsed-time)
  (display " msec "))
(define (fast-prime? n times)
  (cond ((= times 0) #t)
	((fermat-test n) (fast-prime? n (- times 1)))
        (else #f)))
(define (square x)
  (* x x))

