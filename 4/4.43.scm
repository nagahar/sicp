;; 下記の3通りある

;; 下記手続きをambevalで評価する
(define (distinct? items)
  (cond ((null? items) true)
    ((null? (cdr items)) true)
    ((member (car items) (cdr items)) false)
    (else (distinct? (cdr items)))))
(define (father)
  (let ((Moore 1)
	(Downing 2)
	(Hall 3)
	(Barnacle 4)
	(Parker 5))
    (let ((Mary (amb 1 2 3 4 5)))
      (require (= Mary Moore))
      (let ((Melissa (amb 1 2 3 4 5)))
	(require (= Melissa Barnacle))
	(let ((Gabrielle (amb 1 2 3 4 5)))
	  (require (not (= Gabrielle Barnacle)))
	  (require (not (= Gabrielle Parker)))
	  (let ((Rosalind (amb 1 2 3 4 5)))
	    (require (not (= Rosalind Hall)))
	    (let ((Lorna (amb 1 2 3 4 5)))
	      (require (not (= Lorna Moore)))
	      (require (distinct? (list Mary Gabrielle Lorna Rosalind Melissa)))
	      (list (list 'Mary Mary)
		    (list 'Melissa Melissa)
		    (list 'Gabrielle Gabrielle)
		    (list 'Rosalind Rosalind)
		    (list 'Lorna Lorna)))))))))

;;;; Amb-Eval input:
;(father)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;((Mary 1) (Melissa 4) (Gabrielle 2) (Rosalind 5) (Lorna 3))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 1) (Melissa 4) (Gabrielle 3) (Rosalind 2) (Lorna 5))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 1) (Melissa 4) (Gabrielle 3) (Rosalind 5) (Lorna 2))
;
;;;; Amb-Eval input:
;try-again
;
;;;; There are no more values of
;(father)

;; Mary Annの姓がMooreか分からない場合は下記の7通りある
;;;; Amb-Eval input:
;(define (father)
;  (let ((Moore 1)
;        (Downing 2)
;        (Hall 3)
;        (Barnacle 4)
;        (Parker 5))
;    (let ((Mary (amb 1 2 3 4 5)))
;      ;(require (= Mary Moore))
;      (let ((Melissa (amb 1 2 3 4 5)))
;        (require (= Melissa Barnacle))
;        (let ((Gabrielle (amb 1 2 3 4 5)))
;          (require (not (= Gabrielle Barnacle)))
;          (require (not (= Gabrielle Parker)))
;          (let ((Rosalind (amb 1 2 3 4 5)))
;            (require (not (= Rosalind Hall)))
;            (let ((Lorna (amb 1 2 3 4 5)))
;              (require (not (= Lorna Moore)))
;              (require (distinct? (list Mary Gabrielle Lorna Rosalind Melissa)))
;              (list (list 'Mary Mary)
;                    (list 'Melissa Melissa)
;                    (list 'Gabrielle Gabrielle)
;                    (list 'Rosalind Rosalind)
;                    (list 'Lorna Lorna)))))))))
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;ok
;
;;;; Amb-Eval input:
;(father)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;((Mary 1) (Melissa 4) (Gabrielle 2) (Rosalind 5) (Lorna 3))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 1) (Melissa 4) (Gabrielle 3) (Rosalind 2) (Lorna 5))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 1) (Melissa 4) (Gabrielle 3) (Rosalind 5) (Lorna 2))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 2) (Melissa 4) (Gabrielle 1) (Rosalind 5) (Lorna 3))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 2) (Melissa 4) (Gabrielle 3) (Rosalind 1) (Lorna 5))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 3) (Melissa 4) (Gabrielle 1) (Rosalind 2) (Lorna 5))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 3) (Melissa 4) (Gabrielle 1) (Rosalind 5) (Lorna 2))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 3) (Melissa 4) (Gabrielle 2) (Rosalind 1) (Lorna 5))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 5) (Melissa 4) (Gabrielle 1) (Rosalind 2) (Lorna 3))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 5) (Melissa 4) (Gabrielle 2) (Rosalind 1) (Lorna 3))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((Mary 5) (Melissa 4) (Gabrielle 3) (Rosalind 1) (Lorna 2))
;
;;;; Amb-Eval input:
;try-again
;
;;;; There are no more values of
;(father)

