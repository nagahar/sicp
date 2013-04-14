;; list, newline, displayを基本手続きに追加しておく
(load "../lazy-metacircular.scm")

(define (eval-sequence exps env)
  (cond ((last-exp? exps) (eval (first-exp exps) env))
    (else (actual-value (first-exp exps) env)
      (eval-sequence (rest-exps exps) env))))

(define (for-each proc items)
  (if (null? items)
    'done
    (begin (proc (car items))
      (for-each proc (cdr items)))))
(driver-loop)
;; a.
;; newline, displayは基本手続きであるため、いずれのeval-sequenceであっても、applyにおいて引数は評価されるため
;; 下式の例だけではCyが正しいことは証明できず、Benは正しい
(for-each (lambda (x) (newline) (display x))
	  (list 57 321 88))


;; b.
;; original
;;;; L-Eval input:
;(p1 1)
;;;; L-Eval value:
;(1 2)
;;;; L-Eval input:
;(p2 1)
;;;; L-Eval value:
;1

;; Cy's proposed
;;;; L-Eval input:
;(p1 1)
;;;; L-Eval value:
;(1 2)
;;;; L-Eval input:
;(p2 1)
;;;; L-Eval value:
;(1 2)

(define (p1 x)
  (set! x (cons x '(2)))
  x)
(define (p2 x)
  (define (p e)
    e
    x)
  (p (set! x (cons x '(2)))))

;; c.
;; a.の理由に同じ

;; d.
;; 遅延評価器では並びの最終値のみが遅延されるべきである。
;; Cyの解決法は好きである。
;; 本文の解決法は並びの中間値も遅延されるため、b.の例のような現象が生じる
