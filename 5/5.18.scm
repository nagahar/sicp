(load "../simulator.scm")

(define (make-register name)
  (let ((contents '*unassigned*)
	(trace-mode #f))
    (define (trace-on)
      (set! trace-mode #t))
    (define (trace-off)
      (set! trace-mode #f))
    (define (dispatch message)
      (cond ((eq? message 'get) contents)
	((eq? message 'set) (lambda (value)
			      (cond (trace-mode
				      (format #t "register ~a: ~a => ~a" name contents value)
				      (newline)))
			      (set! contents value)))
	((eq? message 'trace-on) (trace-on))
	((eq? message 'trace-off) (trace-off))
	(else
	  (error "Unknown request -- REGISTER" message))))
    dispatch))

(define (make-new-machine)
  (let ((pc (make-register 'pc))
	(flag (make-register 'flag))
	(stack (make-stack))
	(the-instruction-sequence '())
	(number-inst 0)
	(trace-mode #f)
	(current-label '()))
    (let ((the-ops
	    (list
	      (list 'initialize-stack
		    (lambda () (stack 'initialize)))
	      (list 'print-stack-statistics
		    (lambda () (stack 'print-statistics)))))
	  (register-table
	    (list (list 'pc pc) (list 'flag flag))))
      (define (allocate-register name)
	(if (assoc name register-table)
	  (error "Multiply defined register: " name)
	  (set! register-table
	    (cons (list name (make-register name))
		  register-table)))
	'register-allocated)
      (define (lookup-register name)
	(let ((val (assoc name register-table)))
	  (if val
	    (cadr val)
	    (error "Unknown register:" name))))
      (define (execute)
	(let ((insts (get-contents pc)))
	  (cond ((null? insts) 'done)
	    (else
	      (cond ((equal? (caaar insts) 'label)
		       (set! current-label (cadaar insts))
		       (set! number-inst (- number-inst 1)))
		  (trace-mode
		    (format #t "label: ~a" current-label)
		    (newline)
		    (format #t "instruction: ~a" (caar insts))
		    (newline)))
	      ((instruction-execution-proc (car insts)))
	      (set! number-inst (+ 1 number-inst))
	      (execute)))))
      (define (reset-count)
	(set! number-inst 0))
      (define (reset-label)
	(set! current-label '()))
      (define (trace-on)
	(set! trace-mode #t)
	(for-each
	  (lambda (register)
	    (if (not (or (equal? (car register) 'pc)
		       (equal? (car register) 'flag)))
	      ((cadr register) 'trace-on)))
	  register-table))
      (define (trace-off)
	(set! trace-mode #f))
      (define (dispatch message)
	(cond ((eq? message 'start)
	       (stack 'reset-statistics)
	       (reset-count)
	       (reset-label)
	       (set-contents! pc the-instruction-sequence)
	       (execute))
	  ((eq? message 'install-instruction-sequence)
	   (lambda (seq) (set! the-instruction-sequence seq)))
	  ((eq? message 'allocate-register) allocate-register)
	  ((eq? message 'get-register) lookup-register)
	  ((eq? message 'install-operations)
	   (lambda (ops) (set! the-ops (append the-ops ops))))
	  ((eq? message 'stack) stack)
	  ((eq? message 'operations) the-ops)
	  ((eq? message 'reset-count) (reset-count))
	  ((eq? message 'get-count) number-inst)
	  ((eq? message 'trace-on) (trace-on))
	  ((eq? message 'trace-off) (trace-off))
	  (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(define (extract-labels text receive)
  (if (null? text)
    (receive '() '())
    (extract-labels (cdr text)
		    (lambda (insts labels)
		      (let ((next-inst (car text)))
			(if (symbol? next-inst)
			  (let ((inst-label (cons (make-instruction
						    (list 'label next-inst))
						  insts)))
			    (receive inst-label
			      (cons (make-label-entry next-inst
						      inst-label)
				    labels)))
			  (receive (cons (make-instruction next-inst)
					 insts)
			    labels)))))))

(define (make-execution-procedure inst labels machine
				  pc flag stack ops)
  (cond ((eq? (car inst) 'assign)
	 (make-assign inst machine labels ops pc))
    ((eq? (car inst) 'test)
     (make-test inst machine labels ops flag pc))
    ((eq? (car inst) 'branch)
     (make-branch inst machine labels flag pc))
    ((eq? (car inst) 'goto)
     (make-goto inst machine labels pc))
    ((eq? (car inst) 'save)
     (make-save inst machine stack pc))
    ((eq? (car inst) 'restore)
     (make-restore inst machine stack pc))
    ((eq? (car inst) 'perform)
     (make-perform inst machine labels ops pc))
    ((eq? (car inst) 'label)
     (make-label pc))
    (else (error "Unknown instruction type -- ASSEMBLE"
		 inst))))

(define (make-label pc)
  (lambda ()
    (advance-pc pc)))

(define (trace-it machine in-value in-register out-register)
  (set-register-contents! machine in-register in-value)
  (machine 'trace-on)
  (start machine)
  (machine 'trace-off)
  (format #t "in:~2d => out:~10d"
	  (get-register-contents machine in-register)
	  (get-register-contents machine out-register))
  (newline))

(define fact-machine
  (make-machine
    '(n continue val)
    (list (list '= =) (list '- -) (list '* *))
    '((assign continue (label fact-done))
      fact-loop
      (test (op =) (reg n) (const 1))
      (branch (label base-case))
      (save continue)
      (save n)
      (assign n (op -) (reg n) (const 1))
      (assign continue (label after-fact))
      (goto (label fact-loop))
      after-fact
      (restore n)
      (restore continue)
      (assign val (op *) (reg n) (reg val))
      (goto (reg continue))
      base-case
      (assign val (const 1))
      (goto (reg continue))
      fact-done)))

(define (fact-to n)
  (define (fact-iter m)
    (if (< m n)
      (begin
	(trace-it fact-machine m 'n 'val)
	(fact-iter (+ m 1)))
      'done))
  (fact-iter 1))

(fact-to 4)

;label: ()
;instruction: (assign continue (label fact-done))
;register continue: *unassigned* => (((label fact-done) . #<closure (make-label make-label)>))
;label: fact-loop
;instruction: (test (op =) (reg n) (const 1))
;label: fact-loop
;instruction: (branch (label base-case))
;label: base-case
;instruction: (assign val (const 1))
;register val: *unassigned* => 1
;label: base-case
;instruction: (goto (reg continue))
;in: 1 => out:         1
;register n: 1 => 2
;label: ()
;instruction: (assign continue (label fact-done))
;register continue: (((label fact-done) . #<closure (make-label make-label)>)) => (((label fact-done) . #<closure (make-label make-label)>))
;label: fact-loop
;instruction: (test (op =) (reg n) (const 1))
;label: fact-loop
;instruction: (branch (label base-case))
;label: fact-loop
;instruction: (save continue)
;label: fact-loop
;instruction: (save n)
;label: fact-loop
;instruction: (assign n (op -) (reg n) (const 1))
;register n: 2 => 1
;label: fact-loop
;instruction: (assign continue (label after-fact))
;register continue: (((label fact-done) . #<closure (make-label make-label)>)) => (((label after-fact) . #<closure (make-label make-label)>) ((restore n) . #<closure (make-restore make-restore)>) ((restore continue) . #<closure (make-restore make-restore)>) ((assign val (op *) (reg n) (reg val)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label base-case) . #<closure (make-label make-label)>) ((assign val (const 1)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label fact-done) . #<closure (make-label make-label)>))
;label: fact-loop
;instruction: (goto (label fact-loop))
;label: fact-loop
;instruction: (test (op =) (reg n) (const 1))
;label: fact-loop
;instruction: (branch (label base-case))
;label: base-case
;instruction: (assign val (const 1))
;register val: 1 => 1
;label: base-case
;instruction: (goto (reg continue))
;label: after-fact
;instruction: (restore n)
;register n: 1 => 2
;label: after-fact
;instruction: (restore continue)
;register continue: (((label after-fact) . #<closure (make-label make-label)>) ((restore n) . #<closure (make-restore make-restore)>) ((restore continue) . #<closure (make-restore make-restore)>) ((assign val (op *) (reg n) (reg val)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label base-case) . #<closure (make-label make-label)>) ((assign val (const 1)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label fact-done) . #<closure (make-label make-label)>)) => (((label fact-done) . #<closure (make-label make-label)>))
;label: after-fact
;instruction: (assign val (op *) (reg n) (reg val))
;register val: 1 => 2
;label: after-fact
;instruction: (goto (reg continue))
;in: 2 => out:         2
;register n: 2 => 3
;label: ()
;instruction: (assign continue (label fact-done))
;register continue: (((label fact-done) . #<closure (make-label make-label)>)) => (((label fact-done) . #<closure (make-label make-label)>))
;label: fact-loop
;instruction: (test (op =) (reg n) (const 1))
;label: fact-loop
;instruction: (branch (label base-case))
;label: fact-loop
;instruction: (save continue)
;label: fact-loop
;instruction: (save n)
;label: fact-loop
;instruction: (assign n (op -) (reg n) (const 1))
;register n: 3 => 2
;label: fact-loop
;instruction: (assign continue (label after-fact))
;register continue: (((label fact-done) . #<closure (make-label make-label)>)) => (((label after-fact) . #<closure (make-label make-label)>) ((restore n) . #<closure (make-restore make-restore)>) ((restore continue) . #<closure (make-restore make-restore)>) ((assign val (op *) (reg n) (reg val)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label base-case) . #<closure (make-label make-label)>) ((assign val (const 1)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label fact-done) . #<closure (make-label make-label)>))
;label: fact-loop
;instruction: (goto (label fact-loop))
;label: fact-loop
;instruction: (test (op =) (reg n) (const 1))
;label: fact-loop
;instruction: (branch (label base-case))
;label: fact-loop
;instruction: (save continue)
;label: fact-loop
;instruction: (save n)
;label: fact-loop
;instruction: (assign n (op -) (reg n) (const 1))
;register n: 2 => 1
;label: fact-loop
;instruction: (assign continue (label after-fact))
;register continue: (((label after-fact) . #<closure (make-label make-label)>) ((restore n) . #<closure (make-restore make-restore)>) ((restore continue) . #<closure (make-restore make-restore)>) ((assign val (op *) (reg n) (reg val)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label base-case) . #<closure (make-label make-label)>) ((assign val (const 1)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label fact-done) . #<closure (make-label make-label)>)) => (((label after-fact) . #<closure (make-label make-label)>) ((restore n) . #<closure (make-restore make-restore)>) ((restore continue) . #<closure (make-restore make-restore)>) ((assign val (op *) (reg n) (reg val)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label base-case) . #<closure (make-label make-label)>) ((assign val (const 1)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label fact-done) . #<closure (make-label make-label)>))
;label: fact-loop
;instruction: (goto (label fact-loop))
;label: fact-loop
;instruction: (test (op =) (reg n) (const 1))
;label: fact-loop
;instruction: (branch (label base-case))
;label: base-case
;instruction: (assign val (const 1))
;register val: 2 => 1
;label: base-case
;instruction: (goto (reg continue))
;label: after-fact
;instruction: (restore n)
;register n: 1 => 2
;label: after-fact
;instruction: (restore continue)
;register continue: (((label after-fact) . #<closure (make-label make-label)>) ((restore n) . #<closure (make-restore make-restore)>) ((restore continue) . #<closure (make-restore make-restore)>) ((assign val (op *) (reg n) (reg val)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label base-case) . #<closure (make-label make-label)>) ((assign val (const 1)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label fact-done) . #<closure (make-label make-label)>)) => (((label after-fact) . #<closure (make-label make-label)>) ((restore n) . #<closure (make-restore make-restore)>) ((restore continue) . #<closure (make-restore make-restore)>) ((assign val (op *) (reg n) (reg val)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label base-case) . #<closure (make-label make-label)>) ((assign val (const 1)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label fact-done) . #<closure (make-label make-label)>))
;label: after-fact
;instruction: (assign val (op *) (reg n) (reg val))
;register val: 1 => 2
;label: after-fact
;instruction: (goto (reg continue))
;label: after-fact
;instruction: (restore n)
;register n: 2 => 3
;label: after-fact
;instruction: (restore continue)
;register continue: (((label after-fact) . #<closure (make-label make-label)>) ((restore n) . #<closure (make-restore make-restore)>) ((restore continue) . #<closure (make-restore make-restore)>) ((assign val (op *) (reg n) (reg val)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label base-case) . #<closure (make-label make-label)>) ((assign val (const 1)) . #<closure (make-assign make-assign)>) ((goto (reg continue)) . #<closure (make-goto make-goto)>) ((label fact-done) . #<closure (make-label make-label)>)) => (((label fact-done) . #<closure (make-label make-label)>))
;label: after-fact
;instruction: (assign val (op *) (reg n) (reg val))
;register val: 2 => 6
;label: after-fact
;instruction: (goto (reg continue))
;in: 3 => out:         6
