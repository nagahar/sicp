;; 多次元表
;; o:o---->o:o---------------------->o:o>...
;; v       v                         v
;; o:x     o:o----->o:o---->o:o>...  o:o>...
;; v       v        v       v        v
;; *table* o:x      o:o     o:o      o:x
;;         v        v v     v        v
;;  *table1*      key value key      *table2*
;;
;;
;(define (assoc key records)
; (cond ((null? records) false)
;       ((equal? key (caar records)) (car records))
;       (else (assoc key (cdr records)))))

(define (make-table)
  (let ((local-table (list '*table*)))
	(define (lookup keys)
	  (define (lookup-inter key table)
		(let ((record (assoc (car key) (cdr table))))
		  (if record
			(if (null? (cdr key))
			  (cdr record)
			  (lookup-inter (cdr key) record))
			#f)))
	  (lookup-inter keys local-table))
	(define (insert! keys value)
	  (define (insert-inter! key table)
		(let ((record (assoc (car key) (cdr table))))
		  (if #?=record
			(if (null? (cdr key))
			  (set-cdr! record value)
			  (insert-inter! (cdr key) record))
			(set-cdr! table
					  (cons (create-table key)
							(cdr table))))))
	  (define (create-table key)
		(if (null? (cdr key))
		  (cons (car key) value)
		  (list (car key) (create-table (cdr key)))))
	  (insert-inter! keys local-table)
	  (display local-table)
	  'ok)
	(define (dispatch m)
	  (cond ((eq? m 'lookup-proc) lookup)
		((eq? m 'insert-proc!) insert!)
		(else (error "Unknown operation -- TABLE" m))))
	dispatch))

(define tab (make-table))
((tab 'insert-proc!) '(0 1 2 3) 'a)
((tab 'lookup-proc) '(0 1 2 3))

