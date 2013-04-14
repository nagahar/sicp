(timed-prime-test 1009)
(timed-prime-test 1013)
(timed-prime-test 1019)
(timed-prime-test 10007)
(timed-prime-test 10009)
(timed-prime-test 10037)
(timed-prime-test 100003)
(timed-prime-test 100019)
(timed-prime-test 100043)
(timed-prime-test 1000003)
(timed-prime-test 1000033)
(timed-prime-test 1000037)

(define (calc a b c x y z)
  (/ (+ (/ a x) (/ b y) (/ c z)) 3))

;; 2にならない。ほぼ1.6倍になる。
;; 本アルゴリズムでは、オリジナルに比べてnextサブルーチン呼出しのためにステップ数が増加しているため

;; 1000の時    1.1361416361416363
;; 10000の時   1.573619257086999
;; 100000の時  1.6418439716312057
;; 1000000の時 1.6071901843940861
;; 今回結果
;; 1009 *** 28 msec
;; 1013 *** 13 msec
;; 1019 *** 12 msec
;; 10007 *** 31 msec
;; 10009 *** 33 msec
;; 10037 *** 32 msec
;; 100003 *** 94 msec
;; 100019 *** 94 msec
;; 100043 *** 94 msec
;; 1000003 *** 290 msec
;; 1000033 *** 291 msec
;; 1000037 *** 295 msec

;; 前回結果
;; 1009 *** 17 msec
;; 1013 *** 18 msec
;; 1019 *** 17 msec
;; 10007 *** 50 msec
;; 10009 *** 51 msec
;; 10037 *** 50 msec
;; 100003 *** 152 msec
;; 100019 *** 159 msec
;; 100043 *** 152 msec
;; 1000003 *** 488 msec
;; 1000033 *** 483 msec
;; 1000037 *** 477 msec 


(define (smallest-divisor n)
  (find-divisor n 2))
(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (next test-divisor)))))
(define (divides? a b)
  (= (remainder b a) 0))
(define (square x)
  (* x x))
(define (next n)
  (if (= n 2)
      3
      (+ n 2)))
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
