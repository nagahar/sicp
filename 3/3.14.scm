(define (mystery x)
  (define (loop x y)
    (if (null? x)
        y
        (let ((temp (cdr x)))
          (set-cdr! x y)
          (loop temp x))))
  (loop x '()))

(define v (list 'a 'b 'c 'd))
;;
;; v => o:o>o:o>o:o>o:x
;;      v   v   v   v
;;      a   b   c   d

(define w (mystery v))
;; 1.
;; temp => o:o>o:o>o:x
;;         v   v   v
;;         b   c   d
;; x => o:x
;;      v
;;      a
;; 2.
;; temp => o:o>o:x
;;         v   v
;;         c   d
;; x => o:o---
;;      v    |
;;      b    |
;;           v
;;      v => o:x
;;           v
;;           a
;; 3.
;; temp => o:x
;;         v
;;         d
;; x => o:o>o:o---
;;      v   v    |
;;      c   b    |
;;               v
;;          v => o:x
;;               v
;;               a

;; 4.
;; temp => nil
;; x(w) => o:o>o:o>o:o---
;;         v   v   v    |
;;         d   c   b    |
;;                      v
;;                 v => o:x
;;                      v
;;                      a

