module serialize7start

/*
  Definition for assignment 7 in AFP 2021
  Pieter Koopman pieter@cs.ru.nl

  Use this in a project with Environment StdEnv
  Use project option 'Basic Values Only' for nicer output
*/

import StdEnv, StdMaybe, StdDebug

class serialize a where
  write :: a [String] -> [String]
  read  :: [String] -> Maybe (a,[String])

instance serialize Bool where
  write b c = [toString b:c]
  read ["True":r]  = Just (True,r)
  read ["False":r] = Just (False,r)
  read _ = Nothing

instance serialize Int where
  write i c = [toString i:c]
  read [s:r]
    # i = toInt s
    | s == toString i
      = Just (i,r)
      = Nothing
  read _ = Nothing

// ---

:: UNIT       = UNIT
:: EITHER a b = LEFT a | RIGHT b
:: PAIR   a b = PAIR a b
:: CONS   a   = CONS String a

// ---
bindMaybe :: (Maybe a) (a -> Maybe b) -> Maybe b
bindMaybe Nothing _ = Nothing
bindMaybe (Just a) f = f a

instance serialize UNIT where
  write UNIT c = ["UNIT":c]
  read ["UNIT":r] = trace "UNIT" (Just (UNIT, r))
  read _ = Nothing

instance serialize (EITHER a b) | serialize a & serialize b where
  write (LEFT a) c = ["LEFT":(write a c)]
  write (RIGHT a) c = ["RIGHT":(write a c)]
  read ["LEFT":r] = trace "LEFT" (mapMaybe (\(c,r2) = (LEFT c, r2)) (read r))
  read ["RIGHT":r] = trace "RIGHT" (mapMaybe (\(c,r2) = (RIGHT c, r2)) (read r))
  read _ = Nothing

// Writing this in a let binding in the read function itself does not compile
// due to unification error
serF1 :: (a, [String]) -> Maybe (PAIR a b, [String]) | serialize b
serF1 (c1, r1) = mapMaybe (\(c2, r2) = (PAIR c1 c2, r2)) (read r1)

instance serialize (PAIR a b) | serialize a & serialize b where
  write (PAIR a b) c = ["PAIR":(write a (write b c))]
  read ["PAIR":r] = trace "PAIR" Nothing // (bindMaybe (read r) serF1)
  read _ = trace "PAIR2" Nothing
  
instance serialize (CONS a) | serialize a where
  write (CONS _ a) c = ["CONS":(write a c)]
  read ["CONS":r] = trace "CONS" (read r)
  read _ = Nothing

:: ListG a :== EITHER (CONS UNIT) (CONS (PAIR a [a]))

instance serialize [a] | serialize a where // to be improved
  write l c = write (fromList l) c
  read l = mapMaybe (\(x, ls) = (toList x, ls)) (read l)

:: Bin a = Leaf | Bin (Bin a) a (Bin a)
:: BinG a :== EITHER (CONS UNIT) (CONS (PAIR (Bin a) (PAIR a (Bin a))))

instance serialize (Bin a) | serialize a where // to be improved
  write a c = write (fromBin a) c
  read l = mapMaybe (\(x, ls) = (toBin x, ls)) (read l)

instance == (Bin a) | == a where // better use the generic approach
  (==) Leaf Leaf = True
  (==) (Bin l a r) (Bin k b s) = l == k && a == b && r == s
  (==) _ _ = False

// ---

// 2.0

fromList :: [a] -> ListG a
fromList [] = LEFT (CONS "[]" UNIT)
fromList [x:xs] = RIGHT (CONS ":" (PAIR x xs))

toList :: (ListG a) -> [a]
toList (LEFT (CONS _ UNIT)) = []
toList (RIGHT (CONS _ (PAIR x xs))) = [x:xs]
    
fromBin :: (Bin a) -> BinG a
fromBin Leaf = LEFT (CONS "Leaf" UNIT)
fromBin (Bin l x r) = RIGHT (CONS "Bin" (PAIR l (PAIR x r)))
    
toBin :: (BinG a) -> Bin a
toBin (LEFT (CONS _ UNIT)) = Leaf
toBin (RIGHT (CONS _ (PAIR l (PAIR x r)))) = Bin l x r

Start =
  [test True
  ,test False
  ,test 0
  ,test 123
  ,test -36
  ,test [42]
  ,test [0..4]
  ,test [[True],[]]
  ,test (Bin Leaf True Leaf)
  ,test [Bin (Bin Leaf [1] Leaf) [2] (Bin Leaf [3] (Bin Leaf [4,5] Leaf))]
  ,test [Bin (Bin Leaf [1] Leaf) [2] (Bin Leaf [3] (Bin (Bin Leaf [4,5] Leaf) [6,7] (Bin Leaf [8,9] Leaf)))]
  ]

test :: a -> ([String],[String]) | serialize, == a
test a =
  (if (isJust r)
    (if (fst jr == a)
      (if (isEmpty (tl (snd jr)))
        ["Oke "]
        ["Fail: not all input is consumed! ":snd jr])
      ["Fail: Wrong result ":write (fst jr) []])
    ["Fail: read result is Nothing "]
  , ["write produces ": s]
  )
  where
    s = write a ["\n"]
    r = read s
    jr = fromJust r
