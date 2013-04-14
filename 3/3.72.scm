(load "../stream.scm")
(define (merge-weighted s1 s2 weight)
  (cond ((stream-null? s1) s2)
	((stream-null? s2) s1)
	(else
	  (let ((s1car (stream-car s1))
			(s2car (stream-car s2)))
		(if (< (weight s1car) (weight s2car))
		  (cons-stream s1car (merge-weighted (stream-cdr s1) s2 weight))
		  (cons-stream s2car (merge-weighted s1 (stream-cdr s2) weight)))))))
(define (weighted-pairs s t weight)
  (cons-stream
	(list (stream-car s) (stream-car t))
	(merge-weighted
	  (stream-map (lambda (x) (list (stream-car s) x))
				  (stream-cdr t))
	  (weighted-pairs (stream-cdr s) (stream-cdr t) weight)
	  weight)))

(define (weight-square pair)
  (+ (expt (car pair) 2) (expt (cadr pair) 2)))

(define (order-square s)
  (if (= (weight-square (stream-car s)) (weight-square (stream-car (stream-cdr s))) (weight-square (stream-car (stream-cdr (stream-cdr s)))))
	(cons-stream (weight-square (stream-car s))
				 (order-square (stream-cdr s)))
	(order-square (stream-cdr s))))
(define square-numbers
  (order-square (weighted-pairs integers integers weight-square)))

(show-stream square-numbers 6)
;; 325 425 650 725 845 850
