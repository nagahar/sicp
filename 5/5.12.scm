(load "../simulator.scm")
(define (make-analyzer)
  (let ((the-instructions '())
	(the-entry-registers '())
	(the-saved-stored-registers '())
	(the-sources-by-registers '()))
    (define (analyze insts)
      (use srfi-1)
      (set! the-instructions (delete-duplicates insts))
      (set! the-entry-registers (delete-duplicates
				  (map (lambda (inst) (cadadr (car inst)))
				       (filter (lambda (inst) (equal? (caar inst) 'goto)) insts))))
      (set! the-saved-stored-registers (delete-duplicates
					 (map (lambda (inst) (cadar inst))
					      (filter (lambda (inst) (or (equal? (caar inst) 'save) (equal? (caar inst) 'restore))) insts))))
      (set! the-sources-by-registers (fold (lambda (pair result)
					     (let ((sources (assoc (car pair) result)))
					       (if sources
						 (begin
						   (set-cdr! sources (cons (cdr pair) (cdr sources)))
						   result)
						 (set! result (cons (list (car pair) (cdr pair)) result)))))
					   '()
					   (delete-duplicates
					     (map (lambda (inst) (cdar inst))
						  (filter (lambda (inst) (equal? (caar inst) 'assign)) insts))))))
    (define (print-result)
      (display "the-instructions")
      (newline)
      (display the-instructions)
      (newline)
      (display "the-entry-registers")
      (newline)
      (display the-entry-registers)
      (newline)
      (display "the-saved-stored-registers")
      (newline)
      (display the-saved-stored-registers)
      (newline)
      (display "the-sources-by-registers")
      (newline)
      (display the-sources-by-registers)
      (newline))
    (define (dispatch message)
      (cond ((eq? message 'analyze) analyze)
	((eq? message 'display) print-result)
	(else (error "Unknown request -- ANALYZER" message))))
    dispatch))

(define (print-analyzed-result machine)
  (((machine 'analyzer) 'display)))

(define (analyze insts labels machine)
  (((machine 'analyzer) 'analyze) insts))

(define (make-new-machine)
  (let ((pc (make-register 'pc))
	(flag (make-register 'flag))
	(stack (make-stack))
	(analyzer (make-analyzer))
	(the-instruction-sequence '()))
    (let ((the-ops
	    (list
	      (list 'initialize-stack
		    (lambda () (stack 'initialize)))))
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
	      (execute)))))
      (define (dispatch message)
	(cond ((eq? message 'start)
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
	  ((eq? message 'analyzer) analyzer)
	  (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(define (assemble controller-text machine)
  (extract-labels controller-text
		  (lambda (insts labels)
		    (analyze insts labels machine)
		    (update-insts! insts labels machine)
		    insts)))

(define fib-machine
  (make-machine
    '(n continue val)
    (list (list '< <) (list '- -) (list '+ +))
    '((assign continue (label fib-done))
      fib-loop
      (test (op <) (reg n) (const 2))
      (branch (label immediate-answer))
      (save continue)
      (assign continue (label afterfib-n-1))
      (save n)
      (assign n (op -) (reg n) (const 1))
      (goto (label fib-loop))
      afterfib-n-1
      (restore n)
      (restore continue)
      (assign n (op -) (reg n) (const 2))
      (save continue)
      (assign continue (label afterfib-n-2))
      (save val)
      (goto (label fib-loop))
      afterfib-n-2
      (assign n (reg val))
      (restore val)
      (restore continue)
      (assign val
	      (op +) (reg val) (reg n))
      (goto (reg continue))
      immediate-answer
      (assign val (reg n))
      (goto (reg continue))
      fib-done)))

(print-analyzed-result fib-machine)

