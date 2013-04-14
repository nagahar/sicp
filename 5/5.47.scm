(load "../explicit-control_evaluator2.scm")

(define eceval
  (make-machine
    '(exp env val proc argl continue unev compapp)
    eceval-operations
    '(
      ;; change
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

;; change
;; compound-applyを呼び出すためにcontinueを退避する
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

(compile-and-go
  '(define (f a b)
     (print (g (+ a b)))))

;;;; EC-Eval2 input:
;(define (g a) (* a 3))
;
;
;(total-pushes = 3 maximum-depth = 3)
;;;; EC-Eval2 value:
;ok
;;;; EC-Eval2 input:
;(f 3 4)
;21
;
;(total-pushes = 21 maximum-depth = 7)
;;;; EC-Eval2 value:
;#<undef>

