
; c stands for Church

(define zero_c
  (lambda (f) (lambda (x) x)))

(define (succ_c n)
  (lambda (f) (lambda (x) (f ((n f) x)))))

(define one_c
  (lambda (f) (lambda (x) (f x))))

(define two_c
  (lambda (f) (lambda (x) (f (f x)))))

(define (c2n n)
  (define (inc i) (+ i 1))
  (display ((n inc) 0)))
;(c2n one_c) ; -> 1

(define (compose f g)
  (lambda (x) (f (g x))))

(define (plus_c n m)
  (lambda (f) (compose (n f) (m f))))

(define three_c (plus_c one_c two_c))
;(c2n three_c) ; -> 3

(define (mult_c n m)
  (lambda (f) (n (m f))))

(define six_c (mult_c three_c two_c))
;(c2n six_c)

(define (expt_c b e) (e b))
