;; 下記のように、queryに関わらないデータを登録すると回答が重複する

(load "../amb.scm")
(driver-loop)

(define (query)
  (let ((meeting (amb '(accounting (Monday 9am))
		      '(administration (Monday 10am))
		      '(computer (Wednesday 3pm))
		      '(administration (Friday 1pm))
		      '(whole-company (Wednesday 4pm))))
	(addres (amb '((Bitdiddle Ben) (Slumerville (Ridge Road) 10))
		     '((Hacker Alyssa P) (Cambridge (Mass Ave) 78))
		     '((Fect Cy D) (Cambridge (Ames Street) 3))
		     '((Tweakit Lem E) (Boston (Bay State Road) 22))
		     '((Reasoner Louis) (Slumerville (Pine Tree Road) 80))
		     '((Warbucks Oliver) (Swellesley (Top Heap Road)))
		     '((Scrooge Eben) (Weston (Shady Lane) 10))
		     '((Cratchet Robert) (Allston (N Harvard Street) 16))
		     '((Aull DeWitt) (Slumerville (Onion Square) 5))))
	(job (amb '((Hacker Alyssa P) (computer programmer))
		  '((Bitdiddle Ben) (computer wizard))
		  '((Fect Cy D) (computer programmer))
		  '((Tweakit Lem E) (computer technician))
		  '((Reasoner Louis) (computer programmer trainee))
		  '((Warbucks Oliver) (administration big wheel))
		  '((Scrooge Eben) (accounting chief accountant))
		  '((Cratchet Robert) (accounting scrivener))
		  '((Aull DeWitt) (administration secretary))))
	(salary (amb '((Hacker Alyssa P) 40000)
		     '((Bitdiddle Ben) 60000)
		     '((Fect Cy D) 35000)
		     '((Tweakit Lem E) 25000)
		     '((Reasoner Louis) 30000)
		     '((Warbucks Oliver) 150000)
		     '((Scrooge Eben) 75000)
		     '((Cratchet Robert) 18000)
		     '((Aull DeWitt) 25000)))
	(supervisor (amb '((Hacker Alyssa P) (Bitdiddle Ben))
			 '((Fect Cy D) (Bitdiddle Ben))
			 '((Tweakit Lem E) (Bitdiddle Ben))
			 '((Reasoner Louis) (Hacker Alyssa P))
			 '((Bitdiddle Ben) (Warbucks Oliver))
			 '((Scrooge Eben) (Warbucks Oliver))
			 '((Cratchet Robert) (Scrooge Eben))
			 '((Aull DeWitt) (Warbucks Oliver))))
	(can-do-job (amb '((computer wizard) (computer programmer))
			 '((computer wizard) (computer technician))
			 '((computer programmer) (computer programmer trainee))
			 '((administration secretary) (administration big wheel)))))
    (require (equal? (car supervisor) (car job)))
    (list (list 'supervisor supervisor)
	  (list 'job job))))

;;;; Amb-Eval input:
;(query)
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;((supervisor ((Hacker Alyssa P) (Bitdiddle Ben))) (job ((Hacker Alyssa P) (computer programmer))))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;((supervisor ((Hacker Alyssa P) (Bitdiddle Ben))) (job ((Hacker Alyssa P) (computer programmer))))

