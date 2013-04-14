(define (subsets s)
  (if (null? s)
      (list ())
      (let ((rest (subsets (cdr s))))
	(append rest (map (lambda (x) (cons (car s) x))
			  rest)))))
;;共有構造で結果が表現されるため、視認性のためにprint出力している
(print (subsets (list 1 2 3)))

;;理由
;;第1要素と残りの全ての部分集合のそれぞれとのペアを生成し、リストとしてつなぐことで、全ての部分集合のリストが生成できる