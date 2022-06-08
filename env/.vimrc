set number
syntax on
filetype plugin indent on "Включает определение типа файла, загрузку...
"... соответствующих ему плагинов и файлов отступов
set encoding=utf-8 "Ставит кодировку UTF-8
set nocompatible "Отключает обратную совместимость с Vi
syntax enable "Включает подсветку синтаксисаset backspace=indent,eol,start
if empty(glob('~/.vim/autoload/plug.vim')) "Если vim-plug не стоит
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs "Создать директорию
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('/home/arctic/.vim/autoload') "Начать искать плагины в этой директории
"Тут будут описаны наши плагины
Plug 'trevordmiller/nova-vim'
Plug 'sickill/vim-monokai'
Plug 'pearofducks/ansible-vim'
Plug 'ErichDonGubler/vim-sublime-monokai'
call plug#end() "Перестать это делать
" "colorscheme koehler 
set autoindent
inoremap ' ''<ESC>ha
inoremap " ""<ESC>ha
inoremap ` ``<ESC>ha
inoremap ( ()<ESC>ha
inoremap [ []<ESC>ha
inoremap { {}<ESC>ha
inoremap /* /** */<ESC>2ha
set t_Co=256
set history=100
colorscheme sublimemonokai
