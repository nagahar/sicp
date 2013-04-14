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
    ;; change
    ((open-coding-primitive? exp ct-env)
     (compile-open-code exp target linkage ct-env))
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
  (let ((ret (find-variable exp ct-env))
	(seq empty-instruction-sequence))
    (if (eq? 'not-found ret)
      (set! seq `((assign ,target (op lookup-variable-value) (const ,exp) (reg env))))
      (set! seq `((assign ,target (op lexical-address-lookup) (const ,ret) (reg env)))))
    (end-with-linkage linkage
		      (make-instruction-sequence '(env) (list target)
						 seq))))

(define (compile-assingment exp target linkage ct-env)
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

;; change
(define (spread-arguments-ct arg-list ct-env)
  (let ((seq1 (compile (car arg-list) 'arg1 'next ct-env))
	(seq2 (compile (cadr arg-list) 'arg2 'next ct-env)))
    (preserving '(env)
		seq1
		(if (modifies-register? seq2 'arg1)
		  (make-instruction-sequence
		    (list-union (registers-needed seq2) '(arg1))
		    (list-difference (registers-modified seq2) '(arg1))
		    `((save arg1) ,seq2 (restore arg1)))
		  seq2))))

;; change
(define (spread-accumulator-ct operator operands ct-env)
  (cond ((null? operands)
	 (empty-instruction-sequence))
    (else
      (let ((seq (compile (car operands) 'arg2 'next ct-env)))
	(preserving '(env)
		    (if (modifies-register? seq 'arg1)
		      (make-instruction-sequence
			(list-union (registers-needed seq) '(arg1))
			(list-difference (registers-modified seq) '(arg1))
			`((save arg1) ,seq (restore arg1)))
		      seq)
		    (append-instruction-sequences
		      (make-instruction-sequence '(arg2) '(arg1)
						 `((assign arg1 (op ,operator) (reg arg1) (reg arg2))))
		      (spread-accumulator-ct operator (cdr operands) ct-env)))))))

(define (compile-open-code exp target linkage ct-env)
  (let ((p-operator (operator exp))
	(p-operands (operands exp)))
      (end-with-linkage linkage
			(cond ((= (length p-operands) 2)
			       (append-instruction-sequences
				 (spread-arguments-ct p-operands ct-env)
				 (make-instruction-sequence '(arg1 arg2) '(val)
							    `((assign val (op ,p-operator) (reg arg1) (reg arg2))))))
			  ((and (memq p-operator '(* +)) (> (length p-operands) 2))
			   (append-instruction-sequences
			     (compile (car p-operands) 'arg1 'next ct-env)
			     (spread-accumulator-ct p-operator (cdr p-operands) ct-env)
			     (make-instruction-sequence '(arg1) '(val) '((assign val (reg arg1))))))
			  (else
			    (error "cannot support the number of operands -- COMPILE" exp))))))

(define (open-coding-primitive? exp ct-env)
  (and (memq (car exp) '(= * - +))
    (eq? 'not-found (find-variable (car exp) ct-env))))

(parse-compiled-code
  (compile
    '((lambda (+ * a b x y)
	(+ (* a x) (* b y)))
     +matrix *matrix k l m n)
    'val
    'next
    the-empty-environment))

;(env)
;(env proc argl continue val)
;  (assign proc (op make-compiled-procedure) (label entry1) (reg env))
;  (goto (label after-lambda2))
;entry1
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (+ * a b x y)) (reg argl) (reg env))
;  (assign proc (op lexical-address-lookup) (const (0 0)) (reg env))
;  (save continue)
;  (save proc)
;  (save env)
;  (assign proc (op lexical-address-lookup) (const (0 1)) (reg env))
;  (assign val (op lexical-address-lookup) (const (0 5)) (reg env))
;  (assign argl (op list) (reg val))
;  (assign val (op lexical-address-lookup) (const (0 3)) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch6))
;compiled-branch7
;  (assign continue (label after-call8))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch6
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call8
;  (assign argl (op list) (reg val))
;  (restore env)
;  (save argl)
;  (assign proc (op lexical-address-lookup) (const (0 1)) (reg env))
;  (assign val (op lexical-address-lookup) (const (0 4)) (reg env))
;  (assign argl (op list) (reg val))
;  (assign val (op lexical-address-lookup) (const (0 2)) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch3))
;compiled-branch4
;  (assign continue (label after-call5))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch3
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call5
;  (restore argl)
;  (assign argl (op cons) (reg val) (reg argl))
;  (restore proc)
;  (restore continue)
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch9))
;compiled-branch10
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch9
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;  (goto (reg continue))
;after-call11
;after-lambda2
;  (assign val (op lookup-variable-value) (const n) (reg env))
;  (assign argl (op list) (reg val))
;  (assign val (op lookup-variable-value) (const m) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (assign val (op lookup-variable-value) (const l) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (assign val (op lookup-variable-value) (const k) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (assign val (op lookup-variable-value) (const *matrix) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (assign val (op lookup-variable-value) (const +matrix) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch12))
;compiled-branch13
;  (assign continue (label after-call14))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch12
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call14
