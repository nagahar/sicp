(load "../compiler.scm")

(define (compile exp target linkage ct-env)
  (cond ((self-evaluating? exp)
	 (compile-self-evaluating exp target linkage ct-env))
    ((quoted? exp) (compile-quoted exp target linkage ct-env))
    ((variable? exp)
     (compile-variable exp target linkage ct-env))
    ((assignment? exp)
     (compile-assingment exp target linkage ct-env))
    ((definition? exp)
     (compile-definition exp target linkage ct-env))
    ((if? exp) (compile-if exp target linkage ct-env))
    ((lambda? exp) (compile-lambda exp target linkage ct-env))
    ((begin? exp)
     (compile-sequence (begin-actions exp)
		       target
		       linkage
		       ct-env))
    ((cond? exp) (compile (cond->if exp) target linkage ct-env))
    ((application? exp)
     (compile-application exp target linkage ct-env))
    (else
      (error "Unknown expression type -- COMPILE" exp))))

(define (compile-self-evaluating exp target linkage ct-env)
  (end-with-linkage linkage
		    (make-instruction-sequence '() (list target)
					       `((assign ,target (const ,exp))))))

(define (compile-quoted exp target linkage ct-env)
  (end-with-linkage linkage
		    (make-instruction-sequence '() (list target)
					       `((assign ,target (const ,(text-of-quotation exp)))))))

(define (compile-variable exp target linkage ct-env)
  (end-with-linkage linkage
		    (make-instruction-sequence '(env) (list target)
					       `((assign ,target
							 (op lookup-variable-value)
							 (const ,exp)
							 (reg env))))))

(define (compile-assingment exp target linkage ct-env)
  (let ((var (assignment-variable exp))
	(get-value-code
	  (compile (assignment-value exp) 'val 'next ct-env)))
    (end-with-linkage linkage
		      (preserving '(env)
				  get-value-code
				  (make-instruction-sequence '(env val) (list target)
							     `((perform (op set-variable-value!)
									(const ,var)
									(reg val)
									(reg env))
							       (assign ,target (const ok))))))))

(define (compile-definition exp target linkage ct-env)
  (let ((var (definition-variable exp))
	(get-value-code
	  (compile (definition-value exp) 'val 'next ct-env)))
    (end-with-linkage linkage
		      (preserving '(env)
				  get-value-code
				  (make-instruction-sequence '(env val) (list target)
							     `((perform (op define-variable!)
									(const ,var)
									(reg val)
									(reg env))
							       (assign ,target (const ok))))))))

(define (compile-if exp target linkage ct-env)
  (let ((t-branch (make-label 'true-branch))
	(f-branch (make-label 'false-branch))
	(after-if (make-label 'after-if)))
    (let ((consequent-linkage
	    (if (eq? linkage 'next) after-if linkage)))
      (let ((p-code (compile (if-predicate exp) 'val 'next ct-env))
	    (c-code
	      (compile
		(if-consequent exp) target consequent-linkage ct-env))
	    (a-code
	      (compile (if-alternative exp) target linkage ct-env)))
	(preserving '(env continue)
		    p-code
		    (append-instruction-sequences
		      (make-instruction-sequence '(val) '()
						 `((test (op false?) (reg val))
						   (branch (label ,f-branch))))
		      (parallel-instruction-sequences
			(append-instruction-sequences t-branch c-code)
			(append-instruction-sequences f-branch a-code))
		      after-if))))))

(define (compile-sequence seq target linkage ct-env)
  (if (last-exp? seq)
    (compile (first-exp seq) target linkage ct-env)
    (preserving '(env continue)
		(compile (first-exp seq) target 'next ct-env)
		(compile-sequence (rest-exps seq) target linkage ct-env))))

(define (compile-lambda exp target linkage ct-env)
  (let ((proc-entry (make-label 'entry))
	(after-lambda (make-label 'after-lambda)))
    (let ((lambda-linkage
	    (if (eq? linkage 'next) after-lambda linkage)))
      (append-instruction-sequences
	(tack-on-instrunction-sequence
	  (end-with-linkage lambda-linkage
			    (make-instruction-sequence '(env) (list target)
						       `((assign ,target
								 (op make-compiled-procedure)
								 (label ,proc-entry)
								 (reg env)))))
	  (compile-lambda-body exp proc-entry ct-env))
	after-lambda))))


(define (compile-lambda-body exp proc-entry ct-env)
  (let ((formals (lambda-parameters exp)))
    (append-instruction-sequences
      (make-instruction-sequence '(env proc argl) '(env)
				 `(,proc-entry
				    (assign env (op compiled-procedure-env) (reg proc))
				    (assign env
					    (op extend-environment)
					    (const ,formals)
					    (reg argl)
					    (reg env))))
      (compile-sequence (lambda-body exp) 'val 'return (extend-environment-ct formals ct-env)))))

(define (compile-application exp target linkage ct-env)
  (let ((proc-code (compile (operator exp) 'proc 'next ct-env))
	(operand-codes
	  (map (lambda (operand) (compile operand 'val 'next ct-env))
	       (operands exp))))
    (preserving '(env continue)
		proc-code
		(preserving '(proc continue)
			    (construct-arglist operand-codes)
			    (compile-procedure-call target linkage)))))

(define (make-lexical-address frame displacement)
  (list frame displacement))
(define (get-frame-number address) (car address))
(define (get-displacement-number address) (cadr address))

(define (lexical-address-lookup address env)
  (let ((frame (list-ref (get-frame-number address) env))
	(displacement (get-displacement-number address)))
    (let ((val (list-ref displacement (frame-values frame))))
      (if (eq? val "*unassigned*")
	(error "Unassigned variable")
	val))))

(define (lexical-address-set! address val env)
  (let ((frame (list-ref (get-frame-number address) env))
	(displacement (get-displacement-number address)))
    (let ((old (list-ref displacement frame)))
      (set! old val))))

(define (extend-environment-ct vars ct-env)
  (cons vars ct-env))

(define ct the-empty-environment)

(parse-compiled-code
  (compile
    '(define (factorial n)
       (if (= n 1)
	 1
	 (* (factorial (- n 1)) n)))
    'val
    'next
    ct))

