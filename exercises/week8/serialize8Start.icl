module serialize8Start

/*
  Definitions for assignment 8 in AFP 20-21
  Kind indexed gennerics
  Pieter Koopman, pieter@cs.ru.nl
  
  Use StdEnv or iTask environment.
  Use Basic Values Only as conclose option for a nicer output.
*/

import StdEnv, StdMaybe, StdDebug

// use this as serialize0 for kind *
class serialize0 a where
  write0 :: a [String] -> [String]
  read0  :: [String] -> Maybe (a,[String])

class serialize1 t where
  write1 :: (a [String] -> [String]) (t a) [String] -> [String]
  read1 :: ([String] -> Maybe (a, [String])) [String] -> Maybe (t a,[String])

class serialize2 t where
  write2 :: (a [String] -> [String]) (b [String] -> [String]) (t a b) [String] -> [String]
  read2 :: ([String] -> Maybe (a, [String])) ([String] -> Maybe (b, [String])) [String] -> Maybe (t a b,[String])
// ---

instance serialize0 Bool where
  write0 b c = [toString b:c]
  read0 list = foldl (match list) Nothing [True, False]
	where
		match [string: rest] r bool | toString bool == string
				= Just (bool, rest)
				= r
		match _ r bool = r

instance serialize0 Int where
  write0 i c = [toString i:c]
  read0 list = foldl (match list) Nothing [True, False]
  where
    match [string: rest] r bool
      # int = toInt string
      | string == toString int
        = Just (int, rest)
        = r
    match _ r bool = r

// ---


//  write0 :: a [String] -> [String]
//  read0  :: [String] -> Maybe (a,[String])
//  write1 :: (a [String] -> [String]) (t a) [String] -> [String]
//  read1 :: ([String] -> Maybe (a, [String])) [String] -> Maybe (t a,[String])
//  write2 :: (a [String] -> [String]) (b [String] -> [String]) (t a b) [String] -> [String]
//  read2 :: ([String] -> Maybe (a, [String])) ([String] -> Maybe (b, [String])) [String] -> Maybe (t a b,[String])

:: UNIT     = UNIT
:: EITHER a b = LEFT a | RIGHT b
:: PAIR   a b = PAIR a b
:: CONS   a   = CONS String a

neq :: !a !a -> Bool | == a
neq a b = not (a == b)

instance serialize0 UNIT where
  write0 UNIT s = s
  read0 s = Just (UNIT, s)

instance serialize1 CONS where
  write1 f (CONS c a) s = ["(":c:f a []] ++ [")":s]
  read1 f ["(":xs] = res
    where
      res = case span (neq ")") xs of
        ([con:args], [")":rem]) = mapMaybe (\(c, s) = (CONS con c, s)) (f (args ++ rem))
        _ = Nothing

instance serialize2 EITHER where
  write2 f g (LEFT a) s = f a s
  write2 f g (RIGHT b) s = g b s
  read2 f g xs = if (isJust lm) lm rm
    where
      lm = mapMaybe (\(c, s) = (LEFT c, s)) (f xs)
      rm = mapMaybe (\(c, s) = (RIGHT c, s)) (g xs)

instance serialize2 PAIR where
  write2 f g (PAIR a b) s = ["(":f a []] ++ [",":g b []] ++ [")":s]
  read2 f g ["(":xs] = res
    where
      res = case (span (neq ",") xs) of
              ([fst:fstArgs], [",":ys]) = case (span (neq ")") ys) of
                ([snd:sndArgs], [",":rem]) = case (f fstArgs, g sndArgs) of
                  (Just (a, s), Just (b, s2)) = Just ((PAIR a b), rem)
                  _ = Nothing
                _ = Nothing
              _ = Nothing
// ---

:: ListG a :== EITHER (CONS UNIT) (CONS (PAIR a [a]))

fromList :: [a] -> ListG a
fromList []    = LEFT  (CONS NilString  UNIT)
fromList [a:x] = RIGHT (CONS ConsString (PAIR a x))

toList :: (ListG a) -> [a]
toList (LEFT  (CONS NilString  UNIT))       = []
toList (RIGHT (CONS ConsString (PAIR a x))) = [a:x]

NilString  :== "Nil"
ConsString :== "Cons"

instance serialize1 [] where 	// to be improved
 write1 f a s = write2 (write1 write0) (write1 (write2 f (write1 f))) (fromList a) s
 read1 f  s   = Nothing


// ---

:: Bin a = Leaf | Bin (Bin a) a (Bin a)

:: BinG a :== EITHER (CONS UNIT) (CONS (PAIR (Bin a) (PAIR a (Bin a))))

fromBin :: (Bin a) -> BinG a
fromBin Leaf = LEFT (CONS LeafString UNIT)
fromBin (Bin l a r) = RIGHT (CONS BinString (PAIR l (PAIR a r)))

toBin :: (BinG a) -> Bin a
toBin (LEFT (CONS _ UNIT)) = Leaf
toBin (RIGHT (CONS _ (PAIR l (PAIR a r)))) = Bin l a r

LeafString :== "Leaf"
BinString  :== "Bin"

instance == (Bin a) | == a where
  (==) Leaf Leaf = True
  (==) (Bin l a r) (Bin k b s) = l == k && a == b && r == s
  (==) _ _ = False

instance serialize0 (Bin a) | serialize0 a where	// to be improved
	write0 b s = s
	read0    l = Nothing

// ---

:: Coin = Head | Tail
:: CoinG :== EITHER (CONS UNIT) (CONS UNIT)

fromCoin :: Coin -> CoinG
fromCoin Head = LEFT (CONS "Head" UNIT)
fromCoin Tail = RIGHT (CONS "Tail" UNIT)

toCoin :: CoinG -> Coin
toCoin (LEFT (CONS _ UNIT)) = Head
toCoin (RIGHT (CONS _ UNIT)) = Tail

instance == Coin where
  (==) Head Head = True
  (==) Tail Tail = True
  (==) _    _    = False

instance serialize0 Coin where
	write0 c s = write2 (write1 write0) (write1 write0) (fromCoin c) s
	read0    l = mapMaybe (\(c,s) -> (toCoin c, s)) resG
    where
      resG = trace "hello" (read2 (read1 read0) (read1 read0) l)

/*
	Define a special purpose version for this type that write0s and read0s
	the value (7,True) as ["(","7",",","True",")"]
*/
instance serialize0 (a,b) | serialize0 a & serialize0 b where
	write0 (a,b) c = c
	read0 _ = Nothing

// ---
// output looks nice if compiled with "Basic Values Only" for console in project options
Start = 
  [test True
  ,test False
  ,test 0
  ,test 123
  ,test -36
  ,test Head
  ,test Tail
  // ,test [42]
  // ,test [0..4]
  // ,test [[True],[]]
  // ,test [[[1]],[[2],[3,4]],[[]]]
  // ,test (Bin Leaf True Leaf)
  // ,test [Bin (Bin Leaf [1] Leaf) [2] (Bin Leaf [3] (Bin Leaf [4,5] Leaf))]
  // ,test [Bin (Bin Leaf [1] Leaf) [2] (Bin Leaf [3] (Bin (Bin Leaf [4,5] Leaf) [6,7] (Bin Leaf [8,9] Leaf)))]
  // ,test Head
  // ,test Tail
  // ,test (7,True)
  // ,test (Head,(7,[Tail]))
  // ,["End of the tests.\n"]
  ]

test :: a -> [String] | serialize0, == a
test a = 
  (if (isJust r)
    (if (fst jr == a)
      (if (isEmpty (tl (snd jr)))
        ["Oke"]
        ["Not all input is consumed! ":snd jr])
      ["Wrong result: ":write0 (fst jr) []])
    ["read0 result is Nothing"]
  ) ++ [", write0 produces: ": s]
  where
    s = write0 a ["\n"]
    r = read0 s
    jr = fromJust r
