(load "../compiler.scm")

(define (scan-out-defines body)
  (use srfi-1)
  (let ((int-def (filter (lambda (x) (eq? 'define (car x))) body))
	(rest (filter (lambda (x) (not (eq? 'define (car x)))) body)))
    (define (let-variable def) (list (cadr def) ''*unassigned*))
    (define (set-body def) (list 'set! (cadr def) (caddr def)))
    (if (null? int-def)
      body
      (list (cons 'let (cons (map let-variable int-def) (append (map set-body int-def) rest)))))))

(define (compile-lambda-body exp proc-entry)
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
      ;; change
      (compile-sequence (scan-out-defines (lambda-body exp)) 'val 'return))))

(parse-compiled-code
  (compile '(define a
	      (lambda (x)
		(define u (+ 1 1))
		(define v (+ 2 2))
		(+ x 3)))
	   'val
	   'the-empty-environment))

;(env)
;(val)
;  (assign val (op make-compiled-procedure) (label entry1) (reg env))
;  (goto (label after-lambda2))
;entry1
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (x)) (reg argl) (reg env))
;  (assign proc (op make-compiled-procedure) (label entry3) (reg env))
;  (goto (label after-lambda4))
;entry3
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (u v)) (reg argl) (reg env))
;  (save continue)
;  (save env)
;  (assign proc (op lookup-variable-value) (const +) (reg env))
;  (assign val (const 1))
;  (assign argl (op list) (reg val))
;  (assign val (const 1))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch5))
;compiled-branch6
;  (assign continue (label after-call7))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch5
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call7
;  (restore env)
;  (perform (op set-variable-value!) (const u) (reg val) (reg env))
;  (assign val (const ok))
;  (restore continue)
;  (save continue)
;  (save env)
;  (assign proc (op lookup-variable-value) (const +) (reg env))
;  (assign val (const 2))
;  (assign argl (op list) (reg val))
;  (assign val (const 2))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch8))
;compiled-branch9
;  (assign continue (label after-call10))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch8
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call10
;  (restore env)
;  (perform (op set-variable-value!) (const v) (reg val) (reg env))
;  (assign val (const ok))
;  (restore continue)
;  (assign proc (op lookup-variable-value) (const +) (reg env))
;  (assign val (const 3))
;  (assign argl (op list) (reg val))
;  (assign val (op lookup-variable-value) (const x) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch11))
;compiled-branch12
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch11
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;  (goto (reg continue))
;after-call13
;after-lambda4
;  (assign val (const *unassigned*))
;  (assign argl (op list) (reg val))
;  (assign val (const *unassigned*))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch14))
;compiled-branch15
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch14
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;  (goto (reg continue))
;after-call16
;after-lambda2
;  (perform (op define-variable!) (const a) (reg val) (reg env))
;  (assign val (const ok))
;  (goto (label the-empty-environment))

