(define (square x)
  (* x x))
(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))
(define (average x y)
  (/ (+ x y) 2))
(define (improve guess x)
  (average guess (/ x guess)))
(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x)
		 x)))
(define (sqrt x)
  (sqrt-iter 1.0 x))

;xが非常に小さい数の場合テストに失敗する
;理由はguessの自乗が0.001よりも小さくなった場合にgood-enough?は常に真となるため
(square (sqrt 1.0E-6))


;xが非常に大きい数の場合テストに無限ループになる
;理由:good-enough?においてguessが有効桁数を超えると実数演算後に切り上げが行われ、必ず1以上になってしまい、good-enough?は常に偽となるため
;gaucheで実数は倍精度小数で表示される(C言語のdouble型)ため2進52桁[10進約16桁]までが有効桁数

(sqrt 1.0E29)

;good-enought?を次のように改良すればよい
(define (good-enough? guess x)
  (< (abs (- 1 (/ (square guess) x))) 0.001))
