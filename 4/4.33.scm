(load "../lazy-metacircular.scm")
(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
    ((variable? exp) (lookup-variable-value exp env))
    ((quoted? exp) (text-of-quotation exp env))
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
    ((application? exp)
     (apply (actual-value (operator exp) env)
	    (operands exp)
	    env))
    (else
      (error "Unknown expression type -- EVAL" exp))))

(define (text-of-quotation exp env)
  (if (list? (cadr exp))
    (eval (make-quotation-list (cadr exp)) env)
    (cadr exp)))
(define (make-quotation-list lis)
  (if (null? lis)
    '()
    (let ((first-list (car lis))
	  (rest-list (cdr lis)))
      (list 'cons (list 'quote first-list) (make-quotation-list rest-list)))))

(driver-loop)

;;;; L-Eval input:
;(define (cons x y)
;  (lambda (m) (m x y)))
;;;; L-Eval value:
;ok
;;;; L-Eval input:
;(define (car z)
;  (z (lambda (p q) p)))
;;;; L-Eval value:
;ok
;;;; L-Eval input:
;(define (cdr z)
;  (z (lambda (p q) q)))
;;;; L-Eval value:
;ok

;;;; L-Eval input:
;(car '(a b c))
;;;; L-Eval value:
;a

