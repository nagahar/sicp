(load "../amb.scm")

;; 実行に時間がかかるが・・・

(driver-loop)

;; 下記手続きをambevalで評価する
(define (distinct? items)
  (cond ((null? items) true)
    ((null? (cdr items)) true)
    ((member (car items) (cdr items)) false)
    (else (distinct? (cdr items)))))
(define (out-of-diagonal? matrix)
  (define (iter mat p-result n-result)
    (if (null? mat)
      (and (distinct? p-result) (distinct? n-result))
      (let ((row (car (car mat)))
            (col (car (cdr (car mat)))))
        (iter (cdr mat)
              (cons (+ row col) p-result)
              (cons (- row col) n-result)))))
  (iter matrix '() '()))
(define (queens)
  (let ((q1-row (amb 1 2 3 4 5 6 7 8))
	(q1-col (amb 1 2 3 4 5 6 7 8)))
    (let ((q2-row (amb 1 2 3 4 5 6 7 8))
	  (q2-col (amb 1 2 3 4 5 6 7 8)))
      (require (distinct? (list q1-row q2-row)))
      (require (distinct? (list q1-col q2-col)))
      (require (out-of-diagonal? (list (list q1-row q1-col) (list q2-row q2-col))))
      (let ((q3-row (amb 1 2 3 4 5 6 7 8))
	    (q3-col (amb 1 2 3 4 5 6 7 8)))
	(require (distinct? (list q1-row q2-row q3-row)))
	(require (distinct? (list q1-col q2-col q3-col)))
	(require (out-of-diagonal? (list (list q1-row q1-col) (list q2-row q2-col) (list q3-row q3-col))))
	(let ((q4-row (amb 1 2 3 4 5 6 7 8))
	      (q4-col (amb 1 2 3 4 5 6 7 8)))
	  (require (distinct? (list q1-row q2-row q3-row q4-row)))
	  (require (distinct? (list q1-col q2-col q3-col q4-col)))
	  (require (out-of-diagonal? (list (list q1-row q1-col) (list q2-row q2-col) (list q3-row q3-col) (list q4-row q4-col))))
	  (let ((q5-row (amb 1 2 3 4 5 6 7 8))
		(q5-col (amb 1 2 3 4 5 6 7 8)))
	    (require (distinct? (list q1-row q2-row q3-row q4-row q5-row)))
	    (require (distinct? (list q1-col q2-col q3-col q4-col q5-col)))
	    (require (out-of-diagonal? (list (list q1-row q1-col) (list q2-row q2-col) (list q3-row q3-col) (list q4-row q4-col) (list q5-row q5-col))))
	    (let ((q6-row (amb 1 2 3 4 5 6 7 8))
		  (q6-col (amb 1 2 3 4 5 6 7 8)))
	      (require (distinct? (list q1-row q2-row q3-row q4-row q5-row q6-row)))
	      (require (distinct? (list q1-col q2-col q3-col q4-col q5-col q6-col)))
	      (require (out-of-diagonal? (list (list q1-row q1-col) (list q2-row q2-col) (list q3-row q3-col) (list q4-row q4-col) (list q5-row q5-col) (list q6-row q6-col))))
	      (let ((q7-row (amb 1 2 3 4 5 6 7 8))
		    (q7-col (amb 1 2 3 4 5 6 7 8)))
		(require (distinct? (list q1-row q2-row q3-row q4-row q5-row q6-row q7-row)))
		(require (distinct? (list q1-col q2-col q3-col q4-col q5-col q6-col q7-col)))
		(require (out-of-diagonal? (list (list q1-row q1-col) (list q2-row q2-col) (list q3-row q3-col) (list q4-row q4-col) (list q5-row q5-col) (list q6-row q6-col) (list q7-row q7-col))))
		(let ((q8-row (amb 1 2 3 4 5 6 7 8))
		      (q8-col (amb 1 2 3 4 5 6 7 8)))
		  (require (distinct? (list q1-row q2-row q3-row q4-row q5-row q6-row q7-row q8-row)))
		  (require (distinct? (list q1-col q2-col q3-col q4-col q5-col q6-col q7-col q8-col)))
		  (require (out-of-diagonal? (list (list q1-row q1-col) (list q2-row q2-col) (list q3-row q3-col) (list q4-row q4-col) (list q5-row q5-col) (list q6-row q6-col) (list q7-row q7-col) (list q8-row q8-col))))
		  (list (list q1-row q1-col) (list q2-row q2-col)
			(list q3-row q3-col) (list q4-row q4-col)
			(list q5-row q5-col) (list q6-row q6-col)
			(list q7-row q7-col) (list q8-row q8-col)))))))))))

;;;; Amb-Eval input:
;(queens)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;((1 1) (2 5) (3 8) (4 6) (5 3) (6 7) (7 2) (8 4))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((1 1) (2 5) (3 8) (4 6) (5 3) (6 7) (8 4) (7 2))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((1 1) (2 5) (3 8) (4 6) (5 3) (7 2) (6 7) (8 4))

