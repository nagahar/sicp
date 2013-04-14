(load "../amb.scm")

(driver-loop)

;; 下記手続きをambevalで評価する
(define (an-integer-between low high)
  (require (< low high))
  (amb low (an-integer-between (+ low 1) high)))
(define (a-pythagorean-triple-between low high)
  (let ((i (an-integer-between low high)))
    (let ((j (an-integer-between i high)))
      (let ((k (an-integer-between j high)))
	(require (= (+ (* i i) (* j j)) (* k k)))
	(list i j k)))))

;;;; Starting a new problem 
;;;; Amb-Eval value:
;ok
;
;;;; Amb-Eval input:
;(a-pythagorean-triple-between 1 15)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;(3 4 5)
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(5 12 13)

