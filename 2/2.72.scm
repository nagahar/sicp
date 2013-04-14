(define (make-leaf symbol weight)
  (list 'leaf symbol weight))
(define (leaf? object)
  (eq? (car object) 'leaf))
(define (symbol-leaf x) (cadr x))
(define (weight-leaf x) (caddr x))
(define (make-code-tree left right)
  (list left
        right
        (append (symbols left) (symbols right))
        (+ (weight left) (weight right))))
(define (left-branch tree) (car tree))
(define (right-branch tree) (cadr tree))
(define (symbols tree)
  (if (leaf? tree)
      (list (symbol-leaf tree))
      (caddr tree)))
(define (weight tree)
  (if (leaf? tree)
      (weight-leaf tree)
      (cadddr tree)))
(define (decode bits tree)
  (define (decode-1 bits current-branch)
    (if (null? bits)
        '()
        (let ((next-branch
               (choose-branch (car bits) current-branch)))
          (if (leaf? next-branch)
              (cons (symbol-leaf next-branch)
                    (decode-1 (cdr bits) tree))
              (decode-1 (cdr bits) next-branch)))))
  (decode-1 bits tree))
(define (choose-branch bit branch)
  (cond ((= bit 0) (left-branch branch))
        ((= bit 1) (right-branch branch))
        (else (error "bad bit -- CHOOSE-BRANCH" bit))))
(define (encode message tree)
  (if (null? message)
      '()
      (append (encode-symbol (car message) tree)
              (encode (cdr message) tree))))
(define (encode-symbol symbol tree)
  (let ((leftb (left-branch tree))
	(rightb (right-branch tree)))
    (cond ((leaf? tree) '())
	  ((symbol-exists? symbol leftb)
	   (cons 0 (encode-symbol symbol leftb)))
	  ((symbol-exists? symbol rightb)
	   (cons 1 (encode-symbol symbol rightb))))))
(define (symbol-exists? symbol tree)
  (if (leaf? tree)
      (eq? symbol (symbol-leaf tree))
      (or (symbol-exists? symbol (left-branch tree))
          (symbol-exists? symbol (right-branch tree)))))

; 最高頻度のアルファベットの符号化
; symbol-exist?: Θ(n)
; encode-symbol?: Θ(n)
; encode: Θ(n**2)
;
; 最低頻度のアルファベットの符号化
; symbol-exist?: Θ(n)
; encode-symbol?: Θ(n**2)
; encode: Θ(n**3)
