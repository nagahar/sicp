(load "../simulator.scm")
;; a.
(define (expt b n)
  (if (= n 0)
    1
    (* b (expt b (- n 1)))))

(define expt-machine
  (make-machine
    '(continue n val b)
    (list (list '- -) (list '* *) (list '= =))
    '((assign continue (label expt-done))
      expt-loop
      (test (op =) (reg n) (const 0))
      (branch (label base-case))
      (save continue)
      (assign n (op -) (reg n) (const 1))
      (assign continue (label after-expt))
      (goto (label expt-loop))
      after-expt
      (restore continue)
      (assign val (op *) (reg b) (reg val))
      (goto (reg continue))
      base-case
      (assign val (const 1))
      (goto (reg continue))
      expt-done)))

;(set-register-contents! expt-machine 'b 2)
;done
;(set-register-contents! expt-machine 'n 3)
;done
;(start expt-machine)
;done
;(get-register-contents expt-machine 'val)
;8

;;; b.
(define (expt b n)
  (define (expt-iter counter product)
    (if (= counter 0)
      product
      (expt-iter (- counter 1) (* b product))))
  (expt-iter n 1))

(define expt-i-machine
  (make-machine
    '(n val b counter product)
    (list (list '- -) (list '* *) (list '= =))
    '((assign counter (reg n))
      (assign product (const 1))
      expt-loop
      (test (op =) (reg counter) (const 0))
      (branch (label expt-done))
      (assign counter (op -) (reg counter) (const 1))
      (assign product (op *) (reg b) (reg product))
      (goto (label expt-loop))
      expt-done)))

;(set-register-contents! expt-i-machine 'b 2)
;done
;(set-register-contents! expt-i-machine 'n 3)
;done
;(start expt-i-machine)
;done
;(get-register-contents expt-i-machine 'product)
;8

