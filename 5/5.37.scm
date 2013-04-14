;; レジスタが命令列で修正されないにも関わらず、直前にsaveを行っている

(load "../compiler.scm")
(define (preserving regs seq1 seq2)
  (if (null? regs)
    (append-instruction-sequences seq1 seq2)
    (let ((first-reg (car regs)))
	(preserving (cdr regs)
		    (make-instruction-sequence
		      (list-union (list first-reg)
				  (registers-needed seq1))
		      (list-difference (registers-modified seq1)
				       (list first-reg))
		      (append `((save ,first-reg))
			      (statements seq1)
			      `((restore ,first-reg))))
		    seq2))))

(parse-compiled-code
  (compile
    '(define (f x)
       (+ x 10))
    'val
    'next))

;; original preserving
;(env)
;(val)
;  (assign val (op make-compiled-procedure) (label entry1) (reg env))
;  (goto (label after-lambda2))
;entry1
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (x)) (reg argl) (reg env))
;  (assign proc (op lookup-variable-value) (const +) (reg env))
;  (assign val (const 10))
;  (assign argl (op list) (reg val))
;  (assign val (op lookup-variable-value) (const x) (reg env))
;  (assign argl (op cons) (reg val) (reg argl))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch3))
;compiled-branch4
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch3
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;  (goto (reg continue))
;after-call5
;after-lambda2
;  (perform (op define-variable!) (const f) (reg val) (reg env))
;  (assign val (const ok))

;; modified preserving
;(continue env)
;(val)
;  (save continue)
;  (save env)
;  (save continue)
;  (assign val (op make-compiled-procedure) (label entry6) (reg env))
;  (restore continue)
;  (goto (label after-lambda7))
;entry6
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (x)) (reg argl) (reg env))
;  (save continue)
;  (save env)
;  (save continue)
;  (assign proc (op lookup-variable-value) (const +) (reg env))
;  (restore continue)
;  (restore env)
;  (restore continue)
;  (save continue)
;  (save proc)
;  (save env)
;  (save continue)
;  (assign val (const 10))
;(restore continue)
;  (assign argl (op list) (reg val))
;  (restore env)
;  (save argl)
;  (save continue)
;  (assign val (op lookup-variable-value) (const x) (reg env))
;  (restore continue)
;  (restore argl)
;  (assign argl (op cons) (reg val) (reg argl))
;  (restore proc)
;  (restore continue)
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch8))
;compiled-branch9
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;primitive-branch8
;  (save continue)
;  (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
;  (restore continue)
;  (goto (reg continue))
;after-call10
;after-lambda7
;  (restore env)
;  (perform (op define-variable!) (const f) (reg val) (reg env))
;  (assign val (const ok))
;  (restore continue)
