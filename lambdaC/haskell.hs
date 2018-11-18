{-# LANGUAGE RankNTypes #-}

import Prelude hiding (succ, exp, head, pred)
import Data.Bool
import Data.Either

---------------------------------
-- Natural numbers

type Nat a = (a -> a) -> (a -> a)

church2nat :: Nat Int -> Int
church2nat n = n (+1) 0

nat2church :: Int -> Nat a
--nat2church n = \f x -> foldl (flip ($)) x $ replicate n f
nat2church n f x = foldl (flip id) x (replicate n f)

zero :: Nat a
zero f = id

one :: Nat a
one = id

two :: Nat a
two f = f . f

three :: Nat a
three f = f . f . f

succ :: Nat a -> Nat a
succ n f = f . n f
-- succ = Monad.ap (.)

four :: Nat a
four = succ three

plus :: Nat a -> Nat a -> Nat a
plus n m f = m f . n f
-- plus = liftM2 (.)

five :: Nat a
five = plus two three

mult :: Nat a -> Nat a -> Nat a
mult = (.)

six :: Nat a
six = mult two three

--exp :: Nat -> Nat -> Nat
exp = flip ($)
-- exp = flip id

eight :: Nat a
eight = exp two three

-- helped by http://pointfree.io/

---------------------------------
-- Boolean

type Boolean a = a -> a -> a

church2bool :: Boolean Bool -> Bool
church2bool f = f True False

bool2church :: Bool -> Boolean a
--bool2church b = if b then true else false
bool2church = bool false true

true :: Boolean a
--true f g = f
true = const

false :: Boolean a
false f g = g
-- false = const id

neg :: Boolean a -> Boolean a
neg = flip

conj :: Boolean a -> Boolean a -> Boolean a
conj b1 b2 = \x y -> b1 (b2 x y) y

disj :: Boolean a -> Boolean a -> Boolean a
disj b1 b2 = \x y -> b1 x (b2 x y)

xand :: Boolean a -> Boolean a -> Boolean a
xand b1 b2 = \x y -> b1 (b2 x y) (b2 y x)

xorr :: Boolean a -> Boolean a -> Boolean a
xorr b1 b2 = \x y -> b1 (b2 y x) (b2 x y)

booltbl2 :: (Boolean Bool -> Boolean Bool -> Boolean Bool) -> IO ()
booltbl2 f = do
  print . church2bool $ f true true
  print . church2bool $ f true false
  print . church2bool $ f false true
  print . church2bool $ f false false

---------------------------------
-- Tuple

type Tuple a = Boolean a -> a

church2tuple :: Tuple a -> (a, a)
church2tuple t = (carT t, cdrT t)

tuple2church :: (a, a) -> Tuple a
tuple2church t = consT (fst t) (snd t)

consT :: a -> a -> Tuple a
consT x y = \b -> b x y

carT :: Tuple a -> a
carT t = t true

cdrT :: Tuple a -> a
cdrT t = t false 

---------------------------------
-- Pair

type Pair a b = Boolean (Either a b) -> Either a b

church2pair :: Pair a b -> (a, b)
church2pair p = (carP p, cdrP p)

consP :: a -> b -> Pair a b
consP x y = \b -> b (Left x) (Right y)

carP :: Pair a b -> a
carP p = fromLeft undefined $ p true

cdrP :: Pair a b -> b
cdrP p = fromRight undefined $ p false

---------------------------------
-- List

type List b a = (b -> a -> b) -> b -> b

church2list :: List [a] a -> [a]
church2list ls = reverse $ ls (flip (:)) []

list2church :: [a] -> List b a
list2church ls = \f x -> foldl f x ls

cons :: a -> List b a -> List b a
cons a ls = \f b -> ls f (f b a)

empty :: List b a
empty _ = id

append :: List b a -> List b a -> List b a
append xs ys = \f x -> ys f (xs f x)

head ls = cdrP $ ls (\b a ->
    (carP b) (consP true (cdrP b)) (consP true a)
  ) (consP false undefined)

{-
> head :: List a -> a
> head ls = cdrP $ ls (\b a ->
>     (carP b) (consP true (cdrP b)) (consP true a)
>   ) (consP false undefined)

the head above doesn't work.
head empty == undefined
head $ cons 1 empty == 1
to analyze, split it into 2 functions.

> foldf b a = (carP b) (consP true (cdrP b)) (consP true a)
> head ls = cdrP $ ls foldf (consP false undefined)

I have guessed its type
> Pair (Boolean x) a -> a -> Pair (Boolean x) a
but it wasn't. the correct type is
> Pair (Boolean (Pair (Boolean x) a)) a -> a -> Pair (Boolean x) a
where `x` is replaced with (Pair (Bool x) a)).
becuase (carP b) is a boolean that should be applied on
`(consP true a)` which has type `Pair (Boolean x) a`, its type
should be (Boolean (Pair (Boolean x) a)).

you can see that `cdrP $ foldf (cons false undefined) 1` returns
1 as expected.

head can't be defined using foldf since List requires accumulator
of type `b -> a -> b` which foldf can't satisfy. if haskell's get
forced to type check head (or the kind of expression), it would
make long -infinit- type chain. you can see it by running
the following

> true = const
> false f g = g
> consP x y = \b -> b (Left x) (Right y)
> carP p = fromLeft undefined $ p true
> cdrP p = fromRight undefined $ p false
> empty = \_ b -> b
> cons a ls = \f b -> ls f (f b a)
> foldf b a = (carP b) (consP true (cdrP b)) (consP true a)
> head ls = cdrP $ ls foldf (consP false undefined)
>
> head empty == undefined
> head (cons 1 empty) == 1
> head (cons 2 (cons 1 empty) == error!

actually the same problem occures when defining y combinator.
> y f = (\x -> f (x x)) (\x -> f (x x))
above definition fails to typecheck.
this is because haskell is typed lambda calculus.
while above definition (and head) is written in untyped lambda calc.
you can solve this problem by
http://r6.ca/blog/20060919T084800Z.html

I thought I defined head and s (in python) without using recursion.
but in fact, they we implicitly using structur of the y combinator.
-}

---------------------------------
-- Rec

--b = b -> a
newtype Mu a = Roll { unroll :: Mu a -> a }

--Roll   :: (Mu a -> a) -> Mu a
--unroll :: Mu a -> Mu a -> a

--fix f = (\x -> f (x x)) (\x -> f (x x))
fix f = (\x -> f . unroll x $ x) (Roll $ \x -> f . unroll x $ x)

isZero :: Nat (Boolean a) -> Boolean a
isZero n = n (const false) true

--x = Pair (Boolean x) (Nat y)
newtype Nu a b = Roll_Nu { unroll_nu :: Pair (Boolean (Nu a b)) (Nat b) }

-- Roll_Nu   :: Pair (Boolean (Nu a b)) (Nat b) -> Nu a b
-- unroll_Nu :: Nu a b -> Pair (Boolean (Nu a b)) (Nat b)

--pred_rec :: Pair (Boolean (Pair (Boolean x) (Nat y))) (Nat y)
--                        -> Pair (Boolean x) (Nat y)
pred_rec :: Nu a b -> Nu a b
pred_rec x = (carP $ unroll_nu x)
  (Roll_Nu $ consP true (succ . cdrP $ unroll_nu x))
  (Roll_Nu $ consP true zero)
--pred_rec x = (carP x) (consP true . succ . cdrP $ x) (consP true zero)

pred :: Nat (Nu a b) -> Nat b
pred n = cdrP . unroll_nu $ n (pred_rec) (Roll_Nu $ consP false zero)

--fact :: (Nat a -> Nat a) -> Nat a -> Nat a
--fact f n = (isZero n) one (mult n (f (pred n)))
--n2        :: Nat (Nu x a)
--n1        :: Nat (Boolean (Nat a))
--isZero n1 :: Nat (Boolean (Nat a)) -> Boolean (Nat a)
--Nat a = Nat (Boolean (Nat a))
--Ru a = Boolean (Nat a)
--Ru a = Boolean (Nat (Ru a))

newtype Ru a = Roll_Ru { unroll_ru :: Boolean (Nat (Ru a)) }
-- Roll_Ru   :: Boolean (Nat (Roll_Ru a)) -> Ru a
-- unroll_ru :: Ru a -> Boolean (Nat (Roll_Ru a))

--fact f n = (isZero n) one (mult n (f (pred n)))
--one       :: Nat (Ru a)
--isZero n1 :: Nat (Boolean (Nat (Ru a))) -> Boolean (Nat (Ru a))
--          :: Nat (Ru a) -> Boolean (Nat (Ru a))
--n1        :: Nat (Boolean (Nat (Ru a)))
--          :: Nat (Ru a)

---------------------------------
-- Integer

