;; 解には影響しないが、解を見いだす時間には影響する
;; その理由は、制限の順序によって探索失敗までのステップが変わるためである。
;; 下記のように制限の強い条件(失敗確率が高い条件)を先頭に持ってくる
;; 但し、distinct?の条件はべき乗のオーダなので最後に置く方が良いかもしれない
;;
;; それぞれの条件が失敗する場合の数は下記の通り
;; (require (distinct? (list baker cooper fletcher miller smith)))
;; ->3125-5!=3005通り
;; (require (not (= (abs (- smith fletcher)) 1)))
;; ->1000通り
;; (require (not (= (abs (- fletcher cooper)) 1)))
;; ->1000通り
;; (require (not (= fletcher 5)))
;; ->625通り
;; (require (not (= fletcher 1)))
;; ->625通り
;; (require (not (= baker 5)))
;; ->625通り
;; (require (not (= cooper 1)))
;; ->625通り
;; (require (> miller cooper))
;; ->5+4+3+2+1=15通り

(load "../amb.scm")
(driver-loop)

;; 下記手続きをambevalで評価する
(define (distinct? items)
  (cond ((null? items) true)
    ((null? (cdr items)) true)
    ((member (car items) (cdr items)) false)
    (else (distinct? (cdr items)))))
(define (multiple-dwelling)
  (let ((baker (amb 1 2 3 4 5))
	(cooper (amb 1 2 3 4 5))
	(fletcher (amb 1 2 3 4 5))
	(miller (amb 1 2 3 4 5))
	(smith (amb 1 2 3 4 5)))
    (require (not (= (abs (- smith fletcher)) 1)))
    (require (not (= (abs (- fletcher cooper)) 1)))
    (require (not (= fletcher 5)))
    (require (not (= fletcher 1)))
    (require (not (= baker 5)))
    (require (not (= cooper 1)))
    (require (> miller cooper))
    (require
      (distinct? (list baker cooper fletcher miller smith)))
    (list (list 'baker baker)
	  (list 'cooper cooper)
	  (list 'fletcher fletcher)
	  (list 'miller miller)
	  (list 'smith smith))))

;;;; Amb-Eval input:
;(multiple-dwelling)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;((baker 3) (cooper 2) (fletcher 4) (miller 5) (smith 1))

