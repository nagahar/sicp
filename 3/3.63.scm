(load "../stream.scm")
;; Louis Reasoner の方法だとoriginalの版に比較してsqrt-improveの計算が繰り返し行われる分非効率になる
;; memo-procを使わないと、両者は同じ計算量になる
(define (sqrt-stream x)
  (cons-stream 1.0
			   (stream-map (lambda (guess)
							 (sqrt-improve guess x))
						   (sqrt-stream x))))
;; original
(define (sqrt-stream x)
  (define guesses
	(cons-stream 1.0
				 (stream-map (lambda (guess)
							   (sqrt-improve guess x))
							 guesses)))
  guesses)
