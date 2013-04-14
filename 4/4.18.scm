(define (solve f y0 dt)
  (define y (integral (delay dy) y0 dt))
  (define dy (stream-map f y))
  y)
(define (integral delayed-integrand initial-value dt)
  (define int
    (cons-stream initial-value
		 (let ((integrand (force delayed-integrand)))
		   (add-streams (scale-stream integrand dt)
				int))))
  int)

;; 本問で提示する掃き出し法
;; letでは束縛時に実引数が評価される(具体的にはevalのlist-of-valuesで評価される)
;; そのため、integralはletとset!で二回評価されるが、dyは二回目も*unassigned*であるため動作しない
(lambda <vars>
  (let ((u '*unassigned*)
	(v '*unassigned*))
    (let ((a <e1>)
	  (b <e2>))
      (set! u a)
      (set! v b))
    <e3>))
(define (solve f y0 dt)
  (let ((y '*unassigned*)
	(dy '*unassigned*))
    (let ((a (integral (delay dy) y0 dt))
	  (b (stream-map f y)))
      (set! y a)
      (set! dy b))
    y))

;; 当初の掃き出し法
;; integralはset!時のみ評価されるため、動作する
(lambda <vars>
  (let ((u '*unassigned*)
	(v '*unassigned*))
    (set! u <e1>)
    (set! v <e2>)
    <e3>))
(define (solve f y0 dt)
  (let ((y '*unassigned*)
	(dy '*unassigned*))
    (set! y (integral (delay dy) y0 dt))
    (set! dy (stream-map f y))
    y))

