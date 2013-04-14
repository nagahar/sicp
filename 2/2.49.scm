(define (make-vect x y)
  (cons x y))
(define (xcor-vect v)
  (car v))
(define (ycor-vect v)
  (cdr v))
(define (add-vect v1 v2)
  (make-vect
   (+ (xcor-vect v1) (xcor-vect v2))
   (+ (ycor-vect v1) (ycor-vect v2))))
(define (sub-vect v1 v2)
  (make-vect
   (- (xcor-vect v1) (xcor-vect v2))
   (- (ycor-vect v1) (ycor-vect v2))))
(define (scale-vect s v)
  (make-vect
   (* s (xcor-vect v))
   (* s (ycor-vect v))))
(define (make-segment start end)
  (cons start end))
(define (start-segment segment)
  (car segment))
(define (end-segment segment)
  (cdr segment))
(define (segments->painter segment-list)
  (lambda (frame)
    (for-each
     (lambda (segment)
       (draw-line
        ((frame-coord-map frame) (start-segment segment))
        ((frame-coord-map frame) (end-segment segment))))
     segment-list)))

;a.
(define ext-painter
  (let ((bl (make-vect 0 0))
	(br (make-vect 1 0))
	(tr (make-vect 1 1))
	(tl (make-vect 0 1)))
    (segments->painter
     (list (make-segment bl br)
	   (make-segment br tr)
	   (make-segment tr tl)
	   (make-segment tl bl)))))

;b.
(define x-painter
  (let ((bl (make-vect 0 0))
	(br (make-vect 1 0))
	(tr (make-vect 1 1))
	(tl (make-vect 0 1)))
    (segments->painter
     (list (make-segment bl tr)
	   (make-segment br tl)))))

;c.
(define diamond-painter
  (let ((b (make-vect 0.5 0))
	(r (make-vect 1 0.5))
	(t (make-vect 0.5 1))
	(l (make-vect 0 0.5)))
    (segments->painter
     (list (make-segment b r)
	   (make-segment r t)
	   (make-segment t l)
	   (make-segment l b)))))

;d.
(define wave
  (let ((p01 (make-vect 0.40 1.00))
        (p02 (make-vect 0.60 1.00))
        (p03 (make-vect 0.00 0.80))
        (p04 (make-vect 0.35 0.80))
        (p05 (make-vect 0.65 0.80))
        (p06 (make-vect 0.00 0.60))
        (p07 (make-vect 0.30 0.60))
        (p08 (make-vect 0.40 0.60))
        (p09 (make-vect 0.60 0.60))
        (p10 (make-vect 0.70 0.60))
        (p11 (make-vect 0.20 0.55))
        (p12 (make-vect 0.30 0.55))
        (p13 (make-vect 0.35 0.50))
        (p14 (make-vect 0.65 0.50))
        (p15 (make-vect 0.20 0.45))
        (p16 (make-vect 1.00 0.40))
        (p17 (make-vect 0.50 0.20))
        (p18 (make-vect 1.00 0.20))
        (p19 (make-vect 0.25 0.00))
        (p20 (make-vect 0.40 0.00))
        (p21 (make-vect 0.60 0.00))
        (p22 (make-vect 0.75 0.00)))
    (segments->painter
     (list (make-segment p01 p04)
           (make-segment p04 p08)
           (make-segment p08 p07)
           (make-segment p07 p11)
           (make-segment p11 p03)
           (make-segment p06 p15)
           (make-segment p15 p12)
           (make-segment p12 p13)
           (make-segment p13 p19)
           (make-segment p20 p17)
           (make-segment p17 p21)
           (make-segment p22 p14)
           (make-segment p14 p18)
           (make-segment p16 p10)
           (make-segment p10 p09)
           (make-segment p09 p05)
           (make-segment p05 p02)))))
