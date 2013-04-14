;; multiplierは3つの値のうち2つが定まらないと他の値は定まらない。
;; そのため(squarer a b)のbの値がセットされてもaの値が定まらない。
(define (squarer a b)
  (multiplier a a b))

