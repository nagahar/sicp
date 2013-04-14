(define x (list 'a 'b))
(define z1 (cons x x))
(define z2 (cons (list 'a 'b) (list 'a 'b)))
(define (set-to-wow! x)
  (set-car! (car x) 'wow)
  x)

z1
((a b) a b)
;; => (#0=(a b) . #0#)
;; z1 => o:o
;;       |-|
;;       v
;;  x => o:o>o:x
;;       v   v
;;       a   b

(set-to-wow! z1)
((wow b) wow b)
;; => (#0=(wow b) . #0#)
;; z1 => o:o
;;       |-|
;;       v
;;  x => o:o>o:x
;;       v   v
;;      wow  b

z2
((a b) a b)
;; => ((a b) a b)
;; z2 => o:o>o:o>o:x
;;       |   v   v
;;       |   a   b
;;       |   ^   ^
;;       --->o:o>o:x

(set-to-wow! z2)
((wow b) a b)
;; => ((wow b) a b)
;;          wow
;;           ^
;; z2 => o:o>o:o>o:x
;;       |       v
;;       |   a   b
;;       |   ^   ^
;;       --->o:o>o:x


