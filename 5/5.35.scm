(load "../compiler.scm")
(parse-compiled-code
  (compile
    '(define (f x)
       (+ x (g (+ x 2))))
    'val
    'next))

;;; Figure 5.18
;;;
;;; 手続きを構成する
;  (assign val (op make-compiled-procedure) (label entry16)
;                                           (reg env))
;  (goto (label after-lambda15))
;
;;; 手続き本体 (f x)
;entry16
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env
;          (op extend-environment) (const (x)) (reg argl) (reg env))
;
;;; 手続き開始 (+ ...)
;  (assign proc (op lookup-variable-value) (const +) (reg env))
;  (save continue)
;  (save proc)
;  (save env)
;
;;; (g ...)の計算
;  (assign proc (op lookup-variable-value) (const g) (reg env))
;  (save proc)
;
;;; (+ x 2)の計算
;  (assign proc (op lookup-variable-value) (const +) (reg env))
;  (assign val (const 2))
;  (assign argl (op list) (reg val))
;  (assign val (op lookup-variable-value) (const x) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch19))
;compiled-branch18
;  (assign continue (label after-call17))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch19
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;
;;; (+ x 2)の計算結果
;after-call17
;  (assign argl (op list) (reg val))
;  (restore proc)
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch22))
;
;;; (g (+ x 2))の計算
;compiled-branch21
;  (assign continue (label after-call20))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch22
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;
;;; (g (+ x 2))の計算の戻り
;;; (+ x (g (+ x 2)))の計算
;after-call20
;  (assign argl (op list) (reg val))
;  (restore env)
;  (assign val (op lookup-variable-value) (const x) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (restore proc)
;  (restore continue)
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch25))
;compiled-branch24
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch25
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;  (goto (reg continue))
;after-call23
;
;;; defineで手続き(f ...)を定義
;after-lambda15
;  (perform (op define-variable!) (const f) (reg val) (reg env))
;  (assign val (const ok))

