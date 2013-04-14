;; 下記のようにcons, car, cdrを遅延評価ループで定義すれば、stのような未定義の変数を使ったリストを定義できる
(load "../lazy-metacircular.scm")
(driver-loop)

;;;; L-Eval input:
;(define (cons x y)
;  (lambda (m) (m x y)))
;;;; L-Eval value:
;ok
;;;; L-Eval input:
;(define (car z)
;  (z (lambda (p q) p)))
;;;; L-Eval value:
;ok
;;;; L-Eval input:
;(define (cdr z)
;  (z (lambda (p q) q)))
;;;; L-Eval value:
;ok

;;;; L-Eval input:
;(define st (cons x y))

