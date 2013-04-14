;; 元の評価ループのapplyには特殊形式のand/orを渡せないので、下記のようにする

(load "../amb.scm")
(define (analyze exp)
  (cond ((self-evaluating? exp)
	 (analyze-self-evaluating exp))
    ((or? exp) (analyze (or->if exp)))
    ((and? exp) (analyze (and->if exp)))
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
    ((require? exp) (analyze-require exp))
    ((application? exp) (analyze-application exp))
    (else
      (error "Unknown expression type -- ANALYZE" exp))))
(define (and? exp) (tagged-list? exp 'and))
(define (and-clauses exp) (cdr exp))
(define (and-first-exp exp) (car exp))
(define (and-rest-exps exp) (cdr exp))
(define (and->if exp)
  (expand-and-clauses (and-clauses exp)))
(define (expand-and-clauses clauses)
  (if (null? clauses)
    'true
    (let ((first (and-first-exp clauses))
	  (rest (and-rest-exps clauses)))
      (make-if first
	       (expand-and-clauses rest)
	       first))))

(define (or? exp) (tagged-list? exp 'or))
(define (or-clauses exp) (cdr exp))
(define (or-first-exp exp) (car exp))
(define (or-rest-exps exp) (cdr exp))
(define (or->if exp)
  (expand-or-clauses (or-clauses exp)))
(define (expand-or-clauses clauses)
  (if (null? clauses)
    'false
    (let ((first (or-first-exp clauses))
	  (rest (or-rest-exps clauses)))
      (make-if first
	       first
	       (expand-or-clauses rest)))))

(driver-loop)

;; 下記手続きをambevalで評価する
(define (distinct? items)
  (cond ((null? items) true)
    ((null? (cdr items)) true)
    ((member (car items) (cdr items)) false)
    (else (distinct? (cdr items)))))
(define (test-liar)
  (let ((Betty (amb 1 2 3 4 5))
	(Ethel (amb 1 2 3 4 5))
	(Joan (amb 1 2 3 4 5))
	(Kitty (amb 1 2 3 4 5))
	(Mary (amb 1 2 3 4 5)))
    (require
      (distinct? (list Betty Ethel Joan Kitty Mary)))
    (require (or (and (= Kitty 2) (not (= Betty 3))) (and (not (= Kitty 2)) (= Betty 3))))
    (require (or (and (= Ethel 1) (not (= Joan 2))) (and (not (= Ethel 1)) (= Joan 2))))
    (require (or (and (= Joan 3) (not (= Ethel 5))) (and (not (= Joan 3)) (= Ethel 5))))
    (require (or (and (= Kitty 2) (not (= Mary 4))) (and (not (= Kitty 2)) (= Mary 4))))
    (require (or (and (= Mary 4) (not (= Betty 1))) (and (not (= Mary 4)) (= Betty 1))))
    (list (list 'Betty Betty)
	  (list 'Ethel Ethel)
	  (list 'Joan Joan)
	  (list 'Kitty Kitty)
	  (list 'Mary Mary))))

;;;; Amb-Eval input:
;(test-liar)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;((Betty 3) (Ethel 5) (Joan 2) (Kitty 1) (Mary 4))
;

