;; 下記の規則が定義されているときに質問(job ?x ?y)を行うと無限ループになる
;(assert! (rule (job ?x ?y)
;	       (job ?y ?x)))

;; original ver.
(define (simple-query query-pattern frame-stream)
  (stream-flatmap
    (lambda (frame)
      (stream-append-delayed
	(find-assertions query-pattern frame)
	(delay (apply-rules query-pattern frame))))
    frame-stream))
(define (disjoin disjuncts frame-stream)
  (if (empty-disjunction? disjuncts)
    the-empty-stream
    (interleave-delayed
      (qeval (first-disjunct disjuncts) frame-stream)
      (delay (disjoin (rest-disjuncts disjuncts)
		      frame-stream)))))
;; Louis ver.
(define (simple-query query-pattern frame-stream)
  (stream-flatmap
    (lambda (frame)
      (stream-append (find-assertions query-pattern frame)
		     (apply-rules query-pattern frame)))
    frame-stream))
(define (disjoin disjuncts frame-stream)
  (if (empty-disjunction? disjuncts)
    the-empty-stream
    (interleave
      (qeval (first-disjunct disjuncts) frame-stream)
      (disjoin (rest-disjuncts disjuncts) frame-stream))))


