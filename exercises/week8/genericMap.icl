module genericMap

/*
  Genric map definition for assignment 8 in AFP 20-21
  Pieter Koopman, pieter@cs.ru.nl
  
  Use StdEnv or iTask environment.
*/

import StdEnv, StdGeneric

generic gMap a b :: a -> b

gMap{|c|}        x = x
gMap{|PAIR|}   f g (PAIR x y) = PAIR   (f x) (g y) 
gMap{|EITHER|} f g (LEFT x)   = LEFT   (f x)
gMap{|EITHER|} f g (RIGHT x)  = RIGHT  (g x)
gMap{|CONS|}   f   (CONS x)   = CONS   (f x)
gMap{|OBJECT|} f   (OBJECT x) = OBJECT (f x)
gMap{|RECORD|} f   (RECORD x) = RECORD (f x)
gMap{|FIELD|}  f   (FIELD  x) = FIELD  (f x)

:: Bin a = Leaf | Bin (Bin a) a (Bin a)
t = Bin (Bin Leaf 1 Leaf) 2 (Bin (Bin Leaf 3 Leaf) 4 Leaf)

:: Pos a = {x :: a, y :: a}
p = {x = 2.3, y = 4.5}

l = [0..7]

Start = (l, t, p)
	
