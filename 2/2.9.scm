;; w1=(u1-l1)/2,w2=(u2-l1)/2
;;
;; uadd = u1+u2,ladd = l1+l2
;; wadd = (uadd-ladd)/2
;;      = ((u1+u2)-(l1+l2))/2
;;      = w1+w2
;;
;; usub = u1-u2,lsub = l1-l2
;; wsub = (usub-lsub)/2
;;      = ((u1-u2)-(l1-l2))/2
;;      = w1-w2
;;
;; umul = u1*u2,lmul = l1*l2
;; wmul = (umul-lmul)/2
;;      = ((u1*u2)-(l1*l2))/2
;;      ->w1,w2の関数にはならない
;;
;; udiv = u1*(1/u2),ldiv = l1*(1/l2)
;; wmul = (udiv-ldiv)/2
;;      = ((u1*(1/u2))-(l1*(1/l2)))/2
;;      ->w1,w2の関数にはならない


(define (width x) (/ (- (upper-bound x) (lower-bound x)) 2))
(define (add-interval x y)
  (make-interval (+ (lower-bound x) (lower-bound y))
		 (+ (upper-bound x) (upper-bound y))))
(define (sub-interval x y)
  (make-interval (- (lower-bound x) (upper-bound y))
		 (- (upper-bound x) (lower-bound y))))
(define (mul-interval x y)
  (let ((p1 (* (lower-bound x) (lower-bound y)))
	(p2 (* (lower-bound x) (upper-bound y)))
	(p3 (* (upper-bound x) (lower-bound y)))
	(p4 (* (upper-bound x) (upper-bound y))))
    (make-interval (min p1 p2 p3 p4)
		   (max p1 p2 p3 p4))))
(define (div-interval x y)
  (mul-interval x
		(make-interval (/ 1.0 (upper-bound y))
			       (/ 1.0 (lower-bound y)))))
(define (make-interval a b) (cons a b))
(define (lower-bound x) (car x))
(define (upper-bound x) (cdr x))

