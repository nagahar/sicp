;; a.
;;(letrec ((<var1> <exp1>) ...  (<varn> <expn>))
;;  <body>)
;;
;;(let ((<var1> '*unassigned*)
;;      ...
;;      (<var2> '*unassigned*))
;;  (set! <var1> <exp1>)
;;  ...
;;  (set! <varn> <expn>)
;;  <body>)
(load "../metacircular.scm")
(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
    ((variable? exp) (lookup-variable-value exp env))
    ((quoted? exp) (text-of-quotation exp))
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
    ((let? exp) (eval (let->combination exp) env))
    ((letrec? exp) (eval (letrec->let exp) env))
    ((application? exp)
     (apply (eval (operator exp) env)
	    (list-of-values (operands exp) env)))
    (else
      (error "Unknown expression type -- EVAL" exp))))

(define (letrec? exp) (tagged-list? exp 'letrec))
(define (letrec->let exp)
  (let ((vars (map car (cadr exp)))
	(exps (map cdr (cadr exp)))
	(body (cddr exp)))
    (cons 'let
	  (cons (map (lambda (x) (list x ''*unassigned*)) vars)
		(append (map (lambda (x y) (cons 'set! (cons x y))) vars exps)
			body)))))
(letrec ((fact
	   (lambda (n)
	     (if (= n 1)
	       1
	       (* n (fact (- n 1)))))))
  (fact 10))
;3628800
(driver-loop)

;; b.
;; letrec
;; <rest of body of f> を (even? x) とする
(define (f x)
  (letrec ((even?
	     (lambda (n)
	       (if (= n 0)
		 #t
		 (odd? (- n 1)))))
	   (odd?
	     (lambda (n)
	       (if (= n 0)
		 #f
		 (even? (- n 1))))))
    (even? x)))
(f 5)
;; - global
;;    f: <-> x, (letrec ...)
;;    <- E1
;;       x: 5
;;       <- E2
;;          even?: (lambda ...)
;;          odd?: (lambda ...)
;;          <- E3(call to even?)
;;             n: 5
;;             <- E4(call to odd?)
;;                n: 4
;;                <- E5(call to even?)
;;                   n: 3
;;                   <- E7(call to odd?)
;;                      n: 2
;;                      <- E8(call to even?)
;;                         n: 1
;;                         <- E9(call to odd?)
;;                            n: 0

;; let
;; <rest of body of f> を (even? x) とする
(define (f x)
  (let ((even?
	  (lambda (n)
	    (if (= n 0)
	      #t
	      (odd? (- n 1)))))
	(odd?
	  (lambda (n)
	    (if (= n 0)
	      #f
	      (even? (- n 1))))))
    (even? x)))
(f 5)
;; - global
;;    f: <-> x, (let ...)
;;    <- E1
;;       x: 5
;;       <- E2
;;          even?: (lambda ...)
;;          odd?: (lambda ...)
;; E1において、lambdaの引数even?, odd?が評価されるが、互いを未知であるため評価に失敗する(実際にE2は作成されない)


;; -> letではlambdaの中からの相互参照はできるが、直接参照はできないということがLouiseの抜けていることらしい
;; http://sioramen.sub.jp/blog/2008/02/sicp-416.html
