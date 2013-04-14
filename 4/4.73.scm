;; delayを使わないとflatten-streamが引数として再帰的に評価されてしまい、無限ループになるため

;; original ver.
(define (flatten-stream stream)
  (if (stream-null? stream)
    the-empty-stream
    (interleave-delayed
      (stream-car stream)
      (delay (flatten-stream (stream-cdr stream))))))

;; 本問のver.
(define (flatten-stream stream)
  (if (stream-null? stream)
    the-empty-stream
    (interleave
      (stream-car stream)
      (flatten-stream (stream-cdr stream)))))
