syntax on
set nu
set nowrap
set noswapfile
set nobackup
set nowritebackup
set tabstop=4
set expandtab
set autoindent
set smartindent

" So we don't have to press shift when we want to get into command mode.
nnoremap ; :
vnoremap ; :

" So we don't have to reach for escape to leave insert mode.
imap ff <Esc>
nmap ff i
