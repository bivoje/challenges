{-# LANGUAGE RankNTypes #-}
-- TODO https://wiki.haskell.org/Rank-N_types

import Prelude hiding (succ, exp)
import Data.Bool
import Data.Either

---------------------------------
-- Natural numbers

type Nat = forall a . (a -> a) -> (a -> a)

church2nat :: Nat -> Int
church2nat n = n (+1) 0

nat2church :: Int -> Nat
--nat2church n = \f x -> foldl (flip ($)) x $ replicate n f
nat2church n f x = foldl (flip id) x (replicate n f)

zero :: Nat
zero f = id

one :: Nat
one = id

two :: Nat
two f = f . f

three :: Nat
three f = f . f . f

succ :: Nat -> Nat
succ n f = f . n f
-- succ = Monad.ap (.)

four :: Nat
four = succ three

plus :: Nat -> Nat -> Nat
plus n m f = m f . n f
-- plus = liftM2 (.)

five :: Nat
five = plus two three

mult :: Nat -> Nat -> Nat
mult = (.)

six :: Nat
six = mult two three

exp :: Nat -> Nat -> Nat
exp = flip ($)
-- exp = flip id

eight :: Nat
eight = exp two three

-- helped by http://pointfree.io/

---------------------------------
-- Boolean

type Boolean = forall a . a -> a -> a

--church2bool :: Boolean -> Bool
church2bool :: (Bool -> Bool -> Bool) -> Bool
church2bool f = f True False

bool2church :: Bool -> Boolean
--bool2church b = if b then true else false
bool2church = bool false true

true :: Boolean
--true f g = f
true = const

false :: Boolean
false f g = g
-- false = const id

neg :: Boolean -> Boolean
neg = flip

conj :: Boolean -> Boolean -> Boolean
conj b1 b2 = \x y -> b1 (b2 x y) y

disj :: Boolean -> Boolean -> Boolean
disj b1 b2 = \x y -> b1 x (b2 x y)

xand :: Boolean -> Boolean -> Boolean
xand b1 b2 = \x y -> b1 (b2 x y) (b2 y x)

xorr :: Boolean -> Boolean -> Boolean
xorr b1 b2 = \x y -> b1 (b2 y x) (b2 x y)

booltbl2 :: (Boolean -> Boolean -> Boolean) -> IO ()
booltbl2 f = do
  print . church2bool $ f true true
  print . church2bool $ f true false
  print . church2bool $ f false true
  print . church2bool $ f false false

---------------------------------
-- Tuple

type Tuple a = Boolean -> a

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

type Pair a b = Boolean -> Either a b

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

type List a = forall b . (b -> a -> b) -> b -> b

church2list :: List a -> [a]
church2list ls = reverse $ ls (flip (:)) []

list2church :: [a] -> List a
list2church ls = \f x -> foldl f x ls

cons :: a -> List a -> List a
cons a ls = \f b -> ls f (f b a)

empty :: List a
empty _ = id

append :: List a -> List a -> List a
append xs ys = \f x -> ys f (xs f x)

--head :: List a -> a
--head ls = cdrP $ ls (\b a ->
--    (carP b) (consP true (cdrP b)) (consP true a)
--  ) (consP false undefined)

---------------------------------
-- HashMap

---------------------------------
-- Integer

