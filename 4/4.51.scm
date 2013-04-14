;; permanent-set!の実装は下記となる
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
    ((permanent-assignment? exp) (analyze-permanent-assignment exp))
    ((application? exp) (analyze-application exp))
    (else
      (error "Unknown expression type -- ANALYZE" exp))))

(define (permanent-assignment? exp)
  (tagged-list? exp 'permanent-set!))

(define (analyze-permanent-assignment exp)
  (let ((var (assignment-variable exp))
	(vproc (analyze (assignment-value exp))))
    (lambda (env succeed fail)
      (vproc env
	     (lambda (val fail2) ; *1*
	       (set-variable-value! var val env)
	       (succeed 'ok
			(lambda () ; *2*
			  (fail2))))
	     fail))))

(driver-loop)

;; 下記手続きをambevalで評価する
(define (require p)
  (if (not p) (amb)))
(define (an-element-of items)
  (require (not (null? items)))
  (amb (car items) (an-element-of (cdr items))))
(define count 0)
(let ((x (an-element-of '(a b c)))
      (y (an-element-of '(a b c))))
  (permanent-set! count (+ count 1))
  (require (not (eq? x y)))
  (list x y count))

;; permanent-set!の代わりにset!を用いると下記のようになる
;;;; Starting a new problem
;;;; Amb-Eval value:
;(a b 1)
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(a c 1)

