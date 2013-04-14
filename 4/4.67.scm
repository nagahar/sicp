;; 歴史には質問パターンの質問キーと変数束縛のリストを保存する
;; 下記のように変更すればよい

(load "../logic.scm")
(define (simple-query query-pattern frame-stream)
  (stream-flatmap
    (lambda (frame)
      ;; history ver.
      (if (found-in-history? query-pattern frame)
	the-empty-stream
	(begin
	  (add-history! query-pattern frame)
	  (stream-append-delayed
	    (find-assertions query-pattern frame)
	    (delay (apply-rules query-pattern frame))))))
    frame-stream))

(define (question query) (car query))
(define (variables query frame)
  (map
    (lambda (var)
      (let ((binding (binding-in-frame var frame)))
	(if binding binding '())))
    (cdr query)))

(define (found-in-history? query frame)
  (let ((key (question query))
	(vars (variables query frame)))
    (if (get (list key vars) 'history-stream)
      true
      false)))

(define (add-history! query frame)
  (if (indexable? query)
    (let ((key (question query))
	  (vars (variables query frame)))
      (let ((current-history-stream
	      (get-stream (list key vars) 'history-stream)))
	(put (list key vars)
	     'history-stream
	     (cons-stream key
			  current-history-stream)))))
  'history)

(query-driver-loop)

;; Louis ver.
(assert! (rule (outranked-by ?staff-person ?boss)
	       (or (supervisor ?staff-person ?boss)
		 (and (outranked-by ?middle-manager ?boss)
		   (supervisor ?staff-person ?middle-manager)))))

;;;; Query input:
;(outranked-by (Bitdiddle Ben) ?who)
;
;;;; Query results:
;(outranked-by (Bitdiddle Ben) (Warbucks Oliver))
;
;;;; Query input:
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
(assert! (can-do-job (computer programmer))
	 (computer programmer trainee))
(assert! (can-do-job (administration secretary))
	 (administration big wheel))

