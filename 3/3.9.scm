(define (factorial n)
  (if (= n 1)
      1
      (* n (factorial (- n 1)))))

(factrial 6)
;;
;; - global
;;    factorial: <-> n, body
;;    <- E1
;;        n: 6
;;    <- E2
;;        n: 5
;;    <- E3
;;        n: 4
;;    <- E4
;;        n: 3
;;    <- E5
;;        n: 2
;;    <- E6
;;        n: 1

(define (factorial n)
  (fact-iter 1 1 n))
(define (fact-iter product counter max-count)
  (if (> counter max-count)
      product
      (fact-iter (* counter product)
                 (+ counter 1)
                 max-count)))

(factrial 6)
;;
;; - global
;;    factorial: <-> n, body
;;    fact-iter: <-> product counter max-count, body
;;    <- E1
;;        n: 6
;;    <- E2
;;        product: 1
;;        counter: 1
;;        max-count: 6
;;    <- E3
;;        product: 1
;;        counter: 2
;;        max-count: 6
;;    <- E4
;;        product: 2
;;        counter: 3
;;        max-count: 6
;;    <- E5
;;        product: 6
;;        counter: 4
;;        max-count: 6
;;    <- E6
;;        product: 24
;;        counter: 5
;;        max-count: 6
;;    <- E7
;;        product: 120
;;        counter: 6
;;        max-count: 6
;;    <- E8
;;        product: 720
;;        counter: 7
;;        max-count: 6
