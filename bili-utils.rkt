#lang racket

(require net/url net/cookies net/uri-codec json)
(provide (all-defined-out))
;;; fonction auxiliaire

;; GET
(define (str/get->json str-url)
  (read-json (get-pure-port (string->url str-url))))
