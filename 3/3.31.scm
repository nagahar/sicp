;; 初期化によりagendaに各outputに対するset-signal!(信号変化検知)を追加している
;; これによりpropagateでagendaが実行できる
;;
;; 初期化を行わないとpropagateは実行されない
;;
;; add-action!によりwireに登録される手続き after-delay
;; after-delayによりagendaに登録される手続き set-signal!
;;
;; propagateの実行
;; -> set-signal!(for output)実行
;;  -> wireの値が変化する -> wireに登録されているafter-delay(for input)が駆動する
;;  -> wireの値が変化しない -> 何も起きない
;;

(define (probe name wire)
  (add-action! wire
			   (lambda ()
				 (newline)
				 (display name)
				 (display " ")
				 (display (current-time the-agenda))
				 (display "  New-value = ")
				 (display (get-signal wire)))))

(define (half-adder a b s c)
  (let ((d (make-wire)) (e (make-wire)))
	(or-gate a b d)
	(and-gate a b c)
	(inverter c e)
	(and-gate d e s)
	'ok))
(define (make-wire)
  (let ((signal-value 0) (action-procedures '()))
	(define (set-my-signal! new-value)
	  (if (not (= signal-value new-value))
		(begin (set! signal-value new-value)
		  (call-each action-procedures))
		'done))
	(define (accept-action-procedure! proc)
	  (set! action-procedures (cons proc action-procedures))
	  (proc))
	(define (dispatch m)
	  (cond ((eq? m 'get-signal) signal-value)
		((eq? m 'set-signal!) set-my-signal!)
		((eq? m 'add-action!) accept-action-procedure!)
		(else (error "Unknown operation -- WIRE" m))))
	dispatch))
(define (propagate)
  (if (empty-agenda? the-agenda)
	'done
	(let ((first-item (first-agenda-item the-agenda)))
	  (first-item)
	  (remove-first-agenda-item! the-agenda)
	  (propagate))))
(define (after-delay delay action)
  (add-to-agenda! (+ delay (current-time the-agenda))
				  action
				  the-agenda))
(define the-agenda (make-agenda))
(define inverter-delay 2)
(define and-gate-delay 3)
(define or-gate-delay 5)
(define input-1 (make-wire))
(define input-2 (make-wire))
(define sum (make-wire))
(define carry (make-wire))
(define (call-each procedures)
  (if (null? procedures)
	'done
	(begin
	  ((car procedures))
	  (call-each (cdr procedures)))))
(define (get-signal wire)
  (wire 'get-signal))
(define (set-signal! wire new-value)
  ((wire 'set-signal!) new-value))
(define (add-action! wire action-procedure)
  ((wire 'add-action!) action-procedure))
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
(define (or-gate a1 a2 output)
  (let ((a1out (make-wire))
		(a2out (make-wire))
		(andout (make-wire)))
	(inverter a1 a1out)
	(inverter a2 a2out)
	(and-gate a1out a2out andout)
	(inverter andout output)))

