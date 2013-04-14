(load "../metacircular.scm")

;; a.
(define (lookup-variable-value var env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
	     (env-loop (enclosing-environment env)))
	((eq? var (car vars))
	 (if (eq? '*unassigned* (car vals))
	   (error "Unassigned variable" var)
	   (car vals)))
	(else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
      (error "Unbound variable" var)
      (let ((frame (first-frame env)))
	(scan (frame-variables frame)
	      (frame-values frame)))))
  (env-loop env))

;; b.
;; applyはbodyをリストとして扱うため、scan-out-definesの戻り値は一要素のリスト((body))にする
;; *unassigned*はapplyでの評価時にもクオーテーションとして扱うため、クオーテーションは二つ必要
(define (scan-out-defines body)
  (use srfi-1)
  (let ((int-def (filter (lambda (x) (eq? 'define (car x))) body))
	(rest (filter (lambda (x) (not (eq? 'define (car x)))) body)))
    (define (let-variable def) (list (cadr def) ''*unassigned*))
    (define (set-body def) (list 'set! (cadr def) (caddr def)))
    (if (null? int-def)
      body
      (list (cons 'let (cons (map let-variable int-def) (append (map set-body int-def) rest)))))))
(define a
  '(lambda (x)
     (define u (+ 1 1))
     (define v (+ 2 2))
     (+ x 3)))

(print (scan-out-defines (cddr a)))

;; c.
;; make-procedure, procedure-bodyどちらでも実現可能だが、procedure-bodyだと呼び出される毎に展開されるため、make-procedureに比べて実行効率が悪い

(define (make-procedure parameters body env)
  (list 'procedure parameters (scan-out-defines body) env))

(driver-loop)

(define a
  (lambda (x)
    (define u (+ 1 1))
    (define v (+ 2 2))
    (+ x 3)))

