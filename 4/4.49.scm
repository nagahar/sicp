(load "../amb.scm")
(driver-loop)

;; 下記手続きをambevalで評価する
(define (parse-word word-list)
  (require (not (null? word-list)))
  (let ((found-word (cadr word-list)))
    (set! word-list (cons (car word-list) (cddr word-list)))
    (list (car word-list) found-word)))

(define nouns '(noun student professor cat class))
(define verbs '(verb studies lectures eats sleeps))
(define articles '(article the a))
(define prepositions '(prep for to in by with))

(define (parse-sentence)
  (list 'sentence
	(parse-noun-phrase)
	(parse-verb-phrase)))
(define (parse-noun-phrase)
  (define (maybe-extend noun-phrase)
    (amb noun-phrase
	 (maybe-extend (list 'noun-phrase
			     noun-phrase
			     (parse-prepositional-phrase))
		       (parse-simple-noun-phrase))))
  (maybe-extend (parse-simple-noun-phrase)))
(define (parse-verb-phrase)
  (define (maybe-extend verb-phrase)
    (amb verb-phrase
	 (maybe-extend (list 'verb-phrase
			     verb-phrase
			     (parse-prepositional-phrase)))))
  (maybe-extend (parse-word verbs)))
(define (parse-prepositional-phrase)
  (list 'prep-phrase
	(parse-word prepositions)
	(parse-noun-phrase)))
(define (parse-simple-noun-phrase)
  (list 'simple-noun-phrase
	(parse-word articles)
	(parse-word nouns)))

(define *unparsed* '())
(define (parse input)
  (set! *unparsed* input)
  (let ((sent (parse-sentence)))
    (require (null? *unparsed*))
    sent))

;;;; Amb-Eval input:
;(parse '())
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;(sentence (simple-noun-phrase (article the) (noun student)) (verb studies))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(sentence (simple-noun-phrase (article the) (noun student)) (verb-phrase (verb studies) (prep-phrase (prep for) (simple-noun-phrase (article the) (noun student)))))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(sentence (simple-noun-phrase (article the) (noun student)) (verb-phrase (verb-phrase (verb studies) (prep-phrase (prep for) (simple-noun-phrase (article the) (noun student)))) (prep-phrase (prep for) (simple-noun-phrase (article the) (noun student)))))
;
