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
  ;; change
  (let ((ret (find-variable exp ct-env))
	(seq empty-instruction-sequence))
    (if (eq? 'not-found ret)
      (set! seq `((assign ,target (op lookup-variable-value) (const ,exp) (reg env))))
      (set! seq `((assign ,target (op lexical-address-lookup) (const ,ret) (reg env)))))
    (end-with-linkage linkage
		      (make-instruction-sequence '(env) (list target)
						 seq))))

(define (compile-assingment exp target linkage ct-env)
  ;; change
  (let ((var (assignment-variable exp))
	(get-value-code
	  (compile (assignment-value exp) 'val 'next ct-env))
	(ret (find-variable exp ct-env))
	(seq empty-instruction-sequence))
    (if (eq? 'not-found ret)
      (set! seq `((perform (op set-variable-value!) (const ,var) (reg val) (reg env))))
      (set! seq `((perform (op lexical-address-set! (const ,ret) (reg env))))))
    (append seq `((assign ,target (const ok))))
    (end-with-linkage linkage
		      (preserving '(env)
				  get-value-code
				  (make-instruction-sequence '(env val) (list target) seq)))))

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
    (let ((val (list-ref displacement frame)))
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

(define (find-variable var ct-env)
  (define (env-loop env f-num)
    (define (scan vars d-num)
      (cond ((null? vars)
	     (env-loop (enclosing-environment env) (+ f-num 1)))
	((eq? var (car vars))
	 (make-lexical-address f-num d-num))
	(else (scan (cdr vars) (+ d-num 1)))))
    (if (eq? env the-empty-environment)
      'not-found
      (scan (first-frame env) 0)))
  (env-loop ct-env 0))

(define ct the-empty-environment)

(parse-compiled-code
  (compile
    '((lambda (x y)
	(lambda (a b c d e)
	  ((lambda (y z) (* x y z))
	   (* a b x)
	   (+ c d x))))
      3
      4)
    'val
    'next
    ct))

;(env)
;(env proc argl continue val)
;  (assign proc (op make-compiled-procedure) (label entry1) (reg env))
;  (goto (label after-lambda2))
;entry1
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (x y)) (reg argl) (reg env))
;  (assign val (op make-compiled-procedure) (label entry3) (reg env))
;  (goto (reg continue))
;entry3
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (a b c d e)) (reg argl) (reg env))
;  (assign proc (op make-compiled-procedure) (label entry5) (reg env))
;  (goto (label after-lambda6))
;entry5
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (y z)) (reg argl) (reg env))
;  (assign proc (op lookup-variable-value) (const *) (reg env))
;  (assign val (op lexical-address-lookup) (const (0 1)) (reg env))
;  (assign argl (op list) (reg val))
;  (assign val (op lexical-address-lookup) (const (0 0)) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (assign val (op lexical-address-lookup) (const (2 0)) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch7))
;compiled-branch8
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch7
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;  (goto (reg continue))
;after-call9
;after-lambda6
;  (save continue)
;  (save proc)
;  (save env)
;  (assign proc (op lookup-variable-value) (const +) (reg env))
;  (assign val (op lexical-address-lookup) (const (1 0)) (reg env))
;  (assign argl (op list) (reg val))
;  (assign val (op lexical-address-lookup) (const (0 3)) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (assign val (op lexical-address-lookup) (const (0 2)) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch13))
;compiled-branch14
;  (assign continue (label after-call15))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch13
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call15
;  (assign argl (op list) (reg val))
;  (restore env)
;  (save argl)
;  (assign proc (op lookup-variable-value) (const *) (reg env))
;  (assign val (op lexical-address-lookup) (const (1 0)) (reg env))
;  (assign argl (op list) (reg val))
;  (assign val (op lexical-address-lookup) (const (0 1)) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (assign val (op lexical-address-lookup) (const (0 0)) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch10))
;compiled-branch11
;  (assign continue (label after-call12))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch10
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call12
;  (restore argl)
;  (assign argl (op cons) (reg val) (reg argl))
;  (restore proc)
;  (restore continue)
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch16))
;compiled-branch17
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch16
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;  (goto (reg continue))
;after-call18
;after-lambda4
;after-lambda2
;  (assign val (const 4))
;  (assign argl (op list) (reg val))
;  (assign val (const 3))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch19))
;compiled-branch20
;  (assign continue (label after-call21))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch19
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call21
