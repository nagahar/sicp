(define (fast-* a b)
  (cond ((= b 0) 0)
        ((even? b) (double (fast-* a (halv b))))
        (else (+ a (fast-* a (- b 1))))))
(define (even? n)
  (= (remainder n 2) 0))
(define (double x)
  (+ x x))
(define (halv x)
  (/ x 2))

; (* a b) ステップ数 Θ(log(b))
; 底2の対数ステップ