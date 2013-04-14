(load "../stream.scm")
(define (sign-change-detector i1 i2)
  (cond ((and (>= i1 0) (< i2 0)) 1)
	((and (< i1 0) (>= i2 0)) -1)
	(else 0)))
(define sense-data (stream-map (lambda (x)
								 (if (even? x) (* x -1) x))
							   (integers-starting-from 0)))
;; Alyssa P.Hacker
;;(define (make-zero-crossings input-stream last-value)
;;  (cons-stream
;;	(sign-change-detector (stream-car input-stream) last-value)
;;	(make-zero-crossings (stream-cdr input-stream)
;;						 (stream-car input-stream))))

;; Louis Reasoner modified
(define (make-zero-crossings input-stream last-value last-avpt)
  (let ((avpt (/ (+ (stream-car input-stream) last-value) 2)))
	(cons-stream (sign-change-detector avpt last-avpt)
				 (make-zero-crossings (stream-cdr input-stream)
									  (stream-car input-stream)
									  avpt))))
(define zero-crossings (make-zero-crossings sense-data 0 0))

(show-stream sense-data 5)
;; 0 1 -2 3 -4
(show-stream zero-crossings 5)
;; 0 0 -1 1 -1

