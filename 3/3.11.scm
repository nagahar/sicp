(define (make-account balance)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch m)
    (cond ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          (else (error "Unknown request -- MAKE-ACCOUNT"
                       m))))
  dispatch)

(define acc (make-account 50))
;; - global
;;    make-account: <-> balance, (define (withdraw amount) ...
;;    acc: -> m, (cond ((eq? m 'withdraw) withdraw)
;;    <- E1
;;       balance: 50
;;       withdraw: <-> amount,...
;;       deposit: <-> amount,...
;;       dispatch: <-> m, (cond ((eq? m 'withdraw) withdraw)

((acc 'deposit) 40)
90
;; - global
;;    make-account: <-> balance, (define (withdraw amount) ...
;;    acc: -> m, (cond ((eq? m 'withdraw) withdraw)
;;    <- E1
;;        balance: 90
;;        withdraw: <-> amount,...
;;        deposit: <-> amount,...
;;        dispatch: <-> m, (cond ((eq? m 'withdraw) withdraw)
;;        <- E2
;;            m: 'deposit
;;        <- E3
;;            amount: 40

((acc 'withdraw) 60)
30
;; - global
;;    make-account: <-> balance, (define (withdraw amount) ...
;;    acc: -> dispatch
;;    <- E1
;;        balance: 30
;;        withdraw: <-> amount,...
;;        deposit: <-> amount,...
;;        dispatch: <-> m, (cond ((eq? m 'withdraw) withdraw)
;;        <- E4
;;            m: 'withdraw
;;        <- E5
;;            amount: 60

(define acc2 (make-account 100))
;; - global
;;    make-account: <-> balance, (define (withdraw amount) ...
;;    acc: -> dispatch
;;    acc2: -> dispatch
;;    <- E1
;;        balance: 30
;;        withdraw: <-> amount,...
;;        deposit: <-> amount,...
;;        dispatch: <-> m, (cond ((eq? m 'withdraw) withdraw)
;;    <- E6
;;        balance: 100
;;        withdraw: <-> amount,...
;;        deposit: <-> amount,...
;;        dispatch: <-> m, (cond ((eq? m 'withdraw) withdraw)

