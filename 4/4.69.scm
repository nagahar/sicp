(load "../logic.scm")
(query-driver-loop)

(assert! (rule (grandson ?g ?s)
	       (and (son ?f ?s)
		 (son ?g ?f))))
(assert! (rule (son-of ?m ?s)
	       (or (son ?m ?s)
		 (and (wife ?m ?w)
		   (son ?w ?s)))))

(assert! (rule ((great . ?rel) ?g ?ggs)
	       (and (son ?gs ?ggs)
		 (?rel ?g ?gs))))
(assert! (rule ((grandson) ?x ?y)
	       (grandson ?x ?y)))

;;;; Query input:
;((great grandson) ?g ?ggs)
;
;;;; Query results:
;((great grandson) Irad Lamech)
;((great grandson) Enoch Methushael)
;((great grandson) Cain Mehujael)
;((great grandson) Adam Irad)
;
;;;; Query input:
;(?relationship Adam Irad)
;
;;;; Query results:
;((great grandson) Adam Irad)
;((great great . son) Adam Irad)
;((great . grandson) Adam Irad)
;((great great . son-of) Adam Irad)

;;データベース
(assert! (son Adam Cain))
(assert! (son Cain Enoch))
(assert! (son Enoch Irad))
(assert! (son Irad Mehujael))
(assert! (son Mehujael Methushael))
(assert! (son Methushael Lamech))
(assert! (wife Lamech Ada))
(assert! (son Ada Jabal))
(assert! (son Ada Jubal))

