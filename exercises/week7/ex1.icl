module ex1

import StdEnv, StdMaybe

:: UNIT       = UNIT
:: EITHER a b = LEFT a | RIGHT b
:: PAIR   a b = PAIR a b
:: CONS   a   = CONS String a

// 1. We can use the following:
instance == UNIT
  where (==) UNIT UNIT = True

// That makes the most sense since the UNIT data type only has a single
// constructor. A wildcard implies there are multiple constructors. this
// is misleading and could even lead to wrong behaviour if more constructors
// are added to UNIT and the developer does not notice equality has to be
// changed for correctness.

// 2. The correct way is without the constructor name having to be equal
//    The constructor name is only used when for example serializing.

instance == (CONS a) | == a where
  (==) (CONS _ x) (CONS _ y) = x == y

// 3.

:: Bin a = Leaf | Bin (Bin a) a (Bin a)
:: BinG a :== EITHER (CONS UNIT) (CONS (PAIR (Bin a) (PAIR a (Bin a))))
:: List a = Nil | Cons a (List a)
:: ListG a :== EITHER (CONS UNIT) (CONS (PAIR a [a]))

// Generic representation of []
gEmptyList = LEFT (CONS "Nil" UNIT)

// Generic representation of leaf
gLeaf = LEFT (CONS "Leaf" UNIT)

// So they are in fact equal. The constructor names are not used in the
// equality check

Start = ["hi"]
