(define f
  (let ((state 0))
	(lambda (x)
	  (if (= #?=state 0)
		(begin (set! state 1) 0)
		(if (= x 0)
		  1
		  0)))))

;; eval left to right
;; (f 0) => 0, (f 1) => 0
;; eval right to left
;; (f 0) => 1, (f 1) => 0
(f 0)
(f 1)
(+ (f 0) (f 1))
