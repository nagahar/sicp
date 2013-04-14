
(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp)
	 ;;ここで、expmodを2回呼んでいるため、baseの乗算回数がexpに比例してしまい、Θ(n)になっている
         (remainder (* (expmod base (/ exp 2) m)
                       (expmod base (/ exp 2) m))
                    m))
        (else
         (remainder (* base (expmod base (- exp 1) m))
                    m))))