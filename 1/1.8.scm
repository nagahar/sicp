(define (cube x)
  (* x x x))
(define (square x)
  (* x x))
(define (good-enough? guess x)
  (< (abs (- 1 (/ (cube guess) x))) 0.001))
(define (improve-cube guess x)
  (/ (+ (/ x (square guess)) (* 2 guess)) 3))
(define (cbrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (cbrt-iter (improve-cube guess x)
		 x)))
(define (cbrt x)
  (cbrt-iter 1.0 x))

(cube (cbrt 1.0E-9))
(cube (cbrt 1.0E43))