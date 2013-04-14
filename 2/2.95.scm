(define P1 (make-polynomial 'x '((2 1) (1 -2) (0 1))))
(define P2 (make-polynomial 'x '((2 11) (0 7))))
(define P3 (make-polynomial 'x '((1 13) (0 5))))
(define Q1 (mul P1 P2))
(define Q2 (mul P1 P3))
(greatest-common-divisor Q1 Q2)
P1