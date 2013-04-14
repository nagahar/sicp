(define (variable? x) (symbol? x))
(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))
(define (=number? exp num)
  (and (number? exp) (= exp num)))
(define (sum? x)
  (and (pair? x) (eq? (car x) '+)))
(define (addend s) (car s))
(define (augend s)
  (if (null? (cddr s))
      (cadr s)
      (cons '+ (cdr s))))
(define (make-sum a1 a2)
  (cond ((=number? a1 0) a2)
	((=number? a2 0) a1)
	((and (number? a1) (number? a2)) (+ a1 a2))
	(else (list '+ a1 a2))))
(define (product? x)
  (and (pair? x) (eq? (car x) '*)))
(define (multiplier p) (car p))
(define (multiplicand p)
  (if (null? (cddr p))
      (cadr p)
      (cons '* (cdr p))))
(define (make-product m1 m2)
  (cond ((or (=number? m1 0) (=number? m2 0)) 0)
	((=number? m1 1) m2)
	((=number? m2 1) m1)
	((and (number? m1) (number? m2)) (* m1 m2))
	(else (list '* m1 m2))))
(define (exponentiation? x)
  (and (pair? x) (eq? (car x) '**)))
(define (base e) (car e))
(define (exponent e) (cadr e))
(define (make-exponetiation x n)
  (cond ((=number? n 0) 1)
	((=number? n 1) x)
	((and (number? x) (number? n)) (expt x n))
	(else (list '** x n))))
(define (deriv exp var)
  (cond ((number? exp) 0)
	((variable? exp) (if (same-variable? exp var) 1 0))
	(else ((get 'deriv (operator exp)) (operands exp)
	       var))))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))

;a.
;+,*,**などの演算子をデータ主導流における型として扱っているため、
;number?,variable?などは型となる演算子を持っていないため吸収できない

;b.
(define (install-sum-package)
  ;; internal procedures
  (define (deriv exp var)
    (make-sum (deriv (addend exp) var)
	      (deriv (augend exp) var)))

  ;; interface to the rest of the system
  (define (tag x) (attach-tag '+ x))
  (put 'deriv '+ deriv)
  'done)
(define (install-product-package)
  ;; internal procedures
  (define (deriv exp var)
    (make-sum
     (make-product (multiplier exp)
		   (deriv (multiplicand exp) var))
     (make-product (deriv (multiplier exp) var)
		   (multiplicand exp))))
  ;; interface to the rest of the system
  (define (tag x) (attach-tag '* x))
  (put 'deriv '* deriv)
  'done)
;c.
(define (install-exponentiation-package)
  ;; internal procedures
  (define (deriv exp var)
    (let ((e (exponent exp))
	  (b (base exp)))
      (make-product (make-product e (make-exponetiation b (make-sum e -1)))
		    (deriv b var))))
  ;; interface to the rest of the system
  (define (tag x) (attach-tag '** x))
  (put 'deriv '** deriv)
  'done)
;d.
(define (deriv exp var)
   (cond ((number? exp) 0)
         ((variable? exp) (if (same-variable? exp var) 1 0))
         (else ((get (operator exp) 'deriv) (operands exp) var))))
(define (install-sum-package)
  ;; internal procedures
  (define (deriv exp var)
    (make-sum (deriv (addend exp) var)
	      (deriv (augend exp) var)))

  ;; interface to the rest of the system
  (define (tag x) (attach-tag '+ x))
  (put '+ 'deriv deriv)
  'done)
(define (install-product-package)
  ;; internal procedures
  (define (deriv exp var)
    (make-sum
     (make-product (multiplier exp)
		   (deriv (multiplicand exp) var))
     (make-product (deriv (multiplier exp) var)
		   (multiplicand exp))))
  ;; interface to the rest of the system
  (define (tag x) (attach-tag '* x))
  (put '* 'deriv deriv)
  'done)
(define (install-exponentiation-package)
  ;; internal procedures
  (define (deriv exp var)
    (let ((e (exponent exp))
	  (b (base exp)))
      (make-product (make-product e (make-exponetiation b (make-sum e -1)))
		    (deriv b var))))
  ;; interface to the rest of the system
  (define (tag x) (attach-tag '** x))
  (put '** 'deriv deriv)
  'done)
