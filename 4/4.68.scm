;(define (reverse list1)
;  (define (reverse-iter a result)
;    (if (null? a)
;	result
;	(reverse-iter (cdr a) (cons (car a) result))))
;  (reverse-iter list1 ()))

(load "../logic.scm")
(query-driver-loop)

(assert! (rule (append-to-form () ?y ?y)))
(assert! (rule (append-to-form (?u . ?v) ?y (?u . ?z))
	       (append-to-form ?v ?y ?z)))

(assert! (rule (reverse () ())))
(assert! (rule (reverse (?u . ?v) ?x)
	       (and (reverse ?v ?y)
		 (append-to-form ?y (?u) ?x))))

;;;; Query input:
;(reverse (1 2 3) ?x)
;
;;;; Query results:
;(reverse (1 2 3) (3 2 1))

;;;; Query input:
;(reverse ?x (1 2 3))
;; 無限ループになる
;; 歴史を使えば回避できる

