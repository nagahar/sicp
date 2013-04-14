(load "../stream.scm")
(load "../sicp-util.scm")
(define (pairs s t)
  (cons-stream
    (list (stream-car s) (stream-car t))
    (interleave
      (stream-map (lambda (x) (list (stream-car s) x))
		  (stream-cdr t))
      (pairs (stream-cdr s) (stream-cdr t)))))

(define (interleave s1 s2)
  (if (stream-null? s1)
    s2
    (cons-stream (stream-car s1)
		 (interleave s2 (stream-cdr s1)))))

(define (triples s t u)
  (cons-stream
    (list (stream-car s) (stream-car t) (stream-car u))
    (interleave
      (stream-map (lambda (x) (cons (stream-car s) x))
		  (stream-cdr (pairs t u)))
      (triples (stream-cdr s) (stream-cdr t) (stream-cdr u)))))
(show-stream (triples integers integers integers) 5)
;; (1 1 1) (1 1 2) (2 2 2) (1 2 2) (2 3 3)

;; ピタゴラスを満たすトリプル
(define pythagoras
  (stream-filter (lambda (triple)
		   (= (square (caddr triple)) (+ (square (car triple)) (square (cadr triple)))))
		 (triples integers integers integers)))

(show-stream pythagoras 5)
;; (3 4 5) (6 8 10) (5 12 13) (9 12 15) (8 15 17)
