(load "../stream.scm")
;; Louis Reasonerの版ではcons-streamを使っていないため、pairsが遅延評価されない。そのため、無限ループになる
(define (pairs s t)
  (interleave
	(stream-map (lambda (x) (list (stream-car s) x))
				t)
	(pairs (stream-cdr s) (stream-cdr t))))

;; original
(define (pairs s t)
  (cons-stream
	(list (stream-car s) (stream-car t))
	(interleave
	  (stream-map (lambda (x) (list (stream-car s) x))
				  (stream-cdr t))
	  (pairs (stream-cdr s) (stream-cdr t)))))
(show-stream (pairs integers integers) 5)
;; (1 1) (1 2) (2 2) (2 3) (3 3)

(define (interleave s1 s2)
  (if (stream-null? s1)
	s2
	(cons-stream (stream-car s1)
				 (interleave s2 (stream-cdr s1)))))

