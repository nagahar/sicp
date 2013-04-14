(define (make-lexical-address frame displacement)
  (list frame displacement))
(define (get-frame-number address) (car address))
(define (get-displacement-number address) (cadr address))

(define (lexical-address-set! address val env)
  (let ((frame (list-ref (get-frame-number address) env))
	(displacement (get-displacement-number address)))
    (let ((old (list-ref displacement frame)))
      (set! old val))))

(define (lexical-address-set! address val env)
  (let ((frame (list-ref (get-frame-number address) env))
	(displacement (get-displacement-number address)))
    (let ((old (list-ref displacement (frame-values frame))))
      (set! old val))))

