;; a.
((lambda (n)
   ((lambda (fact)
      (fact fact n))
    (lambda (ft k)
      (if (= k 1)
	1
	(* k (ft ft (- k 1)))))))
 10)
;; 3628800

((lambda (n)
   ((lambda (fact)
      (fact fact n))
    (lambda (ft k)
      (if (or (= k 1) (= k 2))
	1
	(+ (ft ft (- k 1)) (ft ft (- k 2)))))))
 10)
;; 55
;; 1 1 2 3 5 8 13 21 34 55

;; b.
(define (f x)
  (define (even? n)
    (if (= n 0)
      true
      (odd? (- n 1))))
  (define (odd? n)
    (if (= n 0)
      false
      (even? (- n 1))))
  (even? x))

(define (f x)
  ((lambda (even? odd?)
     (even? even? odd? x))
   (lambda (ev? od? n)
     (if (= n 0) #t (od? ev? od? (- n 1))))
   (lambda (ev? od? n)
     (if (= n 0) #f (ev? ev? od? (- n 1))))))

