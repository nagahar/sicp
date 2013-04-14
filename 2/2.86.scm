(define (attach-tag type-tag contents)
  (cons type-tag contents))
(define (type-tag datum)
  (if (pair? datum)
      (car datum)
      (error "Bad tagged datum -- TYPE-TAG" datum)))
(define (contents datum)
  (if (pair? datum)
      (cdr datum)
      (error "Bad tagged datum -- CONTENTS" datum)))
(define (add x y) (apply-generic 'add x y))
(define (sub x y) (apply-generic 'sub x y))
(define (mul x y) (apply-generic 'mul x y))
(define (div x y) (apply-generic 'div x y))
(define (equ? x y) (apply-generic 'equ? x y))
(define (=zero? x) (apply-generic '=zero? x))
(define (xsquare x) (apply-generic 'xsquare x));add
(define (xsqrt x) (apply-generic 'xsqrt x));add
(define (xcos x) (apply-generic 'xcos x));add
(define (xsin x) (apply-generic 'xsin x));add
(define (xatan x y) (apply-generic 'xatan x y));add

(define (install-integer-package)
  (define (integer->rational x)
    (make-rational x 1))
  (define (tag x)
    (attach-tag 'integer x))
  (put 'add '(integer integer)
       (lambda (x y) (tag (+ x y))))
  (put 'sub '(integer integer)
       (lambda (x y) (tag (- x y))))
  (put 'mul '(integer integer)
       (lambda (x y) (tag (* x y))))
  (put 'div '(integer integer)
       (lambda (x y) (tag (/ x y))))
  (put 'make 'integer
       (lambda (x) (tag x)))
  (put 'equ? '(integer integer)
       (lambda (x y) (= x y)))
  (put '=zero? '(integer)
       (lambda (x) (zero? x)))
  (put 'raise '(integer)
       (lambda (x) (integer->rational x)))
  (put 'xsquare '(integer)
       (lambda (x) (tag (square x))));add
  (put 'xsqrt '(integer)
       (lambda (x) (tag (round (sqrt x)))));add
  (put 'xcos '(integer)
       (lambda (x) (tag (round (cos x)))));add
  (put 'xsin '(integer)
       (lambda (x) (tag (round (sin x)))));add
  (put 'xatan '(integer integer)
       (lambda (x y) (tag (round (atan x y)))));add
  'done)
(define (make-integer n)
  ((get 'make 'integer) n))

(define (install-rational-package)
  ;; internal procedures
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d)
    (let ((g (gcd n d)))
      (cons (/ n g) (/ d g))))
  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
              (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y))
              (* (denom x) (numer y))))
  (define (sin-rat x)
    (make-rat (round (sin (/ (numer x) (denom x))))
	      1));add
  (define (cos-rat x)
    (make-rat (round (cos (/ (numer x) (denom x))))
	      1));add
  (define (sqrt-rat x)
    (make-rat (round (sqrt (/ (numer x) (denom x))))
	      1));add
  (define (atan-rat x y)
    (make-rat (round (atan (/ (numer x) (denom x)) (/ (numer y) (denom y))))
	      1));add
  (define (square-rat x)
    (mul-rat x x));add
  (define (rational->real x)
    (make-real (/ (numer x) (denom x))))
  (define (rational->integer x)
    (make-integer (round (/ (numer x) (denom x)))))
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
       (lambda (x y) (and (= (numer x) (numer y))
			  (= (denom x) (denom y)))));change
  (put '=zero? '(rational)
       (lambda (x) (zero? (numer x))))
  (put 'raise '(rational)
       (lambda (x) (rational->real x)))
  (put 'project '(rational)
       (lambda (x) (rational->integer x)))
  (put 'xsin '(rational)
       (lambda (x) (tag (sin-rat x))));add
  (put 'xcos '(rational)
       (lambda (x) (tag (cos-rat x))));add
  (put 'xsqrt '(rational)
       (lambda (x) (tag (sqrt-rat x))));add
  (put 'xatan '(rational rational)
       (lambda (x y) (tag (atan-rat x y))));add
  (put 'xsquare '(rational)
       (lambda (x) (tag (square-rat x))));add
  'done)
(define (make-rational n d)
  ((get 'make 'rational) n d))

(define (install-real-package)
  (define (tag x)
    (attach-tag 'real x)) 
  (define (real->complex x)
    (make-complex-from-real-imag (make-integer (round x)) (make-integer 0)));change
  (define (real->rational x)
    (make-rational (round x) 1)) 
  (put '=zero? '(real)
       (lambda (x) (zero? x)))
  (put 'equ? '(real real)
       (lambda (x y) (= x y)))
  (put 'add '(real real)
       (lambda (x y) (tag (+ x y))))
  (put 'sub '(real real)
       (lambda (x y) (tag (- x y))))
  (put 'mul '(real real)
       (lambda (x y) (tag (* x y))))
  (put 'div '(real real)
       (lambda (x y) (tag (/ x y))))
  (put 'exp '(real real)
       (lambda (x y) (tag (expt x y))))
  (put 'make 'real
       (lambda (x) (tag x)))
  (put 'raise '(real)
       (lambda (x) (real->complex x)))
  (put 'project '(real)
       (lambda (x) (real->rational x)))
  'done)
(define (make-real n)
  ((get 'make 'real) n)) 

(define (install-rectangular-package)
  ;; internal procedures
  (define (real-part z) (car z))
  (define (imag-part z) (cdr z))
  (define (make-from-real-imag x y) (cons x y))
  (define (magnitude z)
    (xsqrt (add (xsquare (real-part z))
		(xsquare (imag-part z)))));change
  (define (angle z)
    (xatan (imag-part z) (real-part z)));change
  (define (make-from-mag-ang r a) 
    (cons (mul r (xcos a)) (mul r (xsin a))));change
  ;; interface to the rest of the system
  (define (tag x) (attach-tag 'rectangular x))
  (put 'real-part '(rectangular) real-part)
  (put 'imag-part '(rectangular) imag-part)
  (put 'magnitude '(rectangular) magnitude)
  (put 'angle '(rectangular) angle)
  (put 'make-from-real-imag 'rectangular 
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'rectangular 
       (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)
(define (install-polar-package)
  ;; internal procedures
  (define (magnitude z) (car z))
  (define (angle z) (cdr z))
  (define (make-from-mag-ang r a) (cons r a))
  (define (real-part z)
    (mul (magnitude z) (xcos (angle z))));change
  (define (imag-part z)
    (mul (magnitude z) (xsin (angle z))));change
  (define (make-from-real-imag x y) 
    (cons (xsqrt (add (xsquare x) (xsquare y)))
          (xatan y x)));change
  ;; interface to the rest of the system
  (define (tag x) (attach-tag 'polar x))
  (put 'real-part '(polar) real-part)
  (put 'imag-part '(polar) imag-part)
  (put 'magnitude '(polar) magnitude)
  (put 'angle '(polar) angle)
  (put 'make-from-real-imag 'polar
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'polar 
       (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)
(define (real-part z) (apply-generic 'real-part z))
(define (imag-part z) (apply-generic 'imag-part z))
(define (magnitude z) (apply-generic 'magnitude z))
(define (angle z) (apply-generic 'angle z))
(define (make-from-real-imag x y)
  ((get 'make-from-real-imag 'rectangular) x y))
(define (make-from-mag-ang r a)
  ((get 'make-from-mag-ang 'polar) r a))

(define (install-complex-package)
  ;; imported procedures from rectangular and polar packages
  (define (make-from-real-imag x y)
    ((get 'make-from-real-imag 'rectangular) x y))
  (define (make-from-mag-ang r a)
    ((get 'make-from-mag-ang 'polar) r a))
  ;; internal procedures
  (define (add-complex z1 z2)
    (make-from-real-imag (add (real-part z1) (real-part z2))
                         (add (imag-part z1) (imag-part z2))));change
  (define (sub-complex z1 z2)
    (make-from-real-imag (sub (real-part z1) (real-part z2))
                         (sub (imag-part z1) (imag-part z2))));change
  (define (mul-complex z1 z2)
    (make-from-mag-ang (mul (magnitude z1) (magnitude z2))
                       (add (angle z1) (angle z2))));change
  (define (div-complex z1 z2)
    (make-from-mag-ang (div (magnitude z1) (magnitude z2))
                       (sub (angle z1) (angle z2))));change
;;;change
;;;(define (complex->real z)
;;;(make-real (real-part z)))
  (define (complex->real z)
    (real-part z));add
  ;; interface to rest of the system
  (define (tag z) (attach-tag 'complex z))
  (put 'add '(complex complex)
       (lambda (z1 z2) (tag (add-complex z1 z2))))
  (put 'sub '(complex complex)
       (lambda (z1 z2) (tag (sub-complex z1 z2))))
  (put 'mul '(complex complex)
       (lambda (z1 z2) (tag (mul-complex z1 z2))))
  (put 'div '(complex complex)
       (lambda (z1 z2) (tag (div-complex z1 z2))))
  (put 'make-from-real-imag 'complex
       (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'complex
       (lambda (r a) (tag (make-from-mag-ang r a))))
  (put 'real-part '(complex) real-part)
  (put 'imag-part '(complex) imag-part)
  (put 'magnitude '(complex) magnitude)
  (put 'angle '(complex) angle)
  (put 'equ? '(complex complex)
       (lambda (z1 z2) (and (equ? (magnitude z1) (magnitude z2))
			    (equ? (angle z1) (angle z2)))));change
  (put '=zero? '(complex)
       (lambda (z) (=zero? (magnitude z))));change
  (put 'project '(complex)
       (lambda (z) (complex->real z)))
  'done)
(define (make-complex-from-real-imag x y)
  ((get 'make-from-real-imag 'complex) x y))
(define (make-complex-from-mag-ang r a)
  ((get 'make-from-mag-ang 'complex) r a))

(define (raise x)
  (apply-generic 'raise x))

(define (>-type? x y)
  (let ((px (get 'raise (list (type-tag x))))
	(py (get 'raise (list (type-tag y)))))
    (cond ((eq? px py) #f)
	  ((not py) #f)
	  ((not px) #t)
	  (else
	   (>-type? (px (contents x)) (py (contents y)))))))

(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
	  (let ((applied (apply proc (map contents args))))
	    (if (or (eq? op 'raise)
		    (eq? applied #t)
		    (eq? applied #f))
		applied
		(drop applied)))
	  (if (= (length args) 2)
	      (let ((type1 (car type-tags))
		    (type2 (cadr type-tags))
		    (a1 (car args))
		    (a2 (cadr args)))
		(cond ((eq? type1 type2)
		       (error "No method for these types"
			      (list op type-tags)))
		      ((>-type? a1 a2) (apply-generic op a1 (raise a2)))
		      ((>-type? a2 a1) (apply-generic op (raise a1) a2))
		      (else #f)))
	      (error "No method for these types"
		     (list op type-tags)))))))

(define (drop x)
  (let ((project-x (project x)))
    (if (not project-x)
	x
	(let ((project-raise-x (raise project-x)))
	  (if (equ? x project-raise-x)
	      (drop project-x)
	      x)))))

(define (project x)
  (let ((proc (get 'project (list (type-tag x)))))
    (if proc
	(proc (contents x))
	#f)))

(install-integer-package)
(install-rational-package)
(install-real-package)
(install-complex-package)
(install-rectangular-package)
(install-polar-package)
(define int3 (make-integer 3))
(define int4 (make-integer 4))
(define int10 (make-integer 10))
(define int0 (make-integer 0))
(define rat1 (make-rational 3 10))
(define rat2 (make-rational 3 3))
(define rat3 (make-rational 0 1))
(define comp1 (make-complex-from-real-imag int4 int10))
(define comp2 (make-complex-from-mag-ang int4 int10))
(define comp3 (make-complex-from-real-imag rat1 rat2))
(define comp4 (make-complex-from-mag-ang rat1 rat2))
(define comp5 (make-complex-from-real-imag rat1 rat3))

(magnitude comp1)
(angle comp1)
(real-part comp2)
(imag-part comp2)
(magnitude comp3)
(angle comp3)
(real-part comp4)
(imag-part comp4)

(drop comp1)
(drop comp2)
(drop comp3)
(drop comp4)
(drop comp5)
