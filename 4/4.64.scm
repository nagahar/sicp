;; Louisの版では、(outranked-by ?middle-manager ?boss)の入力フレームでmiddle-managerが束縛されないまま再帰的に呼び出されるため、無限ループに落ち込む
;; original ver.
(rule (outranked-by ?staff-person ?boss)
	       (or (supervisor ?staff-person ?boss)
		 (and (supervisor ?staff-person ?middle-manager)
		   (outranked-by ?middle-manager ?boss))))

;; Louis ver.
(rule (outranked-by ?staff-person ?boss)
      (or (supervisor ?staff-person ?boss)
	(and (outranked-by ?middle-manager ?boss)
	  (supervisor ?staff-person ?middle-manager))))

