;; cons-streamは第2引数の評価を遅延させるため、本問のadd-assertion!では、assertionが追加された後のTHE-ASSERTIONSが代入されてしまうことになる
;; すなわちassertionが二回追加されてしまうことになるため、本問の実装は問題がある
;;
;; original ver.
(define (add-assertion! assertion)
  (store-assertion-in-index assertion)
  (let ((old-assertions THE-ASSERTIONS))
    (set! THE-ASSERTIONS
      (cons-stream assertion old-assertions))
    'ok))

;; wrong ver.
(define (add-assertion! assertion)
  (store-assertion-in-index assertion)
  (set! THE-ASSERTIONS
    (cons-stream assertion THE-ASSERTIONS))
  'ok)
