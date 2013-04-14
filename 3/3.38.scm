;; a. balance
;; initial 100
;; Peter: 	(set! balance (+ balance 10))
;; Paul: 	(set! balance (- balance 20))
;; Mary: 	(set! balance (- balance (/ balance 2)))
;;
;; Peter -> Paul -> Mary 45
;; Peter -> Mary -> Paul 35
;; Paul -> Peter -> Mary 45
;; Paul -> Mary -> Peter 50
;; Mary -> Peter -> Paul 40
;; Mary -> Paul -> Peter 40
;;
;; 35, 40, 45, 50
;;
;; b.
;; 3者同時(100)  110, 80, 50
;; Peterだけ完了(110) 90, 45
;; Paulだけ完了(80) 90, 40
;; Maryだけ完了(50) 60, 30
;;
