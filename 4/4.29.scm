(load "../lazy-metacircular.scm")
;(define (driver-loop)
;  (prompt-for-input input-prompt)
;  (let ((input (read)))
;    (let ((output
;	    (time (actual-value input the-global-environment))))
;      (announce-output output-prompt)
;      (user-print output)))
;  (driver-loop))
;; メモ化しない force-it
(define (force-it obj)
  (if (thunk? obj)
    (actual-value (thunk-exp obj) (thunk-env obj))
    obj))
(driver-loop)

;; 下記のようなフィボナッチ数を求めるプログラムがメモ化の有無による速度差が大きい
(define (fib n)
  (define (fib-iter a b count)
    (if (= count 0)
      b
      (fib-iter (+ a b) a (- count 1))))
  (fib-iter 1 0 n))
;; メモ化した場合
(fib 20)
;(time (actual-value input the-global-environment))
; real   0.001
; user   0.000
; sys    0.000
;; メモ化しない場合
(fib 20)
;(time (actual-value input the-global-environment))
; real   0.118
; user   0.110
; sys    0.010

(define count 0)
(define (id x)
  (set! count (+ count 1))
  x)
(define (square x)
  (* x x))

;; メモ化した場合
;;;; L-Eval input:
;(square (id 10))
;;;; L-Eval value:
;100
;;;; L-Eval input:
;count
;;;; L-Eval value:
;1

;; メモ化しない場合
;;; L-Eval input:
;(square (id 10))
;;;; L-Eval value:
;100
;;;; L-Eval input:
;count
;;;; L-Eval value:
;2

