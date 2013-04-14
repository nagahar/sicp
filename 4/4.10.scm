(load "../metacircular.scm")
;; defineを後置記法にする
;; (i 4 define)
(use srfi-1)
(define (tagged-list? exp tag)
  (if (pair? exp)
    (eq? (last exp) tag)
    #f))
(define (operator exp) (last exp))
(define (operands exp)
  (define (operands-iter ex)
    (if (= (length ex) 1)
      '()
      (cons (car ex) (operands-iter (cdr ex)))))
  (operands-iter exp))

(define (definition-variable exp)
  (if (symbol? (car exp))
    (car exp)
    (caar exp)))

(define (definition-value exp)
  (if (symbol? (car exp))
    (cadr exp)
    (make-lambda (cdar exp)      ; 仮パラメタ
		 (cadr exp))))    ; 本体

(driver-loop)

