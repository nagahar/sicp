(load "../amb.scm")

(define (analyze exp)
  (cond ((self-evaluating? exp)
	 (analyze-self-evaluating exp))
    ((quoted? exp) (analyze-quoted exp))
    ((variable? exp) (analyze-variable exp))
    ((assignment? exp) (analyze-assignment exp))
    ((definition? exp) (analyze-definition exp))
    ((if? exp) (analyze-if exp))
    ((lambda? exp) (analyze-lambda exp))
    ((begin? exp) (analyze-sequence (begin-actions exp)))
    ((cond? exp) (analyze (cond->if exp)))
    ((let? exp) (analyze (let->combination exp)))
    ((amb? exp) (analyze-amb exp))
    ((if-fail? exp) (analyze-if-fail exp))
    ((application? exp) (analyze-application exp))
    (else
      (error "Unknown expression type -- ANALYZE" exp))))

(define (if-fail? exp)
  (tagged-list? exp 'if-fail))
(define (if-fail-state exp) (cadr exp))
(define (if-fail-fail exp) (caddr exp))
(define (analyze-if-fail exp)
  (let ((state (analyze (if-fail-state exp)))
	(fail (analyze (if-fail-fail exp))))
    (lambda (env succeed fail2)
      (state env
	     succeed
	     (lambda ()
	       (fail env succeed fail2))))))

(driver-loop)

;; 下記手続きをambevalで評価する
(define (require p)
  (if (not p) (amb)))
(define (an-element-of items)
  (require (not (null? items)))
  (amb (car items) (an-element-of (cdr items))))

;;;; Amb-Eval input:
;(if-fail (let ((x (an-element-of '(1 3 5))))
;           (require (even? x))
;           x)
;         'all-odd)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;all-odd
;
;;;; Amb-Eval input:
;(if-fail (let ((x (an-element-of '(1 3 5 8))))
;           (require (even? x))
;           x)
;         'all-odd)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;8

