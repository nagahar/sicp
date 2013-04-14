(stream-map + (list 1 2 3) (list 40 50 60) (list 700 800 900))
;; => (741 852 963)

(stream-map (lambda (x y) (+ x (* 2 y)))
	 (list 1 2 3)
	 (list 4 5 6))
;; => (9 12 15)

(define (stream-map proc . argstreams)
  (if (stream-null? (car argstreams))
	the-empty-stream
	(cons
	  (apply proc (map stream-car argstreams))
	  (apply stream-map
			 (cons proc (map stream-cdr argstreams))))))

(define the-empty-stream '())
(define (stream-null? s)
  (null? s))
(define (cons-stream a b)
  (cons a (delay b)))
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))
(define (force delayed-object)
  delayed-object)
(define (memo-proc proc)
  (let ((already-run? #f) (result #f))
    (lambda ()
      (if (not already-run?)
          (begin (set! result (proc))
                 (set! already-run? #t)
                 result)
          result))))
(define (delay express)
  (memo-proc (lambda () express)))

;; old
(define (stream-map proc s)
  (if (stream-null? s)
	the-empty-stream
	(cons-stream (proc (stream-car s))
				 (stream-map proc (stream-cdr s)))))

