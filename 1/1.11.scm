;; recursive

(define (f n)
  (if (< n 3)
    n
    (+ (f (- n 1)) (* 2 (f (- n 2))) (* 3 (f (- n 3))))))

(f 5)
;25

;; iterative

(define (f n)
  (define (f-iter n1 n2 n3 count)
    (if (= n count)
      n3
      (f-iter (+ n1 (* 2 n2) (* 3 n3)) n1 n2  (+ count 1))))
  (f-iter 2 1 0 0))

(f 5)
;25
