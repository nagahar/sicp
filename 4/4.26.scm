;; unlessを特殊形式として実装する
(load "../metacircular2.scm")
(define (unless? exp) (tagged-list? exp 'unless))
(define (unless-condition exp) (cadr exp))
(define (unless-usual exp) (caddr exp))
(define (unless-exceptional exp) (cadddr exp))

(define (unless->if exp)
  (make-if (unless-condition exp)
	   (unless-exceptional exp)
	   (unless-usual exp)))

;;;; 構文解析手続き
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
    ((unless? exp) (analyze (unless->if exp)))
    ((application? exp) (analyze-application exp))
    (else
      (error "Unknown expression type -- ANALYZE" exp))))

(define (factorial n)
  (unless (= n 1)
    (* n (factorial (- n 1)))
    1))
;(factorial 5)
;120

(driver-loop)

;; unlessが手続きとして使える場合は思いつかない・・・
