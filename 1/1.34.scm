(define (f g)
  (g 2))

(仮説)
(f f)->(f 2)->(2 2)
2は数値であるので2を返す

(検証)
*** Error: invalid application: (2 2)
Stack Trace:
_______________________________________

(2 2)最初の2は関数でないのでエラー