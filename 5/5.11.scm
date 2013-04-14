;; a.
;; afterfib-n-2において(restore val)を(restore n)にすれば(assign n (reg val))を除去できる
;(controller
;   (assign continue (label fib-done))
; fib-loop
;   (test (op <) (reg n) (const 2))
;   (branch (label immediate-answer))
;   ;; set up to compute Fib(n - 1)
;   (save continue)
;   (assign continue (label afterfib-n-1))
;   (save n)                           ; save old value of n
;   (assign n (op -) (reg n) (const 1)); clobber n to n - 1
;   (goto (label fib-loop))            ; perform recursive call
; afterfib-n-1                         ; upon return, val contains Fib(n - 1)
;   (restore n)
;   (restore continue)
;   ;; set up to compute Fib(n - 2)
;   (assign n (op -) (reg n) (const 2))
;   (save continue)
;   (assign continue (label afterfib-n-2))
;   (save val)                         ; save Fib(n - 1)
;   (goto (label fib-loop))
; afterfib-n-2                         ; upon return, val contains Fib(n - 2)
;   (assign n (reg val))               ; n now contains Fib(n - 2)
;   (restore val)                      ; val now contains Fib(n - 1)
;   (restore continue)
;   (assign val                        ;  Fib(n - 1) +  Fib(n - 2)
;           (op +) (reg val) (reg n))
;   (goto (reg continue))              ; return to caller, answer is in val
; immediate-answer
;   (assign val (reg n))               ; base case:  Fib(n) = n
;   (goto (reg continue))
; fib-done)

;; b.
;; 正しくrestoreするためには下記のように修正する

(load "../simulator.scm")
(define (make-save inst machine stack pc)
  (let ((reg (get-register machine
			   (stack-inst-reg-name inst))))
    (lambda ()
      (push stack (list (stack-inst-reg-name inst) (get-contents reg)))
      (advance-pc pc))))

(define (make-restore inst machine stack pc)
  (let ((reg (get-register machine
			   (stack-inst-reg-name inst))))
    (lambda ()
      (let ((val (pop stack))
	    (reg-name (stack-inst-reg-name inst)))
	(if (equal? (car val) reg-name)
	  (set-contents! reg val)
	  (error "Bad register name -- ASSEMBLE" reg-name)))
      (advance-pc pc))))

(define test-machine
  (make-machine
    '(a b)
    '()
    '(start
       (assign a (const 1))
       (assign b (const 2))
       (save a)
       (save b)
       (restore a)
       (restore b)
       (goto (label done))
      done)))

;(start test-machine)
;*** ERROR: Bad register name -- ASSEMBLE a

;; c.
;; 下記のようにスタックをレジスタ毎に作成する

(load "../simulator.scm")

(define (make-stack name)
  (let ((s '()))
    (define (push x)
      (set! s (cons x s)))
    (define (pop)
      (if (null? s)
	(error "Empty stack -- POP")
	(let ((top (car s)))
	  (set! s (cdr s))
	  top)))
    (define (initialize)
      (set! s '())
      'done)
    (define (dispatch message)
      (cond ((eq? message 'push) push)
	((eq? message 'pop) (pop))
	((eq? message 'initialize) (initialize))
	((eq? message 'get-name) name)
	(else (error "Unknown request -- STACK"
		     message))))
    dispatch))

(define (get-stack stack name)
  (find (lambda (s) (equal? name (s 'get-name))) stack))

(define (make-new-machine)
  (let ((pc (make-register 'pc))
	(flag (make-register 'flag))
	(stacks '())
	(the-instruction-sequence '()))
    (let ((the-ops '())
	  (register-table
	    (list (list 'pc pc) (list 'flag flag))))
      (define (allocate-register name)
	(if (assoc name register-table)
	  (error "Multiply defined register: " name)
	  (begin
	    (set! register-table
	      (cons (list name (make-register name))
		    register-table))
	    (let ((stack (make-stack name)))
	      (set! stacks (cons stack stacks))
	      (set! the-ops (cons (list 'initialize-stack (lambda () (stack 'initialize)))
				  the-ops)))))
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
	  ((eq? message 'stack) stacks)
	  ((eq? message 'operations) the-ops)
	  ((eq? message 'initialize-stack) initialize-stack)
	  (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

(define (make-save inst machine stack pc)
  (let ((reg-name (stack-inst-reg-name inst)))
    (let ((reg (get-register machine
			     reg-name)))
      (lambda ()
	(push stack reg-name (get-contents reg))
	(advance-pc pc)))))

(define (make-restore inst machine stack pc)
  (let ((reg-name (stack-inst-reg-name inst)))
    (let ((reg (get-register machine
			     reg-name)))
      (lambda ()
	(set-contents! reg (pop stack reg-name))
	(advance-pc pc)))))

(define (pop stack name)
  ((get-stack stack name) 'pop))
(define (push stack name value)
  (((get-stack stack name) 'push) value))

(define test-machine
  (make-machine
    '(a b)
    '()
    '(start
       (assign a (const 1))
       (assign b (const 2))
       (save a)
       (save b)
       (restore a)
       (restore b)
       (goto (label done))
      done)))

(start test-machine)
;(get-register-contents test-machine 'a)
;1
;(get-register-contents test-machine 'b)
;2

