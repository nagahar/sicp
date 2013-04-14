(memo-fib 3)
;; => 2
;; (define memo-fib ...)
;; - global
;;    memo-fib: -> (let ((previously-computed-result ...
;;    memoize: -> f,  (let ((table (make-table)))
;;    n: 3
;;    <- E1
;;       f: n, (cond ((= n 0) 0)...
;;       <- E2
;;          table: <-> (let ((local-table (list (list '*table*) '() '())))...
;;          <- E3
;;             x: 3
;;             <- E4
;;                result: ...
;;                ....
;;
;; nに比例する理由:
;; フィボナッチ数の計算は引数0...nに対し実施されるが、memoizeで結果をキャッシュすることで同一引数での計算の繰り返しを避けることができるため
;;
(define memo-fib (memoize fib))
(memo-fib 3)
;; => 2
;; make-tableは一度しか実行されないため計算量が指数的になる

(define memo-fib
  (memoize (lambda (n)
			 (cond ((= n 0) 0)
			   ((= n 1) 1)
			   (else (+ (memo-fib (- n 1))
						(memo-fib (- n 2))))))))
(define (memoize f)
  (let ((table (make-table)))
	(lambda (x)
	  (let ((previously-computed-result ((table 'lookup-proc) (list x))))
		(or previously-computed-result
		  (let ((result (f x)))
			((table 'insert-proc!) (list #?=x) #?=result)
			result))))))
(define (fib n)
  (cond ((= n 0) 0)
	((= n 1) 1)
	(else (+ (fib (- n 1))
			 (fib (- n 2))))))

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

