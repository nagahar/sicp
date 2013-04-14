;; 多次元表(tree)
;; o:o:o---|
;; v |-----|
;; o:x     |
;; v       |
;; *table* |
;;         v
;;         o:o:o--------------------->o:o:o>...
;;         | v                        v |-->...
;;         | o:o:o------->o:o:o>...   o:x
;;         | | v          v |-->...   v
;;         | | o:o:o>...  o:o>rvalue  *rtable*
;;         | | v |-->...  v
;;         | | o:o>lvalue rkey
;;         | | v
;;         | v lkey
;;         | o:x
;;         | v
;;         v *ltable*
;;         o:x
;;         v
;;         *toptable*
;;

(define (make-table)
  (let ((local-table (list (list '*table*) '() '())))
	(define (key-tree tree)
	  (caar tree))
	(define (value-tree tree)
	  (cdar tree))
	(define (left-branch tree)
	  (cadr tree))
	(define (right-branch tree)
	  (caddr tree))
	(define (make-tree key value left right)
	  (list (cons key value) left right))
	(define (assoc-tree key records)
	  (cond ((null? records) #f)
		((equal? (key-tree records) '*table*)
		 (assoc-tree key (left-branch records)))
		((= key (key-tree records)) records)
		((< key (key-tree records))
		 (assoc-tree key (left-branch records)))
		((> key (key-tree records))
		 (assoc-tree key (right-branch records)))))
	(define (set-left-branch-tree! tree left)
	  (set-car! (cdr tree) left))
	(define (set-right-branch-tree! tree right)
	  (set-car! (cddr tree) right))
	(define (set-value! tree value)
	  (set-cdr! (car tree) value))

	(define (lookup keys)
	  (define (lookup-inter key table)
		(let ((record (assoc-tree (car key) table)))
		  (if record
			(if (null? (cdr key))
			  (value-tree record)
			  (lookup-inter (cdr key) record))
			#f)))
	  (lookup-inter keys local-table))

	(define (insert! key value)
	  (define (make-branch key value)
		(make-tree key value '() '()))
	  (define (insert-inter! key tree)
		(if (null? key)
		  (set-value! tree value)
		  (cond ((equal? (key-tree tree) '*table*)
				 (if (null? (left-branch tree))
				   (let ((new (make-branch (car key) '())))
					 (set-left-branch-tree! tree new)
					 (set-right-branch-tree! tree new)
					 (insert-inter! (cdr key) (left-branch tree)))
				   (insert-inter! key (left-branch tree))))
			((= (car key) (key-tree tree))
			 (set-value! tree value))
			((< (car key) (key-tree tree))
			 (if (null? (left-branch tree))
			   (set-left-branch-tree! tree (make-branch (car key) '())))
			 (insert-inter! (cdr key) (left-branch tree)))
			((> (car key) (key-tree tree))
			 (if (null? (right-branch tree))
			   (set-right-branch-tree! tree (make-branch (car key) '())))
			 (insert-inter! (cdr key) (right-branch tree))))))
	  (insert-inter! #?=key #?=local-table)
	  'ok)
	(define (dispatch m)
	  (cond ((eq? m 'lookup-proc) lookup)
		((eq? m 'insert-proc!) insert!)
		(else (error "Unknown operation -- TABLE" m))))
	dispatch))
(define tab (make-table))
((tab 'insert-proc!) '(0 1 2 3) 'a)
((tab 'lookup-proc) '(0 1 2 3))

