" Make Vim more useful
set nocompatible

" TODO move to a section
" Use the Solarized Dark theme
set background=dark
colorscheme Tomorrow-Night-Eighties
let g:solarized_termtrans=1

" ================================== PATHOGEN ==================================

" Pathogen load
filetype off
call pathogen#infect()
call pathogen#helptags()

" =============================== GENERAL CONFIG ===============================

set shell=bash
set number                      " Line numbers are good
set relativenumber              " User relative line numbers
set numberwidth=5               " Show line numbers of up to 4 characters
set cursorline                  " Highlight current line
set backspace=indent,eol,start  " Allow backspace in insert mode
set history=1000                " Store lots of :cmdline history
set showcmd                     " Show incomplete cmds down the bottom
set showmode                    " Show current mode down the bottom
set ruler                       " Show the cursor position
set laststatus=2                " Always show status line
set title                       " Show the filename in the window titlebar
set nojoinspaces                " Only insert single space after a '.', '?' and '!' with a join command.
set report=0                    " Show all changes
set showtabline=2               " Always show tab bar
set nostartofline               " Don’t reset cursor to start of line when moving around.
set virtualedit=onemore         " Allow the cursor to go one character after the end of the line
set switchbuf=useopen           " Don't open a new split if the buffer is already open

" Switch from block-cursor to vertical-line-cursor when going into/out of insert mode
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Disable beep on errors
set noerrorbells
set visualbell

" Optimize for fast terminal connections
set ttyfast

" Use UTF-8 without BOM
set encoding=utf-8 nobomb

" Enable mouse in all modes
if has('mouse')
  set mouse=a
endif

runtime macros/matchit.vim      " Make % key smarter

" http://www.shallowsky.com/linux/noaltscreen.html
" set t_ti= t_te=        " Don't clear the screen when quitting

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
 set hidden

syntax on                       " Turn syntax highlighting on

" Highlight trailing whitespace
highlight SpecialKey ctermfg=DarkGray ctermbg=Black

set nomodeline          " Do not use modelines, because of security vulnerability

" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed

" ================================= SWAP FILES =================================

set noswapfile
set nobackup
set nowritebackup

" ============================== PERSISTENT UNDO ===============================

" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================================ INDENTATION =================================

set autoindent     "Copy indent from last line when starting a new line
set smartindent    "Make indenting smarter
set smarttab       "At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shiftwidth spaces.
set expandtab      "Expand tabs to spaces
set shiftwidth=4   "The # of spaces for indenting
set softtabstop=4  "The # of spaces tab key results in
set tabstop=4      "The # of spaces tabs indent

set showmatch    " Show matching brackets
set matchtime=5  " Duration to show matching brace

" Enable file type detection
filetype plugin on
filetype indent on

" Display tabs and trailing spaces visually
set list listchars=tab:▸\ ,trail:·,eol:¬,nbsp:_

" ================================== WRAPPING ==================================

set wrap                    " Wrap lines
set linebreak               " Wrap lines at convenient points

" =================================== FOLDS ====================================

" Turn folding off for real, hopefully
set foldmethod=manual
set nofoldenable

" ================================= COMPLETION =================================

set completeopt=longest,menu,preview

set wildmode=longest:full
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
"stuff to ignore when tab completing
set wildignore=*.o,*.obj,*.pyc,*~  " ignore compiled files
set wildignore+=.git\*,.hg\*,.svn\*
"set wildignore+=*vim/backups*
"set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
"set wildignore+=vendor/rails/**
"set wildignore+=vendor/cache/**
"set wildignore+=*.gem
"set wildignore+=log/**
"set wildignore+=tmp/**
"set wildignore+=*.png,*.jpg,*.gif

" ================================= SCROLLING ==================================

set scrolloff=5         "Start scrolling when we're 5 lines away from margins
set sidescrolloff=15
set sidescroll=1

" =================================== SPLITS ===================================

set splitbelow "New split goes below
set splitright "New split goes right

" Set size of windows, always showing 79 columns vertical
" and show the most possible horizontally while keeping 5 lines of each split
set winwidth=79
silent! set winminwidth=20
set winheight=5
set winminheight=5
set winheight=999

" Hack to change preview window sizes in the same fashion
" http://stackoverflow.com/a/3787326
set previewheight=999
au BufEnter ?* call PreviewHeightWorkAround()
func PreviewHeightWorkAround()
    if &previewwindow
        exec 'setlocal winheight='.&previewheight
    endif
endfunc

" Split horizontally with both windows having the same size, reset without
" argument
function! SplitEqual(...)
    if a:0
        let &winheight=winheight(winnr()) / 2
        execute 'split ' a:1
    else
        let &winheight=999
    endif
endfunction

command! -nargs=? -complete=file Spe call SplitEqual(<f-args>)
nnoremap <leader>spe :Spe<space>

" =================================== SEARCH ===================================

set incsearch       " Find the next match as we type the search
set hlsearch        " Highlight searches by default
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital
set gdefault        " Substitute all matches on a line

" ================================== AUTOCMD ===================================

if has("autocmd")
  " Create vimrc autocmd group and remove any existing vimrc autocmds,
  " in case .vimrc is re-sourced.
  augroup vimrc
    autocmd!
  augroup END

  " When editing a file, always jump to the last known cursor position. Don't do
  " it for commit messages, when the position is invalid, or when inside an event
  " handler (happens when dropping a file on gvim).
  autocmd vimrc BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Show absolute numbers in insert mode, otherwise relative line numbers.
  autocmd vimrc InsertEnter * :set number norelativenumber
  autocmd vimrc InsertLeave * :set relativenumber

  " Treat .json files as .js
  autocmd vimrc BufNewFile,BufRead *.json setl ft=json syn=javascript
  " Treat .md files as Markdown
  autocmd vimrc BufNewFile,BufRead *.md setl ft=markdown
  " Vagrantfile
  autocmd vimrc BufNewFile,BufRead Vagrantfile setl ft=ruby ts=2 sts=2 sw=2
  " Proper indentation for puppet files
  autocmd vimrc FileType puppet setl ts=2 sts=2 sw=2
  " Proper indentation for ruby files
  autocmd vimrc FileType ruby setl ts=2 sts=2 sw=2
  " Don't start new lines w/ comment leader on pressing 'o'
  autocmd vimrc Filetype * setl fo-=o
 " https://github.com/nvie/vimrc/blob/master/vimrc :489
 "  augroup python_files "{{{
 "        au!

 "        " This function detects, based on Python content, whether this is a
 "        " Django file, which may enabling snippet completion for it
 "        fun! s:DetectPythonVariant()
 "            let n = 1
 "            while n < 50 && n < line("$")
 "                " check for django
 "                if getline(n) =~ 'import\s\+\<django\>' || getline(n) =~ 'from\s\+\<django\>\s\+import'
 "                    set ft=python.django
 "                    "set syntax=python
 "                    return
 "                endif
 "                let n = n + 1
 "            endwhile
 "            " go with html
 "            set ft=python
 "        endfun
 "        autocmd BufNewFile,BufRead *.py call s:DetectPythonVariant()

 "        " PEP8 compliance (set 1 tab = 4 chars explicitly, even if set
 "        " earlier, as it is important)
 "        autocmd filetype python setlocal textwidth=78
 "        autocmd filetype python match ErrorMsg '\%>120v.\+'

 "        " But disable autowrapping as it is super annoying
 "        autocmd filetype python setlocal formatoptions-=t

 "        " Folding for Python (uses syntax/python.vim for fold definitions)
 "        "autocmd filetype python,rst setlocal nofoldenable
 "        "autocmd filetype python setlocal foldmethod=expr

 "        " Python runners
 "        autocmd filetype python noremap <buffer> <F5> :w<CR>:!python %<CR>
 "        autocmd filetype python inoremap <buffer> <F5> <Esc>:w<CR>:!python %<CR>
 "        autocmd filetype python noremap <buffer> <S-F5> :w<CR>:!ipython %<CR>
 "        autocmd filetype python inoremap <buffer> <S-F5> <Esc>:w<CR>:!ipython %<CR>

 "        " Automatic insertion of breakpoints
 "        autocmd filetype python nnoremap <buffer> <leader>bp :normal oimport pdb; pdb.set_trace()  # TODO: BREAKPOINT  # noqa<Esc>

 "        " Toggling True/False
 "        autocmd filetype python nnoremap <silent> <C-t> mmviw:s/True\\|False/\={'True':'False','False':'True'}[submatch(0)]/<CR>`m:nohlsearch<CR>

 "        " Run a quick static syntax check every time we save a Python file
 "        autocmd BufWritePost *.py call Flake8()

 "        " Defer to isort for sorting Python imports (instead of using Unix sort)
 "        autocmd filetype python nnoremap <leader>s mX:%! isort -<cr>`X
 "    augroup end " }}}
endif

" ================================== MAPPINGS ==================================

let mapleader=","               "Change leader to a comma

" Ctrl-H/J/K/L select split
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext

" TODO: not working
" Diff tab management: open the current git diff in a tab
" command! GdiffInTab tabedit %|vsplit|Gdiff
" nnoremap <leader>d :GdiffInTab<cr>

" Save a file as root (,W)
command! W w !sudo tee % > /dev/null

" Sane movement with wrap turned on
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" TODO: DEBUG
" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
"nmap <M-j> mz:m+<cr>`z
"nmap <M-k> mz:m-2<cr>`z
"vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
"vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

"if has("mac") || has("macunix")
"  nmap <D-j> <M-j>
"  nmap <D-k> <M-k>
"  vmap <D-j> <M-j>
"  vmap <D-k> <M-k>
"endif

" Strip trailing whitespace (,ss)
function! StripWhitespace()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>

" Return clears search highlight
:nnoremap <CR> :nohlsearch<cr>

" Copy and paste using system clipboard
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" Automatically jump to end of text you pasted:
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" Auto center on matched string.
noremap n nzz
noremap N Nzz

" Search using normal regexes hacked with searchindex mappings
nnoremap / :ShowSearchIndex<CR>/\v
vnoremap / :ShowSearchIndex<CR>/\v

nnoremap <silent> * *:ShowSearchIndex<CR>
vnoremap <silent> * *:ShowSearchIndex<CR>

nnoremap <silent> # #:ShowSearchIndex<CR>
vnoremap <silent> # #:ShowSearchIndex<CR>

nnoremap <silent> n n:ShowSearchIndex<CR>
vnoremap <silent> n n:ShowSearchIndex<CR>

nnoremap <silent> N N:ShowSearchIndex<CR>
vnoremap <silent> N N:ShowSearchIndex<CR>

" Visually select the text that was last edited/pasted (Vimcast#26).
noremap gV `[v`]

" Speed up scrolling of the viewport slightly
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>

" Disable arrow keys
map <Left> :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OPEN FILES IN DIRECTORY OF CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoremap <expr> %% expand('%:h').'/'
map <leader>e :edit %%
map <leader>v :view %%

" Leader leader switches between the two most recent buffers
nnoremap <leader><leader> <c-^>

" ================================== PLUGINS ===================================

" Use v to expand selection and ctrl-v to shrink
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>gf :CommandTFlush<cr>\|:CommandT %%<cr>







" ======== skwp ==========
" TODO: ,ig - toggle visual indentation guides
" TODO: Use Cmd-1 thru Cmd-9 to switch to a specific tab number (like iTerm and Chrome) - and tabs have been set up to show numbers (Alt in Linux)
" TODO: ,# ," ,' ,] ,) ,} to surround a word in these common wrappers. the # does #{ruby interpolation}. works in visual mode
let g:indexed_search_mappings = 0

let g:airline#extensions#tabline#enabled   = 1
let g:airline#extensions#syntastic#enabled = 1

let g:syntastic_puppet_checkers = ['puppetlint']
let g:syntastic_python_checkers = ['flake8']

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
