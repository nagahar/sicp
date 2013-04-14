(define (make-joint acc ac-password new-password)
  (define (dispatch passwd m)
    (if (not (eq? new-password passwd))
        (lambda (x) "Incorrect password")
        (acc ac-password m)))
  (if (acc ac-password 'match-password)
      dispatch
      (error "Invalid password")))
(define (make-account balance pass)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (pass-miss amount)
    "Incorrect password")
  (define (match-password new-pass)
    (eq? pass new-pass))
  (define (dispatch p m)
    (cond ((eq? m 'match-password) (match-password p))
	  ((not (eq? p pass)) pass-miss)
	  ((eq? m 'withdraw) withdraw)
	  ((eq? m 'deposit) deposit)
	  (else (error "Unknown request -- MAKE-ACCOUNT"
		       m))))
  dispatch)

(define peter-acc (make-account 100 'open-sesame))
((peter-acc 'open-sesame 'withdraw) 40)
(define paul-acc (make-joint peter-acc 'open-sesame 'rosebud))
((paul-acc 'rosebud 'deposit) 50)
((peter-acc 'rosebud 'deposit) 50)
((peter-acc 'open-sesame 'deposit) 50)
(define bad-acc (make-joint peter-acc 'open 'rosebud))
((bad-acc 'rosebud 'withdraw) 40)