;(define (last-pair list)
;  (if (null? (cdr list))
;      (car list)
;      (last-pair (cdr list))))

(load "../logic.scm")
(query-driver-loop)

(assert! (rule (last-pair (?x) (?x))))
(assert! (rule (last-pair (?u . ?v) ?x)
	       (last-pair ?v ?x)))

;;;; Query input:
;(last-pair (1 2 3) ?x)
;
;;;; Query results:
;(last-pair (1 2 3) (3))

;;;; Query input:
;(last-pair (2 ?x) (3))
;
;;;; Query results:
;(last-pair (2 3) (3))

;;;; Query input:
;(last-pair ?x (3))
;;無限ループになる

