@echo off
set cwd=%cd%
"c:\Program Files\Vim\vim73\gvim" ^
    -u %cwd%\.vimrc ^
    --cmd "let g:exvim_dev=1" ^
    --cmd "set runtimepath=%cwd%\vimfiles,$VIMRUNTIME,%cwd%\vimfiles\after" ^
    %1
@echo on
