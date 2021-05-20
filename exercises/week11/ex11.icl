module ex11

import StdEnv, StdGeneric, StdMaybe

:: Action a b
	= MoveToShip (BM a High) (BM b High)
	| MoveToQuay (BM a High) (BM b High)
	| MoveUp (BM a Low) (BM b High)
	| MoveDown (BM a High) (BM b Low)
	| Lock (BM a Low) (BM b Low)
	| Unlock (BM a Low) (BM b Low)
	| Wait (BM a b)
	| E.c: (:.) infixl 1 (Action a c) (Action c b)
	| WhileContainerBelow (BM a b) (Action a b)

:: BM a b =
	{ ab   :: a -> b
	, ba   :: b -> a
	, tab2 :: A.c.t : (t c a) -> t c b
	, tba2 :: A.c.t : (t b c) -> t a c
	}

bm :: BM a a
bm =
	{ ab = id
	, ba = id
	, tab2 = id
	, tba2 = id
	}

:: High = High
:: Low = Low

moveToShip = MoveToShip bm bm
moveToQuay = MoveToQuay bm bm
moveUp = MoveUp bm bm
moveDown = MoveDown bm bm
lock = Lock bm bm
unlock = Unlock bm bm
wait = Wait bm
whileContainerBelow = WhileContainerBelow bm

loadShip = whileContainerBelow
	(  moveDown
	:. lock
	:. moveUp
	:. moveToShip
	:. wait
	:. moveDown
	:. wait
	:. unlock
	:. moveUp
	:. moveToQuay
	)

:: CraneError
	= CraneAlreadyOnQuay
	| CraneAlreadyOnShip
	| NoContainersRemaining
	| ContainerAlreadyLocked
	| NoContainerLocked

:: ErrorOrResult e r = Error e | Result r

:: State =
	{ onShip      :: [Container]
	, onQuay      :: [Container]
	, craneUp     :: Bool
	, craneOnQuay :: Bool
	, locked      :: Maybe Container
	}

:: Container :== String

initialState =
	{ onShip      = []
	, onQuay      = ["apples", "beer", "camera's"]
	, craneUp     = True
	, craneOnQuay = True
	, locked      = Nothing
	}

eval :: (Action a b) State -> ErrorOrResult CraneError State
eval (MoveToShip _ _) s = Result {s & craneOnQuay = False }
eval (MoveToQuay _ _) s = Result {s & craneOnQuay = True}
eval (Wait _) s = Result s
eval (a :. b) s = case (eval a s) of
	Result r = (eval b r)
	Error e = Error e
eval (WhileContainerBelow _ a) s = if (s.craneOnQuay)
	(moveWhile (\s. s.onQuay) s.onQuay a s)
	(moveWhile (\s. s.onShip) s.onShip a s)
	where
		moveWhile f [] _ s = Result s
		moveWhile f _ a s = case (eval a s) of
			Result r = moveWhile f (f r) a r
			Error e = Error e
eval (MoveUp _ _) s = Result {s & craneUp = True }
eval (MoveDown _ _) s = Result {s & craneUp = False }
eval (Lock _ _) s = case (s.craneOnQuay, s.onQuay, s.onShip, s.locked) of
	(_, _, _, Just _) -> Error ContainerAlreadyLocked
	(True, [], _, _) -> Error NoContainersRemaining
	(False, _, [], _) -> Error NoContainersRemaining
	(True, [x:xs], _, _) -> Result {s & locked = Just x, onQuay = xs}
	(False, [x:xs], _, _) -> Result {s & locked = Just x, onShip = xs}
eval (Unlock _ _) s = case (s.craneOnQuay, s.onQuay, s.onShip, s.locked) of
	(_, _, _, Nothing) -> Error NoContainerLocked
	(True, xs, _, Just x) -> Result {s & locked = Nothing, onQuay = [x:xs]}
	(False, _, xs, Just x) -> Result {s & locked = Nothing, onShip = [x:xs]}

print :: (Action a b) [String] -> [String]
print (MoveToShip _ _) s = ["MoveToShip" : s]
print (MoveToQuay _ _) s = ["MoveToQuay" : s]
print (MoveUp _ _) s = ["MoveUp" : s]
print (MoveDown _ _) s = ["MoveDown" : s]
print (Lock _ _) s = ["Lock" : s]
print (Unlock _ _) s = ["Unlock" : s]
print (Wait _) s = ["Wait" : s]
print (l :. r) s = ["(" : print l [":." : (print r [")":s])]]
print (WhileContainerBelow _ a) s = ["WhileContainerBelow" : print a s]

opt :: (Action a b) -> (Action a b)
opt (a :. b) = case (opt a, opt b) of
	(x, Wait bm) -> bm.tab2 x
	(Wait bm, y) -> bm.tba2 y
	(x, y) -> x :. y
opt (WhileContainerBelow bm a) = WhileContainerBelow bm (opt a)
opt x = x

//Start = eval loadShip initialState
// (Result (State ["camera's","beer","apples"] [] True True ?None))

//Start = print loadShip []
// ["WhileContainerBelow","(","(","(","(","(","(","(","(","(","MoveDown",":.","Lock",")",":.","MoveUp",")",":.","MoveToShip",")",":.","Wait",")",":.","MoveDown",")",":.","Wait",")",":.","Unlock",")",":.","MoveUp",")",":.","MoveToQuay",")"]

Start = print (opt loadShip) []
// ["WhileContainerBelow","(","(","(","(","(","(","(","MoveDown",":.","Lock",")",":.","MoveUp",")",":.","MoveToShip",")",":.","MoveDown",")",":.","Unlock",")",":.","MoveUp",")",":.","MoveToQuay",")"]
