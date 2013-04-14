;; 全ての組み合わせを作りfilterする

(use srfi-1)
(use util.combinations)

(define (distinct? items)
  (cond ((null? items) #t)
    ((null? (cdr items)) #t)
    ((member (car items) (cdr items)) #f)
    (else (distinct? (cdr items)))))

(define (multiple-dwelling-filter items)
  (let ((baker (car items))
	(cooper (cadr items))
	(fletcher (caddr items))
	(miller (cadddr items))
	(smith (car (cddddr items))))
    (and (distinct? items)
      (not (= baker 5))
      (not (= cooper 1))
      (not (= fletcher 5))
      (not (= fletcher 1))
      (> miller cooper)
      (not (= (abs (- smith fletcher)) 1))
      (not (= (abs (- fletcher cooper)) 1)))))

(filter multiple-dwelling-filter (permutations* '(1 2 3 4 5)))
;;((3 2 4 5 1))

