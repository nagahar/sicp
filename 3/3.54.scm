(load "../stream.scm")
(define factorials (cons-stream 1 (mul-streams factorials (integers-starting-from 2))))
(show-stream factorials 5)
;; 1 2 6 24 120

