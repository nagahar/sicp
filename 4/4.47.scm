;; Louisの版だとambの次の候補を取り出すときにparse-wordが作用してしまい、元の動詞(名詞)を飛ばして動詞句(名詞句)を作成してしまう
;; 式の順序を交換するとparse-***-phrasesの無限ループになってしまう

;; Louis ver.
(define (parse-verb-phrase)
  (amb (parse-word verbs)
       (list 'verb-phrase
	     (parse-verb-phrase)
	     (parse-prepositional-phrase))))
(define (parse-noun-phrase)
  (amb (parse-word nouns)
       (list 'noun-phrase
	     (parse-noun-phrase)
	     (parse-prepositional-phrase))))
;; original ver.
(define (parse-verb-phrase)
  (define (maybe-extend verb-phrase)
    (amb verb-phrase
	 (maybe-extend (list 'verb-phrase
			     verb-phrase
			     (parse-prepositional-phrase)))))
  (maybe-extend (parse-word verbs)))
(define (parse-noun-phrase)
  (define (maybe-extend noun-phrase)
    (amb noun-phrase
	 (maybe-extend (list 'noun-phrase
			     noun-phrase
			     (parse-prepositional-phrase)))))
  (maybe-extend (parse-simple-noun-phrase)))
