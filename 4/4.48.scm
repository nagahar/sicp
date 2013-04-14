(load "../amb.scm")
(driver-loop)

;; 下記手続きをambevalで評価する
(define nouns '(noun student professor cat class))
(define verbs '(verb studies lectures eats sleeps))
(define articles '(article the a))
(define prepositions '(prep for to in by with))
(define adjectives '(adjective tall little large small))
(define adverbs '(adverb brilliantly daily soon))
(define conjunctions '(conjunction and but))

(define (parse-sentences)
  (define (maybe-extend sentence)
    (amb sentence
	 (maybe-extend (list 'sentece
			     sentence
			     (parse-word conjunctions)
			     (parse-sentence)))))
  (maybe-extend (parse-sentence)))

(define (parse-sentence)
  (list 'sentence
	(parse-noun-phrase)
	(parse-verb-phrase)))

(define (parse-noun-phrase)
  (define (maybe-extend noun-phrase)
    (amb noun-phrase
	 (maybe-extend (list 'noun-phrase
			     noun-phrase
			     (parse-prepositional-phrase)))))
  (maybe-extend (parse-simple-noun-phrase)))

(define (parse-verb-phrase)
  (define (maybe-extend verb-phrase)
    (amb verb-phrase
	 (maybe-extend (list 'verb-phrase
			     verb-phrase
			     (parse-prepositional-phrase)
			     (parse-adverb)))))
  (maybe-extend (parse-word verbs)))

(define (parse-adverb)
  (define (maybe-extend adverb)
    (amb adverb
	 (maybe-extend (list
			 adverb
			 (parse-word adverbs)))))
  (maybe-extend (parse-word adverbs)))

(define (parse-prepositional-phrase)
  (list 'prep-phrase
	(parse-word prepositions)
	(parse-noun-phrase)))

(define (parse-simple-noun-phrase)
  (amb
    (list 'simple-noun-phrase
	  (parse-word articles)
	  (parse-word nouns))
    (list 'adjective-noun-phrase
	  (parse-word articles)
	  (parse-word adjectives)
	  (parse-word nouns))
    (list 'adjective-noun-phrase
	  (parse-word articles)
	  (parse-adverb)
	  (parse-word adjectives)
	  (parse-word nouns))))

(define (parse-word word-list)
  (require (not (null? *unparsed*)))
  (require (memq (car *unparsed*) (cdr word-list)))
  (let ((found-word (car *unparsed*)))
    (set! *unparsed* (cdr *unparsed*))
    (list (car word-list) found-word)))
(define *unparsed* '())
(define (parse input)
  (set! *unparsed* input)
  (let ((sent (parse-sentence)))
    (require (null? *unparsed*))
    sent))

;;;; Amb-Eval input:
;(parse '(the professor lectures to the student in the class with the small cat daily))
;
;;;; Starting a new problem 
;;;; Amb-Eval value:
;(sentence (simple-noun-phrase (article the) (noun professor)) (verb-phrase (verb lectures) (prep-phrase (prep to) (noun-phrase (noun-phrase (simple-noun-phrase (article the) (noun student)) (prep-phrase (prep in) (simple-noun-phrase (article the) (noun class)))) (prep-phrase (prep with) (adjective-noun-phrase (article the) (adjective small) (noun cat))))) (adverb daily)))
;
;;;; Amb-Eval input:
;try-again
;
;;;; Amb-Eval value:
;(sentence (simple-noun-phrase (article the) (noun professor)) (verb-phrase (verb lectures) (prep-phrase (prep to) (noun-phrase (simple-noun-phrase (article the) (noun student)) (prep-phrase (prep in) (noun-phrase (simple-noun-phrase (article the) (noun class)) (prep-phrase (prep with) (adjective-noun-phrase (article the) (adjective small) (noun cat))))))) (adverb daily)))

