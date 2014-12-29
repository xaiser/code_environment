set encoding=utf-8
set guifont=Consolas\ for\ Powerline\ FixedD:h12
"set guifont=Source\ Code\ Pro\ Medium:h12
"set guifont=Sauce\ Code\ Powerline:h12
set termencoding=utf-8
language messages zh_TW.utf-8

" make gvim on window encode menu right
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
behave mswin

"------------------------------------------------------------------------------
"Global var
"------------------------------------------------------------------------------
let g:dir = getcwd()
if ( has("win32") || has("win16") || has("win64") || has("win16") )
	let g:iswindows=1
else
	let g:iswindows=0
endif

"------------------------------------------------------------------------------
"mapping
"------------------------------------------------------------------------------

" open NERDTree
map <C-n> :NERDTreeToggle<CR>

" open taglist
map <C-l> :TlistToggle<CR>

" move between split by tab
nmap <tab> <C-w>w


"------------------------------------------------------------------------------------
"Install Vundle automatically
"------------------------------------------------------------------------------------
let iCanHazVundle=1
if (g:iswindows!=1)
	let vundle_readme=expand('~/.vim/bundle/Vundle/README.md')
else
	let vundle_readme=expand('$HOME/vimfiles/bundle/Vundle/README.md')
endif

if !filereadable(vundle_readme)
	echo "Installing Vundle.."
	echo ""
	if (g:iswindows!=1)
		silent !mkdir -p ~/.vim/bundle
		silent !git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle
	else
		silent !mkdir \%HOME\%\vimfiles\bundle
		silent !git clone https://github.com/gmarik/Vundle.vim.git \%HOME\%\vimfiles\bundle\Vundle
	endif

	let iCanHazVundle=0
endif

"------------------------------------------------------------------------------------
"Vundle setting
"------------------------------------------------------------------------------------
set nocompatible " be iMproved
filetype off " required!

" set the runtime path to include Vundle and initialize
if (g:iswindows==1)
	set rtp+=%HOME%/vimfiles/bundle/Vundle
	let path='$HOME/vimfiles/bundle'
	call vundle#begin(path)
else
	set rtp+=~/.vim/bundle/Vundle
	call vundle#begin()
endif

Plugin 'gmarik/Vundle.vim'
Plugin 'Lokaltog/vim-powerline'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'taglist.vim'
Plugin 'vim-scripts/omnicppcomplete'
Plugin 'a.vim'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'gregsexton/gitv'

call vundle#end() " required
filetype plugin indent on " required


"------------------------------------------------------------------------------
"Vim-powerline setting
"------------------------------------------------------------------------------
set laststatus=2
set t_Co=256
set encoding=utf-8
let g:Powerline_symbols="fancy"

"------------------------------------------------------------------------------
"Taglist setting
"------------------------------------------------------------------------------
let Tlist_Exit_OnlyWindow=1 " close vim when the taglist is the only window
let Tlist_Use_Right_Window=1 " open taglist at right hand
let Tlist_WinWidth=30 " the width of taglist

"------------------------------------------------------------------------------
"Cscope setting
"------------------------------------------------------------------------------
if has("cscope")
	" use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
	set cscopetag
	" check cscope for definition of a symbol before
	"checking ctags: set to 1
	" if you want the reverse search order.
	set csto=0
	"add any cscope database in current
	"directory
	if filereadable("cscope.out")
		cs add cscope.out  
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif

	" show msg when any other cscope db added
	set cscopeverbose  

	nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>	
	nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>	
	nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>	
	nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>	
	nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>	
	nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>	
	nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
	map <F12> :call Do_CsTag()<CR>
endif


function Do_CsTag()
	let dir = getcwd()

	if filereadable("tags")
		if(g:iswindows==1)
			let tagsdeleted=delete(dir."\\"."tags")
		else
			let tagsdeleted=delete("./"."tags")
		endif
		if(tagsdeleted!=0)
			echohl WarningMsg | echo "Fail to do tags! I cannot delete the tags" | echohl None
			return
		endif
	endif

	if has("cscope")
		silent! execute "cs kill -1"
	endif
	if filereadable("./cscope.files")
		if(g:iswindows==1)
			let csfilesdeleted=delete(dir."\\"."cscope.files")
		else
			let csfilesdeleted=delete("./"."cscope.files")
		endif
		if(csfilesdeleted!=0)
			echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.files" | echohl None
			return
		endif
	endif
	if filereadable("cscope.out")
		if(g:iswindows==1)
			let csoutdeleted=delete(dir."\\"."cscope.out")
		else
			let csoutdeleted=delete("./"."cscope.out")
		endif
		if(csoutdeleted!=0)
			echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.out" | echohl None
			return
		endif
	endif
	if(executable('ctags'))
		"silent! execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q ."
		silent! execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q"
	endif
	if(executable('cscope') && has("cscope") )
		if(g:iswindows!=1)
			silent! execute "!find . -name '*.h' -o -name '*.c' -o -name '*.cpp' -o -name '*.java' -o -name '*.cs' > cscope.files"
		else
			silent! execute "!dir /s/b *.c,*.cpp,*.h,*.java,*.cs >> cscope.files"
		endif
		silent! execute "!cscope -Rbq"
		execute "normal :"
		if filereadable("cscope.out")

			" silent make screen black, force reflash screen
			execute ":redraw!"

			execute "cs add cscope.out ."
		endif
	endif
endfunction

"------------------------------------------------------------------------------
"General setting
"------------------------------------------------------------------------------
filetype off
syntax on
filetype on
filetype indent on
filetype plugin on

set autoindent
set shiftwidth=4
set tabstop=4

" tell vim not to generate ~ file
set nobackup

if(g:iswindows==1)
	colorscheme spring
endif


"------------------------------------------------------------------------------
"CompleteOpt
"------------------------------------------------------------------------------
set completeopt=menuone,menu,longest

if(g:iswindows==1)
	set tags+=%HOME%/vimfiles/tags/cpp
else
	set tags+=~/.vim/tags/cpp
endif

let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
"let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
" automatically open and close the popup menu / preview window
" au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
" set completeopt=menuone,menu,longest,preview

"------------------------------------------------------------------------------
"Ultisnips
"------------------------------------------------------------------------------
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-f>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
let g:UltiSnipsEditSplit="vertical"
