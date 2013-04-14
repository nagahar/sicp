;; 理由：ccはcoin-valuesの区別が出来れば、当該硬貨での両替時、その他の硬貨での両替時での場合の数が計算できるため、順序には影響しない

(cc 100 us-coins)
(cc 100 us-coins1)

(define us-coins (list 50 25 10 5 1))
(define us-coins1 (list 25 50 1 5 10))
(define uk-coins (list 100 50 20 10 5 2 1 0.5))

(define (cc amount coin-values)
  (cond ((= amount 0) 1)
	((or (< amount 0) (no-more? coin-values)) 0)
	(else
	 (+ (cc amount
		(except-first-denomination coin-values))
	    (cc (- amount
		   (first-denomination coin-values))
		coin-values)))))
(define (first-denomination coin-values)
  (car coin-values))
(define (except-first-denomination coin-values)
  (cdr coin-values))
(define (no-more? coin-values)
  (null? coin-values))
