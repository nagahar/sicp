(load "../amb.scm")
(driver-loop)

;; 下記手続きをambevalで評価する
(define (distinct? items)
  (cond ((null? items) true)
    ((null? (cdr items)) true)
    ((member (car items) (cdr items)) false)
    (else (distinct? (cdr items)))))
(define (multiple-dwelling)
  (let ((fletcher (amb 1 2 3 4 5)))
    (require (not (= fletcher 5)))
    (require (not (= fletcher 1)))
    (let ((cooper (amb 1 2 3 4 5)))
      (require (not (= cooper 1)))
      (require (not (= (abs (- fletcher cooper)) 1)))
      (let ((miller (amb 1 2 3 4 5)))
	(require (> miller cooper))
	(let ((smith (amb 1 2 3 4 5)))
	  (require (not (= (abs (- smith fletcher)) 1)))
	  (let ((baker (amb 1 2 3 4 5)))
	    (require (not (= baker 5)))
	    (require (distinct? (list baker cooper fletcher miller smith)))
	    (list (list 'baker baker)
		  (list 'cooper cooper)
		  (list 'fletcher fletcher)
		  (list 'miller miller)
		  (list 'smith smith))))))))

;;;; Amb-Eval input:
;(multiple-dwelling)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;((baker 3) (cooper 2) (fletcher 4) (miller 5) (smith 1))

