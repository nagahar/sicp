(define (cube x) (* x x x))
(define (p x) (- (* 3 x) (* 4 (cube x))))
(define (sine angle)
   (if (not (> (abs angle) 0.1))
       angle
       (p (sine (/ angle 3.0)))))

; a. 下式を計算して5回
(define (calc x count)
  (if (< x 0.1)
      count
      (calc (/ x 3.0) (+ count 1))))
(calc 81 0)

; b. (sine a) スペース Θ(log(a)), ステップ数 Θ(log(a))
; (sine a) は 3a としたとき、1しか増加しない