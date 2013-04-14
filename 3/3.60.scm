(load "../stream.scm")
(define (mul-series s1 s2)
  (cons-stream (* (stream-car s1) (stream-car s2))
			   (add-streams (scale-stream (stream-cdr s2) (stream-car s1)) (mul-series (stream-cdr s1) s2))))
(define (integrate-series s)
  (stream-map / s integers))
(define exp-series
  (cons-stream 1 (integrate-series exp-series)))
(define cosine-series
  (cons-stream 1 (scale-stream (integrate-series sine-series) -1)))
(define sine-series
  (cons-stream 0 (integrate-series cosine-series)))

(show-stream (add-streams (mul-series sine-series sine-series) (mul-series cosine-series cosine-series)) 1)
;; 1

