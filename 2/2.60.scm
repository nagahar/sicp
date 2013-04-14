(define (element-of-set? x set)
  (cond ((null? set) #f)
        ((equal? x (car set)) #t)
        (else (element-of-set? x (cdr set)))))
(define (adjoin-set x set)
  (cons x set))
(define (intersection-set set1 set2)
  (cond ((or (null? set1) (null? set2)) '())
        ((element-of-set? (car set1) set2)        
         (cons (car set1)
               (intersection-set (cdr set1) set2)))
        (else (intersection-set (cdr set1) set2))))
(define (union-set set1 set2)
  (cond ((and (null? set1) (null? set2)) '())
	((and (null? set1) (not (null? set2))) set2)
	((and (not (null? set1)) (null? set2)) set1)
        (else (append set1 set2))))

;adjoint-set, union-setにおいて効率がΘ(1)になる
;intersection-setは重複分効率が低下するΘ(n+a)(a:重複分)
;集合のマージ、要素の追加作業が頻繁に発生する場合に処理速度が早い