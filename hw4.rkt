#lang racket

(provide 
         entry entry-key entry-value entry?
         bnot bnot-arg bnot?
         band band-arg1 band-arg2 band?
         bor bor-arg1 bor-arg2 bor?
         tt tt-vars tt-rows tt?
	 hours
         lookup unique-keys?
         boolean-exp? type-of
	 all-vars
	 eval-in-env
	 all-combs
	 truth-table	 	 	 
	 satisfiable? equivalent?
	 find-exp
         substitute-in
         match)

; Please do not modify lines above this one.

; ****************************************************************
; CS 201 HW #4  DUE 11:59 pm Friday, March 26, 2021
; using the submit command on the Zoo.
; ****************************************************************
; Name: Chocho Hu
; Email address: hudie.hu@yale.edu
; ****************************************************************
; ** problem 0 ** (1 easy point)
; Please modify the following definition to reflect the number of
; hours you spent on this assignment.

(define hours 7.4)

; ****************************************************************
; Unless the problem specifies otherwise:
; * You may solve the problem using any method 
; and any Racket constructs, except mutators (set! and its relatives.)
; * You may write auxiliary procedure(s) in addition to
; the one(s) specified in the problem.  Please include
; a comment for each one explaining its input and results.

; The topics of this assignment are as follows.
; Racket: deep recursion on a recursively defined data structure.
; Computer Science: Boolean functions, expressions, environments,
; truth tables, satisfiability, equivalence.

; You might also find uses for the special form: case.

; ****************************************************************
; We define a table as a list of entries,
; where each entry is given by the following structure.

(struct entry (key value) #:transparent)

; Recall that a struct defines a constructor, selector(s), and a type predicate.
; In this case, the constructor is entry, the selectors are
; entry-key and entry-value, and the type predicate is entry?.

; Here are two examples of tables.

(define test1
  (list
   (entry "second" 2)
   (entry "first" 1)
   (entry "fifth" 5)))

(define test2
  (list
   (entry 'x 0)
   (entry 'z 1)
   (entry 'y 1)
   (entry 'z 0)))

; ****************************************************************
; ** problem 1 ** (9 points)
; Write two procedures to deal with tables as follows.

; (lookup key table)
; (unique-keys? table)

; (lookup key table)
; returns #f if no entry in the table has a key equal? to key
; otherwise, returns the value of the first entry whose key is equal? to key.

; (unique-keys? table)
; returns #t if all the entries of table have keys that are pairwise
; not equal? and #f otherwise.

; Examples
;> (lookup "first" test1)
;1
;> (lookup "third" test1)
;#f
;> (lookup 'z test2)
;1
;> (unique-keys? test1)
;#t
;> (unique-keys? test2)
;#f
;>
; ****************************************************************

(define (lookup key table)
  (if (empty? table)
      #f
      (if (equal? key (entry-key (car table)))
          (entry-value (car table))
          (lookup key (cdr table)))))

(define (unique-keys? table)
  (cond
    [(empty? table) #t]
    [(= 0 (length table)) #t]
    [(not (not (lookup (entry-key (car table)) (cdr table)))) #f]
    [else (unique-keys? (cdr table))]))

; ****************************************************************
; Our representation of Boolean expressions will use the following
; struct definitions.  Note that the transparent attribute allows
; the contents of a structure to be printed out, and allows two
; structures to be compared for content using equal?

(struct bnot (arg) #:transparent)
(struct band (arg1 arg2) #:transparent)
(struct bor (arg1 arg2) #:transparent)

; We recursively define a representation of Boolean expressions as follows.

; 1) 0 and 1 represent the constants 0 and 1 and are valid Boolean
;    expressions

; 2) Racket symbols represent variables (for example, 'x, 'y, 'z2) and
;    are valid Boolean expressions

; 3) If exp1 and exp2 represent Boolean expressions, then
;    (bnot exp1) represents the NOT of exp1
;    (band exp1 exp2) represents the AND of exp1 and exp2
;    (bor exp1 exp2) represents the OR of exp1 and exp2

; Some examples of Boolean expressions follow.

(define exp0 (bnot 0))
(define exp1 (bor 'x 'y))
(define exp2 (band 'y 'z))
(define exp3 (band 'w (bor (bnot 'x) 0)))
(define exp4 (bor 'x (bnot 'x)))
(define exp5 (band (bor 'x (bnot 'y)) (bnot (band 0 'z))))

; ****************************************************************
; ** problem 2 ** (10 points)
; Write two procedures

; (boolean-exp? exp)
; (type-of exp)

; (boolean-exp? exp) takes an arbitrary Racket value exp
; and tests to see whether it is a Boolean expression according
; to the definition above, returning #t if so and #f if not.

; (type-of exp)
; that takes a Boolean expression as defined above
; and returns its type as one of the symbols:
;   constant, variable, not, or, and
; Note that the type is determined by the top-level
; operation in case the expression is not a constant or variable.

; Recall that (number? exp) tests whether exp is a number,
; and (symbol? exp) tests whether exp is a symbol, and the
; structs bnot, band, and bor have type predicates bnot?, band?, and bor?

; Examples
;> (boolean-exp? 0)
;#t
;> (boolean-exp? 2)
;#f
;> (boolean-exp? exp0)
;#t
;> (boolean-exp? (band "hi" 'c))
;#f
;> (boolean-exp? (band 'x (bor 0 (bnot 1))))
;#t
;> (boolean-exp? (band 'x (bor 0 (bnot #t))))
;#f
;> (type-of 0)
;'constant
;> (type-of 'hi)
;'variable
;> (type-of (bnot (band 'x 0)))
;'not
;> (type-of (bor (band 'x 'y) (band 'x 'z)))
;'or
;> (type-of (band (bor 0 1) (bnot 'x)))
;'and
; ****************************************************************

(define (boolean-exp? exp)
  (if (empty? exp)
      #f
      (cond
        [(equal? exp 0) #t]
        [(equal? exp 1) #t]
        [(symbol? exp) #t]
        [(bnot? exp)
          (if (boolean-exp? (bnot-arg exp)) #t #f)]
        [(band? exp)
         (if (and
              (boolean-exp? (band-arg1 exp))
              (boolean-exp? (band-arg2 exp)))
             #t #f)]
        [(bor? exp)
         (if (and
              (boolean-exp? (bor-arg1 exp))
              (boolean-exp? (bor-arg2 exp)))
             #t #f)]
        [else #f]
        )))

(define (type-of exp)
  (if (boolean-exp? exp)
      (cond
        [(equal? exp 0) 'constant]
        [(equal? exp 1) 'constant]
        [(symbol? exp) 'variable]
        [(bnot? exp) 'not]
        [(band? exp) 'and]
        [(bor? exp) 'or]
        [else #f]
        )
      #f))

; ****************************************************************
; ** problem 3 ** (10 points)
; Write a procedure

; (all-vars exp)

; that takes a Boolean expression exp 
; and makes a list containing all the variables
; that occur in exp.  The list should not contain duplicates,
; and should have the variables in the order of their
; first appearance in exp (scanning left to right.)

; Hint: selectors, type-of and deep recursion on the structure 
; of Boolean expressions.  Note that there is a Racket procedure
; remove-duplicates.

; Examples
;> (all-vars 0)
;'()
;> (all-vars (bnot (band 'x (band 'y (bor 'x 'z)))))
;'(x y z)
;> (all-vars (band 1 (bor 0 (bnot 'u))))
;'(u)
;> (all-vars (band (band 'x 'y) (band 'y 'x)))
;'(x y)
;> (all-vars (bor (bor (bor 'c 'b) (bor 'a 'b)) 'c))
;'(c b a)
;> 
; ****************************************************************

(define (all-vars exp)
  (remove-duplicates
   (if (empty? exp)
       '()
       (cond
         [(symbol? exp) (list exp)]
         [(bnot? exp)
          (all-vars (bnot-arg exp))]
         [(band? exp)
          (append
           (all-vars (band-arg1 exp))
           (all-vars (band-arg2 exp)))]
         [(bor? exp)
          (append
           (all-vars (bor-arg1 exp))
           (all-vars (bor-arg2 exp)))]
         [else '()]
         ))))

; ****************************************************************
; We represent an environment as a table each entry of which
; has a key that is a Racket symbol and a value that is 0 or 1,
; which specifies the truth value of that variable in the environment.
; For example:

(define environ1
  (list
   (entry 'x 0) (entry 'y 1) (entry 'z 0)))
  
(define environ2
  (list
   (entry 'u 0) (entry 'x 1) (entry 'w 1) (entry 'y 0) (entry 'z 1)))

; ****************************************************************
; ** problem 4 ** (10 points)
; Write a procedure 

; (eval-in-env exp env)

; that takes a Boolean expression exp and an environment env
; (represented as described above) and returns 0 or 1 giving 
; the value of the expression in the environment.

; If the Boolean expression contains variables that do not
; occur in the environment, (eval-in-env exp env) should
; return the symbol: 'unspecified-variable.
; (You may want to check for this condition first.)

; Hint: deep recursion on the structure of Boolean expressions
; along with argument selectors and type-of.

; Examples
;> (eval-in-env 1 environ1)
;1
;> (eval-in-env (bor 0 0) '())
;0
;> (eval-in-env 'x environ1)
;0
;> (eval-in-env 'x environ2)
;1
;> (eval-in-env (bnot 'z) environ1)
;1
;> (eval-in-env (bor 'y (bnot 'x)) environ2)
;0
;> (eval-in-env (band (band (bor 'u 'x) (bor 'w 0)) (bnot (band 'y 'z))) environ2)
;1
;> (eval-in-env exp5 environ1)
;0
;> (eval-in-env (band 'y (bor 'x 'u)) (list (entry 'x 0) (entry 'y 1)))
;'unspecified-variable
;>
; ****************************************************************

(define (eval-in-env exp env)
  (if (eval-helper exp env)
      (if (eval-helper2 exp env)
          1
          0)
      'unspecified-variable))

;check if contains unspecified-variable: #t for none; #f for having unspecified-variable: 
(define (eval-helper exp env)
  (cond
    [(equal? exp 0) #t]
    [(equal? exp 1) #t]
    [(symbol? exp)
     (if (not (lookup exp env)) #f #t)]
    [(bnot? exp)
     (if (eval-helper (bnot-arg exp) env) #t #f)]
    [(band? exp)
     (if (and
          (eval-helper (band-arg1 exp) env)
          (eval-helper (band-arg2 exp) env))
         #t #f)]
    [(bor? exp)
     (if (and
          (eval-helper (bor-arg1 exp) env)
          (eval-helper (bor-arg2 exp) env))
         #t #f)]
    [else #f]
    ))

;runs the not/and/or calculation
(define (eval-helper2 exp env)
  (cond
    [(equal? exp 0) #f]
    [(equal? exp 1) #t]
    [(symbol? exp)
     (if (= 1 (lookup exp env))
         #t
         #f)]
    [(bnot? exp)
     (not
      (eval-helper2 (bnot-arg exp) env))]
    [(band? exp)
     (and
      (eval-helper2 (band-arg1 exp) env)
      (eval-helper2 (band-arg2 exp) env))]
    [(bor? exp)
     (or
      (eval-helper2 (bor-arg1 exp) env)
      (eval-helper2 (bor-arg2 exp) env))]
    [else 'unspecified-variable]))

; ****************************************************************
; We define a truth table as represented by the following struct

(struct tt (vars rows) #:transparent)

; whose fields contain the following
; (1) a (possibly empty) list of n distinct variables, and
; (2) a table containing an entry for each combination of n 0's and 1's,
; whose key is a list of n 0's and 1's and whose value is the value (0 or 1)
; of the function represented by the truth table.

; Note that the entries in a truth table should be in increasing order of
; their keys, considered as binary numbers.

; Examples of truth tables for the expressions
; (bnot 'x), (band 'x 'y), (bor (bnot 'a) 'b) 
; and the function that is the XOR of 'u and 'v.

(define tt-not (tt '(x)
                   (list
                    (entry '(0) 1)
                    (entry '(1) 0))))

(define tt-and (tt '(x y)
                   (list 
                    (entry '(0 0) 0)
                    (entry '(0 1) 0)
                    (entry '(1 0) 0)
                    (entry '(1 1) 1))))
                    
 
(define tt-imp (tt '(a b)
                   (list
                    (entry '(0 0) 1)
                    (entry '(0 1) 1)
                    (entry '(1 0) 0)
                    (entry '(1 1) 1))))
  
(define tt-xor (tt '(u v)
                   (list
                    (entry '(0 0) 0)
                    (entry '(0 1) 1)
                    (entry '(1 0) 1)
                    (entry '(1 1) 0))))

; Here is a truth table for a function of three arguments a, b, c.

(define tt-f1 (tt '(a b c)
                  (list
                   (entry '(0 0 0) 0)
                   (entry '(0 0 1) 0)
                   (entry '(0 1 0) 1)
                   (entry '(0 1 1) 1)
                   (entry '(1 0 0) 0)
                   (entry '(1 0 1) 1)
                   (entry '(1 1 0) 0)
                   (entry '(1 1 1) 1))))

; ****************************************************************
; ** problem 5 ** (10 points)
; Write a procedure 

; (all-combs n)

; that takes a non-negative integer n and creates the list of all 
; lists of n 0's or 1's in the *specific order* required for
; a truth table.  In other words, the lists, interpreted as binary numbers, 
; should be in increasing order.

; Hint: if a recursive call gives the correct answer
; for (all-combs 2), what needs to happen to it
; to give the correct answer for (all-combs 3)?
; (This may remind you of power-set from assignment #1.)

; Use let or let* to avoid recomputing the recursive call!

; Examples
;> (all-combs 0)
;'(())
;> (all-combs 1)
;'((0) (1))
;> (all-combs 2)
;'((0 0) (0 1) (1 0) (1 1))
;> (all-combs 3)
;'((0 0 0) (0 0 1) (0 1 0) (0 1 1) (1 0 0) (1 0 1) (1 1 0) (1 1 1))
;> 
; ****************************************************************

(define (all-combs n)
  (if (= n 0)
      '(())
      (append
       (map (lambda(x) (cons 0 x)) (all-combs (- n 1)))
       (map (lambda(x) (cons 1 x)) (all-combs (- n 1)))
       )))

; ****************************************************************
; ** problem 6 ** (10 points)
; Write a procedure

; (truth-table exp)

; that takes a Boolean expression exp and returns the truth table for exp
; where the variables for the table are extracted from exp using all-vars, 
; and the function value for each row is obtained by evaluating exp 
; in the corresponding environment.  Notice that all-vars specifies
; the order of variables for the truth table.

; Examples:
;> (truth-table exp0)
;(tt '() (list (entry '() 1)))
;> (truth-table exp1)
;(tt
; '(x y)
; (list (entry '(0 0) 0) (entry '(0 1) 1) (entry '(1 0) 1) (entry '(1 1) 1)))
;> (truth-table exp5)
;(tt
; '(x y z)
; (list
;  (entry '(0 0 0) 1)
;  (entry '(0 0 1) 1)
;  (entry '(0 1 0) 0)
;  (entry '(0 1 1) 0)
;  (entry '(1 0 0) 1)
;  (entry '(1 0 1) 1)
;  (entry '(1 1 0) 1)
;  (entry '(1 1 1) 1)))
;> 
; ****************************************************************


(define (truth-table exp)
      (tt (all-vars exp)
          (map
           (lambda(x)
             (entry x (eval-in-env exp (tt-helper exp x))))
           (all-combs (length (all-vars exp))))))

;helper function to build the calculation env
;lst for (1,0)kind value list
;add for adding another row onto the table
(define (tt-helper exp lst [add 0])
  (if (empty? lst)
      '()
      (map
       (lambda(x y) (entry x y))
       (if (empty? (all-vars exp))
           '(())
             (if (> add 0)
                 (cons 'zz (all-vars exp))
                 (all-vars exp))
             )
       lst)))



; ****************************************************************
; ** problem 7 ** (10 points)
; Write two procedures

; (satisfiable? exp)
; (equivalent? exp1 exp2)

; (satisfiable? exp)
; takes one Boolean expression exp and
; returns #t if exp is satisfiable and #f otherwise.

; (equivalent? exp1 exp2)
; takes two Boolean expressions exp1 and exp2
; and returns #t if they are equivalent and #f if they
; are not equivalent.

; A Boolean expression is satisfiable if there exists an environment
; in which its value is 1.  Two Boolean expressions are equivalent
; if for every environment which assigns values to all the variables
; in either expression, they have the same value in that environment.

; One possibility might be to use satisfiable? to help implement equivalent?

; These procedures will be tested on expressions with few enough
; variables that generating truth tables will be a feasible approach.

; Examples:
;>  (satisfiable? 0)
;#f
;> (satisfiable? 1)
;#t
;>  (satisfiable? (band 'x (band 'y 'z)))
;#t
;> (satisfiable? (band 'x (band 'y (bnot 'y))))
;#f
;>  (satisfiable? (band (bor 'x (bnot 'y)) 0))
;#f
;>  (equivalent? 0 (band 'a (bnot 'a)))
;#t
;>  (equivalent? 0 'a) 
;#f
;>  (equivalent? (bor 'x (bor 'y 'z)) (bor 0 (bor 'z (bor 'x 'y))))
;#t
;> (equivalent? (bor 'x (band 'y 'z)) (band (bor 'x 'y) (bor 'x 'z)))
;#t
;> 
; ****************************************************************


(define (satisfiable? exp [lst (tt-rows(truth-table exp))])
  (if (empty? lst)
      #f
      (if (= 1 (entry-value(car lst)))
          #t
          (satisfiable? exp (cdr lst)))))

;(require racket/trace)

(define (equivalent? exp1 exp2)
  (andmap (lambda(x)x)
   (let ((exp
         (if (> (length (all-vars exp1)) (length (all-vars exp2)))
             exp1 exp2)))
     (map
     (lambda(x)
       (equal?
        (eval-in-env exp1 (tt-helper exp1 x
                                     (- (length (all-vars exp)) (length (all-vars exp1)))))
        (eval-in-env exp2 (tt-helper exp2 x
                                     (- (length (all-vars exp)) (length (all-vars exp2)))))
        ))
     (all-combs (length (all-vars exp)))
     ))))

;(trace equivalent?)

; ****************************************************************
; ** problem 8 ** (10 points)
; Write a procedure

; (find-exp tt)

; This procedure takes a truth table
; and returns a Boolean expression 
; for the given truth table.

; You may choose to use the sum-of-products algorithm
; from lecture, or some other method.
; Please include comments explaining your method
; in either case.

;Examples
;>  (boolean-exp? (find-exp tt-and))
;#t
;>  (equivalent? (find-exp tt-and) (band 'x 'y))
;#t
;>  (equivalent? (find-exp tt-imp) (bor (bnot 'a) 'b)) 
;#t
;>  (equivalent? (find-exp tt-xor) (bor (band 'u (bnot 'v)) (band (bnot 'u) 'v)))
;#t
;>  (boolean-exp? (find-exp tt-f1))
;#t
;> 
; ****************************************************************

;(struct tt (vars rows) #:transparent)

; The Sum of Products Algorithm

(define (find-exp tt)
  (find-helper3 tt
                (find-helper (tt-rows tt))
                (length (find-helper (tt-rows tt)))))

;find rows which return 1
(define (find-helper lst)
  (if (empty? lst)
      '()
      (if (= (entry-value (car lst)) 1)
          (cons (car lst) (find-helper (cdr lst)))
          (find-helper (cdr lst)))))

;create band part
(define (find-helper2 lst)
  (band
   (if (= (car lst) 1)
       'x
       (bnot 'x))
   (if (= (cadr lst) 1)
       'y
       (bnot 'y))))

;create bor part
(define (find-helper3 tt new-ttrows n)
  (cond
    [(> n 2)
     (bor
      (bor
       (find-helper2 (entry-key (car new-ttrows)))
       (find-helper2 (entry-key (cadr new-ttrows))))
      (find-helper3 tt (cdr (cdr new-ttrows)) (- n 2)))
     ]
    [(= n 2)
     (bor
      (find-helper2 (entry-key (car new-ttrows)))
      (find-helper2 (entry-key (cadr new-ttrows))))
     ]
    [(= n 1) (find-helper2 (entry-key (car new-ttrows)))]
    [else 0]
    ))

    
; ****************************************************************
; ** problem 9 ** (10 points)
; Write a procedure

; (substitute-in exp sub-table)

; that takes a Boolean expression exp and a table sub-table each of whose
; entries has a key that is a variable and a value that is a
; Boolean expression, and returns the Boolean expression obtained
; by replacing every occurrence in exp of a variable in the sub-table with
; the corresponding Boolean expression.

; Hint: type-of and deep recursion on the structure of Boolean expressions.

; Examples
;> (substitute-in 0 (list (entry 'x 1)))
;0
;> (substitute-in 'x (list (entry 'x 1)))
;1
;> (substitute-in (band 'x 'y) (list (entry 'x (bnot 'z)) (entry 'y 0)))
;(band (bnot 'z) 0)
;> (substitute-in (band (bor 'x 'y) (bor (bnot 'x) 'y)) (list (entry 'x (bnot 1))))
;(band (bor (bnot 1) 'y) (bor (bnot (bnot 1)) 'y))
;> 
; ****************************************************************

(define (substitute-in exp sub-table)
    (if (empty? exp)
      empty
      (cond
        [(equal? exp 0) 0]
        [(equal? exp 1) 1]
        [(symbol? exp)
         (if (lookup exp sub-table)
             (lookup exp sub-table)
             exp)]
        [(bnot? exp)
          (bnot
           (substitute-in (bnot-arg exp) sub-table))]
        [(band? exp)
         (band
              (substitute-in (band-arg1 exp) sub-table)
              (substitute-in (band-arg2 exp) sub-table))]
        [(bor? exp)
         (bor
              (substitute-in (bor-arg1 exp) sub-table)
              (substitute-in (bor-arg2 exp) sub-table))]
        [else empty]
        )))

; ****************************************************************
; ** problem 10 ** (10 points)
; Write a procedure

; (match exp pat)

; that takes two Boolean expressions exp and pat and
; attempts to "match" the expression exp to the pattern pat.
; That is, it tries to find a table sub-table (as in the preceding
; problem) such that (substitute-in pat sub-table) returns
; the expression exp.  If this is not possible, it should return #f.

; Examples
;> (match 1 1)-
;'()
;> (match 0 'x)-
;(list (entry 'x 0))
;> (match 'z 0)-
;#f
;>  (match 'z 'x)-
;(list (entry 'x 'z))
;> (match (band 'y 'x) 'x)-
;(list (entry 'x (band 'y 'x)))
;>  (match (bnot (band 'a 'b)) (bnot 'z))-
;(list (entry 'z (band 'a 'b)))
;> (match (bor (band 'x 'y) 0) (bor 'a 0))==
;(list (entry 'a (band 'x 'y)))
;> (match (band (bor (bnot 'z) 0) (bor (bnot 'z) 'y)) (band (bor 'a 'b) (bor 'a 'c)))
;(list (entry 'a (bnot 'z)) (entry 'b 0) (entry 'c 'y))
;> (match (band (band 'x 'y) 'z) (band (bor 'a 'b) 'c))   
;#f
;> (match (band 'x 'y) (band 'a 'a))
;#f
;> (substitute-in (band 'a 'a) (match (band (bor 0 1) (bor 0 1)) (band 'a 'a)))
;(band (bor 0 1) (bor 0 1))
;> 
; ****************************************************************

(define (match exp pat)
  (match-helper (match-helper2 exp pat)))

;check #f and remove dups
(define (match-helper lst)
  (if (andmap (lambda(x)x) lst)
      (if (unique-keys? (remove-duplicates lst))
          (remove-duplicates lst)
          #f)
      #f))

(define (match-helper2 exp pat)
  (cond
    [(and (number? exp)(number? pat))
     '()]
    [(and (band? exp)(band? pat))
     (append
      (match-helper2 (band-arg1 exp) (band-arg1 pat))
      (match-helper2 (band-arg2 exp) (band-arg2 pat))
     )]
    [(and (bor? exp)(bor? pat))
     (append
      (match-helper2 (bor-arg1 exp) (bor-arg1 pat))
      (match-helper2 (bor-arg2 exp) (bor-arg2 pat))
     )]
    [(and (bnot? exp)(bnot? pat))
     (match-helper2 (bnot-arg exp) (bnot-arg pat))]
    [(symbol? pat)
     (list (entry pat exp))]
    [else (list #f)]))
  

; ********************************************************
; ********  testing, testing. 1, 2, 3 ....
; ********************************************************

(define *testing-flag* #t)
(define error display)  ;; turn off error messages

(define (testold name got expected)
  (cond (*testing-flag*
	 (let* ((expected (if (procedure? expected)
			      (and (expected got) 'OK-TEST)
			      expected))
		(prefix (if (equal? got expected)
			    'OK
			    'X)))
	   (list 'testing name prefix 'got: got 'expected: expected)))))
	
(define (test name got expected)
  (cond (*testing-flag*
	 (let* ((OK (if (procedure? expected)
		    	(expected got)
			(equal? got expected)))
		(prefix (if OK
			    'OK
			    'X)))
	   (list 'testing name prefix 'got: got 'expected: expected)))))

(test 'hours hours (lambda (x) (> x 0)))


(test 'lookup  (lookup "first" test1) 1)
(test 'lookup  (lookup "third" test1) #f)
(test 'lookup  (lookup 'z test2) 1)
(test 'unique-keys?  (unique-keys? test1) #t)
(test 'unique-keys?  (unique-keys? test2) #f)


(test 'boolean-exp?  (boolean-exp? 0) #t)
(test 'boolean-exp?  (boolean-exp? 2) #f)
(test 'boolean-exp?  (boolean-exp? exp0) #t)
(test 'boolean-exp?  (boolean-exp? (band "hi" 'c)) #f)
(test 'boolean-exp?  (boolean-exp? (band 'x (bor 0 (bnot 1)))) #t)
(test 'boolean-exp?  (boolean-exp? (band 'x (bor 0 (bnot #t)))) #f)
(test 'type-of  (type-of 0) 'constant)
(test 'type-of  (type-of 'hi) 'variable)
(test 'type-of  (type-of (bnot (band 'x 0))) 'not)
(test 'type-of  (type-of (bor (band 'x 'y) (band 'x 'z))) 'or)
(test 'type-of  (type-of (band (bor 0 1) (bnot 'x))) 'and)

(test 'all-vars (all-vars 0) '())
(test 'all-vars (all-vars (bnot (band 'x (band 'y (bor 'x 'z))))) '(x y z))
(test 'all-vars (all-vars (band 1 (bor 0 (bnot 'u)))) '(u))
(test 'all-vars (all-vars (band (band 'x 'y) (band 'y 'x))) '(x y))
(test 'all-vars (all-vars (bor (bor (bor 'c 'b) (bor 'a 'b)) 'c)) '(c b a))


(test 'eval-in-env (eval-in-env 1 environ1) 1)
(test 'eval-in-env (eval-in-env (bor 0 0) '()) 0)
(test 'eval-in-env (eval-in-env 'x environ1) 0)
(test 'eval-in-env (eval-in-env 'x environ2) 1)
(test 'eval-in-env (eval-in-env (bnot 'z) environ1) 1)
(test 'eval-in-env (eval-in-env (bor 'y (bnot 'x)) environ2) 0)
(test 'eval-in-env (eval-in-env (band (band (bor 'u 'x) (bor 'w 0)) (bnot (band 'y 'z))) environ2) 1)
(test 'eval-in-env (eval-in-env exp5 environ1) 0)
(test 'eval-in-env (eval-in-env (band 'y (bor 'x 'u)) (list (entry 'x 0) (entry 'y 1))) 'unspecified-variable)


(test 'all-combs (all-combs 0) '(()))
(test 'all-combs (all-combs 1) '((0) (1)))
(test 'all-combs (all-combs 2) '((0 0) (0 1) (1 0) (1 1)))
(test 'all-combs (all-combs 3) '((0 0 0) (0 0 1) (0 1 0) (0 1 1) (1 0 0) (1 0 1) (1 1 0) (1 1 1)))


(test 'truth-table (truth-table exp0) (tt '() (list (entry '() 1))))
(test 'truth-table (truth-table exp1) 
      (tt '(x y)
	  (list (entry '(0 0) 0) (entry '(0 1) 1) (entry '(1 0) 1) (entry '(1 1) 1))))
(test 'truth-table (truth-table exp5) (tt
				       '(x y z)
				       (list
					(entry '(0 0 0) 1)
					(entry '(0 0 1) 1)
					(entry '(0 1 0) 0)
					(entry '(0 1 1) 0)
					(entry '(1 0 0) 1)
					(entry '(1 0 1) 1)
					(entry '(1 1 0) 1)
					(entry '(1 1 1) 1))))



(test satisfiable?  (satisfiable? 0) #f)
(test satisfiable? (satisfiable? 1) #t)
(test satisfiable?  (satisfiable? (band 'x (band 'y 'z))) #t)
(test satisfiable? (satisfiable? (band 'x (band 'y (bnot 'y)))) #f)
(test satisfiable?  (satisfiable? (band (bor 'x (bnot 'y)) 0)) #f)
(test equivalent?  (equivalent? 0 (band 'a (bnot 'a))) #t)
(test equivalent?  (equivalent? 0 'a) #f)
(test equivalent?  (equivalent? (bor 'x (bor 'y 'z)) (bor 0 (bor 'z (bor 'x 'y)))) #t)
(test equivalent? (equivalent? (bor 'x (band 'y 'z)) (band (bor 'x 'y) (bor 'x 'z))) #t)


(test 'find-exp  (boolean-exp? (find-exp tt-and)) #t)
(test 'find-exp  (equivalent? (find-exp tt-and) (band 'x 'y)) #t)
(test 'find-exp  (equivalent? (find-exp tt-imp) (bor (bnot 'a) 'b)) #t)
(test 'find-exp  (equivalent? (find-exp tt-xor) (bor (band 'u (bnot 'v)) (band (bnot 'u) 'v))) #t)
(test 'find-exp  (boolean-exp? (find-exp tt-f1)) #t)

(test 'substitute-in (substitute-in 0 (list (entry 'x 1))) 0)
(test 'substitute-in (substitute-in 'x (list (entry 'x 1))) 1)
(test 'substitute-in (substitute-in (band 'x 'y) (list (entry 'x (bnot 'z)) (entry 'y 0))) (band (bnot 'z) 0))
(test 'substitute-in (substitute-in (band (bor 'x 'y) (bor (bnot 'x) 'y)) (list (entry 'x (bnot 1)))) (band (bor (bnot 1) 'y) (bor (bnot (bnot 1)) 'y)))


(test 'match (match 1 1) '())
(test 'match (match 0 'x) (list (entry 'x 0)))
(test 'match (match 'z 0) #f)
(test 'match  (match 'z 'x) (list (entry 'x 'z)))
(test 'match (match (band 'y 'x) 'x) (list (entry 'x (band 'y 'x))))
(test 'match  (match (bnot (band 'a 'b)) (bnot 'z)) (list (entry 'z (band 'a 'b))))
(test 'match (match (bor (band 'x 'y) 0) (bor 'a 0)) (list (entry 'a (band 'x 'y))))
(test 'match (match (band (bor (bnot 'z) 0) (bor (bnot 'z) 'y)) (band (bor 'a 'b) (bor 'a 'c))) (list (entry 'a (bnot 'z)) (entry 'b 0) (entry 'c 'y)))
(test 'match (match (band (band 'x 'y) 'z) (band (bor 'a 'b) 'c)) #f)
(test 'match (match (band 'x 'y) (band 'a 'a)) #f)
(test 'match (substitute-in (band 'a 'a) (match (band (bor 0 1) (bor 0 1)) (band 'a 'a))) (band (bor 0 1) (bor 0 1)))



; **************** end of hw #4 *********************************