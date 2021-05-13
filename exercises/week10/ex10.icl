module ex10

import iTasks, StdEnv
import iTasks.Extensions.DateTime
import Data.Func
import Data.Functor
from StdMaybe import Just, Nothing

:: Login =
	{ username :: String
	, pass     :: Password
	}

:: ToDo =
	{ todo  :: String
	, limit :: Date
	, names :: [String]
	}

derive class iTask Login, ToDo
derive class Eq Login, ToDo

accounts :: [Login]
accounts =
	[ { username = "alice"
	  , pass = Password "p1"
	  }
	, { username = "bob"
	  , pass = Password "p2"
	  }
	]

accountsSDS :: SimpleSDSLens [Login]
accountsSDS = sharedStore "accountsSDS" accounts
todosSDS :: SimpleSDSLens [ToDo]
todosSDS = sharedStore "todosSDS" []

Start w = doTasks main w

main :: Task ()
main = (login accountsSDS -||- register accountsSDS)
	>>- (\l. (createToDo accountsSDS todosSDS -||- listToDos todosSDS l))

login :: (SimpleSDSLens [Login]) -> Task Login
login sds = Title "Login" @>> enterInformation [] >>? (\login. get accountsSDS >>- verifyLogin login)
	where
		verifyLogin log [l:ls] = if (gEq{|*|} log l) (return l) (verifyLogin log ls)
		verifyLogin log [] = Title "Invalid login please try again." @>> unitEnter >?| login sds
		unitEnter :: Task ()
		unitEnter = enterInformation []

register :: (SimpleSDSLens [Login]) -> Task Login
register sds = Title "Register" @>> enterInformation [] >>? return >>- updateLogins
	where
		updateLogins login = (upd (\old. [login:old]) sds) >>- (const (return login))

listToDos :: (SimpleSDSLens [ToDo]) Login -> Task ()
listToDos sds l =
		Title "ToDos" @>> enterChoiceWithShared [ChooseFromList id] sds
		>>? removeToDo
		>>- (const (listToDos sds l))
	where
		removeToDo t = upd (filter (\x. t.ToDo.todo <> x.ToDo.todo)) sds

createToDo :: (SimpleSDSLens [Login]) (SimpleSDSLens [ToDo]) -> Task ()
createToDo aSDS tSDS =
		Title "Create ToDo" @>> enterToDo
		>>- updateToDos
		>>- (const (createToDo aSDS tSDS))
	where
		updateToDos t = upd (\ts. [t : ts]) tSDS

		enterToDo = get aSDS >>- addTodo
		addTodo accs = (enterInformation [] -&&- enterInformation [] -&&- enterMultipleChoice [ChooseFromCheckGroup (\a. a.Login.username)] accs)
			>>* actions
			>>- (\(t,(l, as)) = return { todo = t
						   , limit = l
						   , names= map (\a.  a.Login.username) as
						   })
		actions = [OnAction ActionOk (ifValue isValidToDo return)]
		isValidToDo (t, (l, as)) = (size t) > 0 && length as > 0
