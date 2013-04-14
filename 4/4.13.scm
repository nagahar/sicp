;; 意図しない変数破壊を防ぐため、現在のフレームの束縛のみを除去する

(load "../metacircular.scm")
(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
    ((variable? exp) (lookup-variable-value exp env))
    ((quoted? exp) (text-of-quotation exp))
    ((assignment? exp) (eval-assignment exp env))
    ((definition? exp) (eval-definition exp env))
    ((unbind? exp) (eval-unbinding exp env))
    ((if? exp) (eval-if exp env))
    ((lambda? exp)
     (make-procedure (lambda-parameters exp)
		     (lambda-body exp)
		     env))
    ((begin? exp)
     (eval-sequence (begin-actions exp) env))
    ((cond? exp) (eval (cond->if exp) env))
    ((let? exp) (eval (let->combination exp) env))
    ((application? exp)
     (apply (eval (operator exp) env)
	    (list-of-values (operands exp) env)))
    (else
      (error "Unknown expression type -- EVAL" exp))))

(define (unbind? exp)
  (tagged-list? exp 'unbind!))
(define (unbinding-variable exp) (cadr exp))

(define (eval-unbinding exp env)
  (unbind-variable! (unbinding-variable exp) env)
  'ok)

(define (remove-binding-from-frame! var val frame)
  (use srfi-1)
  (set-car! frame (delete var (frame-variables frame)))
  (set-cdr! frame (delete val (frame-values frame))))

(define (unbind-variable! var env)
  (let ((frame (first-frame env)))
    (define (scan vars vals)
      (cond ((null? vars)
	     (error "Unbound variable -- UNBINDING" var))
	((eq? #?=var (car vars))
	 (remove-binding-from-frame! var (car vals) frame))
	(else (scan (cdr vars) (cdr vals)))))
    (scan (frame-variables frame) (frame-values frame))))

(driver-loop)

