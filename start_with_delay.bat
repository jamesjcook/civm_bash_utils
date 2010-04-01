@echo Off 
REM start execution with delay
REM takes two arguments, first one is a delay in seconds second is a program


set delay=%1
set program=%2

echo "Starting Program: %program% "
echo "with delay %1"

FOR /L %%i in (0,1,%delay%) DO (
  echo Delayed %%i seconds
  ping 0.0.0.1 -n 1 -w 1000 > NUL
)
start /wait /B "" "%program%"
