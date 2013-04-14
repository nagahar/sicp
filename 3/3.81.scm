(load "../stream.scm")
(define (generate-random a b m)
  (lambda (x)
	(modulo (+ (* a x) b) m)))
(define rand-update (generate-random 3 5 13))
(define (rand input-stream random-init)
  (define random-stream
	(if (stream-null? input-stream)
	  the-empty-stream
	  (let ((request (stream-car input-stream)))
		(cons-stream
		  (cond ((eq? request 'generate) (rand-update random-init))
			((number? request) (rand-update request))
			(else (error "Unknown request --- RAND" request)))
		  (rand (stream-cdr input-stream) (stream-car random-stream))))))
  random-stream)
(define request-stream
  (cons-stream 100
               (cons-stream 'generate
                            (cons-stream 'generate
                                         (cons-stream 100
													  (cons-stream 'generate
																   the-empty-stream))))))

(show-stream (rand request-stream 1) 5)
;; 6 10 9 6 10
