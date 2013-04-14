;; assocとcadrをprimitive-proceduresに追加する
(load "../metacircular.scm")
(define (expand-clauses clauses)
  (if (null? clauses)
	#f
	(let ((first (car clauses))
		  (rest (cdr clauses)))
	  (if (cond-else-clause? first)
		(if (null? rest)
		  (sequence->exp (cond-actions first))
		  (error "ELSE clause isn't last -- COND->IF"
				 clauses))
		(let ((predicate (cond-predicate first)))
		  (make-if predicate
				   (if (eq? (cadr first) '=>)
					 (list (caddr first) predicate)
					 (sequence->exp (cond-actions first)))
				   (expand-clauses rest)))))))
(cond ((assoc 'b '((a 1) (b 2))) => cadr)
  (else #f))
;; 2
