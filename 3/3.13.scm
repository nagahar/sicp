(define (last-pair x)
  (if (null? (cdr x))
      x
      (last-pair (cdr x))))
(define (make-cycle x)
  (set-cdr! (last-pair x) x)
  x)

(define z (make-cycle (list 'a 'b 'c)))
(last-pair z)
;; => 応答なし。last-pairの(cdr x)が実行され続ける
;;
;;      ------------
;;      v          |
;; z => o:o>o:o>o:o-
;;      v   v   v
;;      a   b   c

