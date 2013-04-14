(load "../logic.scm")
(query-driver-loop)

;; a.
;;;; Query input:
;(and (supervisor ?person (Bitdiddle Ben))
;  (address ?person ?where))
;
;;;; Query results:
;(and (supervisor (Tweakit Lem E) (Bitdiddle Ben)) (address (Tweakit Lem E) (Boston (Bay State Road) 22)))
;(and (supervisor (Fect Cy D) (Bitdiddle Ben)) (address (Fect Cy D) (Cambridge (Ames Street) 3)))
;(and (supervisor (Hacker Alyssa P) (Bitdiddle Ben)) (address (Hacker Alyssa P) (Cambridge (Mass Ave) 78)))

;; b.
;;;; Query input:
;(and (salary (Bitdiddle Ben) ?benAmount)
;  (salary ?person ?amount)
;  (lisp-value < ?amount ?benAmount))
;
;;;; Query results:
;(and (salary (Bitdiddle Ben) 60000) (salary (Aull DeWitt) 25000) (lisp-value < 25000 60000))
;(and (salary (Bitdiddle Ben) 60000) (salary (Cratchet Robert) 18000) (lisp-value < 18000 60000))
;(and (salary (Bitdiddle Ben) 60000) (salary (Reasoner Louis) 30000) (lisp-value < 30000 60000))
;(and (salary (Bitdiddle Ben) 60000) (salary (Tweakit Lem E) 25000) (lisp-value < 25000 60000))
;(and (salary (Bitdiddle Ben) 60000) (salary (Fect Cy D) 35000) (lisp-value < 35000 60000))
;(and (salary (Bitdiddle Ben) 60000) (salary (Hacker Alyssa P) 40000) (lisp-value < 40000 60000))

;; c.
;;;; Query input:
;(and (job ?person ?job)
;  (not (job ?person (computer . ?type)))
;  (supervisor ?person ?supervisor))
;
;;;; Query results:
;(and (job (Aull DeWitt) (administration secretary)) (not (job (Aull DeWitt) (computer . ?type))) (supervisor (Aull DeWitt) (Warbucks Oliver)))
;(and (job (Cratchet Robert) (accounting scrivener)) (not (job (Cratchet Robert) (computer . ?type))) (supervisor (Cratchet Robert) (Scrooge Eben)))
;(and (job (Scrooge Eben) (accounting chief accountant)) (not (job (Scrooge Eben) (computer . ?type))) (supervisor (Scrooge Eben) (Warbucks Oliver)))

;;データベース
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
(assert! (can-do-job (computer programmer))
	 (computer programmer trainee))
(assert! (can-do-job (administration secretary))
	 (administration big wheel))

