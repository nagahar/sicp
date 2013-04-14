;; gaucheのtimeを使う

;(load "../metacircular.scm")
(load "../metacircular2.scm")
(define (driver-loop)
  (prompt-for-input input-prompt)
  (let ((input (read)))
    (let ((output (time (eval input the-global-environment))))
      (announce-output output-prompt)
      (user-print output)))
  (driver-loop))

;; 評価用関数
(define (fib n)
  (define (fib-iter a b count)
    (if (= count 0)
      b
      (fib-iter (+ a b) a (- count 1))))
  (fib-iter 1 0 n))

(driver-loop)

;; 始めの版
(fib 1000)
;(time (eval input the-global-environment))
; real   0.053
; user   0.050
; sys    0.000
(fib 10000)
;(time (eval input the-global-environment))
; real   0.351
; user   0.340
; sys    0.010
(fib 100000)
;(time (eval input the-global-environment))
; real   5.707
; user   5.590
; sys    0.070

;; 本節の版
(fib 1000)
;(time (eval input the-global-environment))
; real   0.033
; user   0.030
; sys    0.010
(fib 10000)
;(time (eval input the-global-environment))
; real   0.240
; user   0.240
; sys    0.000
(fib 100000)
;(time (eval input the-global-environment))
; real   4.437
; user   4.340
; sys    0.050

;; 下記より始めの版と本節の版の解析と実行に使われる時間はnの増加に伴い、漸近する
;; nが1000の時: 始めの版と本節の版の比率 0.053:0.033=1:0.622
;; nが10000の時: 始めの版と本節の版の比率 0.351:0.240=1:0.683
;; nが100000の時: 始めの版と本節の版の比率 5.707:4.437=1:0.777
;;
;; 上記より、nが大きいとき解析と実行の分離の影響は小さくなることが分かる

