(define (or-gate a1 a2 output)
  (let ((a1out (make-wire))
		(a2out (make-wire))
		(andout (make-wire)))
	(inverter a1 a1out)
	(inverter a2 a2out)
	(and-gate a1out a2out andout)
	(inverter andout output)))

;; 遅延時間は二inverter-delay(時間)と一and-gate-delay(時間)
;; a1とa2の処理は並行できるため

(define (inverter input output)
  (define (invert-input)
	(let ((new-value (logical-not (get-signal input))))
	  (after-delay inverter-delay
				   (lambda ()
					 (set-signal! output new-value)))))
  (add-action! input invert-input)
  'ok)
(define (logical-not s)
  (cond ((= s 0) 1)
	((= s 1) 0)
	(else (error "Invalid signal" s))))
(define (and-gate a1 a2 output)
  (define (and-action-procedure)
	(let ((new-value
			(logical-and (get-signal a1) (get-signal a2))))
	  (after-delay and-gate-delay
				   (lambda ()
					 (set-signal! output new-value)))))
  (add-action! a1 and-action-procedure)
  (add-action! a2 and-action-procedure)
  'ok)

