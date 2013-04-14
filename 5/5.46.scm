;; フィボナッチ数Fib(n)(n>=2)の実験結果
;; 翻訳版(下記より)
;; スタックの最大深さ = 3 * n - 1
;; スタックのプッシュ総数 = 10 * Fib(n)
;; (但し、F(n) ~ \frac{\phi^{n}}{\sqrt{5}}, \phi = \frac{1+\sqrt{5}}{2})
;;
;; 解釈版(5.29より)
;; スタックの最大深さ = 5 * n + 3
;; スタックのプッシュ総数 = 56 * Fib(n+1) - 40
;; (但し、F(n) ~ \frac{\phi^{n}}{\sqrt{5}}, \phi = \frac{1+\sqrt{5}}{2})
;;
;; 特殊目的計算機(下記より)
;; スタックの最大深さ = 2 * n - 2
;; スタックのプッシュ総数 = 2 * (n-1) * (n-2) + 4
;;
;; 比較
;; 翻訳版と解釈版の比較
;; スタックの最大深さの比 = (3n-1)/(5n+3)
;; n->infのとき3/5(定数)となる
;; スタックのプッシュ回数の比 = (10Fib(n))/(56Fib(n)-40)
;; n->infのときFib(n)->infとなり、5/28(定数)となる
;;
;; 特殊目的計算機と解釈版の比較
;; スタックの最大深さの比 = (2n-2)/(5n+3)
;; n->infのとき2/5(定数)となる
;; スタックのプッシュ回数の比 = (2(n-1)(n-2))/(56Fib(n)-40)
;; 極限値には近づかない

;; フィボナッチ数の翻訳版の実験
(load "../explicit-control_evaluator2.scm")
(compile-and-go
  '(define (fib n)
     (if (< n 2)
       n
       (+ (fib (- n 1)) (fib (- n 2))))))

;;;; EC-Eval2 input:
;(fib 2)
;
;(total-pushes = 17 maximum-depth = 5)
;;;; EC-Eval2 value:
;1
;
;;;; EC-Eval2 input:
;(fib 3)
;
;(total-pushes = 27 maximum-depth = 8)
;;;; EC-Eval2 value:
;2
;
;;;; EC-Eval2 input:
;(fib 4)
;
;(total-pushes = 47 maximum-depth = 11)
;;;; EC-Eval2 value:
;3
;
;;;; EC-Eval2 input:
;(fib 5)
;
;(total-pushes = 77 maximum-depth = 14)
;;;; EC-Eval2 value:
;5
;
;;;; EC-Eval2 input:
;(fib 6)
;
;(total-pushes = 127 maximum-depth = 17)
;;;; EC-Eval2 value:
;8
;
;;; EC-Eval2 input:
;(fib 7)
;
;(total-pushes = 207 maximum-depth = 20)
;;;; EC-Eval2 value:
;13
;
;;;; EC-Eval2 input:
;(fib 8)
;
;(total-pushes = 337 maximum-depth = 23)
;;;; EC-Eval2 value:
;21
;
;;;; EC-Eval2 input:
;(fib 9)
;
;(total-pushes = 547 maximum-depth = 26)
;;;; EC-Eval2 value:
;34
;
;;;; EC-Eval2 input:
;(fib 10)
;
;(total-pushes = 887 maximum-depth = 29)
;;;; EC-Eval2 value:
;55


;; フィボナッチ数の特殊目的計算機の実験
(load "../simulator.scm")
(define fib-machine
  (make-machine
    '(n continue val)
    (list (list '= =) (list '- -) (list '+ +) (list '< <))
    '(
      (assign continue (label fib-done))
      fib-loop
      (test (op <) (reg n) (const 2))
      (branch (label immediate-answer))
      ;; set up to compute Fib(n - 1)
      (save continue)
      (assign continue (label afterfib-n-1))
      (save n)                           ; save old value of n
      (assign n (op -) (reg n) (const 1)); clobber n to n - 1
      (goto (label fib-loop))            ; perform recursive call
      afterfib-n-1                         ; upon return, val contains Fib(n - 1)
      (restore n)
      (restore continue)
      ;; set up to compute Fib(n - 2)
      (assign n (op -) (reg n) (const 2))
      (save continue)
      (assign continue (label afterfib-n-2))
      (save val)                         ; save Fib(n - 1)
      (goto (label fib-loop))
      afterfib-n-2                         ; upon return, val contains Fib(n - 2)
      (assign n (reg val))               ; n now contains Fib(n - 2)
      (restore val)                      ; val now contains Fib(n - 1)
      (restore continue)
      (assign val                        ;  Fib(n - 1) +  Fib(n - 2)
	      (op +) (reg val) (reg n))
      (goto (reg continue))              ; return to caller, answer is in val
      immediate-answer
      (assign val (reg n))               ; base case:  Fib(n) = n
      (goto (reg continue))
      fib-done)))

(calc-loop 2 10 'n 'val fib-machine)
;in: 2
;=> out:         1
;
;(total-pushes = 4 maximum-depth = 2)
;in: 3
;=> out:         2
;
;(total-pushes = 8 maximum-depth = 4)
;in: 4
;=> out:         3
;
;(total-pushes = 16 maximum-depth = 6)
;in: 5
;=> out:         5
;
;(total-pushes = 28 maximum-depth = 8)
;in: 6
;=> out:         8
;
;(total-pushes = 48 maximum-depth = 10)
;in: 7
;=> out:        13
;
;(total-pushes = 80 maximum-depth = 12)
;in: 8
;=> out:        21
;
;(total-pushes = 132 maximum-depth = 14)
;in: 9
;=> out:        34
;
;(total-pushes = 216 maximum-depth = 16)
;in:10
;=> out:        55
;
;(total-pushes = 352 maximum-depth = 18)

