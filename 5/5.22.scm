(load "../simulator.scm")

(define x '(1 2))
(define y '(3 4))

;(define (append x y)
;  (if (null? x)
;    y
;    (cons (car x) (append (cdr x) y))))

(define append-machine
  (make-machine
    '(x y tmp continue val)
    (list (list 'null? null?) (list 'car car) (list 'cdr cdr) (list 'cons cons))
    '((assign continue (label append-done))
      (assign val (reg y))
      append-loop
      (test (op null?) (reg x))
      (branch (label base-case))
      (save continue)
      (save x)
      (assign x (op cdr) (reg x))
      (assign continue (label after))
      (goto (label append-loop))
      after
      (restore x)
      (restore continue)
      (assign tmp (op car) (reg x))
      (assign val (op cons) (reg tmp) (reg val))
      (goto (reg continue))
      base-case
      (assign val (reg y))
      (goto (reg continue))
      append-done)))

;(set-register-contents! append-machine 'x x)
;(set-register-contents! append-machine 'y y)
;;(append-machine 'trace-on)
;(start append-machine)
;(get-register-contents append-machine 'val)
;(get-register-contents append-machine 'x)
;(get-register-contents append-machine 'y)

;(define (append! x y)
;  (set-cdr! (last-pair x) y)
;  x)
;(define (last-pair x)
;  (if (null? (cdr x))
;    x
;    (last-pair (cdr x))))

(define append!-machine
  (make-machine
    '(x y tmp continue val)
    (list (list 'null? null?) (list 'car car) (list 'cdr cdr) (list 'cons cons) (list 'set-cdr! set-cdr!))
    '((assign continue (label after))
      (save x)
      (goto (label last-pair))
      after
      (restore x)
      (perform (op set-cdr!) (reg val) (reg y))
      (goto (label append!-done))
      last-pair
      (assign tmp (op cdr) (reg x))
      (test (op null?) (reg tmp))
      (branch (label base-case))
      (assign x (reg tmp))
      (goto (label last-pair))
      base-case
      (assign val (reg x))
      (goto (reg continue))
      append!-done)))

(set-register-contents! append!-machine 'x x)
(set-register-contents! append!-machine 'y y)
;(append!-machine 'trace-on)
(start append!-machine)
(get-register-contents append!-machine 'x)
(get-register-contents append!-machine 'y)

