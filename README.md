# Welcome to TBasic
TBasic is a flavor of BASIC for TempleOS. It was made so people don't have to learn HolyC since its pretty complicated.
I'm not saying TBasic isn't complicated either but its surely easier than HolyC.

Here are some examples of code, you also have some demos i made in the TB files. But before that, you gotta learn how to even run TBasic code.

## Running TBasic
First thing you have to do is include the Interpreter.
```HC
#include "Interpreter.TB";
```
And then you can either enter the Shell
```HC
TB_Shell;
```
or run a script
```HC
TB_Run("Directory");
```

## Setting variables and printing
The way you set variables is by doing
```
set <variable_name> <value>
```
TBasic doesnt have any string variables, but its possible to print stuff normally like this:
```
print Hello World!
```

Here is a little demo of how you set a variable and how you print it.
Input
```
set variable 10
print variable
```
Output
```
10
```

## Math 
In TBasic, you do math a very interesting way. You have a math command and it takes 4 arguments
```
math <value1> <operator> <value2> <value3>
```
<b>value1</b> being the first value in the equation, <b>operator</b> being the operator in the equation,
<b>value2</b> being the second value in the equation and <b>value3</b> being the output of the command.

Here is a demo
Input
```
set a 10
set b 20
math a + b result
print result
```
Output
```
30
```
Note: Arguments in commands are case sensitive, meaning you cant just do
```
math 1+1 result
```
It must be like it was in the demos


## Getting variables
Basically it's used for getting a variable based on what you type.
Here is how you write it
```
get <variable_name>
```
It already creates the variable so you dont have to do a set.
Here is a little demo to show you how it works

Input
```
print Type in your variable
get a
print a
```
Output
```
Type in your variable
>> 10
10
```

## If statements
If statements are pretty simple in this language, although we do not have else if. 
There is a different way to nest the if statements which I'll show it to you in a bit.

Example of an if statement
```
if 10 == 10 then
  print 10 is equal to 10
else
  print I dont know how you managed to do this
endif
```
Every if statement must have an endif, else is not required.

Example of a nested if statement
```
if 10 == 10 then
  print 10 is equal to 10
else
  if 10 == 11 then
    print 10 is somehow equal to 11
  endif
endif
```
You could do this infinitely. There is no reason to make a demo for this therefore im not gonna make one.


## Goto
Like in BASIC or Batch, we have a goto command that can go to different points in the file. Goto only works in a file, it doesnt work in the shell.
To use goto, you have to setup labels kinda like you have in Batch.
```
label main
print Choose 2 options
print (1) - Enter a different label
print (2) - Exit
get choice
if choice == 1 then
  goto woah
else
  goto cleanup
endif

label woah
cls
print Woah you went to a different label
exit

label cleanup
delete choice 
```
Here you can see i used some of the commands i havent explained before,
<b>delete</b> is being used to delete the variable so it doesnt stay in the program for no reason
<b>cls</b> is used to clear the screen, kinda like you have in the linux terminal or in batch


## Loops
In TBasic, we don't really have built-in loop functions, so you have to get creative with the goto command.

Here is an example of a while loop
```
label loop
if 1 == 1 then
  print Youre looping!
  goto loop
endif
```

Here is an example of a for loop
```
set index 0
set max 10
label loop
if index < max then
  math index + 1 index
  print index
  goto loop
endif
```

## Drawing things on the screen
Kinda like you have in the C64, you use the poke function. Although its not used to poke memory, its used to draw things on the screen.

Here is an example on how to use it
```
poke <x> <y> <backgroundColor> <foregroundColor> <asciiCharacter>
```
It's recommended to use the sleep command which works like in any programming language to
stop with the flashing of it.

There is a demo called KeyTest.TB in the repository so you can check it out if you want to.
It also uses a command togglecursor which basically toggles the visibility of your cursor.

## Getting key input
TBasic has a global variable called g_TBKey that basically outputs the
ascii value of the key being currently pressed. It's used in the KeyTest.TB demo.


## Queues
Instead of arrays, we have queues. Since this language is trying to make you be somewhat ready to move onto HolyC
in the future.

Queues have multiple commands and here they are:

To initialize a queue with that name
```
queinit <name>
```
To get data from a queue, kinda like you have in an array
```
queget <name> <index> <result>
```
To push stuff into the queue
```
quepush <name> <value>
```
To delete the last element in the queue
```
quepop <name>
```
To count how much elements the queue has, it sets the output as the result
```
quecnt <name> <result>
```

























