#lang racket/gui

(require net/url net/cookies net/uri-codec)
(require racket/future racket/draw)
(require json pict)
(require simple-qr)


;; URL Constants
(define str-getkey
  "https://passport.bilibili.com/login?act=getkey")

(define str-qrlogin-init
  "http://passport.bilibili.com/qrcode/getLoginUrl")

(define str-qrlogin-info
  "http://passport.bilibili.com/qrcode/getLoginInfo")

;;; fonction auxiliaire

;; GET
(define (str/get->json str-url)
  (read-json (get-pure-port (string->url str-url))))

;; POST
(define (str/post->json str-url params)
  (let-values
      ([(_ __ p)
        (http-sendrecv/url
         (string->url str-url)
         #:method #"POST"
         #:data (alist->form-urlencoded params)
         #:headers (list "Content-Type: application/x-www-form-urlencoded"))])
    (read-json p)))


(define (check-login-info oauth)
  (str/post->json
   str-qrlogin-info
   `((oauthKey . ,oauth))))

;; Response Accessor
(define (json/qrlogin-url j)
  (hash-ref (hash-ref j 'data) 'url))

(define (json/qrlogin-oauth j)
  (hash-ref (hash-ref j 'data) 'oauthKey))


(define (display-img/frame img-path lab)
  (let* ([frm (new frame% [label lab])]
         [bmp (make-object bitmap% img-path)]
         [msg (new message% [label bmp] [parent frm])])
    (send frm show #t)))

(define (diverge-until f guard)
  (begin
    (let ([result (f)])
      (displayln result)
      (if (guard result)
          result
          (diverge-until f guard)))))


;; Authentication Helper 
(define (auth-succeed? j)
  (hash? (hash-ref j 'data)))

(define (check-sleep t a)
  (sleep t)
  (check-login-info a))

;; Main Program
(define (main)
  (let* ([res-init (str/get->json str-qrlogin-init)] ; GET
         [auth-url (json/qrlogin-url res-init)]      ; extract url
         [auth-oauth (json/qrlogin-oauth res-init)]
         )     
    (begin 
      (qr-write auth-url "qr-auth.png")
      (thread (lambda () (display-img/frame "qr-auth.png" "Login QR Display")))
      (thread ;; TODO : replace with future and logger
       (lambda ()
         (diverge-until (lambda () (check-sleep 2 auth-oauth))
                        auth-succeed?))))))

#;(define final (main))