;; 証明
;; (car (cons x y))
;; (car (lambda (m) (m x y)))
;; (lambda ((lambda (p q) p)) ((lambda (p q) p) x y))
;; (lambda ((lambda (p q) p)) (x))
;; x

(define (cons x y)
  (lambda (m) (m x y)))
(define (car z)
  (z (lambda (p q) p)))
(define (cdr z)
  (z (lambda (p q) q)))
