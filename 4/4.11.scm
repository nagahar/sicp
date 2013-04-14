(define (make-frame variables values)
  (cons (cons (car vars) (car vals))
	(make-frame (cdr vars) (cdr vals))))
(define (frame-variables frame) (map car frame))
(define (frame-values frame) (map cadr frame))
(define (add-binding-to-frame! var val frame)
  (set-cdr! frame (cons var val)))

