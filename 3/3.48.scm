;; 口座1と2がある場合、Peter、Paulがそれぞれ先に口座1のシリアライザーを獲得するようにすれば、デッドロックは回避できる

(define (make-account-and-serializer balance number)
  (define (withdraw amount)
	(if (>= balance amount)
	  (begin (set! balance (- balance amount))
		balance)
	  "Insufficient funds"))
  (define (deposit amount)
	(set! balance (+ balance amount))
	balance)
  (let ((balance-serializer (make-serializer)))
	(define (dispatch m)
	  (cond ((eq? m 'withdraw) withdraw)
		((eq? m 'deposit) deposit)
		((eq? m 'balance) balance)
		((eq? m 'serializer) balance-serializer)
		((eq? m 'number) number)
		(else (error "Unknown request -- MAKE-ACCOUNT"
					 m))))
	dispatch))

(define (serialized-exchange account1 account2)
  (let ((serializer1 (account1 'serializer))
		(serializer2 (account2 'serializer)))
	(if (> (account1 'number) (account2 'number))
	  ((serializer1 (serializer2 exchange))
	   account1
	   account2)
	  ((serializer2 (serializer1 exchange))
	   account1
	   account2))))

(define (exchange account1 account2)
  (let ((difference (- (account1 'balance)
					   (account2 'balance))))
	((account1 'withdraw) difference)
	((account2 'deposit) difference)))

