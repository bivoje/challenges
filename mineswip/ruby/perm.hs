{-# LANGUAGE InstanceSigs, ScopedTypeVariables #-}

import Data.Tuple.Extra (second)

type Label = Char

data Libra a
  = Weight a
  | Balance [(Int, Libra a)]

instance Functor Libra where
  fmap :: (a -> b) -> Libra a -> Libra b
  fmap f (Weight x) = Weight (f x)
  fmap f (Balance ls) = Balance $ map (second $ fmap f) ls 
  -- what about scaling factors?

--instance Applicative Libra where
--  pure :: a -> Libra a
--  pure = Weight
--  (Weight f) <*> (Weight x) = Weight $ f x
--  (Balance bs) <*> (Weight x) = Weight $ f x
--  --???
--
--  --fmap f (Balance ls) = Balance $ map (second $ fmap f) ls 
--
--instance Foldable Libra where
--  foldr :: (a -> b -> b) -> b -> Libra a -> b
--  foldr f acc (Weight x) = f x acc
--  foldr f acc (Balance ls) = foldr (flip (foldr f)) acc $ map snd ls
--
----instance Traversable Libra where
  
genPossibility :: Libra a -> [Int]
genPossibility

libra :: Libra Label
libra = Balance
  [ (-3, Weight 'b')
  , (-1, Balance
      [ (-1, Balance
          [ (-1, Weight 'f')
          , ( 1, Weight 'k')
          , ( 2, Weight 'g')
          ]
        )
      , (1, Balance
          [ (-1, Weight 'c')
          , ( 1, Weight 'd')
          , ( 2, Weight 'e')
          ]
        )
      ]
    )
  , (1, Weight 'a')
  , (3, Balance
      [ (-2, Weight 'h')
      , (-1, Weight 'i')
      , ( 3, Weight 'j')
      ]
    )
  ]

