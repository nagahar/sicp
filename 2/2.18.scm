(reverse (list 1 4 9 16 25))

(define (reverse list1)
  (define (reverse-iter a result)
    (if (null? a)
	result
	(reverse-iter (cdr a) (cons (car a) result))))
  (reverse-iter list1 ()))