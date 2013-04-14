(define a (make-connector))
(define b (make-connector))
(set-value! a 10 'user)

;; - global
;;    a: request, (cond ((eq? request 'has-value?)...
;;    b: request, (cond ((eq? request 'has-value?)...
;;    <- E1
;;       value: 10
;;       infromant: 'user
;;       constraints: '()
;;    <- E2
;;       value: #f
;;       infromant: #f
;;       constraints: '()

(define (make-connector)
  (let ((value #f) (informant #f) (constraints '()))
	(define (set-my-value newval setter)
	  (cond ((not (has-value? me))
			 (set! value newval)
			 (set! informant setter)
			 (for-each-except setter
							  inform-about-value
							  constraints))
		((not (= value newval))
		 (error "Contradiction" (list value newval)))
		(else 'ignored)))
	(define (forget-my-value retractor)
	  (if (eq? retractor informant)
		(begin (set! informant #f)
		  (for-each-except retractor
						   inform-about-no-value
						   constraints))
		'ignored))
	(define (connect new-constraint)
	  (if (not (memq new-constraint constraints))
		(set! constraints 
		  (cons new-constraint constraints)))
	  (if (has-value? me)
		(inform-about-value new-constraint))
	  'done)
	(define (me request)
	  (cond ((eq? request 'has-value?)
			 (if informant #t #f))
		((eq? request 'value) value)
		((eq? request 'set-value!) set-my-value)
		((eq? request 'forget) forget-my-value)
		((eq? request 'connect) connect)
		(else (error "Unknown operation -- CONNECTOR"
					 request))))
	me))
(define (for-each-except exception procedure list)
  (define (loop items)
	(cond ((null? items) 'done)
	  ((eq? (car items) exception) (loop (cdr items)))
	  (else (procedure (car items))
		(loop (cdr items)))))
  (loop list))
(define (has-value? connector)
  (connector 'has-value?))
(define (get-value connector)
  (connector 'value))
(define (set-value! connector new-value informant)
  ((connector 'set-value!) new-value informant))
(define (forget-value! connector retractor)
  ((connector 'forget) retractor))
(define (connect connector new-constraint)
  ((connector 'connect) new-constraint))

