(load "../explicit-control_evaluator.scm")

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

(start eceval)

;; a.
;; Fib(n) (n>=2)を計算するのに必要なスタックの最大深さ = 5 * n + 3
;;
;; b.
;; Fib(n) (n>=2)を計算するのに使うプッシュの総数をS(n)とする
;;
;; S(n) = S(n-1) + S(n-2) + kを導出する
;;
;; 下記の監視結果より
;; S(5) = 408 = S(4) + 168 = S(4) + S(3) + 40
;; S(4) = 240 = S(3) + 112 = S(3) + S(2) + 40
;; S(3) = 128 = S(2) + 56 = S(2) + 56
;; S(2) = 72
;;
;; 従って、S(n) = S(n-1) + S(n-2) + 40
;; 定数k = 40となる
;;
;; 次に、S(n) = a * Fib(n+1) + b を示す
;;
;; S(n+1) = a * Fib(n+2) + b より
;; S(n+1) - S(n) = a * (Fib(n+2) - Fib(n+1))
;; S(n+1) - S(n) = a * Fib(n)
;;
;; S(n) = S(n-1) + S(n-2) + 40 より
;; S(n) - S(n-1) = a * Fib(n-1)
;; S(n-1) + S(n-2) + 40 - S(n-1) = a * Fib(n-1)
;; S(n-2) = a * Fib(n-1) - 40
;; すなわち、S(n) = a * Fib(n+1) - 40
;;
;; 下記の監視結果より
;; S(5) = 408 = a * Fib(6) - 40 = a * 8 - 40
;; a = 56
;;
;; 従って、S(n) = 56 * Fib(n+1) - 40
;; よって、a = 56, b = -40
;;
;;;; EC-Eval input:
;(define (fib n)
;  (if (< n 2)
;      n
;      (+ (fib (- n 1)) (fib (- n 2)))))
;
;(total-pushes = 3 maximum-depth = 3)
;;;; EC-Eval value:
;ok
;
;;;; EC-Eval input:
;(fib 2)
;
;(total-pushes = 72 maximum-depth = 13)
;;;; EC-Eval value:
;1
;
;;;; EC-Eval input:
;(fib 3)
;
;(total-pushes = 128 maximum-depth = 18)
;;;; EC-Eval value:
;2
;
;;;; EC-Eval input:
;(fib 4)
;
;(total-pushes = 240 maximum-depth = 23)
;;;; EC-Eval value:
;3
;
;;;; EC-Eval input:
;(fib 5)
;
;(total-pushes = 408 maximum-depth = 28)
;;;; EC-Eval value:
;5

