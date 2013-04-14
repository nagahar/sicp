(load "../stream.scm")
;; a.
(define (integrate-series s)
  (stream-map / s integers))

(show-stream (integrate-series ones) 5)
;; 1 1/2 1/3 1/4 1/5

;; b.
(define exp-series
  (cons-stream 1 (integrate-series exp-series)))
(define cosine-series
  (cons-stream 1 (scale-stream (integrate-series sine-series) -1)))
(define sine-series
  (cons-stream 0 (integrate-series cosine-series)))

(show-stream cosine-series 5)
;; 1 0 -1/2 0 1/24
(show-stream sine-series 5)
;; 0 1 0 -1/6 0
