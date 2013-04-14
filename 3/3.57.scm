(load "../stream.scm")
(define fibs
  (cons-stream 0
			   (cons-stream 1
							(add-streams (stream-cdr fibs)
										 fibs))))
;; メモ化の場合 n番目を計算する時の加算回数は n-1 回
;; 非メモ化の場合 n番目を計算する時の加算回数は n(n-1)/2 回

