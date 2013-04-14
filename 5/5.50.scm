(load "../explicit-control_evaluator2.scm")
;; 解釈系はmapを多用しているが、ソースプログラムではmapの第一引数の手続きはprimitiveタグを含む
;; したがって、scheme本来のmapは使用できない
;; そのため、mapをソースプログラムの中で定義する
;;
;; 一方、ソースプログラムのapply-in-underlying-schemeは二つのprimitiveタグを持つ
;; 一つはソースプログラムの環境としてのprimitiveタグであり、 もう一つはレジスタ計算機の環境としてのprimitiveタグである
;; したがって、ソースプログラムのapply-in-underlying-schemeはレジスタ計算機のapply-primitive-procedureに割り当てる

(define primitive-procedures
  (list (list 'car car)
	(list 'cdr cdr)
	(list 'cons cons)
	(list 'null? null?)
	(list 'assoc assoc)
	(list 'cadr cadr)
	(list 'display display)
	(list 'print print)
	(list 'not not)
	(list '+ +)
	(list '- -)
	(list '* *)
	(list '/ /)
	(list '= =)
	(list '< <)
	(list '> >)
	(list '<= <=)
	(list '>= >=)
	;; 基本手続きが続く
	(list 'compile-and-run compile-and-run)
	;; change
	(list 'true #t)
	(list 'false #f)
	(list 'list list)
	(list 'read read)
	(list 'newline newline)
	(list 'length length)
	(list 'eq? eq?)
	(list 'set-car! set-car!)
	(list 'set-cdr! set-cdr!)
	(list 'number? number?)
	(list 'string? string?)
	(list 'symbol? symbol?)
	(list 'pair? pair?)
	(list 'error error)
	(list 'cddr cddr)
	(list 'cdadr cdadr)
	(list 'caadr caadr)
	(list 'cadddr cadddr)
	(list 'caddr caddr)
	(list 'cdddr cdddr)
	(list 'apply-in-underlying-scheme apply-primitive-procedure)
	))
;; primitive-proceduresを追加したので環境を再構築する
(set! the-global-environment (setup-environment))

(define metacircular-code
  '(begin
     ;; change
     ;; map の定義を追加する
     (define (map p sequence)
       (accumulate (lambda (x y) (cons (p x) y)) '() sequence))
     (define (accumulate op initial sequence)
       (if (null? sequence)
	 initial
	 (op (car sequence)
	     (accumulate op initial (cdr sequence)))))

     ;;;; apply の定義
     (define (apply procedure arguments)
       (cond ((primitive-procedure? procedure)
	      (apply-primitive-procedure procedure arguments))
	 ((compound-procedure? procedure)
	  (eval-sequence
	    (procedure-body procedure)
	    (extend-environment
	      (procedure-parameters procedure)
	      arguments
	      (procedure-environment procedure))))
	 (else
	   (error
	     "Unknown procedure type -- APPLY (Compiled)" procedure))))

     ;;;; eval の定義
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
	 ((application? exp)
	  (apply (eval (operator exp) env)
		 (list-of-values (operands exp) env)))
	 (else
	   (error "Unknown expression type -- EVAL (Compiled)" exp))))

     ;;;; 手続きの引数
     (define (list-of-values exps env)
       (if (no-operands? exps)
	 '()
	 (cons (eval (first-operand exps) env)
	       (list-of-values (rest-operands exps) env))))

     ;;;; 条件式
     (define (eval-if exp env)
       (if (true? (eval (if-predicate exp) env))
	 (eval (if-consequent exp) env)
	 (eval (if-alternative exp) env)))

     ;;;; 並び
     (define (eval-sequence exps env)
       (cond ((last-exp? exps) (eval (first-exp exps) env))
	 (else (eval (first-exp exps) env)
	   (eval-sequence (rest-exps exps) env))))

     ;;;; 代入と定義
     (define (eval-assignment exp env)
       (set-variable-value! (assignment-variable exp)
			    (eval (assignment-value exp) env)
			    env)
       'ok)

     (define (eval-definition exp env)
       (define-variable! (definition-variable exp)
			 (eval (definition-value exp) env)
			 env)
       'ok)

     ;;;; 4.1.2 式の表現

     ;;;; 自己評価式は数と文字だけ
     (define (self-evaluating? exp)
       (cond ((number? exp) true)
	 ((string? exp) true)
	 (else false)))

     ;;;; 変数は記号で表現
     (define (variable? exp) (symbol? exp))

     ;;;; クォート式は (quote <text-of-quotation>) の形
     (define (quoted? exp)
       (tagged-list? exp 'quote))

     (define (text-of-quotation exp) (cadr exp))

     (define (tagged-list? exp tag)
       (if (pair? exp)
	 (eq? (car exp) tag)
	 false))

     ;;;; 代入は (set! <var> <value>) の形
     (define (assignment? exp)
       (tagged-list? exp 'set!))

     (define (assignment-variable exp) (cadr exp))

     (define (assignment-value exp) (caddr exp))

     ;;;; 定義
     (define (definition? exp)
       (tagged-list? exp 'define))

     (define (definition-variable exp)
       (if (symbol? (cadr exp))
	 (cadr exp)
	 (caadr exp)))

     (define (definition-value exp)
       (if (symbol? (cadr exp))
	 (caddr exp)
	 (make-lambda (cdadr exp)      ; 仮パラメタ
		      (cddr exp))))    ; 本体

     ;;;; lambda 式は記号 lambda で始まるリスト
     (define (lambda? exp) (tagged-list? exp 'lambda))

     (define (lambda-parameters exp) (cadr exp))

     (define (lambda-body exp) (cddr exp))

     (define (make-lambda parameters body)
       (cons 'lambda (cons parameters body)))

     ;;;; 条件式
     (define (if? exp) (tagged-list? exp 'if))

     (define (if-predicate exp) (cadr exp))

     (define (if-consequent exp) (caddr exp))

     (define (if-alternative exp)
       (if (not (null? (cdddr exp)))
	 (cadddr exp)
	 false))

     (define (make-if predicate consequent alternative)
       (list 'if predicate consequent alternative))

     ;;;; begin
     (define (begin? exp) (tagged-list? exp 'begin))

     (define (begin-actions exp) (cdr exp))

     (define (last-exp? seq) (null? (cdr seq)))

     (define (first-exp seq) (car seq))

     (define (rest-exps seq) (cdr seq))

     (define (sequence->exp seq)
       (cond ((null? seq) seq)
	 ((last-exp? seq) (first-exp seq))
	 (else (make-begin seq))))

     (define (make-begin seq) (cons 'begin seq))

     ;;;; 手続き作用
     (define (application? exp) (pair? exp))

     (define (operator exp) (car exp))

     (define (operands exp) (cdr exp))

     (define (no-operands? ops) (null? ops))

     (define (first-operand ops) (car ops))

     (define (rest-operands ops) (cdr ops))

     ;;;; cond 式
     (define (cond? exp) (tagged-list? exp 'cond))

     (define (cond-clauses exp) (cdr exp))

     (define (cond-else-clause? clause)
       (eq? (cond-predicate clause) 'else))

     (define (cond-predicate clause) (car clause))

     (define (cond-actions clause) (cdr clause))

     (define (cond->if exp)
       (expand-clauses (cond-clauses exp)))

     (define (expand-clauses clauses)
       (if (null? clauses)
	 false
	 (let ((first (car clauses))
	       (rest (cdr clauses)))
	   (if (cond-else-clause? first)
	     (if (null? rest)
	       (sequence->exp (cond-actions first))
	       (error "ELSE clause isn't last -- COND->IF (Compiled)"
		      clauses))
	     (make-if (cond-predicate first)
		      (sequence->exp (cond-actions first))
		      (expand-clauses rest))))))

     ;;;; 4.6 let
     (define (let? exp) (tagged-list? exp 'let))
     ;; change
     (define (let-var clauses) (map car (car clauses)))
     (define (let-exp clauses) (map cadr (car clauses)))
     (define (let-body clauses) (cdr clauses))
     (define (let-clause exp) (cdr exp))
     (define (let->combination exp)
       (expand-let-clauses (let-clause exp)))
     (define (expand-let-clauses clauses)
       (if (null? (car clauses))
	 '()
	 (append (list (make-lambda (let-var clauses) (let-body clauses))) (let-exp clauses))))

     ;;;; 4.1.3 評価器のデータ構造

     ;;;; 述語のテスト
     (define (true? x)
       (not (eq? x false)))

     (define (false? x)
       (eq? x false))

     ;;;; 手続きの表現
     (define (make-procedure parameters body env)
       (list 'procedure parameters body env))

     (define (compound-procedure? p)
       (tagged-list? p 'procedure))

     (define (procedure-parameters p) (cadr p))

     (define (procedure-body p) (caddr p))

     (define (procedure-environment p) (cadddr p))

     ;;;; 環境に対する操作
     (define (enclosing-environment env) (cdr env))

     (define (first-frame env) (car env))

     (define the-empty-environment '())

     (define (make-frame variables values)
       (cons variables values))

     (define (frame-variables frame) (car frame))

     (define (frame-values frame) (cdr frame))

     (define (add-binding-to-frame! var val frame)
       (set-car! frame (cons var (car frame)))
       (set-cdr! frame (cons val (cdr frame))))

     (define (extend-environment vars vals base-env)
       (if (= (length vars) (length vals))
	 (cons (make-frame vars vals) base-env)
	 (if (< (length vars) (length vals))
	   (error "Too many arguments supplied (Compiled)" vars vals)
	   (error "Too few arguments supplied (Compiled)" vars vals))))

     (define (lookup-variable-value var env)
       (define (env-loop env)
	 (define (scan vars vals)
	   (cond ((null? vars)
		  (env-loop (enclosing-environment env)))
	     ((eq? var (car vars))
	      (car vals))
	     (else (scan (cdr vars) (cdr vals)))))
	 (if (eq? env the-empty-environment)
	   (error "Unbound variable (Compiled)" var)
	   (let ((frame (first-frame env)))
	     (scan (frame-variables frame)
		   (frame-values frame)))))
       (env-loop env))

     (define (set-variable-value! var val env)
       (define (env-loop env)
	 (define (scan vars vals)
	   (cond ((null? vars)
		  (env-loop (enclosing-environment env)))
	     ((eq? var (car vars))
	      (set-car! vals val))
	     (else (scan (cdr vars) (cdr vals)))))
	 (if (eq? env the-empty-environment)
	   (error "Unbound variable -- SET! (Compiled)" var)
	   (let ((frame (first-frame env)))
	     (scan (frame-variables frame)
		   (frame-values frame)))))
       (env-loop env))

     (define (define-variable! var val env)
       (let ((frame (first-frame env)))
	 (define (scan vars vals)
	   (cond ((null? vars)
		  (add-binding-to-frame! var val frame))
	     ((eq? var (car vars))
	      (set-car! vals val))
	     (else (scan (cdr vars) (cdr vals)))))
	 (scan (frame-variables frame)
	       (frame-values frame))))

     ;;;; 4.1.4 評価器をプログラムとして走らせる
     (define primitive-procedures
       (list (list 'car car)
	     (list 'cdr cdr)
	     (list 'cons cons)
	     (list 'null? null?)
	     (list 'assoc assoc)
	     (list 'cadr cadr)
	     (list 'display display)
	     (list 'print print)
	     (list 'not not)
	     (list '+ +)
	     (list '- -)
	     (list '* *)
	     (list '/ /)
	     (list '= =)
	     (list '< <)
	     (list '> >)
	     (list '<= <=)
	     (list '>= >=)
	     ;; 基本手続きが続く
	     ))

     (define (primitive-procedure-names)
       (map car
	    primitive-procedures))

     (define (primitive-procedure-objects)
       (map (lambda (proc) (list 'primitive (cadr proc)))
	    primitive-procedures))

     (define (setup-environment)
       (let ((initial-env
	       (extend-environment (primitive-procedure-names)
				   (primitive-procedure-objects)
				   the-empty-environment)))
	 (define-variable! 'true true initial-env)
	 (define-variable! 'false false initial-env)
	 initial-env))

     (define the-global-environment (setup-environment))

     (define (primitive-procedure? proc)
       (tagged-list? proc 'primitive))

     (define (primitive-implementation proc) (cadr proc))

     (define (apply-primitive-procedure proc args)
       (apply-in-underlying-scheme
	 (primitive-implementation proc) args))

     ;;;; 基盤の Lisp システムの"読み込み-評価-印字"ループをモデル化する"駆動ループ(driver-loop)"を用意する。
     (define input-prompt ";;; M-Eval (Compiled) input:")
     (define output-prompt ";;; M-Eval (Compiled) value:")

     (define (announce-output string)
       (newline) (display string) (newline))

     (define (user-print object)
       (if (compound-procedure? object)
	 (display (list 'compound-procedure
			(procedure-parameters object)
			(procedure-body object)
			'<procedure-env>))
	 (display object)))

     (define (prompt-for-input string)
       (newline) (newline) (display string) (newline))

     (define (driver-loop)
       (prompt-for-input input-prompt)
       (let ((input (read)))
	 (let ((output (eval input the-global-environment)))
	   (announce-output output-prompt)
	   (user-print output)))
       (driver-loop))

     ;; REPL開始
     (driver-loop)
     ))

(define (start-metacircular)
  (define metacircular-register
    (make-machine
      '(env val proc argl continue compapp)
      eceval-operations
      (statements (compile metacircular-code 'val 'next))))
  ((metacircular-register 'stack) 'initialize)
  (set-register-contents! metacircular-register 'env the-global-environment)
  (start metacircular-register))

(start-metacircular)

;;;; M-Eval (Compiled) input:
;(define (factorial n)
;    (if (= n 1)
;        1
;        (* (factorial (- n 1)) n)))
;
;;;; M-Eval (Compiled) value:
;ok
;
;;;; M-Eval (Compiled) input:
;(factorial 5)
;
;;;; M-Eval (Compiled) value:
;120

