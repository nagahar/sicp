(define (unless condition usual-value exceptional-value)
  (if condition exceptional-value usual-value))

(define (factorial n)
  (unless (= n 1)
    (* n (factorial (- n 1)))
    1))
(factorial 5)

;; 作用順序の言語ではfactorialを無限に展開し続けるため、無限ループになる
;; 正規順序の言語では動作する
