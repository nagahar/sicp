(define (cycle? lst)
  (let ((elements '()))
	(define (cycle-inter x)
	  (cond ((not (pair? x)) #f)
		((memq x #?=elements) #t)
		(else
		  (set! elements (cons x elements))
		  (cycle-inter (cdr x)))))
	(cycle-inter lst)))

(define (make-cycle x)
  (set-cdr! (last-pair x) x)
  x)

(define z (make-cycle (list 'a 'b 'c)))
(cycle? z)

