;; 賛成しない
;; ロックをかけない限り、直列化しても残高を閲覧するタイミングによって値は不定になるため

(define (make-account balance)
  (define (withdraw amount)
	(if (>= balance amount)
	  (begin (set! balance (- balance amount))
		balance)
	  "Insufficient funds"))
  (define (deposit amount)
	(set! balance (+ balance amount))
	balance)
  (let ((protected (make-serializer)))
	(define (dispatch m)
	  (cond ((eq? m 'withdraw) (protected withdraw))
		((eq? m 'deposit) (protected deposit))
		((eq? m 'balance)
		 ((protected (lambda () balance)))) ; serialized
		(else (error "Unknown request -- MAKE-ACCOUNT"
					 m))))
	dispatch))

;; original
(define (make-account balance)
  (define (withdraw amount)
	(if (>= balance amount)
	  (begin (set! balance (- balance amount))
		balance)
	  "Insufficient funds"))
  (define (deposit amount)
	(set! balance (+ balance amount))
	balance)
  (let ((protected (make-serializer)))
	(define (dispatch m)
	  (cond ((eq? m 'withdraw) (protected withdraw))
		((eq? m 'deposit) (protected deposit))
		((eq? m 'balance) balance)
		(else (error "Unknown request -- MAKE-ACCOUNT"
					 m))))
	dispatch))

