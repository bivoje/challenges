
data Tree a
  = Leaf a
  | Node a (Tree a) (Tree a)
  deriving(Eq, Show)

type Report a = Either a a

tree_eg :: Tree Int
tree_eg =
  Node 7
    (Node 5
      (Leaf 1)
      (Node 4
        (Leaf 2)
        (Leaf 3)))
    (Leaf 6)

pre_order :: Tree a -> [Report a]
pre_order (Leaf x) = [Left x]
pre_order (Node x tl tr) = [Right x] ++ pre_order tl ++ pre_order tr

pre_order_eg = pre_order tree_eg ==
  [Right 7, Right 5, Left 1, Right 4, Left 2, Left 3, Left 6]

in_order :: Tree a -> [Report a]
in_order (Leaf x) = [Left x]
in_order (Node x tl tr) = in_order tl ++ [Right x] ++ in_order tr

in_order_eg = in_order tree_eg ==
  [Left 1, Right 5, Left 2, Right 4, Left 3, Right 7, Left 6]

post_order :: Tree a -> [Report a]
post_order (Leaf x) = [Left x]
post_order (Node x tl tr) = post_order tl ++ post_order tr ++ [Right x]

post_order_eg = post_order tree_eg ==
  [Left 1, Left 2, Left 3, Right 4, Right 5, Left 6, Right 7]

order_pre' :: [Report a] -> Maybe (Tree a, [Report a])
order_pre' [] = Nothing
order_pre' (Left x : rest) = Just (Leaf x, rest)
order_pre' (Right x : rest0) = do
  (tl, rest1) <- order_pre' rest0
  (tr, rest2) <- order_pre' rest1
  Just (Node x tl tr, rest2)

order_pre rps = case order_pre' rps of
  Just (t, []) -> Just t
  _ -> Nothing

pre_rev = order_pre (pre_order tree_eg) == Just tree_eg

-- but order_pre is not strictly decreasing on the argument
--   rest1 is returns from function execution, and it is not
--   clear if it's decreasing or not. though we can inductively
--   prove it indeed decreases.
--
-- coq's Fixpoint  won't accept bare translation of [order_pre].
-- howerver, we can define order_post satisfying the strict decreasing
-- criteria with a stack argument

order_post :: [Tree a] -> [Report a] -> Maybe (Tree a)
order_post stack [] = case stack of { [t] -> Just t; _ -> Nothing }
order_post stack (Left x : rest) = order_post (Leaf x : stack) rest
order_post stack (Right x : rest) = case stack of
  a:b:stack' -> order_post (Node x b a : stack') rest
  _ -> Nothing

post_rev = order_post [] (post_order tree_eg) == Just tree_eg

-- it is proved to be invers function

-- it is interesting to observe that
--   order_pre  has auxiliary parameter (rest of report), while
--   order_post has auxiliary return value (constructed tree's)
-- are there... some kind of relation between two auxiliaries?

order_infix :: [Tree a] -> [Report a] -> Maybe (Tree a)
order_infix = undefined

-- frustratingly, we can't defined reverse function of infix_order
-- since there may be two tree's that have common infix representation
