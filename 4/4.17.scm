;; 内部定義の場合
(define a
  (lambda <vars>
    (define u <e1>)
    (define v <e2>)
    <e3>))
(a val)
;; - global
;;    a: <-> <vars>, (define u ...)
;;    <- E1
;;       vars: val
;;       u: <e1>
;;       v: <e2>

;; 掃き出した場合
(define b
  (lambda <vars>
    (scan-out-defines '((define u <e1>) (define v <e2>) <e3>))))
(b val)
;; - global
;;    scan-out-defines: <-> body, ((use ...))
;;    b: <-> vars, (scan-out-defines ...)
;;    <- E1
;;       vars: val
;;       <- E2
;;          body: '((define ...) ...)
;;          <- E3
;;             u: <e1>
;;             v: <e2>

;; 掃き出した場合はscan-out-definesの実行に関するフレーム(E2)が余計にある
;; (これらは、letが自身が呼び出された環境を拡張した環境(extend-environment)に引数名をバインドするために生成される)
;; しかし、変数探索(lookup-variable-value)は上位のフレームを次々と探索するため、プログラムの行動の本質には影響しない
;; 余計なフレームを構成しないためには、scan-out-definesを利用せず、evalにおいて内部定義を同時に評価するような設計が考えられる

