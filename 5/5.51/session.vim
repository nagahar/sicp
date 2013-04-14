let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
map! <S-Insert> <MiddleMouse>
imap <D-BS> 
imap <M-BS> 
imap <M-Down> }
inoremap <D-Down> <C-End>
imap <M-Up> {
inoremap <D-Up> <C-Home>
noremap! <M-Right> <C-Right>
noremap! <D-Right> <End>
noremap! <M-Left> <C-Left>
noremap! <D-Left> <Home>
inoremap <silent> <S-Tab> =BackwardsSnippet()
imap <silent> <Plug>IMAP_JumpBack =IMAP_Jumpfunc('b', 0)
imap <silent> <Plug>IMAP_JumpForward =IMAP_Jumpfunc('', 0)
inoremap <silent> <Plug>NERDCommenterInInsert  <BS>:call NERDComment(0, "insert")
map! <D-v> *
nnoremap <silent> s :sil! call FtOpenVimsh(&ft)
map  :call CCommentWriter()
snoremap <silent> 	 i<Right>=TriggerSnippet()
vmap <NL> <Plug>IMAP_JumpForward
nmap <NL> <Plug>IMAP_JumpForward
snoremap  b<BS>
nnoremap <silent>  :nohlsearch
snoremap % b<BS>%
snoremap ' b<BS>'
nmap ,j vip=
nmap <silent> ,vh :call DTEOnline()
nmap <silent> ,va :call DTEAbout()
nmap <silent> ,vj :call DTEGetProjects()
nmap <silent> ,vs :call DTEGetSolutions()
nmap <silent> ,vc :call DTECompileFile()
nmap <silent> ,vu :call DTEBuildStartupProject()
nmap <silent> ,vb :call DTEBuildSolution()
nmap <silent> ,v2 :call DTEFindResults(2)
nmap <silent> ,vf :call DTEFindResults(1)
nmap <silent> ,vo :call DTEOutput()
nmap <silent> ,vt :call DTETaskList()
nmap <silent> ,vp :call DTEPutFile()
nmap <silent> ,vg :call DTEGetFile()
map ,r <Plug>(quickrun)
nmap ,l <Plug>(quicklaunch-list)
nmap ,9 <Plug>(quicklaunch-9)
nmap ,8 <Plug>(quicklaunch-8)
nmap ,7 <Plug>(quicklaunch-7)
nmap ,6 <Plug>(quicklaunch-6)
nmap ,5 <Plug>(quicklaunch-5)
nmap ,4 <Plug>(quicklaunch-4)
nmap ,3 <Plug>(quicklaunch-3)
nmap ,2 <Plug>(quicklaunch-2)
nmap ,1 <Plug>(quicklaunch-1)
nmap ,0 <Plug>(quicklaunch-0)
nmap ,caL <Plug>CalendarH
nmap ,cal <Plug>CalendarV
nmap ,ihn :IHN
nmap ,is :IHS:A
nmap ,ih :IHS
nmap ,ca <Plug>NERDCommenterAltDelims
vmap ,cA <Plug>NERDCommenterAppend
nmap ,cA <Plug>NERDCommenterAppend
vmap ,c$ <Plug>NERDCommenterToEOL
nmap ,c$ <Plug>NERDCommenterToEOL
vmap ,cu <Plug>NERDCommenterUncomment
nmap ,cu <Plug>NERDCommenterUncomment
vmap ,cn <Plug>NERDCommenterNest
nmap ,cn <Plug>NERDCommenterNest
vmap ,cb <Plug>NERDCommenterAlignBoth
nmap ,cb <Plug>NERDCommenterAlignBoth
vmap ,cl <Plug>NERDCommenterAlignLeft
nmap ,cl <Plug>NERDCommenterAlignLeft
vmap ,cy <Plug>NERDCommenterYank
nmap ,cy <Plug>NERDCommenterYank
vmap ,ci <Plug>NERDCommenterInvert
nmap ,ci <Plug>NERDCommenterInvert
vmap ,cs <Plug>NERDCommenterSexy
nmap ,cs <Plug>NERDCommenterSexy
vmap ,cm <Plug>NERDCommenterMinimal
nmap ,cm <Plug>NERDCommenterMinimal
vmap ,c  <Plug>NERDCommenterToggle
nmap ,c  <Plug>NERDCommenterToggle
vmap ,cc <Plug>NERDCommenterComment
nmap ,cc <Plug>NERDCommenterComment
map ,rwp <Plug>RestoreWinPosn
map ,swp <Plug>SaveWinPosn
map ,tt <Plug>AM_tt
map ,tsq <Plug>AM_tsq
map ,tsp <Plug>AM_tsp
map ,tml <Plug>AM_tml
map ,tab <Plug>AM_tab
map ,m= <Plug>AM_m=
map ,t@ <Plug>AM_t@
map ,t~ <Plug>AM_t~
map ,t? <Plug>AM_t?
map ,w= <Plug>AM_w=
map ,ts= <Plug>AM_ts=
map ,ts< <Plug>AM_ts<
map ,ts; <Plug>AM_ts;
map ,ts: <Plug>AM_ts:
map ,ts, <Plug>AM_ts,
map ,t= <Plug>AM_t=
map ,t< <Plug>AM_t<
map ,t; <Plug>AM_t;
map ,t: <Plug>AM_t:
map ,t, <Plug>AM_t,
map ,t# <Plug>AM_t#
map ,t| <Plug>AM_t|
map ,T~ <Plug>AM_T~
map ,Tsp <Plug>AM_Tsp
map ,Tab <Plug>AM_Tab
map ,T@ <Plug>AM_T@
map ,T? <Plug>AM_T?
map ,T= <Plug>AM_T=
map ,T< <Plug>AM_T<
map ,T; <Plug>AM_T;
map ,T: <Plug>AM_T:
map ,Ts, <Plug>AM_Ts,
map ,T, <Plug>AM_T,o
map ,T# <Plug>AM_T#
map ,T| <Plug>AM_T|
map ,Htd <Plug>AM_Htd
map ,anum <Plug>AM_aunum
map ,aunum <Plug>AM_aenum
map ,afnc <Plug>AM_afnc
map ,adef <Plug>AM_adef
map ,adec <Plug>AM_adec
map ,ascom <Plug>AM_ascom
map ,aocom <Plug>AM_aocom
map ,adcom <Plug>AM_adcom
map ,acom <Plug>AM_acom
map ,abox <Plug>AM_abox
map ,a( <Plug>AM_a(
map ,a= <Plug>AM_a=
map ,a< <Plug>AM_a<
map ,a, <Plug>AM_a,
map ,a? <Plug>AM_a?
nnoremap <silent> ,s :Utl ol www.google.com/search?q=/
nnoremap <silent> ,u :Utl
nnoremap <silent> ,ev :e $MYVIMRC
nnoremap ,sj :rightbelow new
nnoremap ,sk :leftabove  new
nnoremap ,sl :rightbelow vnew
nnoremap ,sh :leftabove  vnew
nnoremap ,swj :botright new
nnoremap ,swk :topleft  new
nnoremap ,swl :botright vnew
nnoremap ,swh :topleft  vnew
nnoremap ,f :cnext
nnoremap ,b :cprevious
map ,c :call IntroduceConstant()
map ,o :call ReorderParameters()
map ,d :call RemoveParameter()
map ,r :call RenameVariable()
map ,p :call LocalVariableToParameter()
map ,e :call ExtractMethod()
snoremap ; :
nnoremap == gg=G2
imap ð :call SearchInvalidComment(1)a
imap î :call SearchInvalidComment(0)a
imap ã :call CCommentWriter()
nnoremap <silent> H :ConqueTermVSplit zsh
vnoremap Q gq
nnoremap Q gqaq
omap Q gq
xmap S <Plug>VSurround
snoremap U b<BS>U
vmap [% [%m'gv``
nmap \pt :call PreviewWord()
snoremap \ b<BS>\
vmap ]% ]%m'gv``
snoremap ^ b<BS>^
snoremap ` b<BS>`
vmap a% [%v]%
nmap cs <Plug>Csurround
nmap ds <Plug>Dsurround
nmap gx <Plug>NetrwBrowseX
xmap gS <Plug>VgSurround
vnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zcgv' : 'h'
nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
nnoremap j gj
nnoremap k gk
vnoremap <expr> l foldclosed(line('.')) != -1 ? 'zogv0' : 'l'
nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo0' : 'l'
xmap s <Plug>Vsurround
nmap ySS <Plug>YSsurround
nmap ySs <Plug>YSsurround
nmap yss <Plug>Yssurround
nmap yS <Plug>YSurround
nmap ys <Plug>Ysurround
map <S-Insert> <MiddleMouse>
map <M-Down> }
noremap <D-Down> <C-End>
map <M-Up> {
noremap <D-Up> <C-Home>
noremap <M-Right> <C-Right>
noremap <D-Right> <End>
noremap <M-Left> <C-Left>
noremap <D-Left> <Home>
snoremap <Left> bi
snoremap <Right> a
snoremap <BS> b<BS>
snoremap <silent> <S-Tab> i<Right>=BackwardsSnippet()
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
vmap <silent> <Plug>IMAP_JumpBack `<i=IMAP_Jumpfunc('b', 0)
vmap <silent> <Plug>IMAP_JumpForward i=IMAP_Jumpfunc('', 0)
vmap <silent> <Plug>IMAP_DeleteAndJumpBack "_<Del>i=IMAP_Jumpfunc('b', 0)
vmap <silent> <Plug>IMAP_DeleteAndJumpForward "_<Del>i=IMAP_Jumpfunc('', 0)
nmap <silent> <Plug>IMAP_JumpBack i=IMAP_Jumpfunc('b', 0)
nmap <silent> <Plug>IMAP_JumpForward i=IMAP_Jumpfunc('', 0)
vnoremap <silent> <Plug>(quickrun) :QuickRun -mode v
nnoremap <silent> <Plug>(quickrun) :QuickRun -mode n
nnoremap <silent> <Plug>(quickrun-op) :set operatorfunc=QuickRung@
nnoremap <silent> <Plug>CalendarH :cal Calendar(1)
nnoremap <silent> <Plug>CalendarV :cal Calendar(0)
nmap <silent> <Plug>NERDCommenterAppend :call NERDComment(0, "append")
nnoremap <silent> <Plug>NERDCommenterToEOL :call NERDComment(0, "toEOL")
vnoremap <silent> <Plug>NERDCommenterUncomment :call NERDComment(1, "uncomment")
nnoremap <silent> <Plug>NERDCommenterUncomment :call NERDComment(0, "uncomment")
vnoremap <silent> <Plug>NERDCommenterNest :call NERDComment(1, "nested")
nnoremap <silent> <Plug>NERDCommenterNest :call NERDComment(0, "nested")
vnoremap <silent> <Plug>NERDCommenterAlignBoth :call NERDComment(1, "alignBoth")
nnoremap <silent> <Plug>NERDCommenterAlignBoth :call NERDComment(0, "alignBoth")
vnoremap <silent> <Plug>NERDCommenterAlignLeft :call NERDComment(1, "alignLeft")
nnoremap <silent> <Plug>NERDCommenterAlignLeft :call NERDComment(0, "alignLeft")
vmap <silent> <Plug>NERDCommenterYank :call NERDComment(1, "yank")
nmap <silent> <Plug>NERDCommenterYank :call NERDComment(0, "yank")
vnoremap <silent> <Plug>NERDCommenterInvert :call NERDComment(1, "invert")
nnoremap <silent> <Plug>NERDCommenterInvert :call NERDComment(0, "invert")
vnoremap <silent> <Plug>NERDCommenterSexy :call NERDComment(1, "sexy")
nnoremap <silent> <Plug>NERDCommenterSexy :call NERDComment(0, "sexy")
vnoremap <silent> <Plug>NERDCommenterMinimal :call NERDComment(1, "minimal")
nnoremap <silent> <Plug>NERDCommenterMinimal :call NERDComment(0, "minimal")
vnoremap <silent> <Plug>NERDCommenterToggle :call NERDComment(1, "toggle")
nnoremap <silent> <Plug>NERDCommenterToggle :call NERDComment(0, "toggle")
vnoremap <silent> <Plug>NERDCommenterComment :call NERDComment(1, "norm")
nnoremap <silent> <Plug>NERDCommenterComment :call NERDComment(0, "norm")
nmap <silent> <Plug>RestoreWinPosn :call RestoreWinPosn()
nmap <silent> <Plug>SaveWinPosn :call SaveWinPosn()
nmap <SNR>18_WE <Plug>AlignMapsWrapperEnd
map <SNR>18_WS <Plug>AlignMapsWrapperStart
nnoremap <SNR>14_(command-line-norange) q:
xnoremap <SNR>14_(command-line-enter) q:
nnoremap <SNR>14_(command-line-enter) q:
nnoremap <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
nnoremap <F12> :TrinityToggleAll
nnoremap <F11> :TrinityToggleTagList
nnoremap <F10> :TrinityToggleSourceExplorer
nnoremap <F4> :runtime macros/vimsh.vim
nnoremap <F3> :source %
nnoremap <F2> :TrinityToggleNERDTree
nnoremap <F1> K
nnoremap <Up> gk
nnoremap <Down> gj
xmap <BS> "-d
vmap <D-x> "*d
vmap <D-c> "*y
vmap <D-v> "-d"*P
nmap <D-v> "*P
cnoremap  <Home>
cnoremap  <Del>
cnoremap  <End>
imap S <Plug>ISurround
imap s <Plug>Isurround
cnoremap  <Left>
inoremap <silent> 	 =TriggerSnippet()
imap <NL> <Plug>IMAP_JumpForward
cnoremap <NL> <Nop>
cnoremap  <Right>
inoremap <expr>  pumvisible() ? "\\" : "\"
inoremap <silent> 	 =ShowAvailableSnips()
imap  <Plug>Isurround
inoremap  u
inoremap <expr>  omni#cpp#maycomplete#Complete()
inoremap "" ""<Left>
inoremap '' ''<Left>
inoremap () ()<Left>
imap ,ihn :IHN
imap ,is :IHS:A
imap ,ih :IHS
inoremap <silent> <expr> ,t (exists('#AutoComplPopGlobalAutoCommand#InsertEnter#*')) ? "\:AutoComplPopDisable\" : "\:AutoComplPopEnable\"
inoremap <expr> . omni#cpp#maycomplete#Dot()
inoremap <expr> : omni#cpp#maycomplete#Scope()
inoremap <> <><Left>
inoremap <expr> > omni#cpp#maycomplete#Arrow()
map ð :call SearchInvalidComment(1)
map î :call SearchInvalidComment(0)
map ã :call CCommentWriter()
map òc :call IntroduceConstant()
map òo :call ReorderParameters()
map òd :call RemoveParameter()
map òr :call RenameVariable()
map òp :call LocalVariableToParameter()
map òe :call ExtractMethod()
inoremap [] []<Left>
cnoremap w!! w !sudo tee % >/dev/null
inoremap {} {}<Left>
iabbr }- }h%?\w:nohl:call CCommentWriter()
abbr #d #define
abbr #i #include
let &cpo=s:cpo_save
unlet s:cpo_save
set ambiwidth=double
set autochdir
set autoindent
set background=dark
set backspace=indent,eol,start
set browsedir=buffer
set cinoptions=:0l1t0g0
set cmdheight=2
set complete=.,w,b,u,t,i,k
set completefunc=ccomplete#Complete
set completeopt=menuone,menu,longest,preview
set display=lastline
set fileencodings=iso-2022-jp-3,euc-jisx0213,cp932,guess,ucs-bom,ucs-2le,ucs-2,iso-2022-jp-3,utf-8,euc-jisx0213,euc-jp
set fileformats=unix,dos,mac
set formatexpr=Format_Japanese()
set formatoptions=tcqlron
set gdefault
set grepprg=grep\ -nH\ $*
set guifont=Osaka-Mono:h14
set guifontwide=Osaka-Mono:h12
set guitablabel=%M%t
set helplang=ja
set hidden
set history=1000
set hlsearch
set noimdisable
set iminsert=0
set imsearch=0
set incsearch
set langmenu=menu_ja_jp.utf-8.vim
set laststatus=2
set lazyredraw
set linespace=1
set lispwords=lambda,and,or,if,cond,case,define,let,let*,letrec,begin,do,delay,set!,else,=>,quote,quasiquote,unquote,unquote-splicing,define-syntax,let-syntax,letrec-syntax,syntax-rules,%macroexpand,%macroexpand-1,and-let*,current-module,define-class,define-constant,define-generic,define-in-module,define-inline,define-macro,define-method,define-module,eval-when,export,export-all,extend,import,lazy,receive,select-module,unless,when,with-module,$,$*,%do-ec,%ec-guarded-do-ec,%first-ec,%guard-rec,%replace-keywords,--,^,^*,^.,^_,add-load-path,any?-ec,append-ec,apropos,assert,autoload,begin0,case-lambda,check-arg,cond-expand,cond-list,condition,cut,cute,debug-print,dec!,declare,define-cgen-literal,define-cise-expr,define-cise-macro,define-cise-stmt,define-condition-type,define-record-type,define-values,defmacro,do-ec,do-ec:do,dolist,dotimes,ec-guarded-do-ec,ec-simplify,every?-ec,export-if-defined,first-ec,fluid-let,fold-ec,fold3-ec,get-keyword*,get-optional,guard,if-let1,inc!,inline-stub,last-ec,let*-values,let-args,let-keywords,let-keywords*,let-optionals*,let-string-start+end,let-values,let/cc,let1,list-ec,make-option-parser,match,match-define,match-lambda,match-lambda*,match-let,match-let*,match-let1,match-letrec,max-ec,min-ec,parameterize,parse-options,pop!,product-ec,program,push!,rec,require,require-extension,rlet1,rxmatch-case,rxmatch-cond,rxmatch-if,rxmatch-let,set!-values,srfi-42-,srfi-42-char-range,srfi-42-dispatched,srfi-42-do,srfi-42-generator-proc,srfi-42-integers,srfi-42-let,srfi-42-list,srfi-42-parallel,srfi-42-parallel-1,srfi-42-port,srfi-42-range,srfi-42-real-range,srfi-42-string,srfi-42-until,srfi-42-until-1,srfi-42-vector,srfi-42-while,srfi-42-while-1,srfi-42-while-2,ssax:make-elem-parser,ssax:make-parser,ssax:make-pi-parser,stream-cons,stream-delay,string-append-ec,string-ec,sum-ec,sxml:find-name-separator,syntax-error,syntax-errorf,test*,time,until,unwind-protect,update!,use,use-version,values-ref,vector-ec,vector-of-length-ec,while,with-builder,with-iterator,with-signal-handlers,with-time-counter,xmac,xmac1
set listchars=tab:^\ ,trail:~
set matchtime=1
set mouse=a
set nrformats=hex
set omnifunc=omni#cpp#complete#Main
set patchexpr=MyPatch()
set printexpr=system('open\ -a\ Preview\ '.v:fname_in)\ +\ v:shell_error
set ruler
set runtimepath=~/.vim,~/.vim/bundle/Align,~/.vim/bundle/NERD_commenter,~/.vim/bundle/NERD_tree,~/.vim/bundle/a,~/.vim/bundle/actionscript,~/.vim/bundle/calendar,~/.vim/bundle/ccodingstyle,~/.vim/bundle/changelog,~/.vim/bundle/conque,~/.vim/bundle/easytags,~/.vim/bundle/gauche,~/.vim/bundle/html_snip_helper,~/.vim/bundle/matchit,~/.vim/bundle/omnicppcomplete,~/.vim/bundle/quickrun,~/.vim/bundle/refactor,~/.vim/bundle/snipMate,~/.vim/bundle/srcexpl,~/.vim/bundle/surround,~/.vim/bundle/switch_style,~/.vim/bundle/tabbi,~/.vim/bundle/taglist,~/.vim/bundle/tex,~/.vim/bundle/trinity,~/.vim/bundle/utl,~/.vim/bundle/vim-autocomplpop,~/.vim/bundle/vim-latex,~/.vim/bundle/vimdoc_ja,~/.vim/bundle/vimsh,~/.vim/bundle/visual_studio,~/.vim/bundle/xxd,/Applications/MacPorts/MacVim.app/Contents/Resources/vim/vimfiles,/Applications/MacPorts/MacVim.app/Contents/Resources/vim/runtime,/Applications/MacPorts/MacVim.app/Contents/Resources/vim/vimfiles/after,~/.vim/bundle/changelog/after,~/.vim/bundle/omnicppcomplete/after,~/.vim/bundle/snipMate/
set shiftround
set shortmess=filnxtToOI
set showcmd
set showmatch
set smartcase
set smartindent
set statusline=%<%f\ %m\ %r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=[0x%{GetB()}]\ (%v,%l)/%L%8P\ 
set noswapfile
set tags=~/.vimtags,./tags,tags,~/.vim/tags/cpp,tags;
set termencoding=utf-8
set timeoutlen=3500
set title
set virtualedit=block
set visualbell
set whichwrap=b,s,h,l,[,],<,>
set wildmenu
set window=49
set nowritebackup
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +24 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/eval.c
badd +170 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/exp.c
badd +285 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/env.c
badd +8 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/util.h
badd +7 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/env.h
badd +57 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/exp.h
badd +42 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/main.c
badd +249 ~/Dropbox/Documents/sandbox/scheme/sicp/metacircular.scm
badd +1 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/add_pair
badd +1 ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/dup_pair
badd +78 ~/Dropbox/Documents/sandbox/scheme/sicp/explicit-control_evaluator.scm
badd +228 ~/Dropbox/Documents/sandbox/scheme/sicp/simulator.scm
args env.c
edit ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/exp.c
set splitbelow splitright
wincmd _ | wincmd |
vsplit
wincmd _ | wincmd |
vsplit
2wincmd h
wincmd w
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
exe 'vert 1resize ' . ((&columns * 60 + 91) / 182)
exe 'vert 2resize ' . ((&columns * 60 + 91) / 182)
exe '3resize ' . ((&lines * 23 + 25) / 50)
exe 'vert 3resize ' . ((&columns * 60 + 91) / 182)
exe '4resize ' . ((&lines * 23 + 25) / 50)
exe 'vert 4resize ' . ((&columns * 60 + 91) / 182)
argglobal
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=:0l1t0g0
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i,k
setlocal conceallevel=0
setlocal completefunc=ccomplete#Complete
setlocal nocopyindent
setlocal cryptmethod=0
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != 'c'
setlocal filetype=c
endif
set foldcolumn=4
setlocal foldcolumn=4
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
set foldmethod=syntax
setlocal foldmethod=syntax
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=Format_Japanese()
setlocal formatoptions=ncroql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
set list
setlocal list
setlocal nomacmeta
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal nomigemo
setlocal modeline
setlocal modifiable
setlocal nrformats=hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=ccomplete#Complete
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=8
setlocal noshortname
setlocal smartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'c'
setlocal syntax=c
endif
setlocal tabstop=8
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
102
normal zo
103
normal zo
105
normal zo
129
normal zo
138
normal zo
142
normal zo
138
normal zo
159
normal zo
168
normal zo
172
normal zo
168
normal zo
189
normal zo
193
normal zo
189
normal zo
206
normal zo
212
normal zo
213
normal zo
212
normal zo
226
normal zo
232
normal zo
238
normal zo
244
normal zo
251
normal zo
105
normal zo
103
normal zo
102
normal zo
131
normal zo
140
normal zo
144
normal zo
140
normal zo
160
normal zo
164
normal zo
160
normal zo
181
normal zo
185
normal zo
181
normal zo
198
normal zo
204
normal zo
205
normal zo
204
normal zo
218
normal zo
224
normal zo
230
normal zo
237
normal zo
230
normal zo
237
normal zo
let s:l = 228 - ((14 * winheight(0) + 23) / 47)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
228
normal! 0
wincmd w
argglobal
edit ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/exp.h
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=:0l1t0g0
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i,k
setlocal conceallevel=0
setlocal completefunc=ccomplete#Complete
setlocal nocopyindent
setlocal cryptmethod=0
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != 'cpp'
setlocal filetype=cpp
endif
set foldcolumn=4
setlocal foldcolumn=4
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
set foldmethod=syntax
setlocal foldmethod=syntax
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=Format_Japanese()
setlocal formatoptions=ncroql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
set list
setlocal list
setlocal nomacmeta
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal nomigemo
setlocal modeline
setlocal modifiable
setlocal nrformats=hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=omni#cpp#complete#Main
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=8
setlocal noshortname
setlocal smartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'cpp'
setlocal syntax=cpp
endif
setlocal tabstop=8
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
11
normal zo
18
normal zo
23
normal zo
25
normal zo
23
normal zo
31
normal zo
36
normal zo
38
normal zo
36
normal zo
56
normal zo
70
normal zo
let s:l = 16 - ((0 * winheight(0) + 23) / 47)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
16
normal! 01l
wincmd w
argglobal
edit ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/env.c
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=:0l1t0g0
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i,k
setlocal conceallevel=0
setlocal completefunc=ccomplete#Complete
setlocal nocopyindent
setlocal cryptmethod=0
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != 'c'
setlocal filetype=c
endif
set foldcolumn=4
setlocal foldcolumn=4
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
set foldmethod=syntax
setlocal foldmethod=syntax
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=Format_Japanese()
setlocal formatoptions=ncroql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
set list
setlocal list
setlocal nomacmeta
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal nomigemo
setlocal modeline
setlocal modifiable
setlocal nrformats=hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=ccomplete#Complete
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=8
setlocal noshortname
setlocal smartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'c'
setlocal syntax=c
endif
setlocal tabstop=8
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
120
normal zo
164
normal zo
277
normal zo
280
normal zo
290
normal zo
292
normal zo
298
normal zo
290
normal zo
313
normal zo
319
normal zo
325
normal zo
331
normal zo
332
normal zo
331
normal zo
341
normal zo
347
normal zo
353
normal zo
359
normal zo
365
normal zo
277
normal zo
290
normal zo
292
normal zo
298
normal zo
290
normal zo
313
normal zo
319
normal zo
325
normal zo
331
normal zo
332
normal zo
331
normal zo
341
normal zo
347
normal zo
353
normal zo
359
normal zo
365
normal zo
let s:l = 289 - ((39 * winheight(0) + 11) / 23)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
289
normal! 019l
wincmd w
argglobal
edit ~/Dropbox/Documents/sandbox/scheme/sicp/5/5.51/eval.c
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=:0l1t0g0
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i,k
setlocal conceallevel=0
setlocal completefunc=ccomplete#Complete
setlocal nocopyindent
setlocal cryptmethod=0
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != 'c'
setlocal filetype=c
endif
set foldcolumn=4
setlocal foldcolumn=4
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
set foldmethod=syntax
setlocal foldmethod=syntax
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=Format_Japanese()
setlocal formatoptions=ncroql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
set list
setlocal list
setlocal nomacmeta
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal nomigemo
setlocal modeline
setlocal modifiable
setlocal nrformats=hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=ccomplete#Complete
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=8
setlocal noshortname
setlocal smartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'c'
setlocal syntax=c
endif
setlocal tabstop=8
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
25
normal zo
27
normal zo
25
normal zo
44
normal zc
55
normal zo
61
normal zo
72
normal zo
74
normal zo
72
normal zo
95
normal zo
100
normal zo
100
normal zo
let s:l = 96 - ((15 * winheight(0) + 11) / 23)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
96
normal! 048l
wincmd w
3wincmd w
exe 'vert 1resize ' . ((&columns * 60 + 91) / 182)
exe 'vert 2resize ' . ((&columns * 60 + 91) / 182)
exe '3resize ' . ((&lines * 23 + 25) / 50)
exe 'vert 3resize ' . ((&columns * 60 + 91) / 182)
exe '4resize ' . ((&lines * 23 + 25) / 50)
exe 'vert 4resize ' . ((&columns * 60 + 91) / 182)
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOI
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
