;; もし、任意の手続きpが停止するか否かを判別する(halts? p p)が存在するとする
;; ここで(try p)は下記のごとく、任意の手続きpが停止するときは停止せず(run-forever実行)、pが停止しないときは'haltedを出力して停止する
;; そこでpをtryとすると、(try try)は、tryが停止するとき停止せず、tryが停止しないとき'haltedを出力して停止することになり、これは矛盾である
;; したがって、任意の手続きpが停止するか否かを判別する(halts? p p)は存在しない

(define (run-forever) (run-forever))
(define (try p)
  (if (halts? p p)
    (run-forever)
    'halted))

