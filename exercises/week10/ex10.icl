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

main :: Task [ToDo]
main = (login accountsSDS -||- register accountsSDS)
	>>- (\l. forever (createToDo accountsSDS todosSDS -||- listToDos todosSDS l))

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

listToDos :: (SimpleSDSLens [ToDo]) Login -> Task [ToDo]
listToDos sds l =
		Title "ToDos" @>> (watch sds >>~ selectToDo)
		>>? removeToDo
	where
		removeToDo t = upd (filter (\x. t.ToDo.todo <> x.ToDo.todo)) sds

		selectToDo todos = enterChoice [ChooseFromList id] (myToDos todos)
		myToDos = filter (\x. isMember l.Login.username x.ToDo.names)

createToDo :: (SimpleSDSLens [Login]) (SimpleSDSLens [ToDo]) -> Task [ToDo]
createToDo aSDS tSDS =
		Title "Create ToDo" @>> (get aSDS >>- addToDo)
		>>- updateToDos
	where
		updateToDos t = upd (\ts. [t : ts]) tSDS

		addToDo accs = (enterInformation [] -&&- enterInformation [] -&&- enterMultipleChoice [ChooseFromCheckGroup (\a. a.Login.username)] accs)
			>>* actions
			>>- (\(t,(l, as)) = return { todo = t
						   , limit = l
						   , names= map (\a.  a.Login.username) as
						   })
		actions = [OnAction ActionOk (ifValue isValidToDo return)]
		isValidToDo (t, (l, as)) = (size t) > 0 && length as > 0
