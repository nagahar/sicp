(load "../explicit-control_evaluator2.scm")

(define input-prompt ";;; R-Eval input:")
(define output-prompt ";;; R-Eval value:")

(define (make-new-machine)
  (let ((pc (make-register 'pc))
	(flag (make-register 'flag))
	(stack (make-stack))
	(the-instruction-sequence '())
	(number-inst 0)
	(trace-mode #f)
	(current-label '())
	(breakpoints '())
	(currentpoints '())
	(label-distance 0))
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
	  (cond ((null? insts)
		 'done)
	    (else
	      (cond ((equal? (caaar insts) 'label)
		     (set! current-label (cadaar insts))
		     (set! number-inst (- number-inst 1))
		     (let ((points (filter
				     (lambda (p) (equal? current-label (car p)))
				     breakpoints)))
		       (set! currentpoints (sort points (lambda (x y) (< (cadr x) (cadr y)))))
		       (set! label-distance 0))))
	      (cond (trace-mode
		      (format #t "label: ~a\n" current-label)
		      (format #t "instruction: ~a\n" (caar insts))
		      ))
	      (cond ((and (not (null? currentpoints)) (= (cadar currentpoints) label-distance))
		     (format #t "break: label ~a + ~d\n"
			     current-label label-distance)
		     (print "******* BREAK *******")
		     'mybreak)
		(else
		  ((instruction-execution-proc (car insts)))
		  (set! number-inst (+ 1 number-inst))
		  (set! label-distance (+ 1 label-distance))
		  (execute)))))))
      (define (reset-currentpoints)
	(set! currentpoints (cdr currentpoints)))
      (define (reset-count)
	(set! number-inst 0))
      (define (reset-label)
	(set! current-label '()))
      (define (trace-on)
	(set! trace-mode #t)
	;(for-each
	;  (lambda (register)
	;    (if (not (or (equal? (car register) 'pc)
	;	       (equal? (car register) 'flag)))
	;      ((cadr register) 'trace-on)))
	;  register-table)
	)
      (define (trace-off)
	(set! trace-mode #f))
      (define (set-breakpoint label n)
	(set! breakpoints (cons (list label n) breakpoints)))
      (define (cancel-breakpoint label n)
	(set! breakpoints (delete (list label n) breakpoints)))
      (define (cancel-all-breakpoint)
	(set! breakpoints '()))
      (define (driver-loop self)
	(stack 'initialize)
	(prompt-for-input input-prompt)
	(let ((expression (read)))
	  (let ((instructions
		  (assemble (statements
			      (compile expression 'val 'next))
			    self)))
	    (set-contents! (lookup-register 'env) the-global-environment)
	    (set! the-instruction-sequence instructions)
	    (start)
	    (stack 'print-statistics)
	    (announce-output output-prompt)
	    (user-print (get-contents (lookup-register 'val)))
	    ))
	(driver-loop self))
      (define (start)
	(stack 'reset-statistics)
	(reset-count)
	(reset-label)
	(set-contents! pc the-instruction-sequence)
	(execute))
      (define (dispatch message)
	(cond ((eq? message 'start) (start))
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
	  ((eq? message 'set-breakpoint) set-breakpoint)
	  ((eq? message 'proceed) (reset-currentpoints) (execute))
	  ((eq? message 'cancel-breakpoint) cancel-breakpoint)
	  ((eq? message 'cancel-all-breakpoint) (cancel-all-breakpoint))
	  ((eq? message 'driver-loop) driver-loop)
	  (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(define repl-register
  (make-machine
    '(env val proc argl continue compapp)
    eceval-operations
    '()))

((repl-register 'driver-loop) repl-register)

;;;; R-Eval input:
;(define (factorial n)
;    (if (= n 1)
;        1
;        (* (factorial (- n 1)) n)))
;
;(total-pushes = 0 maximum-depth = 0)
;;;; R-Eval value:
;ok
;
;;;; R-Eval input:
;(factorial 5)
;
;(total-pushes = 30 maximum-depth = 14)
;;;; R-Eval value:
;120

