"/////////////////////////////////////////////////////////////////////////////
" basic
"/////////////////////////////////////////////////////////////////////////////

set nocompatible " be iMproved, required

function! OSX()
    return has('macunix')
endfunction
function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
function! WINDOWS()
    return  (has('win16') || has('win32') || has('win64'))
endfunction

" On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
" across (heterogeneous) systems easier.
if !exists('g:exvim_dev')
    if WINDOWS()
        set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
    endif
endif

"/////////////////////////////////////////////////////////////////////////////
" language and encoding setup
"/////////////////////////////////////////////////////////////////////////////

" always use English menu
" NOTE: this must before filetype off, otherwise it won't work
set langmenu=none

" use English for anaything in vim-editor. 
if WINDOWS()
    silent exec 'language english'
elseif OSX()
    silent exec 'language en_US' 
else
    let s:uname = system("uname -s")
    if s:uname == "Darwin\n"
        " in mac-terminal
        silent exec 'language en_US' 
    else
        " in linux-terminal
        silent exec 'language en_US.utf8' 
    endif
endif

" try to set encoding to utf-8
if WINDOWS()
    " Be nice and check for multi_byte even if the config requires
    " multi_byte support most of the time
    if has('multi_byte')
        " Windows cmd.exe still uses cp850. If Windows ever moved to
        " Powershell as the primary terminal, this would be utf-8
        set termencoding=cp850
        " Let Vim use utf-8 internally, because many scripts require this
        set encoding=utf-8
        setglobal fileencoding=utf-8
        " Windows has traditionally used cp1252, so it's probably wise to
        " fallback into cp1252 instead of eg. iso-8859-15.
        " Newer Windows files might contain utf-8 or utf-16 LE so we might
        " want to try them first.
        set fileencodings=ucs-bom,utf-8,utf-16le,cp1252,iso-8859-15
    endif

else
    " set default encoding to utf-8
    set encoding=utf-8
    set termencoding=utf-8
endif
scriptencoding utf-8

"/////////////////////////////////////////////////////////////////////////////
" Bundle steup
"/////////////////////////////////////////////////////////////////////////////

filetype off " required
if has('gui_running')
    set background=dark
else
    set background=light
endif

" load .vimrc.plugins and .vimrc.plugins.local
let vimrc_plugins_path = '~/.vimrc.plugins'
let vimrc_plugins_local_path = '~/.vimrc.plugins.local'
if exists('g:exvim_dev') && exists('g:exvim_dev_path')
    let vimrc_plugins_path = g:exvim_dev_path.'/.vimrc.plugins'
    let vimrc_plugins_local_path = g:exvim_dev_path.'/.vimrc.plugins.local'
endif
if filereadable(expand(vimrc_plugins_path))
    exec 'source ' . fnameescape(vimrc_plugins_path)
endif
if filereadable(expand(vimrc_plugins_local_path))
    exec 'source ' . fnameescape(vimrc_plugins_local_path)
endif

filetype plugin indent on " required
syntax on " required
"colorscheme solarized
"silent exec "colorscheme desertEx"
" colorscheme exlightgray

"/////////////////////////////////////////////////////////////////////////////
" General
"/////////////////////////////////////////////////////////////////////////////

"set path=.,/usr/include/*,, " where gf, ^Wf, :find will search 
set backup " make backup file and leave it around 

" setup back and swap directory
let data_dir = $HOME.'/.data/'
let backup_dir = data_dir . 'backup' 
let swap_dir = data_dir . 'swap' 
if finddir(data_dir) == ''
    silent call mkdir(data_dir)
endif
if finddir(backup_dir) == ''
    silent call mkdir(backup_dir)
endif
if finddir(swap_dir) == ''
    silent call mkdir(swap_dir)
endif
unlet backup_dir
unlet swap_dir
unlet data_dir

set backupdir=$HOME/.data/backup " where to put backup file 
set directory=$HOME/.data/swap " where to put swap file 

" Redefine the shell redirection operator to receive both the stderr messages and stdout messages
set shellredir=>%s\ 2>&1
set history=50 " keep 50 lines of command line history
set updatetime=1000 " default = 4000
set autoread " auto read same-file change ( better for vc/vim change )
set maxmempattern=1000 " enlarge maxmempattern from 1000 to ... (2000000 will give it without limit)

"/////////////////////////////////////////////////////////////////////////////
" xterm settings
"/////////////////////////////////////////////////////////////////////////////

behave xterm  " set mouse behavior as xterm
if &term =~ 'xterm'
    set mouse=a
endif

"/////////////////////////////////////////////////////////////////////////////
" Variable settings ( set all )
"/////////////////////////////////////////////////////////////////////////////

" ------------------------------------------------------------------ 
" Desc: Visual
" ------------------------------------------------------------------ 

set matchtime=0 " 0 second to show the matching paren ( much faster )
set nu " show line number
set scrolloff=0 " minimal number of screen lines to keep above and below the cursor 
set nowrap " do not wrap text

" only supoort in 7.3 or higher
if v:version >= 703
    set noacd " no autochchdir
endif

" set default guifont
if has('gui_running')
    augroup ex_gui_font
        " check and determine the gui font after GUIEnter. 
        " NOTE: getfontname function only works after GUIEnter.  
        au!
        au GUIEnter * call s:set_gui_font()
    augroup END

    " set guifont
    function! s:set_gui_font()
        if has('gui_gtk2')
            if getfontname( 'DejaVu Sans Mono for Powerline' ) != ''
                set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 12
            elseif getfontname( 'DejaVu Sans Mono' ) != ''
                set guifont=DejaVu\ Sans\ Mono\ 12
            else
                set guifont=Luxi\ Mono\ 12
            endif
        elseif has('x11')
            " Also for GTK 1
            set guifont=*-lucidatypewriter-medium-r-normal-*-*-180-*-*-m-*-*
        elseif OSX()
            if getfontname( 'DejaVu Sans Mono for Powerline' ) != ''
                set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h15
            elseif getfontname( 'DejaVu Sans Mono' ) != ''
                set guifont=DejaVu\ Sans\ Mono:h15
            endif
        elseif WINDOWS()
            if getfontname( 'DejaVu Sans Mono for Powerline' ) != ''
                set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h11:cANSI
            elseif getfontname( 'DejaVu Sans Mono' ) != ''
                set guifont=DejaVu\ Sans\ Mono:h11:cANSI
            elseif getfontname( 'Consolas' ) != ''
                set guifont=Consolas:h11:cANSI " this is the default visual studio font
            else
                set guifont=Lucida_Console:h11:cANSI
            endif
        endif
    endfunction
endif

" ------------------------------------------------------------------ 
" Desc: Vim UI
" ------------------------------------------------------------------ 

set wildmenu " turn on wild menu, try typing :h and press <Tab>
set showcmd " display incomplete commands
set cmdheight=1 " 1 screen lines to use for the command-line
set ruler " show the cursor position all the time
set hidden " allow to change buffer without saving
set shortmess=aoOtTI " shortens messages to avoid 'press a key' prompt
set lazyredraw " do not redraw while executing macros (much faster)
set display+=lastline " for easy browse last line with wrap text
set laststatus=2 " always have status-line
set titlestring=%t\ (%{expand(\"%:p:.:h\")}/)

" set window size (if it's GUI)
if has('gui_running')
    " set window's width to 130 columns and height to 40 rows
    if exists('+lines')
        set lines=40
    endif
    if exists('+columns')
        set columns=130
    endif

    " DISABLE
    " if WINDOWS()
    "     au GUIEnter * simalt ~x " Maximize window when enter vim
    " else
    "     " TODO: no way right now
    " endif
endif

set showfulltag " show tag with function protype.
set guioptions+=b " present the bottom scrollbar when the longest visible line exceed the window

" disable menu & toolbar
set guioptions-=m
set guioptions-=T

" ------------------------------------------------------------------ 
" Desc: Text edit
" ------------------------------------------------------------------ 

set ai " autoindent 
set si " smartindent 
set backspace=indent,eol,start " allow backspacing over everything in insert mode
" indent options
" see help cinoptions-values for more details
set	cinoptions=>s,e0,n0,f0,{0,}0,^0,:0,=s,l0,b0,g0,hs,ps,ts,is,+s,c3,C0,0,(0,us,U0,w0,W0,m0,j0,)20,*30
" default '0{,0},0),:,0#,!^F,o,O,e' disable 0# for not ident preprocess
" set cinkeys=0{,0},0),:,!^F,o,O,e

" official diff settings
set diffexpr=g:my_diff()
function! g:my_diff()
    let opt = '-a --binary -w '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    silent execute '!' .  'diff ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
endfunction

set cindent shiftwidth=4 " set cindent on to autoinent when editing c/c++ file, with 4 shift width
set tabstop=4 " set tabstop to 4 characters
set expandtab " set expandtab on, the tab will be change to space automaticaly
set ve=block " in visual block mode, cursor can be positioned where there is no actual character

" set Number format to null(default is octal) , when press CTRL-A on number
" like 007, it would not become 010
set nf=

" ------------------------------------------------------------------ 
" Desc: Fold text
" ------------------------------------------------------------------ 

set foldmethod=marker foldmarker={,} foldlevel=9999
set diffopt=filler,context:9999

" ------------------------------------------------------------------ 
" Desc: Search
" ------------------------------------------------------------------ 

set showmatch " show matching paren 
set incsearch " do incremental searching
set hlsearch " highlight search terms
set ignorecase " set search/replace pattern to ignore case 
set smartcase " set smartcase mode on, If there is upper case character in the search patern, the 'ignorecase' option will be override.

" set this to use id-utils for global search
set grepprg=lid\ -Rgrep\ -s
set grepformat=%f:%l:%m

"/////////////////////////////////////////////////////////////////////////////
" Auto Command
"/////////////////////////////////////////////////////////////////////////////

" ------------------------------------------------------------------ 
" Desc: Only do this part when compiled with support for autocommands.
" ------------------------------------------------------------------ 

if has('autocmd')

    augroup ex
        au!

        " ------------------------------------------------------------------ 
        " Desc: Buffer
        " ------------------------------------------------------------------ 

        " when editing a file, always jump to the last known cursor position.
        " don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        au BufReadPost *
                    \ if line("'\"") > 0 && line("'\"") <= line("$") |
                    \   exe "normal g`\"" |
                    \ endif
        au BufNewFile,BufEnter * set cpoptions+=d " NOTE: ctags find the tags file from the current path instead of the path of currect file
        au BufEnter * :syntax sync fromstart " ensure every file does syntax highlighting (full) 
        au BufNewFile,BufRead *.avs set syntax=avs " for avs syntax file.

        " DISABLE { 
        " NOTE: will have problem with exvim, because exvim use exES_CWD as working directory for tag and other thing
        " Change current directory to the file of the buffer ( from Script#65"CD.vim"
        " au   BufEnter *   execute ":lcd " . expand("%:p:h") 
        " } DISABLE end 

        " ------------------------------------------------------------------ 
        " Desc: file types 
        " ------------------------------------------------------------------ 

        au FileType text setlocal textwidth=78 " for all text files set 'textwidth' to 78 characters.
        au FileType c,cpp,cs,swig set nomodeline " this will avoid bug in my project with namespace ex, the vim will tree ex:: as modeline.

        " disable auto-comment for c/cpp, lua, javascript, c# and vim-script
        au FileType c,cpp,java,javascript set comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,f:// 
        au FileType cs set comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,f:///,f:// 
        au FileType vim set comments=sO:\"\ -,mO:\"\ \ ,eO:\"\",f:\"
        au FileType lua set comments=f:--

        " if edit python scripts, check if have \t. ( python said: the programme can only use \t or not, but can't use them together )
        au FileType python,coffee call s:check_if_expand_tab()
    augroup END

    function! s:check_if_expand_tab()
        let has_noexpandtab = search('^\t','wn')
        let has_expandtab = search('^    ','wn')

        "
        if has_noexpandtab && has_expandtab
            let idx = inputlist ( ['ERROR: current file exists both expand and noexpand TAB, python can only use one of these two mode in one file.\nSelect Tab Expand Type:',
                        \ '1. expand (tab=space, recommended)', 
                        \ '2. noexpand (tab=\t, currently have risk)',
                        \ '3. do nothing (I will handle it by myself)'])
            let tab_space = printf('%*s',&tabstop,'')
            if idx == 1
                let has_noexpandtab = 0
                let has_expandtab = 1
                silent exec '%s/\t/' . tab_space . '/g'
            elseif idx == 2
                let has_noexpandtab = 1
                let has_expandtab = 0
                silent exec '%s/' . tab_space . '/\t/g'
            else
                return
            endif
        endif

        " 
        if has_noexpandtab == 1 && has_expandtab == 0  
            echomsg 'substitute space to TAB...'
            set noexpandtab
            echomsg 'done!'
        elseif has_noexpandtab == 0 && has_expandtab == 1
            echomsg 'substitute TAB to space...'
            set expandtab
            echomsg 'done!'
        else
            " it may be a new file
            " we use original vim setting
        endif
    endfunction
endif

"/////////////////////////////////////////////////////////////////////////////
" Key Mappings
"/////////////////////////////////////////////////////////////////////////////

" NOTE: F10 looks like have some feature, when map with F10, the map will take no effects

" Don't use Ex mode, use Q for formatting
map Q gq  

" define the copy/paste judged by clipboard
if &clipboard ==# 'unnamed'
    " fix the visual paste bug in vim
    " vnoremap <silent>p :call g:()<CR>
else
    " general copy/paste.
    " NOTE: y,p,P could be mapped by other key-mapping
    map <unique> <leader>y "*y
    map <unique> <leader>p "*p
    map <unique> <leader>P "*P
endif

" copy folder path to clipboard, foo/bar/foobar.c => foo/bar/
nnoremap <unique> <silent> <leader>y1 :let @*=fnamemodify(bufname('%'),":p:h")<CR>

" copy file name to clipboard, foo/bar/foobar.c => foobar.c
nnoremap <unique> <silent> <leader>y2 :let @*=fnamemodify(bufname('%'),":p:t")<CR>

" copy full path to clipboard, foo/bar/foobar.c => foo/bar/foobar.c 
nnoremap <unique> <silent> <leader>y3 :let @*=fnamemodify(bufname('%'),":p")<CR>

" F8 or <leader>/:  Set Search pattern highlight on/off
nnoremap <unique> <F8> :let @/=""<CR>
nnoremap <unique> <leader>/ :let @/=""<CR>

" map Ctrl-Tab to switch window
nnoremap <unique> <S-Up> <C-W><Up>
nnoremap <unique> <S-Down> <C-W><Down>
nnoremap <unique> <S-Left> <C-W><Left>
nnoremap <unique> <S-Right> <C-W><Right>

" easy buffer navigation
" NOTE: if we already map to EXbn,EXbp. skip setting this
if !hasmapto(':EXbn<CR>') && mapcheck('<C-l>','n') == ''
    nnoremap <C-l> :bn<CR>
endif
if !hasmapto(':EXbp<CR>') && mapcheck('<C-h>','n') == ''
    noremap <C-h> :bp<CR>
endif

" easy diff goto
noremap <unique> <C-k> [c
noremap <unique> <C-j> ]c

" enhance '<' '>' , do not need to reselect the block after shift it.
vnoremap <unique> < <gv
vnoremap <unique> > >gv

" map Up & Down to gj & gk, helpful for wrap text edit
noremap <unique> <Up> gk
noremap <unique> <Down> gj

" TODO: I should write a better one, make it as plugin exvim/swapword
" VimTip 329: A map for swapping words
" http://vim.sourceforge.net/tip_view.php?tip_id=
" Then when you put the cursor on or in a word, press "\sw", and
" the word will be swapped with the next word.  The words may
" even be separated by punctuation (such as "abc = def").
nnoremap <unique> <silent> <leader>sw "_yiw:s/\(\%#\w\+\)\(\W\+\)\(\w\+\)/\3\2\1/<cr><c-o>

"/////////////////////////////////////////////////////////////////////////////
" local setup
"/////////////////////////////////////////////////////////////////////////////

let vimrc_local_path = '~/.vimrc.local'
if exists('g:exvim_dev') && exists('g:exvim_dev_path')
    let vimrc_local_path = g:exvim_dev_path.'/.vimrc.local'
endif
if filereadable(expand(vimrc_local_path))
    exec 'source ' . fnameescape(vimrc_local_path)
endif

" vim:ts=4:sw=4:sts=4 et fdm=marker:

"//////////////////// YunxiZhangy

"@Yunxi color set
set t_Co=256
"colorscheme solarized
silent exec "colorscheme desertEx"
func! CompileAndDownloaderKernel()
    exec "w"
    exec "!dik"
endfunc
"map  <F5>: call CompileKernel() <CR>
"viminfo---------------------------------
map <F6> :set sessionoptions+=curdir<cr>:set sessionoptions+=buffers<cr> :set sessionoptions+=winsize<cr>  :mksession! mine.vim<cr> :wviminfo! mine.viminfo<cr> :wall<cr> : qall<cr> 
map <F7> :source ./mine.vim<cr> :rviminfo ./mine.viminfo<cr> <c-j>:q<cr>  
"----------------------------------------
map! jk <ESC>   
let mapleader=","
set ignorecase
set shortmess+=T  "dont display 'xxxxx Press ENTER or type command to continuer'
"double cr disable return messages
nnoremap <unique> <leader>df :call CompileAndDownloaderKernel()<CR><CR> 
"--------------------------------- yunxi------------------
""""""""""""""""""""""window 
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

nnoremap <c-d> <c-w>+
nnoremap <c-g> <c-w>-
nnoremap <c-p> <c-w><
nnoremap <c-n> <c-w>>

func Enter()
endfunc
set cscopequickfix=s-,c-,d-,i-,t-,e-
if has("cscope")
    set csprg=/usr/bin/cscope
    set csto=0
    set cst
    set csverb
	set cspc=3
    "add any database in current dir
   if filereadable("cscope.out")
    silent cs add cscope.out
    "else search cscope.out elsewhere
   else
      let cscope_file=findfile("cscope.out", ".;")
      let cscope_pre=matchstr(cscope_file, ".*/")
      if !empty(cscope_file) && filereadable(cscope_file)
        exe  " silent cs add" cscope_file cscope_pre
        
      endif      
   endif
end
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>


nmap <silent> <tab> :bn!<CR>
nmap <silent> <s-tab> :bp!<CR>
" map exUtility#Kwbd(1) to \bd will close buffer and keep window
nnoremap <unique> <Leader>bd :call exUtility#Kwbd(1)<CR>
nnoremap <unique> <C-F4> :call exUtility#Kwbd(1)<CR>

" register buffer names of plugins.
let g:ex_plugin_registered_bufnames = ["-MiniBufExplorer-","__Tag_List__","\[Lookup File\]", "\[BufExplorer\]"] 

" register filetypes of plugins.
let g:ex_plugin_registered_filetypes = ["ex_plugin","ex_project","taglist","nerdtree"] 

" default languages
let g:ex_default_langs = ['c', 'cpp', 'c#', 'javascript', 'java', 'shader', 'python', 'lua', 'vim', 'uc', 'matlab', 'wiki', 'ini', 'make', 'sh', 'batch', 'debug', 'qt', 'swig' ] 

" exEnvironmentSetting post update
" NOTE: this is a post update environment function used for any custom environment update 
function g:exES_PostUpdate()

    " set lookup file plugin variables
	if exists( 'g:exES_LookupFileTag' )
        let g:LookupFile_TagExpr='"'.g:exES_LookupFileTag.'"./tags"''
        if exists(':LUCurFile')
            " NOTE: the second <CR>, if only one file, will jump to it directly.
            unmap gf
            nnoremap <unique> <silent> gf :LUCurFile<CR>
        endif
    endif

	" set visual_studio plugin variables
	if exists( 'g:exES_vsTaskList' )
		let g:visual_studio_task_list = g:exES_vsTaskList
	endif
	if exists( 'g:exES_vsOutput' )
		let g:visual_studio_output = g:exES_vsOutput
	endif
	if exists( 'g:exES_vsFindResult1' )
		let g:visual_studio_find_results_1 = g:exES_vsFindResult1
	endif
	if exists( 'g:exES_vsFindResult2' )
		let g:visual_studio_find_results_2 = g:exES_vsFindResult2
	endif

    " set vimwiki
    if exists(:q 'g:exES_wikiHome' )
        " clear the list first
        if exists( 'g:vimwiki_list' ) && !empty(g:vimwiki_list)
            silent call remove( g:vimwiki_list, 0, len(g:vimwiki_list)-1 )
        endif

        " assign vimwiki pathes, 
        " NOTE: vimwiki need full path.
        let g:vimwiki_list = [ { 'path': fnamemodify(g:exES_wikiHome,":p"), 
                    \ 'path_html': fnamemodify(g:exES_wikiHomeHtml,":p"),
                    \ 'html_header': fnamemodify(g:exES_wikiHtmlHeader,":p") } ]

        " create vimwiki files
        call exUtility#CreateVimwikiFiles ()
    endif
endfunction


" ------------------------------------------------------------------ 
" Desc: TagList
" ------------------------------------------------------------------ 

" F4:  Switch on/off TagList
nnoremap <unique> <silent> <F4> :TlistToggle<CR>
"let Tlist_Ctags_Cmd = $VIM.'/vimfiles/ctags.exe' " location of ctags tool 
let Tlist_Show_One_File = 1 " Displaying tags for only one file~
let Tlist_Exist_OnlyWindow = 1 " if you are the last, kill yourself 
let Tlist_Use_Right_Window = 1 " split to the right side of the screen 
let Tlist_Sort_Type = "order" " sort by order or name
let Tlist_Display_Prototype = 0 " do not show prototypes and not tags in the taglist window.
let Tlist_Compart_Format = 1 " Remove extra information and blank lines from the taglist window.
let Tlist_GainFocus_On_ToggleOpen = 1 " Jump to taglist window on open.
let Tlist_Display_Tag_Scope = 1 " Show tag scope next to the tag name.
let Tlist_Close_On_Select = 0 " Close the taglist window when a file or tag is selected.
let Tlist_BackToEditBuffer = 0 " If no close on select, let the user choose back to edit buffer or not
let Tlist_Enable_Fold_Column = 0 " Don't Show the fold indicator column in the taglist window.
let Tlist_WinWidth = 40
let Tlist_Compact_Format = 1 " do not show help
" let Tlist_Ctags_Cmd = 'ctags --c++-kinds=+p --fields=+iaS --extra=+q --languages=c++'
" very slow, so I disable this
" let Tlist_Process_File_Always = 1 " To use the :TlistShowTag and the :TlistShowPrototype commands without the taglist window and the taglist menu, you should set this variable to 1.
":TlistShowPrototype [filename] [linenumber]

" let taglist support shader language as c-like language
let tlist_hlsl_settings = 'c;d:macro;g:enum;s:struct;u:union;t:typedef;v:variable;f:function'

" ------------------------------------------------------------------ 
" Desc: ShowMarks
" ------------------------------------------------------------------ 

let g:showmarks_enable = 1
let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
" Ignore help, quickfix, non-modifiable buffers
let showmarks_ignore_type = "hqm"
" Hilight lower & upper marks
let showmarks_hlline_lower = 1
let showmarks_hlline_upper = 0 

" quick remove mark
" nmap <F9> \mh

" ------------------------------------------------------------------ 
" Desc: LookupFile 
" ------------------------------------------------------------------ 

if has("gui_running") "  the <alt> key is only available in gui mode.
    if has ("mac")
        nnoremap <unique> ˆ :LUTags<CR>
    else
        nnoremap <unique> <M-I> :LUTags<CR>
    endif
endif
nnoremap <unique> <leader>fs :LUTags<CR><CR>
nnoremap <unique> <leader>b :LUBufs<CR>
nnoremap <unique> <silent> <Leader>ll :LUCurWord<CR>

let g:LookupFile_TagExpr = '"filenametags"'
let g:LookupFile_MinPatLength = 3
let g:LookupFile_PreservePatternHistory = 0
let g:LookupFile_PreserveLastPattern = 0
let g:LookupFile_AllowNewFiles = 0
let g:LookupFile_smartcase = 1
let g:LookupFile_EscCancelsPopup = 1

" ------------------------------------------------------------------ 
" Desc: EnhCommentify
" ------------------------------------------------------------------ 

let g:EnhCommentifyFirstLineMode='yes'
let g:EnhCommentifyRespectIndent='yes'
let g:EnhCommentifyUseBlockIndent='yes'
let g:EnhCommentifyAlignRight = 'yes'
let g:EnhCommentifyPretty = 'yes'
let g:EnhCommentifyBindInNormal = 'no'
let g:EnhCommentifyBindInVisual = 'no'
let g:EnhCommentifyBindInInsert = 'no'

" NOTE: VisualComment,Comment,DeComment are plugin mapping(start with <Plug>), so can't use remap here
"vmap <unique> <F11> <Plug>VisualComment
"nmap <unique> <F11> <Plug>Comment
"imap <unique> <F11> <ESC><Plug>Comment
"vmap <unique> <C-F11> <Plug>VisualDeComment
"nmap <unique> <C-F11> <Plug>DeComment
"imap <unique> <C-F11> <ESC><Plug>DeComment

" ------------------------------------------------------------------ 
" Desc: exCscope
" ------------------------------------------------------------------ 

nnoremap <unique> <silent> <F2> :CSIC<CR>
nnoremap <unique> <silent> <Leader>ci :CSID<CR>
nnoremap <unique> <silent> <F3> :ExcsParseFunction<CR>
nnoremap <unique> <silent> <Leader>cd :CSDD<CR>
nnoremap <unique> <silent> <Leader>cc :CSCD<CR>
nnoremap <unique> <silent> <Leader>cs :ExcsSelectToggle<CR>
nnoremap <unique> <silent> <Leader>cq :ExcsQuickViewToggle<CR>

let g:exCS_backto_editbuf = 0
let g:exCS_close_when_selected = 0
let g:exCS_window_direction = 'bel'
let g:exCS_window_width = 48

" ------------------------------------------------------------------ 
" Desc: exQuickFix
" ------------------------------------------------------------------ 

nnoremap <unique> <silent> <leader>qf :ExqfSelectToggle<CR>
nnoremap <unique> <silent> <leader>qq :ExqfQuickViewToggle<CR>

let g:exQF_backto_editbuf = 0
let g:exQF_close_when_selected = 0
let g:exQF_window_direction = 'bel'

" copy only full path name
nnoremap <unique> <silent> <leader>y1 :call exUtility#Yank( fnamemodify(bufname('%'),":p:h") )<CR>
" copy only file name
nnoremap <unique> <silent> <leader>y2 :call exUtility#Yank( fnamemodify(bufname('%'),":p:t") )<CR>
" copy full path + filename
nnoremap <unique> <silent> <leader>y3 :call exUtility#Yank( fnamemodify(bufname('%'),":p") )<CR>
" copy path + filename for code
nnoremap <unique> <silent> <leader>yb :call exUtility#YankBufferNameForCode()<CR>
" copy path for code
nnoremap <unique> <silent> <leader>yp :call exUtility#YankFilePathForCode()<CR>

" ------------------------------------------------------------------ 
" Desc: exTagSelect
" ------------------------------------------------------------------ 

nnoremap <unique> <silent> <Leader>ts :ExtsSelectToggle<CR>
nnoremap <unique> <silent> <Leader>tg :ExtsGoDirectly<CR>
nnoremap <unique> <silent> <Leader>] :ExtsGoDirectly<CR>

let g:exTS_backto_editbuf = 0
let g:exTS_close_when_selected = 1
let g:exTS_window_direction = 'bel'

" ------------------------------------------------------------------ 
" Desc: exGlobalSearch
" ------------------------------------------------------------------ 

nnoremap <unique> <silent> <Leader>gs :ExgsSelectToggle<CR>
nnoremap <unique> <silent> <Leader>gq :ExgsQuickViewToggle<CR>
nnoremap <unique> <silent> <Leader>gg :ExgsGoDirectly<CR>
nnoremap <unique> <silent> <Leader>n :ExgsGotoNextResult<CR>
nnoremap <unique> <silent> <Leader>N :ExgsGotoPrevResult<CR>
nnoremap <unique> <Leader><S-f> :GS 

let g:exGS_backto_editbuf = 0
let g:exGS_close_when_selected = 0
let g:exGS_window_direction = 'bel'
let g:exGS_auto_sort = 1
let g:exGS_lines_for_autosort = 200

"--------------------------------- yunxi------------------
"////////////////////end YunxiZhangy
