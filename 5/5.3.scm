;; good-enough?とimproveを基本演算として使えると仮定
(define (sqrt x)
  (define (sqrt-iter guess)
    (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x))))
  (sqrt-iter 1.0))

;; データパス図
;;
;;       / \
;;      /1.0\
;;      -----
;;        |
;;        X
;;        |
;;        v
;;        -------  /------------\    ---
;; ---X-->|guess|->|good-enough?|<---|x|
;; |      -------  \------------/    ---
;; |         |                        |
;; |         ------|           |-------
;; |               v           v
;; |                \---------/
;; |                 \improve/
;; |                  -------
;; |                     |
;; -----------------------

;; 制御器の命令列
(controler
  (assign guess (const 1.0))
  test-guess
    (test (op good-enough?) (reg guess) (reg x))
    (branch (label done))
    (assign guess (op improve) (reg guess) (reg x))
    (goto (label test-guess))
  done)

;; good-enough?とimproveを算術演算として展開
(define (sqrt x)
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
      guess
      (sqrt-iter (improve guess))))
  (sqrt-iter 1.0))

;; データパス図
;;
;;          / \                        / \
;;         /1.0\                     /0.001\
;;         -----                     -------
;;           |                          |
;;           X                          X
;;           |                          |
;;        -------                       |
;; ------>|guess|--------               |
;; |      -------     | |               |
;; |       |          | v               |
;; X       |          |  \--------/     |
;; |       |          |   \square/      |
;; |       |  ---     |    ------       |
;; |       |  |x|-----+------+-------   |
;; |       |  ---     |      |      |   |
;; |       |   |      |      X      |   |
;; |       |   v      v      v      |   |
;; |       |   \-----/      ----    |   |
;; |       |    \ / /       |t1|    |   |
;; |       |     ---        ----    |   |
;; |       |      |          |      |   |
;; |       |      X          v      v   |
;; |       |      v          \-----/    |
;; |       |     ----         \ - /     |
;; |       |     |t4|          ---      |
;; |       |     ----           |       |
;; |       |      |             X       |
;; |       v      v             v       |
;; |      \---------/          ----     |
;; |       \average/           |t2|     |
;; |       -------             ----     |
;; |           |                |       |
;; -------------                v       |
;;                           \-----/    |
;;                            \abs/     |
;;                             ---      |
;;                              |       |
;;                              X       |
;;                              v       |
;;                             ----     |
;;                             |t3|     |
;;                             ----     |
;;                              |       |
;;                              v       |
;;                            /---\     |
;;                            | < |<----|
;;                            \---/
;;

;; 制御器の命令列
(controler
  (assign guess (const 1.0))
  test-guess
    (assign t1 (op square) (reg guess))
    (assign t2 (op -) (reg t1) (reg x))
    (assign t3 (op abs) (reg t2))
    (test (op <) (reg t3) (const 0.001))
    (branch (label done))
    (assign t4 (op /) (reg x) (reg guess))
    (assign guess (op average) (reg guess) (reg t4))
    (goto (label test-guess))
  done)

