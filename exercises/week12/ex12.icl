module ex12

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

:: ErrorOrResult e r = Error e | Result r

:: CraneError
	= NoContainersRemaining

:: High = High
:: Low = Low
:: Free = Free
:: Locked = Locked

:: S a b :== ErrorOrResult CraneError State

moveToShip :: (S High b) -> S High b
moveToShip (Result s) = Result {s & craneOnQuay = False }
moveToShip e = e

moveToQuay :: (S High b) -> S High b
moveToQuay (Result s) = Result {s & craneOnQuay = True }
moveToQuay e = e

moveUp :: (S Low b) -> S High b
moveUp (Result s) = Result {s & craneOnQuay = s.craneOnQuay } // Set to itself to make type checker happy
moveUp e = e

moveDown :: (S High b) -> S Low b
moveDown (Result s) = Result {s & craneOnQuay = s.craneOnQuay }
moveDown e = e

lock :: (S Low Free) -> (S Low Locked)
lock (Result s) = case (s.craneOnQuay, s.onQuay, s.onShip) of 
	(True, [], _) -> Error NoContainersRemaining
	(False, _, []) -> Error NoContainersRemaining
	(True, [x:xs], _) -> Result {s & locked = Just x, onQuay = xs}
	(False, _, [x:xs]) -> Result {s & locked = Just x, onShip = xs}
lock e = e

unlock :: (S Low Locked) -> S Low Free
unlock (Result s) =  case (s.craneOnQuay, s.onQuay, s.onShip, s.locked) of
	(True, xs, _, Just x) -> Result {s & locked = Nothing, onQuay = [x:xs]}
	(False, _, xs, Just x) -> Result {s & locked = Nothing, onShip = [x:xs]}
unlock e = e

wait :: (S a b) -> S a b
wait s = s

(:.) infixl 1 :: ((S a b) -> (S c d)) ((S c d) -> S e f) -> ((S a b) -> S e f)
(:.) f g = g o f

whileContainerBelow :: (S a b) ((S a b) -> (S a b)) -> S a b
whileContainerBelow (Result s) action = case (if s.craneOnQuay s.onQuay s.onShip) of
	[] -> Result s
	[x:xs] -> whileContainerBelow (action (Result s)) action
whileContainerBelow e _ = e

loadShip :: (S High Free) -> S High Free
loadShip r = whileContainerBelow r
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

Start = loadShip (Result initialState)
