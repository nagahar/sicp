(define (make-withdraw initial-amount)
  (let ((balance initial-amount))
    (lambda (amount)
      (if (>= balance amount)
          (begin (set! balance (- balance amount))
                 balance)
          "Insufficient funds"))))

;;(let ((<var> <exp>)) <body>)
;;((lambda (<var>) <body>) <exp>)

(define W1 (make-withdraw 100))
;;
;; - global
;;    make-withdraw: <-> initial-amount, ((lambda (balance) ...) initial-amount)
;;    W1: -> amount, (lambda (amount) ...
;;    <- E1
;;       initial-amount: 100
;;    <- E2
;;       balance: 100
;;       <- amount, (lambda (amount) ...

(W1 50)
;;
;; - global
;;    make-withdraw: <-> initial-amount, ((lambda (balance) ...) initial-amount)
;;    W1: -> amount, (lambda (amount) ...
;;    <- E1
;;       initial-amount: 100
;;    <- E2
;;       balance: 100
;;       <- amount, (lambda (amount) ...
;;       <- E3
;;          amount: 50

(define W2 (make-withdraw 100))
;;
;; - global
;;    make-withdraw: <-> initial-amount, ((lambda (balance) ...) initial-amount)
;;    W1: -> amount, (lambda (amount) ...
;;    W2: -> amount, (lambda (amount) ...
;;    <- E2
;;       balance: 100
;;       <- amount, (lambda (amount) ...
;;    <- E4
;;       initial-amount: 100
;;       <- amount, (lambda (amount) ...
;;    <- E5
;;       balance: 100

