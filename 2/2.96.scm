;;;a.
;;;b.

(define (install-polynomial-package)
  ;; internal procedures
  ;; representation of poly
  (define (make-poly variable term-list)
    (cons variable term-list))
  (define (variable p) (car p))
  (define (term-list p) (cdr p))
  ;; representation of terms and term lists
  (define (add-terms L1 L2)
    (cond ((empty-termlist? L1) L2)
	  ((empty-termlist? L2) L1)
	  (else
	   (let ((t1 (first-term L1)) (t2 (first-term L2)))
	     (cond ((> (order t1) (order t2))
		    (adjoin-term
		     t1 (add-terms (rest-terms L1) L2)))
		   ((< (order t1) (order t2))
		    (adjoin-term
		     t2 (add-terms L1 (rest-terms L2))))
		   (else
		    (adjoin-term
		     (make-term (order t1)
				(add (coeff t1) (coeff t2)))
		     (add-terms (rest-terms L1)
				(rest-terms L2)))))))))
  (define (mul-terms L1 L2)
    (if (empty-termlist? L1)
	(the-empty-termlist)
	(add-terms (mul-term-by-all-terms (first-term L1) L2)
		   (mul-terms (rest-terms L1) L2))))
  (define (mul-term-by-all-terms t1 L)
    (if (empty-termlist? L)
	(the-empty-termlist)
	(let ((t2 (first-term L)))
	  (adjoin-term
	   (make-term (+ (order t1) (order t2))
		      (mul (coeff t1) (coeff t2)))
	   (mul-term-by-all-terms t1 (rest-terms L))))))
  (define (sub-terms L1 L2)
    (add-terms L1 (inv-terms L2)))
  (define (div-terms L1 L2)
    (if (empty-termlist? L1)
	(list (the-empty-termlist) (the-empty-termlist))
	(let ((t1 (first-term L1))
	      (t2 (first-term L2)))
	  (if (> (order t2) (order t1))
	      (list (the-empty-termlist) L1)
	      (let ((new-c (div (coeff t1) (coeff t2)))
		    (new-o (- (order t1) (order t2))))
		(let ((rest-of-result
		       (div-terms
			(sub-terms L1 (mul-term-by-all-terms (make-term new-o new-c) L2))
			L2)))
		  (list (cons (make-term new-o new-c) (car rest-of-result))
			(cadr rest-of-result))))))))
  (define (adjoin-term term term-list)
    (if (=zero? (coeff term))
	term-list
	(cons term term-list)))
  (define (inv-terms L)
    (if (empty-termlist? L)
	(the-empty-termlist)
	(let ((t (first-term L)))
	  (adjoin-term
	   (make-term (order t)
		      (inv (coeff t)))
	   (inv-terms (rest-terms L))))))
;;;  (define (gcd-terms L1 L2)
;;;    (if (empty-termlist? L2)
;;;	L1
;;;	(gcd-terms L2 (remainder-terms L1 L2))))
  (define (remainder-terms L1 L2)
    (let ((result (div-terms L1 L2)))
      (cadr result)))
  (define (gcd-terms L1 L2)
    (if (empty-termlist? L2)
	(let ((gcdcoeff (apply gcd (map coeff L1))))
	  (car (div-terms L1
			  (adjoin-term 
			   (make-term 0 gcdcoeff) 
			   (the-empty-termlist)))))
	(gcd-terms L2 (pseudoremainder-terms L1 L2))))

  (define (pseudoremainder-terms L1 L2)
    (let ((itf (integerizing-factor L1 L2)))
      (let ((result (div-terms (mul-term-by-all-terms (make-term 0 itf)
						      L1)
			       L2)))
	(cadr result))))
  (define (integerizing-factor L1 L2)
    (let ((o1 (order (first-term L1)))
          (o2 (order (first-term L2)))
          (c  (coeff (first-term L2))))
      (expt c (add (sub o1 o2) 1))))
  (define (the-empty-termlist) '())
  (define (first-term term-list) (car term-list))
  (define (rest-terms term-list) (cdr term-list))
  (define (empty-termlist? term-list) (null? term-list))
  (define (make-term order coeff) (list order coeff))
  (define (order term) (car term))
  (define (coeff term) (cadr term))
  (define (zero-term? term)
    (or (empty-termlist? term)
	(and (=zero? (coeff (first-term term)))
	     (zero-term? (rest-terms term)))))

  (define (add-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(make-poly (variable p1)
		   (add-terms (term-list p1)
			      (term-list p2)))
	(error "Polys not in same var -- ADD-POLY"
	       (list p1 p2))))
  (define (mul-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(make-poly (variable p1)
		   (mul-terms (term-list p1)
			      (term-list p2)))
	(error "Polys not in same var -- MUL-POLY"
	       (list p1 p2))))
  (define (div-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(make-poly (variable p1)
		   (div-terms (term-list p1)
			      (term-list p2)))
	(error "Polys not in same var -- DIV-POLY"
	       (list p1 p2))))
  (define (inv-poly p)
    (make-poly (variable p) (inv-terms (term-list p))))
  (define (equ? p1 p2)
    (use srfi-1)
    (and (same-variable? (variable p1) (variable p2))
	 (list= (term-list p1) (term-list p2))))
  (define (gcd-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(make-poly (variable p1)
		   (gcd-terms (term-list p1)
			      (term-list p2)))
	(error "Polys not in same var -- GCD-POLY"
	       (list p1 p2))))
  ;; interface to rest of the system
  (define (tag p) (attach-tag 'polynomial p))
  (put 'add '(polynomial polynomial) 
       (lambda (p1 p2) (tag (add-poly p1 p2))))
  (put 'mul '(polynomial polynomial) 
       (lambda (p1 p2) (tag (mul-poly p1 p2))))
  (put 'sub '(polynomial polynomial)
       (lambda (p1 p2) (tag (add-poly p1 (inv-poly p2)))))
  (put 'div '(polynomial polynomial)
       (lambda (p1 p2) (tag (div-poly p1 p2))))
  (put 'make 'polynomial
       (lambda (var terms) (tag (make-poly var terms))))
  (put '=zero? '(polynomial)
       (lambda (p) (zero-term? (term-list p))))
  (put 'inv '(polynomial)
       (lambda (p) (tag (inv-poly p))))
  (put 'equ? '(polynomial polynomial)
       (lambda (p1 p2) (equ? p1 p2)))
  (put 'greatest-common-divisor '(polynomial polynomial)
       (lambda (p1 p2) (tag (gcd-poly p1 p2))))
  'done)
(define (make-polynomial var terms)
  ((get 'make 'polynomial) var terms))

(install-polynomial-package)

(define P1 (make-polynomial 'x '((2 1) (1 -2) (0 1))))
(define P2 (make-polynomial 'x '((2 11) (0 7))))
(define P3 (make-polynomial 'x '((1 13) (0 5))))
(define Q1 (mul P1 P2))
(define Q2 (mul P1 P3))
(greatest-common-divisor Q1 Q2)
