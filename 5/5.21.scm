(load "../simulator.scm")

(define x (cons (list 1 2) (list 3 4)))

;; a.
;(define (count-leaves tree)
;  (cond ((null? tree) 0)
;    ((not (pair? tree)) 1)
;    (else (+ (count-leaves (car tree))
;	     (count-leaves (cdr tree))))))

(define count-leaves-machine-a
  (make-machine
    '(tree continue val val-cdr)
    (list (list '+ +) (list 'null? null?) (list 'pair? pair?) (list 'car car) (list 'cdr cdr))
    '((assign continue (label count-done))
      count-loop
      (test (op null?) (reg tree))
      (branch (label base-case))
      (test (op pair?) (reg tree))
      (branch (label before-count))
      (assign val (const 1))
      (goto (reg continue))
      before-count
      (save continue)
      (save tree)
      (assign tree (op car) (reg tree))
      (assign continue (label after-car-count))
      (goto (label count-loop))
      after-car-count
      (restore tree)
      (assign tree (op cdr) (reg tree))
      (assign continue (label after-cdr-count))
      (save val)
      (goto (label count-loop))
      after-cdr-count
      (assign val-cdr (reg val))
      (restore val)
      (assign val (op +) (reg val) (reg val-cdr))
      (restore continue)
      (goto (reg continue))
      base-case
      (assign val (const 0))
      (goto (reg continue))
      count-done)))

(set-register-contents! count-leaves-machine-a 'tree (list x x))
(count-leaves-machine-a 'trace-on)
(start count-leaves-machine-a)
(get-register-contents count-leaves-machine-a 'val)

;;b.
;(define (count-leaves tree)
;  (define (count-iter tree n)
;    (cond ((null? tree) n)
;      ((not (pair? tree)) (+ n 1))
;      (else (count-iter (cdr tree)
;			(count-iter (car tree) n)))))
;  (count-iter tree 0))

(define count-leaves-machine-b
  (make-machine
    '(tree continue val)
    (list (list '+ +) (list 'null? null?) (list 'pair? pair?) (list 'car car) (list 'cdr cdr))
    '((assign continue (label count-done))
      (assign val (const 0))
      count-loop
      (test (op null?) (reg tree))
      (branch (label base-case))
      (test (op pair?) (reg tree))
      (branch (label before-count))
      (assign val (op +) (reg val) (const 1))
      (goto (reg continue))
      before-count
      (save continue)
      (save tree)
      (assign tree (op car) (reg tree))
      (assign continue (label after-car-count))
      (goto (label count-loop))
      after-car-count
      (restore tree)
      (restore continue)
      (assign tree (op cdr) (reg tree))
      (goto (label count-loop))
      base-case
      (goto (reg continue))
      count-done)))

(set-register-contents! count-leaves-machine-b 'tree (list x x))
(count-leaves-machine-b 'trace-on)
(start count-leaves-machine-b)
(get-register-contents count-leaves-machine-b 'val)

