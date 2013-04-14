(load "../logic.scm")
(query-driver-loop)

(assert! (rule (grandson ?g ?s)
	       (and (son ?f ?s)
		 (son ?g ?f))))
(assert! (rule (son-of ?m ?s)
	       (or (son ?m ?s)
		 (and (wife ?m ?w)
		   (son ?w ?s)))))

;;;; Query input:
;(grandson Enoch ?who)
;
;;;; Query results:
;(grandson Enoch Mehujael)
;
;;;; Query input:
;(son-of Lamech ?who)
;
;;;; Query results:
;(son-of Lamech Jubal)
;(son-of Lamech Jabal)

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

