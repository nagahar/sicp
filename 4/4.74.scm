;; a.
(load "../logic.scm")

(define (simple-stream-flatmap proc s)
  (simple-flatten (stream-map proc s)))

(define (simple-flatten stream)
  (stream-map stream-car
	      (stream-filter (lambda (st) (pair? (stream-car st))) stream)))

;; b. 質問システムの振る舞いは変わらない

(query-driver-loop)
;; Query input:
;(and (supervisor ?x ?y)
;     (not (job ?x (computer programmer))))
;
;;;; Query results:
;(and (supervisor (Aull DeWitt) (Warbucks Oliver)) (not (job (Aull DeWitt) (computer programmer))))
;(and (supervisor (Cratchet Robert) (Scrooge Eben)) (not (job (Cratchet Robert) (computer programmer))))
;(and (supervisor (Scrooge Eben) (Warbucks Oliver)) (not (job (Scrooge Eben) (computer programmer))))
;(and (supervisor (Bitdiddle Ben) (Warbucks Oliver)) (not (job (Bitdiddle Ben) (computer programmer))))
;(and (supervisor (Reasoner Louis) (Hacker Alyssa P)) (not (job (Reasoner Louis) (computer programmer))))
;(and (supervisor (Tweakit Lem E) (Bitdiddle Ben)) (not (job (Tweakit Lem E) (computer programmer))))

;;;; Query input:
;(and (salary ?person ?amount)
;     (lisp-value > ?amount 30000))
;
;;;; Query results:
;(and (salary (Scrooge Eben) 75000) (lisp-value > 75000 30000))
;(and (salary (Warbucks Oliver) 150000) (lisp-value > 150000 30000))
;(and (salary (Fect Cy D) 35000) (lisp-value > 35000 30000))
;(and (salary (Hacker Alyssa P) 40000) (lisp-value > 40000 30000))
;(and (salary (Bitdiddle Ben) 60000) (lisp-value > 60000 30000))

;;データベース
(assert! (meeting accounting (Monday 9am)))
(assert! (meeting administration (Monday 10am)))
(assert! (meeting computer (Wednesday 3pm)))
(assert! (meeting administration (Friday 1pm)))
(assert! (meeting whole-company (Wednesday 4pm)))

(assert! (address (Bitdiddle Ben) (Slumerville (Ridge Road) 10)))
(assert! (job (Bitdiddle Ben) (computer wizard)))
(assert! (salary (Bitdiddle Ben) 60000))
(assert! (address (Hacker Alyssa P) (Cambridge (Mass Ave) 78)))
(assert! (job (Hacker Alyssa P) (computer programmer)))
(assert! (salary (Hacker Alyssa P) 40000))
(assert! (supervisor (Hacker Alyssa P) (Bitdiddle Ben)))
(assert! (address (Fect Cy D) (Cambridge (Ames Street) 3)))
(assert! (job (Fect Cy D) (computer programmer)))
(assert! (salary (Fect Cy D) 35000))
(assert! (supervisor (Fect Cy D) (Bitdiddle Ben)))
(assert! (address (Tweakit Lem E) (Boston (Bay State Road) 22)))
(assert! (job (Tweakit Lem E) (computer technician)))
(assert! (salary (Tweakit Lem E) 25000))
(assert! (supervisor (Tweakit Lem E) (Bitdiddle Ben)))
(assert! (address (Reasoner Louis) (Slumerville (Pine Tree Road) 80)))
(assert! (job (Reasoner Louis) (computer programmer trainee)))
(assert! (salary (Reasoner Louis) 30000))
(assert! (supervisor (Reasoner Louis) (Hacker Alyssa P)))
(assert! (supervisor (Bitdiddle Ben) (Warbucks Oliver)))
(assert! (address (Warbucks Oliver) (Swellesley (Top Heap Road))))
(assert! (job (Warbucks Oliver) (administration big wheel)))
(assert! (salary (Warbucks Oliver) 150000))
(assert! (address (Scrooge Eben) (Weston (Shady Lane) 10)))
(assert! (job (Scrooge Eben) (accounting chief accountant)))
(assert! (salary (Scrooge Eben) 75000))
(assert! (supervisor (Scrooge Eben) (Warbucks Oliver)))
(assert! (address (Cratchet Robert) (Allston (N Harvard Street) 16)))
(assert! (job (Cratchet Robert) (accounting scrivener)))
(assert! (salary (Cratchet Robert) 18000))
(assert! (supervisor (Cratchet Robert) (Scrooge Eben)))
(assert! (address (Aull DeWitt) (Slumerville (Onion Square) 5)))
(assert! (job (Aull DeWitt) (administration secretary)))
(assert! (salary (Aull DeWitt) 25000))
(assert! (supervisor (Aull DeWitt) (Warbucks Oliver)))

(assert! (can-do-job (computer wizard) (computer programmer)))
(assert! (can-do-job (computer wizard) (computer technician)))
(assert! (can-do-job (computer programmer)
            (computer programmer trainee)))
(assert! (can-do-job (administration secretary)
            (administration big wheel)))
