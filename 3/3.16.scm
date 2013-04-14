(define (count-pairs x)
  (if (not (pair? x))
      0
      (+ (count-pairs (car x))
         (count-pairs (cdr x))
         1)))

(define x3 (cons 'a (cons 'b (cons 'c '()))))
(count-pairs x3)
;; (a b c)
;; x3 => o:o>o:o>o:x
;;       v   v   v
;;       a   b   c

(define x4 (cons 'dummy (cons 'a '())))
(set-car! x4 (cons 'b (cdr x4)))
(count-pairs x4)
;; ((b . #0=(a)) . #0#)
;; x4 => o:o->o:x
;;       |  | v
;;       |  | a
;;       v  |
;;       o:o-
;;       v
;;       b

(define x7 (cons 'a (cons 'b (cons 'c '()))))
(set-car! (cdr x7) (cdr (cdr x7)))
(set-car! x7 (cdr x7))
(count-pairs x7)
;; (#0=(#1=(c) . #1#) . #0#)
;;           -----
;;           |   v
;; x7 => o:o>o:o>o:x
;;       |   ^   v
;;       -----   c

(define (make-cycle x)
  (set-cdr! (last-pair x) x)
  x)
(define no_return (make-cycle (list 'a 'b 'c)))
(count-pairs no_return)


