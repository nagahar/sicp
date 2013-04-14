(define (max x y) (if (> x y) x y))
(define (max3 x y z) (max (max x y) z))
(define (square x) (* x x))
(define (sum-of-square x y) (+ (square x) (square y)))
(define (smax x y z) (if (= (max3 x y z) x)
			 (max y z)
			 (if (= (max3 x y z) y)
			     (max x z)
			     (if (= (max3 x y z) z)
				 (max x y)))))
(define (f x y z) (sum-of-square (max3 x y z) (smax x y z)))
(f 2 2 2)