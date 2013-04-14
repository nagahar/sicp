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

(define (ramanujan-weight pair)
  (+ (expt (car pair) 3) (expt (cadr pair) 3)))

(define (ramanujan-number s)
  (if (= (ramanujan-weight (stream-car s)) (ramanujan-weight (stream-car (stream-cdr s))))
	(cons-stream (ramanujan-weight (stream-car s))
				 (ramanujan-number (stream-cdr s)))
	(ramanujan-number (stream-cdr s))))
(define ramanujan
  (ramanujan-number (weighted-pairs integers integers ramanujan-weight)))

(show-stream ramanujan 6)
;; 1729 4104 13832 20683 32832 39312

