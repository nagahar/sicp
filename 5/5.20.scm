(define x (cons 1 2))
(define y (list x x))

;; box-pointer
;; y => o:o>o:x
;;      |---|
;;      v
;;      o:o
;;      v v
;;      1 2
;;
;; memory-vector
;; Index	0	1	2	3
;; the-cars		n1	p1	p1
;; the-cdrs		n2	p3	e0
;;
;; freeの最後の値はp4となる

