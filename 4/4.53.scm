(load "../amb.scm")

(define primitive-procedures
  (list (list 'car car)
	(list 'cdr cdr)
	(list 'cons cons)
	(list 'null? null?)
	(list 'list list)
	(list 'memq memq)
	(list 'member member)
	(list 'assoc assoc)
	(list 'not not)
	(list '+ +)
	(list '- -)
	(list '* *)
	(list '/ /)
	(list '= =)
	(list '< <)
	(list '> >)
	(list 'abs abs)
	(list 'remainder remainder)
	(list 'print print)
	(list 'cadr cadr)
	(list 'cddr cddr)
	(list 'eq? eq?)
	(list 'even? even?)
	(list 'odd? odd?)
	;; 基本手続きが続く
	))

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
    ((if-fail? exp) (analyze-if-fail exp))
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
(define (prime? n)
  (= n (smallest-divisor n)))
(define (smallest-divisor n)
  (find-divisor n 2))
(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
	((divides? test-divisor n) test-divisor)
	(else (find-divisor n (+ test-divisor 1)))))
(define (divides? a b)
  (= (remainder b a) 0))
(define (square x)
  (* x x))
(define (prime-sum-pair list1 list2)
  (let ((a (an-element-of list1))
        (b (an-element-of list2)))
    (require (prime? (+ a b)))
    (list a b)))

;;;; Amb-Eval input:
;(let ((pairs '()))
;  (if-fail (let ((p (prime-sum-pair '(1 3 5 8) '(20 35 110))))
;             (permanent-set! pairs (cons p pairs))
;             (amb))
;           pairs))
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;((8 35) (3 110) (3 20))

