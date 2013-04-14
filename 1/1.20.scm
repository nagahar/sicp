(define (gcd a b)
  (if (= b 0)
      a
      (gcd b (remainder a b))))

;; 正規順序　remainderは18回実行される
;; 
;; (gcd 40 (remainder 203 40))
;; (if (= (remainder 203 40) 0))
;*****1
;;
;; (gcd (remainder 203 40) (remainder 40 (remainder 203 40)))
;; (if (= (remainder 40 (remainder 203 40))))
;*****2
;;
;; (gcd (remainder 40 (remainder 203 40))
;;     (remainder (remainder 203 40) (remainder 40 (remainder 203 40))))
;; (if (= (remainder (remainder 203 40) (remainder 40 (remainder 203 40))) 0))
;*****4
;; 
;; (gcd (remainder (remainder 203 40) (remainder 40 (remainder 203 40)))
;;     (remainder (remainder 40 (remainder 203 40)) (remainder (remainder 203 40) (remainder 40 (remainder 203 40)))))
;; (if (remainder (remainder 40 (remainder 203 40)) (remainder (remainder 203 40) (remainder 40 (remainder 203 40)))) 0))
;*****7 
;; (remainder (remainder 203 40) (remainder 40 (remainder 203 40)))
;*****4


;; 作用順序 remainderは4回実行される
;; (gcd 40 (remainder 203 40))
;; (gcd 6 (remainder 40 6))
;; (gcd 4 (remainder 6 4))
;; (gcd 2 (remainder 4 2))

