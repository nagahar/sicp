;; レジスタaは3になる
;(set-register-contents! label-test 'a 0)
;done
;(start label-test)
;done
;(get-register-contents label-test 'a)
;3

;; extract-labelsをラベル名が二つの異なる場所を指すように使われたらエラーとするように修正する
(load "../simulator.scm")
(define (extract-labels text receive)
  (if (null? text)
    (receive '() '())
    (extract-labels (cdr text)
		    (lambda (insts labels)
		      (let ((next-inst (car text)))
			(if (symbol? next-inst)
			  (if (assoc next-inst labels)
			    (error "Duplicated label -- ASSEMBLE" next-inst)
			    (receive insts
			      (cons (make-label-entry next-inst
						      insts)
				    labels)))
			  (receive (cons (make-instruction next-inst)
					 insts)
			    labels)))))))

(define label-test
  (make-machine
    '(a)
    '()
    '(start
       (goto (label here))
       here
       (assign a (const 3))
       (goto (label there))
       here
       (assign a (const 4))
       (goto (label there))
       there)))

