(load "../explicit-control_evaluator.scm")

(define (no-more-exps? seq) (null? seq))

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
	(list 'car car)
	(list 'cdr cdr)
	(list 'print print)
	(list 'no-more-exps? no-more-exps?)
	))

(define eceval
  (make-machine
    '(exp env val proc argl continue unev)
    eceval-operations
    '(
      read-eval-print-loop
      (perform (op initialize-stack))
      (perform
	(op prompt-for-input) (const ";;; EC-Eval input:"))
      (assign exp (op read))
      (assign env (op get-global-environment))
      (assign continue (label print-result))
      (goto (label eval-dispatch))
      print-result
      (perform (op print-stack-statistics))
      (perform
	(op announce-output) (const ";;; EC-Eval value:"))
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
      (goto (label unknown-procedure-type))
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
      ev-sequence ;; 非末尾再帰
      (test (op no-more-exps?) (reg unev))
      (branch (label ev-sequence-end))
      (assign exp (op first-exp) (reg unev))
      (save unev)
      (save env)
      (assign continue (label ev-sequence-continue))
      (goto (label eval-dispatch))
      ev-sequence-continue
      (restore env)
      (restore unev)
      (assign unev (op rest-exps) (reg unev))
      (goto (label ev-sequence))
      ev-sequence-end
      (restore continue)
      (goto (reg continue))
      ;ev-sequence
      ;(assign exp (op first-exp) (reg unev))
      ;(test (op last-exp?) (reg unev))
      ;(branch (label ev-sequence-last-exp))
      ;(save unev)
      ;(save env)
      ;(assign continue (label ev-sequence-continue))
      ;(goto (label eval-dispatch))
      ;ev-sequence-continue
      ;(restore env)
      ;(restore unev)
      ;(assign unev (op rest-exps) (reg unev))
      ;(goto (label ev-sequence))
      ;ev-sequence-last-exp
      ;(restore continue)
      ;(goto (label eval-dispatch))
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

(start eceval)

;; 非末尾再帰評価器の結果
;; |		|最大深さ	|プッシュ回数	|
;; |再帰的階乗	|8 * n + 3	|34 * n - 16	|
;; |反復的階乗	|3 * n + 14	|37 * n + 33	|
;;
;; 末尾再帰評価器の結果
;; |		|最大深さ	|プッシュ回数	|
;; |再帰的階乗	|5 * n + 3	|32 * n + 16	|
;; |反復的階乗	|10		|35 * n + 29	|

;;;; EC-Eval input:
;(define (factorial n)
;  (define (iter product counter)
;    (if (> counter n)
;      product
;      (iter (* counter product)
;            (+ counter 1))))
;  (iter 1 1))
;
;(total-pushes = 3 maximum-depth = 3)
;;;; EC-Eval value:
;ok
;
;;;; EC-Eval input:
;(factorial 1)
;
;(total-pushes = 70 maximum-depth = 17)
;;;; EC-Eval value:
;1
;
;;;; EC-Eval input:
;(factorial 2)
;
;(total-pushes = 107 maximum-depth = 20)
;;;; EC-Eval value:
;2
;
;;;; EC-Eval input:
;(factorial 3)
;
;(total-pushes = 144 maximum-depth = 23)
;;;; EC-Eval value:
;6
;
;;;; EC-Eval input:
;(factorial 4)
;
;(total-pushes = 181 maximum-depth = 26)
;;;; EC-Eval value:
;24
;
;;;; EC-Eval input:
;(factorial 5)
;
;(total-pushes = 218 maximum-depth = 29)
;;;; EC-Eval value:
;120

;;;; EC-Eval input:
;(define (factorial n)
;  (if (= n 1)
;    1
;    (* (factorial (- n 1)) n)))
;
;(total-pushes = 3 maximum-depth = 3)
;;;; EC-Eval value:
;ok
;
;;;; EC-Eval input:
;(factorial 1)
;
;(total-pushes = 18 maximum-depth = 11)
;;;; EC-Eval value:
;1
;
;;;; EC-Eval input:
;(factorial 2)
;
;(total-pushes = 52 maximum-depth = 19)
;;;; EC-Eval value:
;2
;
;;;; EC-Eval input:
;(factorial 3)
;
;(total-pushes = 86 maximum-depth = 27)
;;;; EC-Eval value:
;6
;
;;;; EC-Eval input:
;(factorial 4)
;
;(total-pushes = 120 maximum-depth = 35)
;;;; EC-Eval value:
;24
;
;;;; EC-Eval input:
;(factorial 5)
;
;(total-pushes = 154 maximum-depth = 43)
;;;; EC-Eval value:
;120

