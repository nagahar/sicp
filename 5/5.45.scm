;; a.
;; 階乗の実験結果
;; 翻訳版(下記より)
;; スタックの最大深さ = 3 (n=1), 3 * n - 1 (n>=2)
;; スタックのプッシュの総数 = 6 * n + 1
;;
;; 解釈版(5.27より)
;; スタックの最大深さ = 5 * n + 3
;; スタックのプッシュの総数 = 32 * n + 16
;
;; 特殊目的計算機(5.14より)
;; スタックの最大深さ = 2 * n - 2
;; スタックのプッシュの総数 = 2 * n - 2
;;
;; 比較
;; 翻訳版と解釈版の比較
;; スタックの最大深さの比 = (3n-1)/(5n+3)
;; n->infのとき3/5(定数)となる
;; スタックのプッシュ回数の比 = (6n+1)/(32n+16)
;; n->infのとき3/16(定数)となる
;;
;; 特殊目的計算機と解釈版の比較
;; スタックの最大深さの比 = (2n-2)/(5n+3)
;; n->infのとき2/5(定数)となる
;; スタックのプッシュ回数の比 = (2n-2))/(32n+16)
;; n->infのとき1/16(定数)となる
;;
;; b.
;; 関数呼び出しのオーバヘッド(argl, proc, continue)を無くすために積極的にインライン展開するなど・・・？
;;

(load "../explicit-control_evaluator2.scm")
(compile-and-go
  '(define (factorial n)
     (if (= n 1)
       1
       (* (factorial (- n 1)) n))))

;;;; EC-Eval2 input:
;(factorial 1)
;
;(total-pushes = 7 maximum-depth = 3)
;;;; EC-Eval2 value:
;1
;
;;;; EC-Eval2 input:
;(factorial 2)
;
;(total-pushes = 13 maximum-depth = 5)
;;;; EC-Eval2 value:
;2
;
;;;; EC-Eval2 input:
;(factorial 3)
;
;(total-pushes = 19 maximum-depth = 8)
;;;; EC-Eval2 value:
;6
;
;;;; EC-Eval2 input:
;(factorial 4)
;
;(total-pushes = 25 maximum-depth = 11)
;;;; EC-Eval2 value:
;24
;
;;;; EC-Eval2 input:
;(factorial 5)
;
;(total-pushes = 31 maximum-depth = 14)
;;;; EC-Eval2 value:
;120
