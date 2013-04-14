(define (append x y)
  (if (null? x)
      y
      (cons (car x) (append (cdr x) y))))

(define (append! x y)
  (set-cdr! (last-pair x) y)
  x)

(define (last-pair x)
  (if (null? (cdr x))
      x
      (last-pair (cdr x))))

(define x (list 'a 'b))

(define y (list 'c 'd))

(define z (append x y))

z
;; => (a b c d)

(cdr x)
;; => (b)
;;
;; z => o:o>o:o---
;;      v   v    |
;; x => o:o>o:x  |
;;      v   v    |
;;      a   b    |
;;               v
;;          y => o:o>o:x
;;               v   v
;;               c   d
;;
;; (cdr x) => o:x
;;            v
;;            b

(define w (append! x y)

w
;; => (a b c d)

(cdr x)
;; => (b c d)
;;
;; w(x) => o:o>o:o---
;;         v   v    |
;;         a   b    |
;;                  v
;;             y => o:o>o:x
;;                  v   v
;;                  c   d
;;
;; (cdr x) => o:o---
;;            v    |
;;            b    |
;;                 v
;;            y => o:o>o:x
;;                 v   v
;;                 c   d

