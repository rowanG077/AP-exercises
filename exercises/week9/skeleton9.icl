module skeleton9

import iTasks, StdEnv
import Data.Func
import Data.Functor
from StdMaybe import Just, Nothing

/*
	Pieter Koopman, pieter@cs.ru.nl
	Advanced Programming. Skeleton for assignment 9 in 20-21.
	Use this in a project with environment iTasks.
*/

:: Student =
	{ name :: String
	, snum :: Int
	, bama :: BaMa
	, year :: Int
	}

:: BaMa = Bachelor | Master

derive class iTask Student, BaMa
derive class toString BaMa

Start w = doTasks task8 w

task :: Task [Int]
task = enterInformation []

task1 :: Task Student
task1 = enterInformation []

task2 :: Task [Student]
task2 = enterInformation []

task3 :: Task Student
task3 = updateInformation [] student

task4 :: Task Student
task4 = enterChoice [] students

task5 :: Task Student
task5 = enterChoice [ChooseFromDropdown (\s = s.Student.name)] students

task6 :: Task [Student]
task6 = enterMultipleChoice [ChooseFromList (\s = (s.Student.name, s.Student.bama) )] students

task7 :: Task (Int, [String])
task7 = task6
		>>? return
		>>- (\xs = viewInformation [] (length xs, map (\s = s.Student.name) xs))

task8 :: Task Student
task8 = (setName -&&- viewSnum -&&- viewBama -&&- viewYear)
		>>? return
		>>- (\(n,(s,(b,y))) = viewInformation [] {name=n,snum=s,bama=b,year=y} )
	where
		setName = updateInformation [] student.Student.name
		viewSnum = viewInformation [] student.Student.snum
		viewBama = viewInformation [] student.Student.bama
		viewYear = viewInformation [] student.Student.year

task9 :: Task Student
task9 = ((enterInformation [] >>? return) -||- (viewInformation [] student >>? return))
		>>- viewInformation []

task10 :: Task Student
task10 = (enterInformation [] -&&- enterInformation [] -&&- enterInformation [] -&&- enterInformation [])
		>>? return
		>>- (\(n,(s,(b,y))) = viewInformation [] {name=n,snum=s,bama=b,year=y} )

task11 :: Bool -> Task Bool
task11 b = updateChoice [ChooseFromDropdown id] [True,False] b

students :: [Student]
students =
	[{name = "Alice"
	 ,snum = 1000
	 ,bama = Master
	 ,year = 1
	 }
	,{name = "Bob"
	 ,snum = 1003
	 ,bama = Master
	 ,year = 1
	 }
	,{name = "Carol"
	 ,snum = 1024
	 ,bama = Master
	 ,year = 2
	 }
	,{name = "Dave"
	 ,snum = 2048
	 ,bama = Bachelor
	 ,year = 1
	 }
	,{name = "Eve"
	 ,snum = 4096
	 ,bama = Master
	 ,year = 1
	 }
	,{name = "Frank"
	 ,snum = 1023
	 ,bama = Master
	 ,year = 1
	 }
	]

student :: Student
student = students !! 0
