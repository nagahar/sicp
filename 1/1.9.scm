(use slib)
(require 'trace)

(define (dec x)
  (- x 1))
(define (inc x)
  (- (* x 2) (dec x)))

;;再帰プロセス;再帰関数の戻り値もさらに計算する
(define (+ a b)
  (if (= a 0)
      b
      (inc (+ (dec a) b))))
;;反復プロセス;再帰関数の戻り値が計算されない
(define (+ a b)
  (if (= a 0)
      b
      (+ (dec a) (inc b))))

(trace inc)
(+ 4 5)