;; 下記の理由によりserialized-exchangeの呼び出しはデッドロックを発生する
;;
;; withdrawはexchange内のserializer1により、(serializer2 exchange)より後に実行されるように直列化されるが、(serializer2 exchange)の終了は、exchangeの実行後であるため、withdrawより前には終了しない

(define (make-account-and-serializer balance)
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
	  (cond ((eq? m 'withdraw) (balance-serializer withdraw))
		((eq? m 'deposit) (balance-serializer deposit))
		((eq? m 'balance) balance)
		((eq? m 'serializer) balance-serializer)
		(else (error "Unknown request -- MAKE-ACCOUNT"
					 m))))
	dispatch))

(define (serialized-exchange account1 account2)
  (let ((serializer1 (account1 'serializer))
		(serializer2 (account2 'serializer)))
	((serializer1 (serializer2 exchange))
	 account1
	 account2)))

(define (exchange account1 account2)
  (let ((difference (- (account1 'balance)
					   (account2 'balance))))
	((account1 'withdraw) difference)
	((account2 'deposit) difference)))

