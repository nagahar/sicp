;; 正しい
;; 4.35の版とBenの版のi,jの可能性の数は同じだが、Benの版にはkの探索が無い(可能性の数が0である)ため、Benの版の方が効率的である

(define (an-integer-between low high)
  (require (< low high))
  (amb low (an-integer-between (+ low 1) high)))

;; 4.35 ver.
(define (a-pythagorean-triple-between low high)
  (let ((i (an-integer-between low high)))
    (let ((j (an-integer-between i high)))
      (let ((k (an-integer-between j high)))
	(require (= (+ (* i i) (* j j)) (* k k)))
	(list i j k)))))

;; Ben ver.
(define (a-pythagorean-triple-between low high)
  (let ((i (an-integer-between low high))
	(hsq (* high high)))
    (let ((j (an-integer-between i high)))
      (let ((ksq (+ (* i i) (* j j))))
	(require (>= hsq ksq))
	(let ((k (sqrt ksq)))
	  (require (integer? k))
	  (list i j k))))))

