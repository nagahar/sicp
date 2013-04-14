;; an-integer-betweenをan-integer-starting-fromに置き換えただけでは、an-integer-starting-fromは失敗条件が無いため、無限に値を探索してしまう。したがって、計算が完了しない
;; 下記のようにすればよい
(load "../amb.scm")

(driver-loop)

;; 下記手続きをambevalで評価する
(define (an-integer-starting-from n)
  (amb n (an-integer-starting-from (+ n 1))))
(define (an-integer-between low high)
  (require (< low high))
  (amb low (an-integer-between (+ low 1) high)))
(define (a-pythagorean-triple-between n)
  (let ((k (an-integer-starting-from n)))
    (let ((i (an-integer-between n k)))
      (let ((j (an-integer-between i k)))
	(require (= (+ (* i i) (* j j)) (* k k)))
	(list i j k)))))

;;; Amb-Eval input:
;(a-pythagorean-triple-between 1)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;(3 4 5)
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(6 8 10)

