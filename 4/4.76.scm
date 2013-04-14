(load "../logic.scm")

(define (conjoin conjuncts frame-stream)
  (if (empty-conjunction? conjuncts)
    frame-stream
    (let ((f1 (qeval (first-conjunct conjuncts) frame-stream))
	  (f2 (qeval (first-conjunct (rest-conjuncts conjuncts)) frame-stream)))
      (stream-flatmap
	(lambda (frame1)
	  (stream-flatmap
	    (lambda (frame2)
	      (merge-frames frame1 frame2))
	    f2))
	f1))))

(define (merge-frames f1 f2)
  (let ((check-result (check-frames f1 f2)))
    (if (eq? check-result 'failed)
      the-empty-stream
      (singleton-stream check-result))))

(define (check-frames frame1 frame2)
  (if (null? frame1)
    frame2
    (let ((var (caar frame1))
	  (val (cdar frame1)))
      (let ((extension (extend-if-possible var val frame2)))
	(if (equal? extension 'failed)
	  'failed
	  (check-frames (cdr frame1) extension))))))

(put 'and 'qeval conjoin)

(query-driver-loop)

;;;; Query input:
;(and (address ?x ?y) (supervisor ?x ?z))
;
;;;; Query results:
;(and (address (Aull DeWitt) (Slumerville (Onion Square) 5)) (supervisor (Aull DeWitt) (Warbucks Oliver)))
;(and (address (Cratchet Robert) (Allston (N Harvard Street) 16)) (supervisor (Cratchet Robert) (Scrooge Eben)))
;(and (address (Scrooge Eben) (Weston (Shady Lane) 10)) (supervisor (Scrooge Eben) (Warbucks Oliver)))
;(and (address (Reasoner Louis) (Slumerville (Pine Tree Road) 80)) (supervisor (Reasoner Louis) (Hacker Alyssa P)))
;(and (address (Tweakit Lem E) (Boston (Bay State Road) 22)) (supervisor (Tweakit Lem E) (Bitdiddle Ben)))
;(and (address (Fect Cy D) (Cambridge (Ames Street) 3)) (supervisor (Fect Cy D) (Bitdiddle Ben)))
;(and (address (Hacker Alyssa P) (Cambridge (Mass Ave) 78)) (supervisor (Hacker Alyssa P) (Bitdiddle Ben)))
;(and (address (Bitdiddle Ben) (Slumerville (Ridge Road) 10)) (supervisor (Bitdiddle Ben) (Warbucks Oliver)))

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

