(load "../stream.scm")
(load "../sicp-util.scm")
(define (ln2-summands n)
  (cons-stream (/ 1.0 n)
			   (stream-map - (ln2-summands (+ n 1)))))
(define ln2-stream
  (partial-sums (ln2-summands 1)))

(define (euler-transform s)
  (let ((s0 (stream-ref s 0))           ; Sn-1
		(s1 (stream-ref s 1))           ; Sn
		(s2 (stream-ref s 2)))          ; Sn+1
	(cons-stream (- s2 (/ (square (- s2 s1))
						  (+ s0 (* -2 s1) s2)))
				 (euler-transform (stream-cdr s)))))

(define (make-tableau transform s)
  (cons-stream s
			   (make-tableau transform
							 (transform s))))
(define (accelerated-sequence transform s)
  (stream-map stream-car
			  (make-tableau transform s)))

(show-stream ln2-stream 8)
;; 1.0 0.5 0.8333333333333333 0.5833333333333333 0.7833333333333332 0.6166666666666666 0.7595238095238095 0.6345238095238095
(show-stream (euler-transform ln2-stream) 8)
;; 0.7 0.6904761904761905 0.6944444444444444 0.6924242424242424 0.6935897435897436 0.6928571428571428 0.6933473389355742 0.6930033416875522
(show-stream (accelerated-sequence euler-transform
									  ln2-stream) 8)
;; 1.0 0.7 0.6932773109243697 0.6931488693329254 0.6931471960735491 0.6931471806635636 0.6931471805604039 0.6931471805599445

(define (pi-summands n)
  (cons-stream (/ 1.0 n)
			   (stream-map - (pi-summands (+ n 2)))))
(define pi-stream
  (scale-stream (partial-sums (pi-summands 1)) 4))

