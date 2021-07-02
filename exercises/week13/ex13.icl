module ex13

import StdEnv, StdGeneric, StdMaybe

:: State =
	{ onShip      :: [Container]
	, onQuay      :: [Container]
	, craneOnQuay :: Bool
	, locked      :: Maybe Container
	}

:: Container :== String

initialState =
	{ onShip      = []
	, onQuay      = ["apples", "beer", "camera's"]
	, craneOnQuay = True
	, locked      = Nothing
	}

:: CraneError
	= NoContainersRemaining

:: High = High
:: Low = Low
:: Free = Free
:: Locked = Locked

:: S2 a b = Error CraneError | Result State
:: E1 t = E1 (State -> t)

:: Print2 a b =: P2 [String]
:: Print1 a =: P1 [String]

class action2 v where
	moveToShip :: (v High b) -> v High b
	moveToQuay :: (v High b) -> v High b
	moveUp :: (v Low b) -> v High b
	moveDown :: (v High b) -> v Low b
	lock :: (v Low Free) -> v Low Locked
	unlock :: (v Low Locked) -> v Low Free
	wait :: (v a b) -> v a b
	(:.) infixl 1 :: ((v a b) -> (v c d)) ((v c d) -> v e f) -> ((v a b) -> v e f)
	whileA :: (e bool) ((v a b) -> (v a b)) (v a b) -> v a b | exp2 e

class exp2 v where
	containersBelow :: v Int
	lit :: t -> v t | toString t
	(<.) infix 4 :: (v t) (v t) -> v Bool | <, toString t
	(>.) infix 4 :: (v t) (v t) -> v Bool | <, toString t
	(+.) infix 4 :: (v Int) (v Int) -> v Int

instance action2 Print2 where
	moveToShip (P2 ps) = P2 (ps ++ ["moveToShip"])
	moveToQuay (P2 ps) = P2 (ps ++ ["moveToQuay"])
	moveUp (P2 ps) = P2 (ps ++ ["moveUp"])
	moveDown (P2 ps) = P2 (ps ++ ["moveDown"])
	lock (P2 ps) = P2 (ps ++ ["lock"])
	unlock (P2 ps) = P2 (ps ++ ["unlock"])
	wait (P2 ps) = P2 (ps ++ ["wait"])
	(:.) f g = \(P2 ps) -> (case (f (P2 ps), g (P2 [])) of
		(P2 fs, P2 [x:xs]) -> P2 (fs ++ [(":. " +++. x):xs]))
	// See the comment on whileA for the evaluator.
	whileA _ action (P2 ps) = P2 ps

instance exp2 Print1 where
	containersBelow = P1 ["containersBelow"]
	lit l = P1 ["lit " +++. toString l]
	(<.) (P1 psl) (P1 psr) = P1 (psl ++ ["<." : psr])
	(>.) (P1 psl) (P1 psr) = P1 (psl ++ [">." : psr])
	(+.) (P1 psl) (P1 psr) = P1 (psl ++ ["+" : psr])

instance exp2 E1 where
	containersBelow = E1 (\s -> length (if (s.craneOnQuay) (s.onQuay) (s.onShip)))
	lit l = E1 (const l)
	(<.) (E1 e1) (E1 e2) = E1 (\s -> (e1 s) < (e2 s))
	(>.) (E1 e1) (E1 e2) = E1 (\s -> (e1 s) > (e2 s))
	(+.) (E1 e1) (E1 e2) = E1 (\s -> (e1 s) + (e2 s))

instance action2 S2 where
	moveToShip (Result s) = Result {s & craneOnQuay = False }
	moveToShip (Error x) = Error x

	moveToQuay (Result s) = Result {s & craneOnQuay = True }
	moveToQuay (Error x) = Error x

	moveUp (Result s) = Result {s & craneOnQuay = s.craneOnQuay }
	moveUp (Error x) = Error x

	moveDown (Result s) = Result {s & craneOnQuay = s.craneOnQuay }
	moveDown (Error x) = Error x

	lock (Result s) = case (s.craneOnQuay, s.onQuay, s.onShip) of
		(True, [], _) -> Error NoContainersRemaining
		(False, _, []) -> Error NoContainersRemaining
		(True, [x:xs], _) -> Result {s & locked = Just x, onQuay = xs}
		(False, _, [x:xs]) -> Result {s & locked = Just x, onShip = xs}
	lock (Error x) = Error x

	unlock (Result s) =  case (s.craneOnQuay, s.onQuay, s.onShip, s.locked) of
		(True, xs, _, Just x) -> Result {s & locked = Nothing, onQuay = [x:xs]}
		(False, _, xs, Just x) -> Result {s & locked = Nothing, onShip = [x:xs]}
	unlock (Error x) = Error x

	wait s = s

	(:.) f g = g o f

	// We are not sure how to evaluate our expression here, we have
	// 	(a b) ((S2 c d) -> S2 c d) (S2 c d) -> S2 c d | exp2 a
	// but want
	// 	(State -> Bool) ((S2 a b) -> S2 a b) (S2 a b) -> S2 a b | exp2 ((->)State)
	whileA e action (Result s)  = if (e s)
		(whileA e action (action (Result s)))
		(Result s)
	whileA _ _ (Error x) = Error x


loadShip :: (S2 High Free) -> S2 High Free
loadShip r = whileA loopCondition
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
	) r
	where
		loopCondition :: E1 Bool
		loopCondition = containersBelow  >. lit 0

Start = loadShip (Result initialState)
