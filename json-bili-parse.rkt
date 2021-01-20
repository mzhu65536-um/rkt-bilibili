#lang racket

(require net/url net/cookies)
(require json)
(require "bili-utils.rkt")

(define (load-cookie-header)
  (with-input-from-file "cookies.txt" read))

(define str-url-bangumi-list
  "https://api.bilibili.com/x/space/bangumi/follow/list")

(define uid (with-input-from-file "id.txt" read))

(define params
  `((vmid . ,uid)
    (pn . 1)
    (ps . 30)
    (type . 2)))

(define (params->str p)
  (string-append
   "?"
   (string-join
    (map (lambda (x) (string-append (symbol->string (car x))
                                   "="
                                   (number->string (cdr x))))
         p)
    "&")))


(define (send-request)
  (define-values (_ __ response)
    (http-sendrecv/url
     (string->url (string-append str-url-bangumi-list (params->str params)))
     #:method #"GET"
     #:headers (list (format "Cookie: ~a" (load-cookie-header)))))
  (read-json response))

(define (strip d)
  (hash-ref (hash-ref d 'data) 'list))

(define (main jr)
  (let ([o (open-output-file "output.txt" #:exists 'truncate)])
    (map
     (lambda (x)
       (begin
         (display (hash-ref x 'title) o)
         (displayln "" o)))
     (strip jr))
    (close-output-port o)))

(main (send-request))