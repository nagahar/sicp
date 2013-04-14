;; 本ファイルは直下ディレクトリのscmファイルからloadされることを想定している
;;
;; 超循環評価器の関数だけを利用する
;; evalとapplyはgaucheのものを利用する
(define apply-in-underlying-scheme apply)
(define eval-in-underlying-scheme eval)
(load "../metacircular.scm")
(define apply apply-in-underlying-scheme)
(define eval eval-in-underlying-scheme)
(load "../simulator.scm")
(load "../compiler.scm")

;; メモ
;; primitive-proceduresはコンパイルしたコードの実行時の変数評価に使用される
;; (積極制御評価器は実行時の変数評価において、primitive-proceduresを使用している)
;;
;; レジスタ計算機に渡される命令列（eceval-operationsなど）は、アセンブル時に(op ...)で参照された手続きを評価するために使用される
;; しかしながら、コンパイルしたコードはlookup-variable-valueで手続きを参照するため、compilerで使用されている手続き以外はeceval-operationsから参照されることはない

(define true #t)
(define false #f)

(define (empty-arglist) '())

(define (last-operand? ops)
  (null? (cdr ops)))

(define (adjoin-arg arg arglist)
  (append arglist (list arg)))

(define the-global-environment (setup-environment))

(define (get-global-environment)
  the-global-environment)

(define (make-compiled-procedure entry env)
  (list 'compiled-procedure entry env))

(define (compiled-procedure? proc)
  (tagged-list? proc 'compiled-procedure))

(define (compiled-procedure-entry c-proc) (cadr c-proc))

(define (compiled-procedure-env c-proc) (caddr c-proc))

(define (compile-and-go expression)
  (let ((instructions
	  (assemble (statements
		      (compile expression 'val 'return))
		    eceval)))
    (set! the-global-environment (setup-environment))
    (set-register-contents! eceval 'val instructions)
    (set-register-contents! eceval 'flag true)
    (start eceval)))

(define (user-print object)
  (cond ((compound-procedure? object)
	 (display (list 'compound-procedure
			(procedure-parameters object)
			(procedure-body object)
			'<procedure-env>)))
    ((compiled-procedure? object)
     (display '<compiled-procedure>))
    (else (display object))))

;; 5.47
(define (compile-procedure-call target linkage)
  (let ((primitive-branch (make-label 'primitive-branch))
	(compiled-branch (make-label 'compiled-branch))
	;; change
	(compound-branch (make-label 'compound-branch))
	(after-call (make-label 'after-call)))
    (let ((compiled-linkage
	    (if (eq? linkage 'next) after-call linkage)))
      (append-instruction-sequences
	(make-instruction-sequence '(proc) '()
				   `((test (op primitive-procedure?) (reg proc))
				     (branch (label ,primitive-branch))))
	(parallel-instruction-sequences
	  ;; change
	  (append-instruction-sequences
	    (make-instruction-sequence '(proc) '()
				       `((test (op compound-procedure?) (reg proc))
					 (branch (label ,compound-branch))))
	    (parallel-instruction-sequences
	      (append-instruction-sequences
		compiled-branch
		(compile-proc-appl target compiled-linkage))
	      (append-instruction-sequences
		compound-branch
		(compound-proc-appl target compiled-linkage))))
	  (append-instruction-sequences
	    primitive-branch
	    (end-with-linkage linkage
			      (make-instruction-sequence '(proc argl)
							 (list target)
							 `((assign ,target
								   (op apply-primitive-procedure)
								   (reg proc)
								   (reg argl)))))))
	after-call))))

(define (compound-proc-appl target linkage)
  (cond ((and (eq? target 'val) (not (eq? linkage 'return)))
	 (make-instruction-sequence '(proc continue) all-regs
				    `((assign continue (label ,linkage))
				      (save continue)
				      (goto (reg compapp)))))
    ((and (not (eq? target 'val))
       (not (eq? linkage 'return)))
     (let ((proc-return (make-label 'proc-return)))
       (make-instruction-sequence '(proc continue) all-regs
				  `((assign continue (label ,proc-return))
				    (save continue)
				    (goto (reg compapp))
				    ,proc-return
				    (assign ,target (reg val))
				    (goto (label ,linkage))))))
    ((and (eq? target 'val) (eq? linkage 'return))
     (make-instruction-sequence '(proc continue) all-regs
				'((save continue)
				  (goto (reg compapp)))))
    ((and (not (eq? target 'val)) (eq? linkage 'return))
     (error "return linkage, target not val -- COMPILE"
	    target))))

;; 5.48
(define (compile-and-run expression)
  (let ((instructions
	  (assemble (statements
		      (compile expression 'val 'return))
		    eceval)))
    (set-register-contents! eceval 'val instructions)
    (set-register-contents! eceval 'flag true)
    (start eceval)))

;; 5.48
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
	(list 'compile-and-run compile-and-run)
	;; 基本手続きが続く
	))
;; primitive-proceduresを追加したので環境を再構築する
(set! the-global-environment (setup-environment))

;; 5.48
(define (start-eceval)
  (set-register-contents! eceval 'flag false)
  (start eceval))

(define eceval-operations
  (list (list 'self-evaluating? self-evaluating?)
	(list 'variable? variable?)
	(list 'quoted? quoted?)
	(list 'assignment? assignment?)
	(list 'definition? definition?)
	(list 'if? if?)
	(list 'lambda? lambda?)
	(list 'begin? begin?)
	(list 'application? application?)
	;;
	(list 'lookup-variable-value lookup-variable-value)
	(list 'text-of-quotation text-of-quotation)
	(list 'lambda-parameters lambda-parameters)
	(list 'lambda-body lambda-body)
	(list 'make-procedure make-procedure)
	(list 'operands operands)
	(list 'operator operator)
	(list 'empty-arglist empty-arglist)
	(list 'no-operands? no-operands?)
	(list 'first-operand first-operand)
	(list 'last-operand? last-operand?)
	(list 'adjoin-arg adjoin-arg)
	(list 'rest-operands rest-operands)
	(list 'primitive-procedure? primitive-procedure?)
	(list 'compound-procedure? compound-procedure?)
	(list 'apply-primitive-procedure apply-primitive-procedure)
	(list 'procedure-parameters procedure-parameters)
	(list 'procedure-environment procedure-environment)
	(list 'extend-environment extend-environment)
	(list 'procedure-body procedure-body)
	(list 'begin-actions begin-actions)
	(list 'first-exp first-exp)
	(list 'last-exp? last-exp?)
	(list 'rest-exps rest-exps)
	(list 'if-predicate if-predicate)
	(list 'true? true?)
	(list 'if-alternative if-alternative)
	(list 'if-consequent if-consequent)
	(list 'assignment-variable assignment-variable)
	(list 'assignment-value assignment-value)
	(list 'set-variable-value! set-variable-value!)
	(list 'definition-variable definition-variable)
	(list 'definition-value definition-value)
	(list 'define-variable! define-variable!)
	(list 'prompt-for-input prompt-for-input)
	(list 'read read)
	(list 'get-global-environment get-global-environment)
	(list 'announce-output announce-output)
	(list 'user-print user-print)
	(list 'make-compiled-procedure make-compiled-procedure)
	(list 'compiled-procedure? compiled-procedure?)
	(list 'compiled-procedure-entry compiled-procedure-entry)
	(list 'compiled-procedure-env compiled-procedure-env)
	(list 'car car)
	(list 'cdr cdr)
	(list 'list list)
	(list 'cons cons)
	(list 'false? false?)
	(list 'print print)
	))

(define eceval
  (make-machine
    '(exp env val proc argl continue unev compapp)
    eceval-operations
    '(
      (assign compapp (label compound-apply))
      (branch (label external-entry)) ; branches if flag is set
      read-eval-print-loop
      (perform (op initialize-stack))
      (perform
	(op prompt-for-input) (const ";;; EC-Eval2 input:"))
      (assign exp (op read))
      (assign env (op get-global-environment))
      (assign continue (label print-result))
      (goto (label eval-dispatch))
      external-entry
      (perform (op initialize-stack))
      (assign env (op get-global-environment))
      (assign continue (label print-result))
      (goto (reg val))
      print-result
      (perform (op print-stack-statistics)) ; added instruction
      (perform
	(op announce-output) (const ";;; EC-Eval2 value:"))
      (perform (op user-print) (reg val))
      (goto (label read-eval-print-loop))
      ;; 5.4.1 積極制御評価器の中核
      eval-dispatch
      (test (op self-evaluating?) (reg exp))
      (branch (label ev-self-eval))
      (test (op variable?) (reg exp))
      (branch (label ev-variable))
      (test (op quoted?) (reg exp))
      (branch (label ev-quoted))
      (test (op assignment?) (reg exp))
      (branch (label ev-assignment))
      (test (op definition?) (reg exp))
      (branch (label ev-definition))
      (test (op if?) (reg exp))
      (branch (label ev-if))
      (test (op lambda?) (reg exp))
      (branch (label ev-lambda))
      (test (op begin?) (reg exp))
      (branch (label ev-begin))
      (test (op application?) (reg exp))
      (branch (label ev-application))
      (goto (label unknown-expression-type))
      ;; 5.4.1 単純式の評価
      ev-self-eval
      (assign val (reg exp))
      (goto (reg continue))
      ev-variable
      (assign val (op lookup-variable-value) (reg exp) (reg env))
      (goto (reg continue))
      ev-quoted
      (assign val (op text-of-quotation) (reg exp))
      (goto (reg continue))
      ev-lambda
      (assign unev (op lambda-parameters) (reg exp))
      (assign exp (op lambda-body) (reg exp))
      (assign val (op make-procedure) (reg unev) (reg exp) (reg env))
      (goto (reg continue))
      ;; 5.4.1 手続き作用の評価
      ev-application
      (save continue)
      (save env)
      (assign unev (op operands) (reg exp))
      (save unev)
      (assign exp (op operator) (reg exp))
      (assign continue (label ev-appl-did-operator))
      (goto (label eval-dispatch))
      ev-appl-did-operator
      (restore unev) ; 被演算子
      (restore env)
      (assign argl (op empty-arglist))
      (assign proc (reg val)) ; 演算子
      (test (op no-operands?) (reg unev))
      (branch (label apply-dispatch))
      (save proc)
      ev-appl-operand-loop
      (save argl)
      (assign exp (op first-operand) (reg unev))
      (test (op last-operand?) (reg unev))
      (branch (label ev-appl-last-arg))
      (save env)
      (save unev)
      (assign continue (label ev-appl-accumulate-arg))
      (goto (label eval-dispatch))
      ev-appl-accumulate-arg
      (restore unev)
      (restore env)
      (restore argl)
      (assign argl (op adjoin-arg) (reg val) (reg argl))
      (assign unev (op rest-operands) (reg unev))
      (goto (label ev-appl-operand-loop))
      ev-appl-last-arg
      (assign continue (label ev-appl-accum-last-arg))
      (goto (label eval-dispatch))
      ev-appl-accum-last-arg
      (restore argl)
      (assign argl (op adjoin-arg) (reg val) (reg argl))
      (restore proc)
      (goto (label apply-dispatch))
      ;; 手続き作用
      apply-dispatch
      (test (op primitive-procedure?) (reg proc))
      (branch (label primitive-apply))
      (test (op compound-procedure?) (reg proc))
      (branch (label compound-apply))
      (test (op compiled-procedure?) (reg proc))
      (branch (label compiled-apply))
      (goto (label unknown-procedure-type))
      compiled-apply
      (restore continue)
      (assign val (op compiled-procedure-entry) (reg proc))
      (goto (reg val))
      primitive-apply
      (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
      (restore continue)
      (goto (reg continue))
      compound-apply
      (assign unev (op procedure-parameters) (reg proc))
      (assign env (op procedure-environment) (reg proc))
      (assign env (op extend-environment) (reg unev) (reg argl) (reg env))
      (assign unev (op procedure-body) (reg proc))
      (goto (label ev-sequence))
      ;; 5.4.2 並びの評価と末尾再帰
      ev-begin
      (assign unev (op begin-actions) (reg exp))
      (save continue)
      (goto (label ev-sequence))
      ev-sequence
      (assign exp (op first-exp) (reg unev))
      (test (op last-exp?) (reg unev))
      (branch (label ev-sequence-last-exp))
      (save unev)
      (save env)
      (assign continue (label ev-sequence-continue))
      (goto (label eval-dispatch))
      ev-sequence-continue
      (restore env)
      (restore unev)
      (assign unev (op rest-exps) (reg unev))
      (goto (label ev-sequence))
      ev-sequence-last-exp
      (restore continue)
      (goto (label eval-dispatch))
      ;; 5.4.3 条件式、代入および定義
      ev-if
      (save exp) ; 後のために式を退避
      (save env)
      (save continue)
      (assign continue (label ev-if-decide))
      (assign exp (op if-predicate) (reg exp))
      (goto (label eval-dispatch)) ; 述語を評価
      ev-if-decide
      (restore continue)
      (restore env)
      (restore exp)
      (test (op true?) (reg val))
      (branch (label ev-if-consequent))
      ev-if-alternative
      (assign exp (op if-alternative) (reg exp))
      (goto (label eval-dispatch))
      ev-if-consequent
      (assign exp (op if-consequent) (reg exp))
      (goto (label eval-dispatch))
      ;; 代入
      ev-assignment
      (assign unev (op assignment-variable) (reg exp))
      (save unev) ; 後のために変数を退避
      (assign exp (op assignment-value) (reg exp))
      (save env)
      (save continue)
      (assign continue (label ev-assignment-1))
      (goto (label eval-dispatch)) ; 代入する値を評価
      ev-assignment-1
      (restore continue)
      (restore env)
      (restore unev)
      (perform
	(op set-variable-value!) (reg unev) (reg val) (reg env))
      (assign val (const ok))
      (goto (reg continue))
      ;; 定義
      ev-definition
      (assign unev (op definition-variable) (reg exp))
      (save unev) ; 後のために変数を退避
      (assign exp (op definition-value) (reg exp))
      (save env)
      (save continue)
      (assign continue (label ev-definition-1))
      (goto (label eval-dispatch)) ; 定義する値を評価
      ev-definition-1
      (restore continue)
      (restore env)
      (restore unev)
      (perform
	(op define-variable!) (reg unev) (reg val) (reg env))
      (assign val (const ok))
      (goto (reg continue))
      ;; 5.4.4 評価の実行
      unknown-expression-type
      (assign val (const unknown-expression-type-error))
      (goto (label signal-error))
      unknown-procedure-type
      (restore continue) ; スタックを清掃する (apply-dispatch から)
      (assign val (const unknown-procedure-type-error))
      (goto (label signal-error))
      signal-error
      (perform (op user-print) (reg val))
      (goto (label read-eval-print-loop))
      )))

