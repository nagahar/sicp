;; 本書の翻訳系は右から左に被演算子を評価する
;; 手続きconstruct-arglistによって順序は決まる
;;
;; 評価順序を逆にするには下記のようにする
;; 実行時にreverseが行われるため、本書の翻訳系に比べて実行効率は低下する

(load "../compiler.scm")
(define (construct-arglist operand-codes)
  (if (null? operand-codes)
    (make-instruction-sequence '() '(argl)
			       '((assign argl (const ()))))
    (let ((code-to-get-last-arg
	    (append-instruction-sequences
	      (car operand-codes)
	      (make-instruction-sequence '(val) '(argl)
					 '((assign argl (op list) (reg val)))))))
      (if (null? (cdr operand-codes))
	code-to-get-last-arg
	(append-instruction-sequences
	  (preserving '(env)
		      code-to-get-last-arg
		      (code-to-get-rest-args
			(cdr operand-codes)))
	  (make-instruction-sequence '() '(argl)
				     '((assign argl (op reverse) (reg argl)))))))))

(parse-compiled-code
  (compile
    '(define (f x)
       (+ x (g (+ x 2))))
    'val
    'next))

