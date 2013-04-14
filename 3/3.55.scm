(load "../stream.scm")
(define (partial-sums s)
  (cons-stream (stream-car s)
			   (add-streams
				 (partial-sums s)
				 (stream-cdr s))))
(show-stream (partial-sums integers) 5)
;; 1 3 6 10 15

