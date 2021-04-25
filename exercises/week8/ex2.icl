module ex2

/*
  Definitions for assignment 8 in AFP 20-21
  Kind indexed gennerics
  Pieter Koopman, pieter@cs.ru.nl

  Use StdEnv or iTask environment.
  Use Basic Values Only as conclose option for a nicer output.
*/

import StdEnv, StdMaybe, StdGeneric

neq :: a a -> Bool | == a
neq a b = not (a == b)

generic gWrite a :: a [String] -> [String]
gWrite{|UNIT|} UNIT s = s
gWrite{|PAIR|} f g (PAIR a b) s = f a (g b s)
gWrite{|EITHER|} f g (LEFT x) s = f x s
gWrite{|EITHER|} f g (RIGHT x) s = g x s
gWrite{|CONS of {gcd_name,gcd_arity}|} f (CONS a) s = if (gcd_arity == 0) noParen paren
  where
    noParen = [gcd_name : f a s]
    paren = ["(":gcd_name:(f a [")":s])]
gWrite{|OBJECT|} f (OBJECT a) s = f a s
gWrite{|Int|} a s = [(toString a):s]
gWrite{|Bool|} a s = [(toString a):s]

generic gRead a :: [String] -> Maybe (a,[String])
gRead{|UNIT|} s = Just (UNIT, s)
gRead{|PAIR|} f g s =
  case (f s) of
    Just (a, bs) = case (g bs) of
      Just (b, rem) = Just (PAIR a b, rem)
      _ = Nothing
    _ = Nothing
gRead{|EITHER|} f g s =
  case (f s, g s) of
    (Just (a,s1), Nothing) = Just (LEFT a, s1)
    (Nothing, Just (b,s1)) = Just (RIGHT b, s1)
    _ = Nothing
gRead{|CONS of {gcd_name,gcd_arity}|} f s = if (gcd_arity == 0) (noParen s) (paren s)
  where
    paren ["(":con:xs] | con == gcd_name = case (f xs) of
                                               Just (a, [")":rem]) = Just (CONS a, rem)
                                               Nothing = Nothing
                       | otherwise = Nothing
    paren _ = Nothing
    noParen [con:xs] | con == gcd_name = case (f xs) of
                                           Just (a, rem) = Just (CONS a, rem)
                                           Nothing = Nothing
                     | otherwise = Nothing
    noParen _ = Nothing
gRead{|OBJECT|} f s =
  case (f s) of
    Just (a,s) = Just (OBJECT a, s)
    Nothing = Nothing
gRead{|Int|} [x:xs] = if same (Just (i, xs)) Nothing
  where
    i = toInt x
    same = toString i == x
gRead{|Bool|} list = foldl (match list) Nothing [True, False]
	where
		match [string: rest] r bool | toString bool == string
				= Just (bool, rest)
				= r
		match _ r bool = r

:: Bin a = Leaf | Bin (Bin a) a (Bin a)

instance == (Bin a) | == a where
 (==) Leaf Leaf = True
 (==) (Bin l1 e1 r1) (Bin l2 e2 r2) = l1 == l2 && e1 == e2 && r1 == r2
 (==) _ _ = False

// ---

:: Coin = Head | Tail

instance == Coin where
  (==) Head Head = True
  (==) Tail Tail = True
  (==) _    _    = False

derive gWrite Coin, (,), [], Bin
derive gRead Coin, (,), [], Bin

class serialize a | gRead{|*|}, gWrite{|*|} a

/*
Compiling ex2
Generating code for ex2
Linking ex2
[["Oke",", gWrite produces: ","True","
"],["Oke",", gWrite produces: ","False","
"],["Oke",", gWrite produces: ","0","
"],["Oke",", gWrite produces: ","123","
"],["Oke",", gWrite produces: ","-36","
"],["Oke",", gWrite produces: ","(","_Cons","42","_Nil",")","
"],["Oke",", gWrite produces: ","(","_Cons","0","(","_Cons","1","(","_Cons","2","(","_Cons","3","(","_Cons","4","_Nil",")",")",")",")",")","
"],["Oke",", gWrite produces: ","(","_Cons","(","_Cons","True","_Nil",")","(","_Cons","_Nil","_Nil",")",")","
"],["Oke",", gWrite produces: ","(","_Cons","(","_Cons","(","_Cons","1","_Nil",")","_Nil",")","(","_Cons","(","_Cons","(","_Cons","2","_Nil",")","(","_Cons","(","_Cons","3","(","_Cons","4","_Nil",")",")","_Nil",")",")","(","_Cons","(","_Cons","_Nil","_Nil",")","_Nil",")",")",")","
"],["Oke",", gWrite produces: ","(","Bin","Leaf","True","Leaf",")","
"],["Oke",", gWrite produces: ","(","_Cons","(","Bin","(","Bin","Leaf","(","_Cons","1","_Nil",")","Leaf",")","(","_Cons","2","_Nil",")","(","Bin","Leaf","(","_Cons","3","_Nil",")","(","Bin","Leaf","(","_Cons","4","(","_Cons","5","_Nil",")",")","Leaf",")",")",")","_Nil",")","
"],["Oke",", gWrite produces: ","(","_Cons","(","Bin","(","Bin","Leaf","(","_Cons","1","_Nil",")","Leaf",")","(","_Cons","2","_Nil",")","(","Bin","Leaf","(","_Cons","3","_Nil",")","(","Bin","(","Bin","Leaf","(","_Cons","4","(","_Cons","5","_Nil",")",")","Leaf",")","(","_Cons","6","(","_Cons","7","_Nil",")",")","(","Bin","Leaf","(","_Cons","8","(","_Cons","9","_Nil",")",")","Leaf",")",")",")",")","_Nil",")","
"],["Oke",", gWrite produces: ","Head","
"],["Oke",", gWrite produces: ","Tail","
"],["Oke",", gWrite produces: ","(","_Tuple2","7","True",")","
"],["Oke",", gWrite produces: ","(","_Tuple2","Head","(","_Tuple2","7","(","_Cons","Tail","_Nil",")",")",")","
"],["End of the tests.
"]]
Execution: 0.00  Garbage collection: 0.00  Total: 0.00
*/

// ---
// output looks nice if compiled with "Basic Values Only" for console in project options
Start =
  [ test True
  , test False
  , test 0
  , test 123
  , test -36
  , test [42]
  , test [0..4]
  , test [[True],[]]
  , test [[[1]],[[2],[3,4]],[[]]]
  , test (Bin Leaf True Leaf)
  , test [Bin (Bin Leaf [1] Leaf) [2] (Bin Leaf [3] (Bin Leaf [4,5] Leaf))]
  , test [Bin (Bin Leaf [1] Leaf) [2] (Bin Leaf [3] (Bin (Bin Leaf [4,5] Leaf) [6,7] (Bin Leaf [8,9] Leaf)))]
  , test Head
  , test Tail
  , test (7,True)
  , test (Head,(7,[Tail]))
  , ["End of the tests.\n"]
  ]

test :: a -> [String] | serialize, == a
test a =
  (if (isJust r)
    (if (fst jr == a)
      (if (isEmpty (tl (snd jr)))
        ["Oke"]
        ["Not all input is consumed! ":snd jr])
      ["Wrong result: ":gWrite {|*|} (fst jr) []])
    ["gRead result is Nothing"]
  ) ++ [", gWrite produces: ": s]
  where
    s = gWrite {|*|} a ["\n"]
    r = gRead {|*|} s
    jr = fromJust r
