(define (make-monitored f)
  (let ((mf 0))
    (lambda (m)
      (cond ((eq? m 'how-many-calls?) mf)
	    ((eq? m 'reset-count) (set! mf 0))
	    (else (set! mf (+ mf 1))
		  (f m))))))

(define s (make-monitored sqrt))
(s 100)
(s 'how-many-calls?)
(s 'reset-count)

