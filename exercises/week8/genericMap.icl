module genericMap

/*
  Genric map definition for assignment 8 in AFP 20-21
  Pieter Koopman, pieter@cs.ru.nl

  Use StdEnv or iTask environment.
*/

import StdEnv, StdGeneric, GenEq

generic gMap a b :: a -> b

gMap{|c|}        x = x
gMap{|PAIR|}   f g (PAIR x y) = PAIR   (f x) (g y)
gMap{|EITHER|} f g (LEFT x)   = LEFT   (f x)
gMap{|EITHER|} f g (RIGHT x)  = RIGHT  (g x)
gMap{|CONS|}   f   (CONS x)   = CONS   (f x)
gMap{|OBJECT|} f   (OBJECT x) = OBJECT (f x)
gMap{|RECORD|} f   (RECORD x) = RECORD (f x)
gMap{|FIELD|}  f   (FIELD  x) = FIELD  (f x)
gMap{|UNIT|}        UNIT      = UNIT
gMap{|Int|}         x         = x
gMap{|Bool|}        b         = b

:: Bin a = Leaf | Bin (Bin a) a (Bin a)

derive gMap Pos, Bin, (,), []
derive gEq Pos, Bin

t = Bin (Bin Leaf 1 Leaf) 2 (Bin (Bin Leaf 3 Leaf) 4 Leaf)

:: Pos a = {x :: a, y :: a}
p = {x = 2.3, y = 4.5}

l = [0..7]

// 1.

fac :: Int -> Int
fac n = foldr (\i s = i * s) 1 [1..n]

ex1 = gMap {|*->*|} fac t

// Output: [(Bin (Bin Leaf 1 Leaf) 2 (Bin (Bin Leaf 6 Leaf) 24 Leaf))]

// 2.

ex2 = gMap {|*->*|} (\i = (i, fac i)) l

// Output: [(0,1),(1,1),(2,2),(3,6),(4,24),(5,120),(6,720),(7,5040)]

// 3.

ex3 = gMap {|*->*->*|} (gMap {|*->*|} fac) (gMap {|*->*|} fac) (l, t)

// Output: ([1,1,2,6,24,120,720,5040],(Bin (Bin Leaf 1 Leaf) 2 (Bin (Bin Leaf 6 Leaf) 24 Leaf)))

// 4.

ex4 = gMap {|*->*|} entier p

// Output: (Pos 2 4)

// 5.

ex5 = gMap {|*->*|} (\({x,y}) = {y=x,x=y}) [p,p,p]

// Output: [(Pos 4.5 2.3),(Pos 4.5 2.3),(Pos 4.5 2.3)]

// 6.

ex6 = [1,2] === [1,2]

// Output: True

// 7.

ex7 = [1,2] === [2,3]

// Output: False

// 8.

ex8 = gEq {|*->*|} (<) [1,2] [2,3]

// Output: [True, True]

Start = ex8
