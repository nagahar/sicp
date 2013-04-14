; Tpq を2回実行した場合の対(a',b')は元の対を(a0,b0)とすると、それぞれ
; a'=b0(q**2+2pq)+a0(q**2+2pq)+a0(p**2+q**2)
; b'=b0(p**2+q**2)+a0(q**2+2pq)
; となり
; p**2+q**2=p', q**2+2pq=q'
; とおけば、Tp'q'はTpqを2回実行する変換になる

(define (fib n)
  (fib-iter 1 0 0 1 n))
(define (fib-iter a b p q count)
  (cond ((= count 0) b)
        ((even? count)
         (fib-iter a
                   b
                   (+ (square p) (square q))
		   (+ (square q) (* 2 p q))
                   (/ count 2)))
        (else (fib-iter (+ (* b q) (* a q) (* a p))
                        (+ (* b p) (* a q))
                        p
                        q
                        (- count 1)))))
(define (square x)
  (* x x))

