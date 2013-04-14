(define x (list (list 1 2) (list 3 4)))
(define (reverse list1)
  (define (reverse-iter a result)
    (if (null? a)
	result
	(reverse-iter (cdr a) (cons (car a) result))))
  (reverse-iter list1 ()))
(define (deep-reverse list1)
    (if (not (pair? list1))
	list1
	(reverse (map deep-reverse list1))))
(deep-reverse x)
(reverse x)
