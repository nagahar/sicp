;; 一つの式を持つ並びの場合
;; Alyssaのプログラムはenvを引数にとるlambdaが返される。lambdaの本体はexecute-sequenceを実行する式である。
;; 本文のプログラムは式そのものが返される
;;
;; 二つの式を持つ並びの場合
;; Alyssaのプログラムはenvを引数にとるlambdaが返される。lambdaの本体はexecute-sequenceを実行する式である。
;; 本文のプログラムはenvを引数にとるlambdaが返される。lambdaの本体はenvを引数にとる式二つで構成される。

(load "../metacircular2.scm")
;; Alyssa ver.
(define (analyze-sequence exps)
  (define (execute-sequence procs env)
    (cond ((null? (cdr procs)) ((car procs) env))
      (else ((car procs) env)
	(execute-sequence (cdr procs) env))))
  (let ((procs (map analyze exps)))
    (if (null? procs)
      (error "Empty sequence -- ANALYZE"))
    (lambda (env) (execute-sequence procs env))))

;; original
(define (analyze-sequence exps)
  (define (sequentially proc1 proc2)
    (lambda (env) (proc1 env) (proc2 env)))
  (define (loop first-proc rest-procs)
    (if (null? rest-procs)
      first-proc
      (loop (sequentially first-proc (car rest-procs))
	    (cdr rest-procs))))
  (let ((procs (map analyze exps)))
    (if (null? procs)
      (error "Empty sequence -- ANALYZE"))
    (loop (car procs) (cdr procs))))


;; exps1
(begin
  (display '1))
;; exps2
(begin
  (display '1)
  (display '2))
;; exps3
(begin
  (display '1)
  (display '2)
  (display '3))

(driver-loop)
;; original:
;; exps1 => 1
;; exps2 => 12
