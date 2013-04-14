;; a.
(define (expt b n)
  (if (= n 0)
    1
    (* b (expt b (- n 1)))))

;; 制御器の命令列
(controller
   (assign continue (label expt-done))
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
 expt-done)

;; データパス図
;;
;;                  / \    /---\    / \     -------------X--->-------
;;                 / 1 \   | = |<--/ 0 \    |continue|        |stack|
;;                 -----   \---/   -----    ----------<--X-----------
;;          ------X--|       ^               ^      ^
;;          |        |       |               X      X
;;          v        |      ---              |      |
;;  ---   -----      |      |n|<--          / \    / \
;;  |b|   |val|<--   |      ---  |         /   \  /   \
;;  ---   -----  |   |       |   |         -----  -----
;;   |      |    |   v       v   |     after-expt expt-done
;;   v      v    |    \-----/    |
;;   \-----/     |     \ - /     |
;;    \ * /      |      ---      |
;;     ---       |       |       |
;;      |        |       X       |
;;      X        |       |--------
;;      |---------

;; b.
(define (expt b n)
  (define (expt-iter counter product)
    (if (= counter 0)
      product
      (expt-iter (- counter 1) (* b product))))
  (expt-iter n 1))

;; 制御器の命令列
(controller
   (assign counter (reg n))
   (assign product (const 1))
 expt-loop
   (test (op =) (reg counter) (const 0))
   (branch (label expt-done))
   (assign counter (op -) (reg counter) (const 1))
   (assign product (op *) (reg b) (reg product))
   (goto (label expt-loop))
 expt-done)

;; データパス図
;;
;;                 ---         / \
;;                 |n|        / 1 \
;;                 ---        -----
;;                  |         |   |
;;                  X         |   X
;;                  |         |   |
;;                  v         |   v
;;   / \   /---\  ---------      | ---------  ---
;;  / 0 \->| = |<-|counter|      | |product|  |b|
;;  -----  \---/  ---------      | ---------  ---
;;                 ^   |      |   ^     |      |
;;                 |   v      v   |     v      v
;;                 |   \-----/    |     \-----/
;;                 |    \ - /     |      \ * /
;;                 |     ---      |       ---
;;                 X      |       X        |
;;                 |-------       |---------

