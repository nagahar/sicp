
(define (make-table)
  (let ((local-table (list '*table*)))
    (define (lookup key-1 key-2)
      (let ((subtable (assoc key-1 (cdr local-table))))
        (if subtable
            (let ((record (assoc key-2 (cdr subtable))))
              (if record
                  (cdr record)
                  #f))
            #f)))
    (define (insert! key-1 key-2 value)
      (let ((subtable (assoc key-1 (cdr local-table))))
        (if subtable
            (let ((record (assoc key-2 (cdr subtable))))
              (if record
                  (set-cdr! record value)
                  (set-cdr! subtable
                            (cons (cons key-2 value)
                                  (cdr subtable)))))
            (set-cdr! local-table
                      (cons (list key-1
                                  (cons key-2 value))
                            (cdr local-table)))))
      'ok)    
    (define (dispatch m)
      (cond ((eq? m 'lookup-proc) lookup)
            ((eq? m 'insert-proc!) insert!)
            (else (error "Unknown operation -- TABLE" m))))
    dispatch))

(define coercion-table (make-table))
(define get-coercion (coercion-table 'lookup-proc))
(define put-coercion (coercion-table 'insert-proc!))


(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (if (= (length args) 2)
              (let ((type1 (car type-tags))
                    (type2 (cadr type-tags))
                    (a1 (car args))
                    (a2 (cadr args)))
		(if (eq? type1 type2)
		    (error "No method for these types"
			   (list op type-tags))
		    (let ((t1->t2 (get-coercion type1 type2))
			  (t2->t1 (get-coercion type2 type1)))
		      (cond (t1->t2
			     (apply-generic op (t1->t2 a1) a2))
			    (t2->t1
			     (apply-generic op a1 (t2->t1 a2)))
			    (else
			     (error "No method for these types"
				    (list op type-tags)))))))
	      (error "No method for these types"
		     (list op type-tags)))))))

(define (install-rational-package)
  ;; internal procedures
  (define (numer x) (car x))
  (define (denom x) (cdr x))
;;;  (define (make-rat n d)
;;;    (let ((g (gcd n d)))
;;;      (cons (/ n g) (/ d g))))
  (define (make-rat n d)
    (cons n d))
  (define (add-rat x y)
    (make-rat (add (mul (numer x) (denom y))
		   (mul (numer y) (denom x)))
              (mul (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (sub (mul (numer x) (denom y))
		   (mul (numer y) (denom x)))
              (mul (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (mul (numer x) (numer y))
              (mul (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (mul (numer x) (denom y))
              (mul (denom x) (numer y))))
  (define (sin-rat x)
    (make-rat (round (sin (div (numer x) (denom x))))
	      1))
  (define (cos-rat x)
    (make-rat (round (cos (div (numer x) (denom x))))
	      1))
  (define (sqrt-rat x)
    (make-rat (round (sqrt (div (numer x) (denom x))))
	      1))
  (define (atan-rat x y)
    (make-rat (round (atan (div (numer x) (denom x)) (div (numer y) (denom y))))
	      1))
  (define (square-rat x)
    (mul-rat x x))
  (define (rational->real x)
    (make-real (div (numer x) (denom x))))
  (define (rational->integer x)
    (make-integer (round (div (numer x) (denom x)))))

  ;; interface to rest of the system
  (define (tag x) (attach-tag 'rational x))
  (put 'add '(rational rational)
       (lambda (x y) (tag (add-rat x y))))
  (put 'sub '(rational rational)
       (lambda (x y) (tag (sub-rat x y))))
  (put 'mul '(rational rational)
       (lambda (x y) (tag (mul-rat x y))))
  (put 'div '(rational rational)
       (lambda (x y) (tag (div-rat x y))))
  (put 'make 'rational
       (lambda (n d) (tag (make-rat n d))))
  (put 'equ? '(rational rational)
       (lambda (x y) (and (equ? (numer x) (numer y))
			  (equ? (denom x) (denom y)))))
  (put '=zero? '(rational)
       (lambda (x) (zero? (numer x))))
  (put 'raise '(rational)
       (lambda (x) (rational->real x)))
  (put 'project '(rational)
       (lambda (x) (rational->integer x)))
  (put 'xsin '(rational)
       (lambda (x) (tag (sin-rat x))))
  (put 'xcos '(rational)
       (lambda (x) (tag (cos-rat x))))
  (put 'xsqrt '(rational)
       (lambda (x) (tag (sqrt-rat x))))
  (put 'xatan '(rational rational)
       (lambda (x y) (tag (atan-rat x y))))
  (put 'xsquare '(rational)
       (lambda (x) (tag (square-rat x))))
  (put 'inv '(rational)
       (lambda (x) (tag (make-rat (inv (numer x)) (denom x)))))
  (put-coercion 'rational 'real rational->real)
  (put-coercion 'rational 'integer rational->integer)
  'done)
(define (make-rational n d)
  ((get 'make 'rational) n d))

(install-rational-package)

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
			(sub-terms L1
				   (mul-term-by-all-terms (make-term new-o new-c) L2))
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
  'done)
(define (make-polynomial var terms)
  ((get 'make 'polynomial) var terms))

(install-polynomial-package)

(define p1 (make-polynomial 'x '((2 1) (0 1))))
(define p2 (make-polynomial 'x '((3 1) (0 1))))
(define rf (make-rational p2 p1))
(add rf rf)