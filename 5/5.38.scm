(load "../compiler.scm")

;; a.
(define (spread-arguments arg-list)
  (let ((seq1 (compile (car arg-list) 'arg1 'next))
	(seq2 (compile (cadr arg-list) 'arg2 'next)))
    (preserving '(env)
		seq1
		(if (modifies-register? seq2 'arg1)
		  (make-instruction-sequence
		    (list-union (registers-needed seq2) '(arg1))
		    (list-difference (registers-modified seq2) '(arg1))
		    `((save arg1) ,seq2 (restore arg1)))
		  seq2))))

;; b.
(define (compile-open-code exp target linkage)
  (let ((p-operator (operator exp))
	(p-operands (operands exp)))
    (end-with-linkage linkage
		      (append-instruction-sequences
			(spread-arguments p-operands)
			(make-instruction-sequence '(arg1 arg2) '(val)
						   `((assign val (op ,p-operator) (reg arg1) (reg arg2))))))))

(define (open-coding-primitive? exp)
  (memq (car exp) '(= * - +)))

(define (compile exp target linkage)
  (cond ((self-evaluating? exp)
	 (compile-self-evaluating exp target linkage))
    ((quoted? exp) (compile-quoted exp target linkage))
    ((variable? exp)
     (compile-variable exp target linkage))
    ((assignment? exp)
     (compile-assingment exp target linkage))
    ((definition? exp)
     (compile-definition exp target linkage))
    ((if? exp) (compile-if exp target linkage))
    ((lambda? exp) (compile-lambda exp target linkage))
    ((begin? exp)
     (compile-sequence (begin-actions exp)
		       target
		       linkage))
    ((cond? exp) (compile (cond->if exp) target linkage))
    ;; change
    ((open-coding-primitive? exp)
     (compile-open-code exp target linkage))
    ((application? exp)
     (compile-application exp target linkage))
    (else
      (error "Unknown expression type -- COMPILE" exp))))

;; c.
(parse-compiled-code
  (compile
    '(define (factorial n)
       (if (= n 1)
	 1
	 (* (factorial (- n 1)) n)))
    'val
    'next))

;(env)
;(val)
;  (assign val (op make-compiled-procedure) (label entry1) (reg env))
;  (goto (label after-lambda2))
;entry1
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (n)) (reg argl) (reg env))
;  (assign arg1 (op lookup-variable-value) (const n) (reg env))
;  (assign arg2 (const 1))
;  (assign val (op =) (reg arg1) (reg arg2))
;  (test (op false?) (reg val))
;  (branch (label false-branch4))
;true-branch3
;  (assign val (const 1))
;  (goto (reg continue))
;false-branch4
;  (save continue)
;  (assign proc (op lookup-variable-value) (const factorial) (reg env))
;  (assign arg1 (op lookup-variable-value) (const n) (reg env))
;  (assign arg2 (const 1))
;  (assign val (op -) (reg arg1) (reg arg2))
;  (assign argl (op list) (reg val))
;  (test (op primitive-procedure?) (reg proc))
;  (branch (label primitive-branch6))
;compiled-branch7
;  (assign continue (label proc-return9))
;  (assign val (op compiled-procedure-entry) (reg proc))
;  (goto (reg val))
;proc-return9
;  (assign arg1 (reg val))
;  (goto (label after-call8))
;primitive-branch6
;  (assign arg1 (op apply-primitive-procedure) (reg proc) (reg argl))
;after-call8
;  (assign arg2 (op lookup-variable-value) (const n) (reg env))
;  (assign val (op *) (reg arg1) (reg arg2))
;  (restore continue)
;  (goto (reg continue))
;after-if5
;after-lambda2
;  (perform (op define-variable!) (const factorial) (reg val) (reg env))
;  (assign val (const ok))

;; d.

(define (spread-accumulator operator operands)
  (cond ((null? operands)
	 (empty-instruction-sequence))
    (else
      (let ((seq (compile (car operands) 'arg2 'next)))
	(preserving '(env)
		    (if (modifies-register? seq 'arg1)
		      (make-instruction-sequence
			(list-union (registers-needed seq) '(arg1))
			(list-difference (registers-modified seq) '(arg1))
			`((save arg1) ,seq (restore arg1)))
		      seq)
		    (append-instruction-sequences
		      (make-instruction-sequence '(arg2) '(arg1)
						 `((assign arg1 (op ,operator) (reg arg1) (reg arg2))))
		      (spread-accumulator operator (cdr operands))))))))

(define (compile-open-code exp target linkage)
  (let ((p-operator (operator exp))
	(p-operands (operands exp)))
    (end-with-linkage linkage
		      (cond ((= (length p-operands) 2)
			     (append-instruction-sequences
			       (spread-arguments p-operands)
			       (make-instruction-sequence '(arg1 arg2) '(val)
							  `((assign val (op ,p-operator) (reg arg1) (reg arg2))))))
			((and (memq p-operator '(* +)) (> (length p-operands) 2))
			 (append-instruction-sequences
			   (compile (car p-operands) 'arg1 'next)
			   (spread-accumulator p-operator (cdr p-operands))
			   (make-instruction-sequence '(arg1) '(val) '((assign val (reg arg1))))))
			(else
			  (error "cannot support the number of operands -- COMPILE" exp))))))

;; 引数が3つのとき
(parse-compiled-code
  (compile
    '(define (f x)
       (* x 1 2 3)
       (+ x 1 2 3))
    'val
    'next))

;(env)
;(val)
;  (assign val (op make-compiled-procedure) (label entry3) (reg env))
;  (goto (label after-lambda4))
;entry3
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (x)) (reg argl) (reg env))
;  (assign arg1 (op lookup-variable-value) (const x) (reg env))
;  (assign arg2 (const 1))
;  (assign arg1 (op *) (reg arg1) (reg arg2))
;  (assign arg2 (const 2))
;  (assign arg1 (op *) (reg arg1) (reg arg2))
;  (assign arg2 (const 3))
;  (assign arg1 (op *) (reg arg1) (reg arg2))
;  (assign val (reg arg1))
;  (assign arg1 (op lookup-variable-value) (const x) (reg env))
;  (assign arg2 (const 1))
;  (assign arg1 (op +) (reg arg1) (reg arg2))
;  (assign arg2 (const 2))
;  (assign arg1 (op +) (reg arg1) (reg arg2))
;  (assign arg2 (const 3))
;  (assign arg1 (op +) (reg arg1) (reg arg2))
;  (assign val (reg arg1))
;  (goto (reg continue))
;after-lambda4
;  (perform (op define-variable!) (const f) (reg val) (reg env))
;  (assign val (const ok))

;; 引数が2つのとき
(parse-compiled-code
  (compile
    '(define (f x)
       (* x 1)
       (+ x 1))
    'val
    'next))

;(env)
;(val)
;  (assign val (op make-compiled-procedure) (label entry1) (reg env))
;  (goto (label after-lambda2))
;entry1
;  (assign env (op compiled-procedure-env) (reg proc))
;  (assign env (op extend-environment) (const (x)) (reg argl) (reg env))
;  (assign arg1 (op lookup-variable-value) (const x) (reg env))
;  (assign arg2 (const 1))
;  (assign val (op *) (reg arg1) (reg arg2))
;  (assign arg1 (op lookup-variable-value) (const x) (reg env))
;  (assign arg2 (const 1))
;  (assign val (op +) (reg arg1) (reg arg2))
;  (goto (reg continue))
;after-lambda2
;  (perform (op define-variable!) (const f) (reg val) (reg env))
;  (assign val (const ok))

