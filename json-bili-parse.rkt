#lang racket
(require json)

(define f (open-input-file "bangumi-list.json"))

(define bs (hash-ref (hash-ref (read-json f) 'data)
                     'list))


(define o (open-output-file "output.txt" #:exists 'truncate))

(map
 (lambda (x)
   (begin
     (display (hash-ref x 'title) o)
     (displayln "" o)))
 bs)

(close-output-port o)
