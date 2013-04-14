;; PaulとPeterが並列にmake-serializerを行うとすると下記のように両者がmutexの獲得を成功する時がある
;;
;; タイミングチャート
;; Peter						cell	Paul
;;  							false
;; (mutex 'aquire)				false
;; (test-and-set! cell)			false
;; (set-car! cell #t)実行中	false
;;  							false	(mutex 'aquire)
;;  							false	(test-and-set! cell)
;;  							false	(set-car! cell #t)実行中
;;  							true	(set-car! cell #t)実行完了
;;  							true	falseをリターン
;; (set-car! cell #t)実行完了	true
;; falseをリターン

(define (make-serializer)
  (let ((mutex (make-mutex)))
	(lambda (p)
	  (define (serialized-p . args)
		(mutex 'acquire)
		(let ((val (apply p args)))
		  (mutex 'release)
		  val))
	  serialized-p)))

(define (make-mutex)
  (let ((cell (list #f)))
	(define (the-mutex m)
	  (cond ((eq? m 'acquire)
			 (if (test-and-set! cell)
			   (the-mutex 'acquire))) ; retry
		((eq? m 'release) (clear! cell))))
	the-mutex))
(define (clear! cell)
  (set-car! cell #f))

(define (test-and-set! cell)
  (if (car cell)
	#t
	(begin (set-car! cell #t)
	  #f)))

