;;;; 5.2.1 計算機モデル
(define (make-machine register-names ops controller-text)
  (let ((machine (make-new-machine)))
    (for-each (lambda (register-name)
		((machine 'allocate-register) register-name))
	      register-names)
    ((machine 'install-operations) ops)
    ((machine 'install-instruction-sequence)
     (assemble controller-text machine))
    machine))

;; レジスタ
;; 5.14-5.19
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
			      (if trace-mode
				(format #t "register ~a: ~a => ~a\n" name contents value))
			      (set! contents value)))
	((eq? message 'trace-on) (trace-on))
	((eq? message 'trace-off) (trace-off))
	(else
	  (error "Unknown request -- REGISTER" message))))
    dispatch))

(define (get-contents register)
  (register 'get))

(define (set-contents! register value)
  ((register 'set) value))

;; スタック 5.14
;; 5.14-5.19
(define (make-stack)
  (let ((s '())
	(number-pushes 0)
	(max-depth 0)
	(current-depth 0))
    (define (push x)
      (set! s (cons x s))
      (set! number-pushes (+ 1 number-pushes))
      (set! current-depth (+ 1 current-depth))
      (set! max-depth (max current-depth max-depth)))
    (define (pop)
      (if (null? s)
	(error "Empty stack -- POP")
	(let ((top (car s)))
	  (set! s (cdr s))
	  (set! current-depth (- current-depth 1))
	  top)))
    (define (initialize)
      (set! s '())
      (set! number-pushes 0)
      (set! max-depth 0)
      (set! current-depth 0)
      'done)
    (define (print-statistics)
      (newline)
      (display (list 'total-pushes  '= number-pushes
		     'maximum-depth '= max-depth)))
    (define (reset-statistics)
      (set! number-pushes 0)
      (set! max-depth 0)
      (set! current-depth 0))
    (define (dispatch message)
      (cond ((eq? message 'push) push)
	((eq? message 'pop) (pop))
	((eq? message 'initialize) (initialize))
	((eq? message 'print-statistics)
	 (print-statistics))
	((eq? message 'reset-statistics) (reset-statistics))
	(else
	  (error "Unknown request -- STACK" message))))
    dispatch))

(define (pop stack)
  (stack 'pop))
(define (push stack value)
  ((stack 'push) value))

;; 基本計算機 5.14
;; 5.14-5.19
(use srfi-1)
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
		     ;; for breakpoint
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
	  ((eq? message 'set-breakpoint) set-breakpoint)
	  ((eq? message 'proceed) (reset-currentpoints) (execute))
	  ((eq? message 'cancel-breakpoint) cancel-breakpoint)
	  ((eq? message 'cancel-all-breakpoint) (cancel-all-breakpoint))
	  (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(define (start machine)
  (machine 'start))

(define (get-register-contents machine register-name)
  (get-contents (get-register machine register-name)))

(define (set-register-contents! machine register-name value)
  (set-contents! (get-register machine register-name) value)
  'done)

(define (get-register machine reg-name)
  ((machine 'get-register) reg-name))

;;;; 5.2.2 アセンブラ
(define (assemble controller-text machine)
  (extract-labels controller-text
		  (lambda (insts labels)
		    (update-insts! insts labels machine)
		    insts)))

;; 5.14-5.19
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

(define (update-insts! insts labels machine)
  (let ((pc (get-register machine 'pc))
	(flag (get-register machine 'flag))
	(stack (machine 'stack))
	(ops (machine 'operations)))
    (for-each
      (lambda (inst)
	(set-instruction-execution-proc!
	  inst
	  (make-execution-procedure
	    (instruction-text inst) labels machine
	    pc flag stack ops)))
      insts)))

(define (make-instruction text)
  (cons text '()))

(define (instruction-text inst)
  (car inst))

(define (instruction-execution-proc inst)
  (cdr inst))

(define (set-instruction-execution-proc! inst proc)
  (set-cdr! inst proc))

(define (make-label-entry label-name insts)
  (cons label-name insts))

(define (lookup-label labels label-name)
  (let ((val (assoc label-name labels)))
    (if val
      (cdr val)
      (error "Undefined label -- ASSEMBLE" label-name))))

;;;; 5.2.3 命令の実行手続きの生成
;; 5.14-5.19
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
     (make-label-inst pc))
    (else (error "Unknown instruction type -- ASSEMBLE"
		 inst))))

;; assign 命令
(define (make-assign inst machine labels operations pc)
  (let ((target
	  (get-register machine (assign-reg-name inst)))
	(value-exp (assign-value-exp inst)))
    (let ((value-proc
	    (if (operation-exp? value-exp)
	      (make-operation-exp
		value-exp machine labels operations)
	      (make-primitive-exp
		(car value-exp) machine labels))))
      (lambda () ; assign の実行手続き
	(set-contents! target (value-proc))
	(advance-pc pc)))))

(define (assign-reg-name assign-instruction)
  (cadr assign-instruction))

(define (assign-value-exp assign-instruction)
  (cddr assign-instruction))

(define (advance-pc pc)
  (set-contents! pc (cdr (get-contents pc))))

;; test 命令
(define (make-test inst machine labels operations flag pc)
  (let ((condition (test-condition inst)))
    (if (operation-exp? condition)
      (let ((condition-proc
	      (make-operation-exp
		condition machine labels operations)))
	(lambda ()
	  (set-contents! flag (condition-proc))
	  (advance-pc pc)))
      (error "Bad TEST instruction -- ASSEMBLE" inst))))

(define (test-condition test-instruction)
  (cdr test-instruction))

;; branch 命令
(define (make-branch inst machine labels flag pc)
  (let ((dest (branch-dest inst)))
    (if (label-exp? dest)
      (let ((insts
	      (lookup-label labels (label-exp-label dest))))
	(lambda ()
	  (if (get-contents flag)
	    (set-contents! pc insts)
	    (advance-pc pc))))
      (error "Bad BRANCH instruction -- ASSEMBLE" inst))))

(define (branch-dest branch-instruction)
  (cadr branch-instruction))

;; goto 命令
(define (make-goto inst machine labels pc)
  (let ((dest (goto-dest inst)))
    (cond ((label-exp? dest)
	   (let ((insts
		   (lookup-label labels
				 (label-exp-label dest))))
	     (lambda () (set-contents! pc insts))))
      ((register-exp? dest)
       (let ((reg
	       (get-register machine
			     (register-exp-reg dest))))
	 (lambda ()
	   (set-contents! pc (get-contents reg)))))
      (else (error "Bad GOTO instruction -- ASSEMBLE"
		   inst)))))

(define (goto-dest goto-instruction)
  (cadr goto-instruction))

;; その他の命令
(define (make-save inst machine stack pc)
  (let ((reg (get-register machine
			   (stack-inst-reg-name inst))))
    (lambda ()
      (push stack (get-contents reg))
      (advance-pc pc))))

(define (make-restore inst machine stack pc)
  (let ((reg (get-register machine
			   (stack-inst-reg-name inst))))
    (lambda ()
      (set-contents! reg (pop stack))
      (advance-pc pc))))

(define (stack-inst-reg-name stack-instruction)
  (cadr stack-instruction))

(define (make-perform inst machine labels operations pc)
  (let ((action (perform-action inst)))
    (if (operation-exp? action)
      (let ((action-proc
	      (make-operation-exp
		action machine labels operations)))
	(lambda ()
	  (action-proc)
	  (advance-pc pc)))
      (error "Bad PERFORM instruction -- ASSEMBLE" inst))))

(define (perform-action inst) (cdr inst))

;; 部分式の実行手続き
(define (make-primitive-exp exp machine labels)
  (cond ((constant-exp? exp)
	 (let ((c (constant-exp-value exp)))
	   (lambda () c)))
    ((label-exp? exp)
     (let ((insts
	     (lookup-label labels
			   (label-exp-label exp))))
       (lambda () insts)))
    ((register-exp? exp)
     (let ((r (get-register machine
			    (register-exp-reg exp))))
       (lambda () (get-contents r))))
    (else
      (error "Unknown expression type -- ASSEMBLE" exp))))

(define (register-exp? exp) (tagged-list? exp 'reg))

(define (register-exp-reg exp) (cadr exp))

(define (constant-exp? exp) (tagged-list? exp 'const))

(define (constant-exp-value exp) (cadr exp))

(define (label-exp? exp) (tagged-list? exp 'label))

(define (label-exp-label exp) (cadr exp))

(define (tagged-list? exp tag)
  (if (pair? exp)
    (eq? (car exp) tag)
    #f))

(define (make-operation-exp exp machine labels operations)
  (let ((op (lookup-prim (operation-exp-op exp) operations))
	(aprocs
	  (map (lambda (e)
		 (make-primitive-exp e machine labels))
	       (operation-exp-operands exp))))
    (lambda ()
      (apply op (map (lambda (p) (p)) aprocs)))))

(define (operation-exp? exp)
  (and (pair? exp) (tagged-list? (car exp) 'op)))

(define (operation-exp-op operation-exp)
  (cadr (car operation-exp)))

(define (operation-exp-operands operation-exp)
  (cdr operation-exp))

(define (lookup-prim symbol operations)
  (let ((val (assoc symbol operations)))
    (if val
      (cadr val)
      (error "Unknown operation -- ASSEMBLE" symbol))))

;; 5.14-5.19
(define (make-label-inst pc)
  (lambda ()
    (advance-pc pc)))

(define (set-breakpoint machine label n)
  ((machine 'set-breakpoint) label n)
  'done)

(define (proceed-machine machine)
  (machine 'proceed))

(define (cancel-breakpoint machine label n)
  ((machine 'cancel-breakpoint) label n)
  'done)

(define (cancel-all-breakpoint machine)
  (machine 'cancel-all-breakpoint)
  'done)

(define (calc-it machine in-value in-register out-register)
  (set-register-contents! machine in-register in-value)
  (format #t "in:~2d\n" (get-register-contents machine in-register))
  (start machine)
  (format #t "=> out:~10d\n" (get-register-contents machine out-register))
  ((machine 'stack) 'print-statistics)
  (newline))

(define (trace-it machine in-value in-register out-register)
  (set-register-contents! machine in-register in-value)
  (format #t "in:~2d\n" (get-register-contents machine in-register))
  (machine 'trace-on)
  (start machine)
  (machine 'trace-off)
  (format #t "=> out:~10d\n" (get-register-contents machine out-register)))

(define (calc-loop from to in-register out-register machine)
  (define (iter m)
    (if (and (<= from m) (<= m to))
      (begin
	(calc-it machine m in-register out-register)
	(iter (+ m 1)))
      'done))
  (iter from))

