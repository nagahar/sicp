;; a. make-mutex を使う

(define (make-semaphore n)
  (let ((counter 0)
		(mutex (make-mutex)))
	(define (the-semaphore m)
	  (cond ((eq? m 'acquire)
			 (mutex 'acquire)
			 (if (> counter n)
			   (begin
				 (mutex 'release)
				 (the-semaphore m)) ; retry
			   (begin
				 (set! counter (+ counter 1))
				 (mutex 'release))))
		((eq? m 'release)
		 (mutex 'acquire)
		 (set! counter (- counter 1))
		 (mutex 'release))
		(else (error "Unknown message -- SEMAPHORE" m))))
	the-semaphore))

;; b. test-and-set! を使う

(define (make-semaphore n)
  (let ((counter 0)
		(cell (list #f)))
	(define (the-semaphore m)
	  (cond ((eq? m 'acquire)
			 (if (or (> counter n) (test-and-set! cell))
			   (the-semaphore m) ; retry
			   (begin
				 (set! counter (+ counter 1))
				 (clear! cell))))
		((eq? m 'release)
		 (if (test-and-set! cell)
		   (the-semaphore m) ; retry
		   (begin
			 (set! counter (- counter 1))
			 (clear! cell))))
		(else (error "Unknown message -- SEMAPHORE" m))))
	the-semaphore))

(define (make-serializer)
  (let ((mutex (make-mutex)))
	(lambda (p)
	  (define (serialized-p . args)
		(mutex 'acquire)
		(let ((val (apply p args)))
		  (mutex 'release)
		  val))
	  serialized-p)))

(define (make-mutex)
  (let ((cell (list #f)))
	(define (the-mutex m)
	  (cond ((eq? m 'acquire)
			 (if (test-and-set! cell)
			   (the-mutex 'acquire))) ; retry
		((eq? m 'release) (clear! cell))))
	the-mutex))

(define (clear! cell)
  (set-car! cell #f))

(define (test-and-set! cell)
  (if (car cell)
	#t
	(begin (set-car! cell #t)
	  #f)))

