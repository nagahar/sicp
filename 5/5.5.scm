;; 階乗
;; (factorial 3)の実行をシミュレートする
;; スタック: continue,nをそれぞれリストc(),n()で示す
;; レジスタ: continue,n,valをそれぞれ変数n,c,vで示す
;;
;; 開始
;;  n = 3
;;  c = fact-done
;; fact-loop
;;  c(fact-done)
;;  n(3)
;;  n = 2
;;  c = after-fact
;; fact-loop
;;  c(fact-done after-fact)
;;  n(3 2)
;;  n = 1
;;  c = after-fact
;; fact-loop
;; base-case
;;  v = 1
;; after-fact
;;  n(3)
;;  n = 2
;;  c(fact-done)
;;  c = after-fact
;;  v = 2
;; after-fact
;;  n()
;;  n = 3
;;  c()
;;  c = fact-done
;;  v = 6
;; fact-done

(define (factorial n)
  (if (= n 1)
    1
    (* (factorial (- n 1)) n)))

(controller
   (assign continue (label fact-done))     ; set up final return address
 fact-loop
   (test (op =) (reg n) (const 1))
   (branch (label base-case))
   ;; Set up for the recursive call by saving n and continue.
   ;; Set up continue so that the computation will continue
   ;; at after-fact when the subroutine returns.
   (save continue)
   (save n)
   (assign n (op -) (reg n) (const 1))
   (assign continue (label after-fact))
   (goto (label fact-loop))
 after-fact
   (restore n)
   (restore continue)
   (assign val (op *) (reg n) (reg val))   ; val now contains n(n - 1)!
   (goto (reg continue))                   ; return to caller
 base-case
   (assign val (const 1))                  ; base case: 1! = 1
   (goto (reg continue))                   ; return to caller
 fact-done)

;; Fibonacci
;; (fib 3)の実行をシミュレートする
;; スタック: continue,n,valをそれぞれリストc(),n(),v()で示す
;; レジスタ: continue,n,valをそれぞれ変数n,c,vで示す
;;
;; 開始
;;  n = 3
;;  c = fib-done
;; fib-loop
;;  c(fib-done)
;;  c = afterfib-1
;;  n(3)
;;  n = 2
;; fib-loop
;;  c(fib-done afterfib-n-1)
;;  c = afterfib-1
;;  n(3 2)
;;  n = 1
;; fib-loop
;; immediate-answer
;;  v = 1
;; afterfib-n-1
;;  n(3)
;;  n = 2
;;  c(fib-done)
;;  c = afterfib-n-1
;;  n = 0
;;  c(fib-done afterfib-n-1)
;;  c = afterfib-n-2
;;  v(1)
;; fib-loop
;; immediate-answer
;;  v = 0
;; afterfib-n-2
;;  n = 0
;;  v()
;;  v = 1
;;  c(fib-done)
;;  c = afterfib-n-1
;;  v = 1
;; afterfib-n-1
;;  n()
;;  n = 3
;;  c()
;;  c = fib-done
;;  n = 1
;;  c(fib-done)
;;  c = afterfib-n-2
;;  v(1)
;; fib-loop
;; immediate-answer
;;  v = 1
;; afterfib-n-2
;;  n = 1
;;  v()
;;  v = 1
;;  c()
;;  c = fib-done
;;  v = 2
;; fib-done

(define (fib n)
  (if (< n 2)
    n
    (+ (fib (- n 1)) (fib (- n 2)))))

(controller
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
 fib-done)

