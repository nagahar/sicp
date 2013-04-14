(define (make-mobile left right)
  (list left right))
(define (make-branch length structure)
  (list length structure))
;; a.
(define (left-branch mobile)
  (car mobile))
(define (right-branch mobile)
  (car (cdr mobile)))
(define (branch-length branch)
  (car branch))
(define (branch-structure branch)
  (car (cdr branch)))
;; b.
(define (total-weight mobile)
  (cond	((null? mobile) 0)
	((pair? mobile)
	 (+ (total-weight (branch-structure (left-branch mobile)))
	    (total-weight (branch-structure (right-branch mobile)))))
	(else mobile)))
;; c.
(define (balanced? mobile)
  (cond ((null? mobile) (null? mobile))
	((pair? mobile)
	 (let ((left-mobile (branch-structure (left-branch mobile)))
	       (right-mobile (branch-structure (right-branch mobile))))
	   (and (= (* (total-weight left-mobile)
		      (branch-length (left-branch mobile)))
		   (* (total-weight right-mobile)
		      (branch-length (right-branch mobile))))
		(and (balanced? left-mobile)
		     (balanced? right-mobile)))))
	(else (not (pair? mobile)))))
;;d.
(define (make-mobile left right)
  (cons left rigth))
(define (make-branch length structure)
  (cons length structure))
;;right-branchとbranch-structureを下記のように変更するだけである
(define (right-branch mobile)
  (cdr mobile))
(define (branch-structure branch)
  (cdr branch))

;;テスト
(define mob1
  (make-mobile
   (make-branch 1 10)
   (make-branch 2 5)))
(define mob2
  (make-mobile
   (make-branch 1 10)
   (make-branch 3 5)))
(define mob
  (make-mobile
   (make-branch 5 mob1)
   (make-branch 5 mob2)))
(right-branch mob1)
(branch-structure (right-branch mob1))
(total-weight mob1)
(total-weight mob)
(balanced? mob1)
(balanced? mob2)
(balanced? mob)
