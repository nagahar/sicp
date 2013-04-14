(load "../metacircular.scm")
;; a.
;; Louis Reasoner の版では特殊系表現(defineなど)が手続きとして処理されてしまうためエラーになる
(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
	((variable? exp) (lookup-variable-value exp env))
	((quoted? exp) (text-of-quotation exp))
	((application? exp)
	 (apply (eval (operator exp) env)
			(list-of-values (operands exp) env)))
	((assignment? exp) (eval-assignment exp env))
	((definition? exp) (eval-definition exp env))
	((if? exp) (eval-if exp env))
	((lambda? exp)
	 (make-procedure (lambda-parameters exp)
					 (lambda-body exp)
					 env))
	((begin? exp)
	 (eval-sequence (begin-actions exp) env))
	((cond? exp) (eval (cond->if exp) env))
	(else
	  (error "Unknown expression type -- EVAL" exp))))

;; b. 下記のように修正する
(define (application? exp) (tagged-list? exp 'call))
(define (operator exp) (cadr exp))
(define (operands exp) (cddr exp))

