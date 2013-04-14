(load "../compiler.scm")

(define (make-lexical-address frame displacement)
  (list frame displacement))
(define (get-frame-number address) (car address))
(define (get-displacement-number address) (cadr address))

(define (find-variable var ct-env)
  (define (env-loop env f-num)
    (define (scan vars d-num)
      (cond ((null? vars)
	     (env-loop (enclosing-environment env) (+ f-num 1)))
	((eq? var (car vars))
	 (make-lexical-address f-num d-num))
	(else (scan (cdr vars) (+ d-num 1)))))
    (if (eq? env the-empty-environment)
      'not-found
      (scan (first-frame env) 0)))
  (env-loop ct-env 0))

(find-variable 'c '((y z) (a b c d e) (x y)))
;(1 2)

(find-variable 'x '((y z) (a b c d e) (x y)))
;(2 0)

(find-variable 'w '((y z) (a b c d e) (x y)))
;not-found

