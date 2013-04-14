(load "../simulator.scm")
(define (make-operation-exp exp machine labels operations)
  (let ((op (lookup-prim (operation-exp-op exp) operations))
	(aprocs
	  (map (lambda (e)
		 (make-primitive-exp e machine labels))
	       (operation-exp-operands exp))))
    (lambda ()
      (apply op (map (lambda (p)
		       (if (or (register-exp? p) (label-exp? p))
			 (p)))
		     aprocs)))))

