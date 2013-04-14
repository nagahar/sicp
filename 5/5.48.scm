;; メモ
;; 積極制御評価器は実行時の変数評価において、primitive-proceduresを使用している
;;
;; 上記より、compile-and-runをprimitive-proceduresに追加すれば実行時に評価される
;; compile-and-runで積極制御評価器を再スタートさせれば追加翻訳を実行できる

(load "../explicit-control_evaluator2.scm")

(define (compile-and-run expression)
  (let ((instructions
	  (assemble (statements
		      (compile expression 'val 'return))
		    eceval)))
    (set-register-contents! eceval 'val instructions)
    (set-register-contents! eceval 'flag true)
    (start eceval)))

(define primitive-procedures
  (list (list 'car car)
	(list 'cdr cdr)
	(list 'cons cons)
	(list 'null? null?)
	(list 'assoc assoc)
	(list 'cadr cadr)
	(list 'display display)
	(list 'print print)
	(list 'not not)
	(list '+ +)
	(list '- -)
	(list '* *)
	(list '/ /)
	(list '= =)
	(list '< <)
	(list '> >)
	(list '<= <=)
	(list '>= >=)
	;; 基本手続きが続く
	;; change
	(list 'compile-and-run compile-and-run)
	))

;; primitive-proceduresを追加したので環境を再構築する
(set! the-global-environment (setup-environment))

(define (start-eceval)
  (set-register-contents! eceval 'flag false)
  (start eceval))

(start-eceval)

;;;; EC-Eval2 input:
;(compile-and-run
; '(define (factorial n)
;    (if (= n 1)
;        1
;        (* (factorial (- n 1)) n))))
;
;(total-pushes = 0 maximum-depth = 0)
;;;; EC-Eval2 value:
;ok
;
;;;; EC-Eval2 input:
;(factorial 5)
;
;(total-pushes = 35 maximum-depth = 14)
;;;; EC-Eval2 value:
;120
;
;;;; EC-Eval2 input:
;(define (factorial n)
;    (if (= n 1)
;        1
;        (* (factorial (- n 1)) n)))
;
;(total-pushes = 3 maximum-depth = 3)
;;;; EC-Eval2 value:
;ok
;
;;;; EC-Eval2 input:
;(factorial 5)
;
;(total-pushes = 144 maximum-depth = 28)
;;;; EC-Eval2 value:
;120

