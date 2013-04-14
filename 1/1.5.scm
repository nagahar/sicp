(define (p) (p))
(define (test x y)
  (if (= x 0)
    0
    y))
(test 0 (p))

;作用順序の場合 pの無限評価ループになる
;'cause 引数pを仮引数に作用させるために展開しようとし、無限ループになるため


;正規順序の場合 0
;'cause 被演算子の評価の前にtestが展開され、ifが実行されるため
(if (= 0 0)
  0
  (p))
