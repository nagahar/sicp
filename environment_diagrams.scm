;; 環境図
;;         -----------------------
;; global->| func --|            |
;;         ---------+-------------
;;           ^      |       ^
;;           |      |       |
;;         -------- |     --------
;;     E1->| a: n | | E2->| b: m |
;;         -------- |     --------
;;                  |       ^
;;                  v       |
;;                  oo-------
;;                  |
;;                  v
;;                  パラメタ: p
;;                  本体: (lambda (p) ...)
;;
;; 環境の簡易図
;; - global
;;    func: <-> p, (lambda (p) ...)
;;    <- E1
;;        a: n
;;    <- E2
;;        b: m
;;        <- p, (lambda (p) ...)

