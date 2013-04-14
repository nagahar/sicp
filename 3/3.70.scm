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
;; a.
(define (weight-a pair)
  (+ (car pair) (cadr pair)))
(show-stream (weighted-pairs integers integers weight-a) 5)
;; (1 1) (1 2) (2 2) (1 3) (2 3)

;; b.
(define (weight-b pair)
  (+ (* 2 (car pair)) (* 3 (cadr pair)) (* 5 (car pair) (cadr pair))))
(define stream-b
  (stream-filter (lambda (x)
				   (and (not (= (remainder x 2) 0)) (not (= (remainder x 3) 0)) (not (= (remainder x 5) 0))))
				 integers))
(show-stream (weighted-pairs stream-b stream-b weight-b) 5)
;; (1 1) (1 7) (1 11) (1 13) (1 17)
