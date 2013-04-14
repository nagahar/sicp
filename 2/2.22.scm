;; (16 9 4 1)
;; 逆順のリストを生成する理由：
;; 先頭要素から順に前方に追加されていくリストを生成しているため
(define (square-list items)
  (define (iter things answer)
    (if (null? things)
	answer
	(iter (cdr things)
	      (cons (expt (car things) 2)
		    answer))))
  (iter items ()))
;; ((((() . 1) . 4) . 9) . 16)
;; 理由：
;; リストの後方に追加する場合は最終要素に対して構成子(cons)を適用しなければならないが、本手続きではリスト全体に対して構成子を適用しているため
(define (square-list items)
  (define (iter things answer)
    (if (null? things)
	answer
	(iter (cdr things)
	      (cons answer
		    (expt (car things) 2)))))
  (iter items ()))
(square-list (list 1 2 3 4))