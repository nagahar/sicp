;; 初期状態:
;; (a1, a2, a3)
;; = (30, 20, 10)
;; a1とa2がPaulによって交換され、a1とa3がPeterによって交換される
;;
;;
;; exchangeが逐次処理される
;; (a1, a2, a3)
;; = (10, 30, 20), (20, 10, 30)
;;
;;
;; exchangeは並列実行され、exchange操作は直列化されない
;; 残高の順序は維持されない
;; 合計は維持される
;;
;; タイミングチャート
;; Peter						a1	a2	a3	Paul
;;  							30	20	10
;; a1(30)にアクセス
;; a2(20)にアクセス
;; a1-a2の計算
;;  										a1(30)にアクセス
;;  										a3(10)にアクセス
;;  										a1-a3の計算
;;  							30	20	10	差分(20)をa1から払い出し処理
;;  							10	20	10	差分(20)をa1から払い出し完了
;;  							10	20	10	差分(20)をa3に預け入れ処理
;;  							10	20	30	差分(20)をa3に預け入れ完了
;; 差分(10)をa1から払い出し処理	10	20	30
;; 差分(10)をa1から払い出し完了	0	20	30
;; 差分(10)をa2に預け入れ処理	0	20	30
;; 差分(10)をa2に預け入れ完了	0	30	30
;;
;;
;; exchangeは並列実行され、exchange、depsit、withdrawの操作は直列化されない
;; 残高の順序、合計は維持されない
;;
;; タイミングチャート
;; Peter						a1	a2	a3	Paul
;;  							30	20	10
;; a1(30)にアクセス
;; a2(20)にアクセス
;; a1-a2の計算
;; 差分(10)をa1から払い出し処理	30	20	10
;;  										a1(30)にアクセス
;;  										a3(10)にアクセス
;;  										a1-a3の計算
;;  							30	20	10	差分(20)をa1から払い出し処理
;;  							10	20	10	差分(20)をa1から払い出し完了
;;  							10	20	10	差分(20)をa3に預け入れ処理
;;  							10	20	30	差分(20)をa3に預け入れ完了
;; 差分(10)をa1から払い出し完了	20	20	30
;; 差分(10)をa2に預け入れ処理	20	20	30
;; 差分(10)をa2に預け入れ完了	20	30	30

(define (exchange account1 account2)
  (let ((difference (- (account1 'balance)
					   (account2 'balance))))
	((account1 'withdraw) difference)
	((account2 'deposit) difference)))

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
	  (cond ((eq? m 'withdraw) withdraw)
		((eq? m 'deposit) deposit)
		((eq? m 'balance) balance)
		((eq? m 'serializer) balance-serializer)
		(else (error "Unknown request -- MAKE-ACCOUNT"
					 m))))
	dispatch))

(define (deposit account amount)
  (let ((s (account 'serializer))
		(d (account 'deposit)))
	((s d) amount)))

(define (serialized-exchange account1 account2)
  (let ((serializer1 (account1 'serializer))
		(serializer2 (account2 'serializer)))
	((serializer1 (serializer2 exchange))
	 account1
	 account2)))

