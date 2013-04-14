(define right-split (split beside below))
(define up-split (split below beside))

(define (split t1 t2)
  (lambda (painter n)
    (if (= n 0)
	painter
	(let ((smaller ((split t1 t2) painter (- n 1))))
	  (t1 painter (t2 smaller smaller))))))