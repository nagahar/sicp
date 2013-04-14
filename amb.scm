(define true #t)
(define false #f)

;; 基盤の apply への参照を apply-in-underlying-scheme へ退避させる（こうすることで、基盤の apply に apply-in-underlying-scheme という名前でアクセスできる）。
(define apply-in-underlying-scheme apply)


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
	"Unknown procedure type -- APPLY" procedure))))

;;;; eval の定義
(define (eval exp env)
  ((analyze exp) env))

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
    ((ramb? exp) (analyze-ramb exp))
    ((if-fail? exp) (analyze-if-fail exp))
    ((permanent-assignment? exp) (analyze-permanent-assignment exp))
    ((require? exp) (analyze-require exp))
    ((application? exp) (analyze-application exp))
    (else
      (error "Unknown expression type -- ANALYZE" exp))))

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

(define (analyze-self-evaluating exp)
  (lambda (env succeed fail)
    (succeed exp fail)))

;;;; 変数は記号で表現
(define (variable? exp) (symbol? exp))

(define (analyze-variable exp)
  (lambda (env succeed fail)
    (succeed (lookup-variable-value exp env)
	     fail)))

;;;; クォート式は (quote <text-of-quotation>) の形
(define (quoted? exp)
  (tagged-list? exp 'quote))

(define (text-of-quotation exp) (cadr exp))

(define (analyze-quoted exp)
  (let ((qval (text-of-quotation exp)))
    (lambda (env succeed fail)
      (succeed qval fail))))

(define (tagged-list? exp tag)
  (if (pair? exp)
    (eq? (car exp) tag)
    false))

;;;; 代入は (set! <var> <value>) の形
(define (assignment? exp)
  (tagged-list? exp 'set!))

(define (assignment-variable exp) (cadr exp))

(define (assignment-value exp) (caddr exp))

(define (analyze-assignment exp)
  (let ((var (assignment-variable exp))
	(vproc (analyze (assignment-value exp))))
    (lambda (env succeed fail)
      (vproc env
	     (lambda (val fail2) ; *1*
	       (let ((old-value
		       (lookup-variable-value var env)))
		 (set-variable-value! var val env)
		 (succeed 'ok
			  (lambda () ; *2*
			    (set-variable-value! var
						 old-value
						 env)
			    (fail2)))))
	     fail))))

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

(define (analyze-definition exp)
  (let ((var (definition-variable exp))
	(vproc (analyze (definition-value exp))))
    (lambda (env succeed fail)
      (vproc env
	     (lambda (val fail2)
	       (define-variable! var val env)
	       (succeed 'ok fail2))
	     fail))))

;;;; lambda 式は記号 lambda で始まるリスト
(define (lambda? exp) (tagged-list? exp 'lambda))

(define (lambda-parameters exp) (cadr exp))

(define (lambda-body exp) (cddr exp))

(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))

(define (analyze-lambda exp)
  (let ((vars (lambda-parameters exp))
	(bproc (analyze-sequence (lambda-body exp))))
    (lambda (env succeed fail)
      (succeed (make-procedure vars bproc env)
	       fail))))

;;;; 条件式
(define (if? exp) (tagged-list? exp 'if))

(define (if-predicate exp) (cadr exp))

(define (if-consequent exp) (caddr exp))

(define (if-alternative exp)
  (if (not (null? (cdddr exp)))
    (cadddr exp)
    'false))

(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

(define (analyze-if exp)
  (let ((pproc (analyze (if-predicate exp)))
	(cproc (analyze (if-consequent exp)))
	(aproc (analyze (if-alternative exp))))
    (lambda (env succeed fail)
      (pproc env
	     ;; pred-value を得るための
	     ;; 述語の評価の成功継続
	     (lambda (pred-value fail2)
	       (if (true? pred-value)
		 (cproc env succeed fail2)
		 (aproc env succeed fail2)))
	     ;; 述語の評価の失敗継続
	     fail))))

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

(define (analyze-sequence exps)
  (define (sequentially a b)
    (lambda (env succeed fail)
      (a env
	 ;; a を呼び出す時の成功継続
	 (lambda (a-value fail2)
	   (b env succeed fail2))
	 ;; a を呼び出す時の失敗継続
	 fail)))
  (define (loop first-proc rest-procs)
    (if (null? rest-procs)
      first-proc
      (loop (sequentially first-proc (car rest-procs))
	    (cdr rest-procs))))
  (let ((procs (map analyze exps)))
    (if (null? procs)
      (error "Empty sequence -- ANALYZE"))
    (loop (car procs) (cdr procs))))

;;;; 手続き作用
(define (application? exp) (pair? exp))

(define (operator exp) (car exp))

(define (operands exp) (cdr exp))

(define (no-operands? ops) (null? ops))

(define (first-operand ops) (car ops))

(define (rest-operands ops) (cdr ops))

(define (analyze-application exp)
  (let ((pproc (analyze (operator exp)))
	(aprocs (map analyze (operands exp))))
    (lambda (env succeed fail)
      (pproc env
	     (lambda (proc fail2)
	       (get-args aprocs
			 env
			 (lambda (args fail3)
			   (execute-application
			     proc args succeed fail3))
			 fail2))
	     fail))))

(define (get-args aprocs env succeed fail)
  (if (null? aprocs)
    (succeed '() fail)
    ((car aprocs) env
		  ;; この aproc の成功継続
		  (lambda (arg fail2)
		    (get-args (cdr aprocs)
			      env
			      ;; get-args の再帰呼び出しの
			      ;; 成功継続
			      (lambda (args fail3)
				(succeed (cons arg args)
					 fail3))
			      fail2))
		  fail)))

(define (execute-application proc args succeed fail)
  (cond ((primitive-procedure? proc)
	 (succeed (apply-primitive-procedure proc args)
		  fail))
    ((compound-procedure? proc)
     ((procedure-body proc)
      (extend-environment (procedure-parameters proc)
			  args
			  (procedure-environment proc))
      succeed
      fail))
    (else
      (error
	"Unknown procedure type -- EXECUTE-APPLICATION"
	proc))))

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
	  (error "ELSE clause isn't last -- COND->IF"
		 clauses))
	(make-if (cond-predicate first)
		 (let ((action (cond-actions first))
		       (predicate (cond-predicate first)))
		   (if (eq? (car action) '=>)
		     (list (cadr action) predicate)
		     (sequence->exp action)))
		 (expand-clauses rest))))))

;;;; let 式
(define (let? exp) (tagged-list? exp 'let))

(define (let-clauses exp) (cdr exp))

(define (let-bindings clauses) (car clauses))

(define (let-body clauses) (cdr clauses))

(define (let->combination exp)
  (if (pair? (car (let-clauses exp)))
    (expand-let-clauses (let-clauses exp))
    (expand-named-let-clauses (let-clauses exp))))

(define (expand-let-clauses clauses)
  (if (null? (let-bindings clauses))
    'false
    (cons (make-lambda (map car (let-bindings clauses)) (let-body clauses))
	  (map cadr (let-bindings clauses)))))

;;;; 名前付きlet
(define (named-let-var clauses) (car clauses))

(define (named-let-bindings clauses) (cadr clauses))

(define (named-let-body clauses) (caddr clauses))

(define (expand-named-let-clauses clauses)
  (make-begin
    (list
      (list 'define (cons (named-let-var clauses)
			  (map car (named-let-bindings clauses)))
	    (named-let-body clauses))
      (cons (named-let-var clauses)
	    (map cadr (named-let-bindings clauses))))))

;;;; amb
(define (amb? exp) (tagged-list? exp 'amb))

(define (amb-choices exp) (cdr exp))

(define (ambeval exp env succeed fail)
  ((analyze exp) env succeed fail))

(define (analyze-amb exp)
  (let ((cprocs (map analyze (amb-choices exp))))
    (lambda (env succeed fail)
      (define (try-next choices)
	(if (null? choices)
	  (fail)
	  ((car choices) env
			 succeed
			 (lambda ()
			   (try-next (cdr choices))))))
      (try-next cprocs))))

;;;; 4.42 and/or
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

;;;; 4.50 ramb
(define (ramb? exp) (tagged-list? exp 'ramb))
(define (analyze-ramb exp)
  (let ((cprocs (map analyze (amb-choices exp))))
    (lambda (env succeed fail)
      (define (try-next choices)
	(if (null? choices)
	  (fail)
	  (let ((choice (list-ref choices (random-integer (length choices)))))
	    (choice env
		    succeed
		    (lambda ()
		      (try-next (delete choice choices)))))))
      (try-next cprocs))))

;;;; 4.52 if-fail
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


;;;; 4.53 permanent-set!
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

;;;; 4.54 require
(define (require? exp) (tagged-list? exp 'require))
(define (require-predicate exp) (cadr exp))
(define (analyze-require exp)
  (let ((pproc (analyze (require-predicate exp))))
    (lambda (env succeed fail)
      (pproc env
	     (lambda (pred-value fail2)
	       (if (false? pred-value)
		 (fail2)
		 (succeed 'ok fail2)))
	     fail))))

;;;; 4.1.3 評価器のデータ構造

;;;; 述語のテスト
(define (true? x)
  (not (eq? x false)))

(define (false? x)
  (eq? x false))

;;;; 手続きの表現
(define (scan-out-defines body)
  (define (iter exp vars sets exps)
    (if (null? exp)
      (list (reverse vars) (reverse sets) (reverse exps))
      (if (definition? (car exp))
	(iter (cdr exp) (cons (list (definition-variable (car exp)) ''*unassigned*) vars) (cons (list 'set! (definition-variable(car exp)) (definition-value (car exp))) sets) exps)
	(iter (cdr exp) vars sets (cons (car exp) exps)))))
  (define (include-define? exp)
    (if (null? exp)
      false
      (if (definition? (car exp))
	true
	(include-define? (cdr exp)))))
  (if (include-define? body)
    (let ((var-val-exp-list (iter body '() '() '())))
      (list (cons 'let (cons (car var-val-exp-list) (append (cadr var-val-exp-list) (caddr var-val-exp-list))))))
    body))

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

; フレーム
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
      (error "Too many arguments supplied" vars vals)
      (error "Too few arguments supplied" vars vals))))

(define (lookup-variable-value var env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
	     (env-loop (enclosing-environment env)))
	((eq? var (car vars))
	 (if (eq? '*unassigned* (car vals))
	   (error "Unassigned variable -- LOOKUP-VARIABLE-VALUE" var)
	   (car vals)))
	(else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
      (error "Unbound variable" var)
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
      (error "Unbound variable -- SET!" var)
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
	(list 'equal? equal?)
	(list 'list list)
	(list 'memq memq)
	(list 'member member)
	(list 'assoc assoc)
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
	(list 'not not)
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
(define input-prompt ";;; Amb-Eval input:")
(define output-prompt ";;; Amb-Eval value:")

(define (driver-loop)
  (define (internal-loop try-again)
    (prompt-for-input input-prompt)
    (let ((input (read)))
      (if (eq? input 'try-again)
	(try-again)
	(begin
	  (newline)
	  (display ";;; Starting a new problem ")
	  (ambeval input
		   the-global-environment
		   ;; ambeval 成功
		   (lambda (val next-alternative)
		     (announce-output output-prompt)
		     (user-print val)
		     (internal-loop next-alternative))
		   ;; ambeval 失敗
		   (lambda ()
		     (announce-output
		       ";;; There are no more values of")
		     (user-print input)
		     (driver-loop)))))))
  (internal-loop
    (lambda ()
      (newline)
      (display ";;; There is no current problem")
      (driver-loop))))

(define (prompt-for-input string)
  (newline) (newline) (display string) (newline))

(define (announce-output string)
  (newline) (display string) (newline))

(define (user-print object)
  (if (compound-procedure? object)
    (display (list 'compound-procedure
		   (procedure-parameters object)
		   (procedure-body object)
		   '<procedure-env>))
    (display object)))

