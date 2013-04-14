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
map! <D-v> *
nnoremap <silent> s :sil! call FtOpenVimsh(&ft)
map  :silent! call ImplementAbstractClass()
snoremap <silent> 	 i<Right>=TriggerSnippet()
vmap <NL> <Plug>IMAP_JumpForward
nmap <NL> <Plug>IMAP_JumpForward
snoremap  b<BS>
nnoremap <silent>  :nohlsearch
vnoremap  E :FtEvalVisual vim
vnoremap  e :FtEvalVisual
nnoremap  E :FtEvalBuffer
nnoremap  e :FtEvalLine
snoremap % b<BS>%
snoremap ' b<BS>'
map Q gq
xmap S <Plug>VSurround
snoremap U b<BS>U
vmap [% [%m'gv``
snoremap \ b<BS>\
nmap <silent> \vh :call DTEOnline()
nmap <silent> \va :call DTEAbout()
nmap <silent> \vj :call DTEGetProjects()
nmap <silent> \vs :call DTEGetSolutions()
nmap <silent> \vc :call DTECompileFile()
nmap <silent> \vu :call DTEBuildStartupProject()
nmap <silent> \vb :call DTEBuildSolution()
nmap <silent> \v2 :call DTEFindResults(2)
nmap <silent> \vf :call DTEFindResults(1)
nmap <silent> \vo :call DTEOutput()
nmap <silent> \vt :call DTETaskList()
nmap <silent> \vp :call DTEPutFile()
nmap <silent> \vg :call DTEGetFile()
nmap \caL <Plug>CalendarH
nmap \cal <Plug>CalendarV
nmap \ihn :IHN
nmap \is :IHS:A
nmap \ih :IHS
nnoremap \sj :rightbelow new
nnoremap \sk :leftabove  new
nnoremap \sl :rightbelow vnew
nnoremap \sh :leftabove  vnew
nnoremap \swj :botright new
nnoremap \swk :topleft  new
nnoremap \swl :botright vnew
nnoremap \swh :topleft  vnew
vmap ]% ]%m'gv``
snoremap ^ b<BS>^
snoremap ` b<BS>`
vmap a% [%v]%
nmap cs <Plug>Csurround
nmap ds <Plug>Dsurround
nmap gx <Plug>NetrwBrowseX
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
nmap <silent> <Plug>CalendarH :cal Calendar(1)
nmap <silent> <Plug>CalendarV :cal Calendar(0)
nnoremap <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
nnoremap <F11> :TrinityToggleNERDTree
nnoremap <F10> :TrinityToggleTagList
nnoremap <F9> :TrinityToggleSourceExplorer
nnoremap <F8> :TrinityToggleAll
nnoremap <F4> :runtime macros/vimsh.vim
nnoremap <F3> :source %
nnoremap <F2> "+gp
nnoremap <F1> K
nnoremap <Up> gk
nnoremap <Down> gj
xmap <BS> "-d
vmap <D-x> "*d
vmap <D-c> "*y
vmap <D-v> "-d"*P
nmap <D-v> "*P
cnoremap  <Home>
imap  :call CreateProperty()a
imap  bipublic abstract class A{public abstract void X();}:?X0fXs
imap 	 :call CreateProperty("int")a
imap  :call CreateProperty("string")a
cnoremap  <Del>
cnoremap  <End>
imap S <Plug>ISurround
imap s <Plug>Isurround
cnoremap  <Left>
inoremap <silent> 	 =TriggerSnippet()
imap <NL> <Plug>IMAP_JumpForward
cnoremap  <Right>
inoremap <expr>  pumvisible() ? "\\" : "\"
inoremap <silent> 	 =ShowAvailableSnips()
imap  <Plug>Isurround
inoremap  u
inoremap <expr>  omni#cpp#maycomplete#Complete()
inoremap  :set iminsert=0
inoremap "" ""<Left>
inoremap '' ''<Left>
inoremap () ()<Left>
inoremap <silent> <expr> ,t (exists('#AutoComplPopGlobalAutoCommand#InsertEnter#*')) ? "\:AutoComplPopDisable\" : "\:AutoComplPopEnable\"
inoremap <expr> . omni#cpp#maycomplete#Dot()
inoremap <expr> : omni#cpp#maycomplete#Scope()
inoremap <> <><Left>
inoremap <expr> > omni#cpp#maycomplete#Arrow()
map òc :call IntroduceConstant()
map òo :call ReorderParameters()
map òd :call RemoveParameter()
map òr :call RenameVariable()
map òp :call LocalVariableToParameter()
map òe :call ExtractMethod()
inoremap [] []<Left>
imap \ihn :IHN
imap \is :IHS:A
imap \ih :IHS
inoremap {} {}<Left>
let &cpo=s:cpo_save
unlet s:cpo_save
set ambiwidth=double
set autochdir
set autoindent
set background=dark
set backspace=indent,eol,start
set backup
set backupdir=~/.vimbackup
set browsedir=buffer
set cinoptions=:0
set cmdheight=2
set complete=.,w,b,u,t,i,k
set completefunc=ccomplete#Complete
set completeopt=menuone,menu,longest,preview
set directory=~/.vimbackup
set display=lastline
set fileencodings=iso-2022-jp-3,euc-jisx0213,cp932,guess,ucs-bom,ucs-2le,ucs-2,iso-2022-jp-3,utf-8,euc-jisx0213,euc-jp
set fileformats=unix,dos,mac
set formatexpr=Format_Japanese()
set formatoptions=tcqmM
set gdefault
set grepprg=grep\ -nH\ $*
set guifont=Osaka-Mono:h14
set guifontwide=Osaka-Mono:h12
set guitablabel=%M%t
set helplang=ja
set hidden
set history=50
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
set shortmess=filnxtToOI
set showcmd
set showmatch
set smartcase
set smartindent
set statusline=%<%f\ %m\ %r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=[0x%{GetB()}]\ (%v,%l)/%L%8P\ 
set tags=./tags,tags,~/.vim/tags/cpp,tags;
set termencoding=utf-8
set textwidth=1000
set timeoutlen=3500
set title
set virtualedit=block
set visualbell
set whichwrap=b,s,h,l,[,],<,>
set wildmenu
set window=51
set nowritebackup
" vim: set ft=vim :
