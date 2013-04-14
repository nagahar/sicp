;; 正しくない
;; 交換の場合は各残高の順序は維持されなければならないが、転送の場合は残高の合計が正しければ良いという違いがある
;; 従ってtransferを直列化しなくても残高の合計は維持されるため、今のままで良い

(define (transfer from-account to-account amount)
  ((from-account 'withdraw) amount)
  ((to-account 'deposit) amount))

