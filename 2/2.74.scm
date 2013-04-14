;a.
;事業所ファイルには各事業所ごとの型情報(事業所名など)を付与する必要がある
(define (get-record employee file)
  ((get 'get-record (type-tag file)) employee))
(define (type-tag datum)
  (if (pair? datum)
      (car datum)
      (error "Bad tagged datum -- TYPE-TAG" datum)))
(define (contents datum)
  (if (pair? datum)
      (cdr datum)
      (error "Bad tagged datum -- CONTENTS" datum)))
;b.
;レコードには各事業所ごとの型情報(事業所名など)を付与する必要がある
(define (get-salary record)
  ((get 'get-salary (type-tag record)) record))
;c.
(define (find-employee-record employee files)
  (map (lambda (file) (get-record employee file)) files))
;d.
;事業所ファイルとレコードには新しい事業所の型情報(事業所名など)を付与する必要がある