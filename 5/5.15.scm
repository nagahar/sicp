(load "../simulator.scm")

(define (make-new-machine)
  (let ((pc (make-register 'pc))
	(flag (make-register 'flag))
	(stack (make-stack))
	(the-instruction-sequence '())
	(number-inst 0))
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
	  (if (null? insts)
	    'done
	    (begin
	      ((instruction-execution-proc (car insts)))
	      (set! number-inst (+ 1 number-inst))
	      (execute)))))
      (define (reset-count)
	(set! number-inst 0))
      (define (dispatch message)
	(cond ((eq? message 'start)
	       (stack 'reset-statistics)
	       (reset-count)
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
	  (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(define (calc-it machine in-value in-register out-register)
  (set-register-contents! machine in-register in-value)
  (start machine)
  (format #t "in:~2d => out:~10d"
	  (get-register-contents machine in-register)
	  (get-register-contents machine out-register))
  ((machine 'stack) 'print-statistics)
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
	(calc-it fact-machine m 'n 'val)
	(fact-iter (+ m 1)))
      'done))
  (fact-iter 1))

(fact-to 10)

;in: 1 => out:         1
;# of instructions:         8
;(total-pushes = 0 maximum-depth = 0)
;in: 2 => out:         2
;# of instructions:        21
;(total-pushes = 2 maximum-depth = 2)
;in: 3 => out:         6
;# of instructions:        34
;(total-pushes = 4 maximum-depth = 4)
;in: 4 => out:        24
;# of instructions:        47
;(total-pushes = 6 maximum-depth = 6)
;in: 5 => out:       120
;# of instructions:        60
;(total-pushes = 8 maximum-depth = 8)
;in: 6 => out:       720
;# of instructions:        73
;(total-pushes = 10 maximum-depth = 10)
;in: 7 => out:      5040
;# of instructions:        86
;(total-pushes = 12 maximum-depth = 12)
;in: 8 => out:     40320
;# of instructions:        99
;(total-pushes = 14 maximum-depth = 14)
;in: 9 => out:    362880
;# of instructions:       112
;(total-pushes = 16 maximum-depth = 16)

