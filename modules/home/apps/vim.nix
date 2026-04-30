{ pkgs, ... }:
{
  programs.vim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      vim-sensible
      vim-surround
      vim-commentary
      vim-fugitive
      vim-gitgutter
      fzf-vim
      nerdtree
      vim-airline
      vim-airline-themes
      ale
      vim-polyglot
    ];

    extraConfig = ''
      set nocompatible
      set encoding=utf-8
      set number
      set relativenumber
      set cursorline
      set showmatch
      set incsearch
      set hlsearch
      set ignorecase
      set smartcase
      set wrap
      set linebreak
      set scrolloff=8
      set sidescrolloff=8
      set splitbelow
      set splitright
      set hidden
      set noswapfile
      set nobackup
      set undofile
      set undodir=~/.vim/undodir
      set updatetime=300
      set signcolumn=yes
      set clipboard=unnamedplus

      set tabstop=4
      set softtabstop=4
      set shiftwidth=4
      set expandtab
      set autoindent
      set smartindent

      let mapleader = " "

      nnoremap <leader>e :NERDTreeToggle<CR>
      nnoremap <leader>f :Files<CR>
      nnoremap <leader>b :Buffers<CR>
      nnoremap <leader>/ :Rg<CR>
      nnoremap <leader>gs :Git<CR>
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <Esc> :nohlsearch<CR>

      vnoremap < <gv
      vnoremap > >gv

      autocmd BufWritePre * :%s/\s\+$//e

      let g:NERDTreeShowHidden = 1
      let g:NERDTreeMinimalUI = 1
      let g:NERDTreeAutoDeleteBuffer = 1

      let g:airline_powerline_fonts = 0
      let g:airline_symbols_ascii = 1
      let g:airline#extensions#tabline#enabled = 1
      let g:airline#extensions#tabline#fnamemod = ':t'

      let g:ale_sign_error = 'E'
      let g:ale_sign_warning = 'W'
      let g:ale_lint_on_text_changed = 'never'
      let g:ale_lint_on_insert_leave = 1
      let g:ale_fix_on_save = 1
    '';
  };

  home.file.".vim/undodir/.keep".text = "";
}
