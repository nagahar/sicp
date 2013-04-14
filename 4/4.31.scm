;; applyでの環境作成時に仮パラメタを評価する
;; 評価結果に合わせてlazy,lazy-memoの処理をする

(load "../lazy-metacircular.scm")
(define (apply procedure arguments env)
  (cond ((primitive-procedure? procedure)
	 (apply-primitive-procedure
	   procedure
	   (list-of-arg-values arguments env)))
    ((compound-procedure? procedure)
     (eval-sequence
       (procedure-body procedure)
       (extend-environment
	 (expand-parameters (procedure-parameters procedure))
	 (list-of-user-delayed-args (procedure-parameters procedure) arguments env)
	 (procedure-environment procedure))))
    (else
      (error
	"Unknown procedure type -- APPLY" procedure))))

(define (expand-parameters params)
  (cond ((null? params) '())
    ((pair? (car params)) (cons (caar params) (expand-parameters (cdr params))))
    (else
      (cons (car params) (expand-parameters (cdr params))))))

(define (list-of-user-delayed-args vars vals env)
  (define (get-val var val)
    (if (not (pair? var))
      (actual-value val env)
      (let ((tag (cadr var)))
	(cond ((eq? tag 'lazy)
	       (delay-it vals env))
	  ((eq? tag 'lazy-memo)
	   (delay-memo-it vals env))
	  (else
	    (error "Unbound argument -- DEFINE" var))))))
  (if (no-operands? vars)
    '()
    (cons (get-val (car vars) (car vals))
	  (list-of-user-delayed-args (cdr vars) (cdr vals) env))))

(define (force-it obj)
  (cond ((thunk-memo? obj)
	 (let ((result (actual-value
			 (thunk-exp obj)
			 (thunk-env obj))))
	   (set-car! obj 'evaluated-thunk)
	   (set-car! (cdr obj) result) ; exp をその値で置き換える
	   (set-cdr! (cdr obj) '()) ; 不要な env を忘れる
	   result))
    ((evaluated-thunk? obj)
     (thunk-value obj))
    ((thunk? obj)
     (actual-value (thunk-exp obj) (thunk-env obj)))
    (else obj)))

(define (delay-memo-it exp env)
  (list 'thunk-memo exp env))
(define (thunk-memo? obj)
  (tagged-list? obj 'thunk-memo))

(driver-loop)

;;; L-Eval input:
;(define (p2 x)
;  (define (p (e lazy))
;    e
;    x)
;  (p (set! x (cons x '(2)))))
;;;; L-Eval value:
;ok
;;;; L-Eval input:
;(p2 1)
;;;; L-Eval value:
;1

;;;; L-Eval input:
;(define (p2 x)
;  (define (p e)
;    e
;    x)
;  (p (set! x (cons x '(2)))))
;;;; L-Eval value:
;ok
;;;; L-Eval input:
;(p2 1)
;;;; L-Eval value:
;(1 2)

