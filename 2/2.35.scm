(define (enumerate-tree tree)
  (cond ((null? tree) ())
	((not (pair? tree)) (list tree))
	(else (append (enumerate-tree (car tree))
		      (enumerate-tree (cdr tree))))))
(define (count-leaves t)
  (accumulate +
	      0
	      (map length (map enumerate-tree t))))
(define x (cons (list 1 2) (list 3 4)))
(count-leaves x)
(count-leaves (list x x))