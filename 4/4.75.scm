(load "../logic.scm")

(define (unique-query exps) (car exps))
(define (uniquely-asserted operands frame-stream)
  (stream-flatmap
    (lambda (frame)
      (let ((assertions (qeval (unique-query operands)
			       (singleton-stream frame))))
	(if (and (not (stream-null? assertions))
	      (stream-null? (stream-cdr assertions)))
	  assertions
	  the-empty-stream)))
    frame-stream))
(put 'unique 'qeval uniquely-asserted)

(query-driver-loop)

;;; Query input:
;(unique (job ?x (computer wizard)))
;
;;;; Query results:
;(unique (job (Bitdiddle Ben) (computer wizard)))

;;;; Query input:
;(unique (job ?x (computer programmer)))
;
;;;; Query results:

;;;; Query input:
;(and (job ?x ?j) (unique (job ?anyone ?j)))
;
;;;; Query results:
;(and (job (Aull DeWitt) (administration secretary)) (unique (job (Aull DeWitt) (administration secretary))))
;(and (job (Cratchet Robert) (accounting scrivener)) (unique (job (Cratchet Robert) (accounting scrivener))))
;(and (job (Scrooge Eben) (accounting chief accountant)) (unique (job (Scrooge Eben) (accounting chief accountant))))
;(and (job (Warbucks Oliver) (administration big wheel)) (unique (job (Warbucks Oliver) (administration big wheel))))
;(and (job (Reasoner Louis) (computer programmer trainee)) (unique (job (Reasoner Louis) (computer programmer trainee))))
;(and (job (Tweakit Lem E) (computer technician)) (unique (job (Tweakit Lem E) (computer technician))))
;(and (job (Bitdiddle Ben) (computer wizard)) (unique (job (Bitdiddle Ben) (computer wizard))))

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
