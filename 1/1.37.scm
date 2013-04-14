;; a. iterative
(define (cont-frac n d k)
  (define (iter count result)
    (if (= count 0)
      result
      (iter (- count 1) (/ (n count) (+ result (d count))))))
  (iter k 0))

(cont-frac (lambda (i) 1.0)
	   (lambda (i) 1.0)
	   11)
;; k>=11
;; 0.6180555555555556
;; 1/φ=0.6180344478216819
(/ 1 (fixed-point (lambda (x) (+ 1 (/ 1 x))) 1.0))
(define tolerance 0.00001)
(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
	  next
	  (try next))))
  (try first-guess))

;; b. recursive
(define (cont-frac n d k)
  (if (= k 1)
      (/ (n k) (d k))
      (/ (n k) (+ (d k) (cont-frac n d (- k 1))))))
