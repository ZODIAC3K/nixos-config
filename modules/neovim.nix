{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    vimPlugins.telescope-nvim
    vimPlugins.nvim-treesitter
    vimPlugins.cmp-nvim-lsp
    vimPlugins.which-key-nvim
    vimPlugins.gitsigns-nvim
    vimPlugins.tokyonight-nvim
  ];

  # Simple config written directly to ~/.config/nvim/init.vim for all users
  environment.etc."nvim/init.vim".text = ''
    set number
    set relativenumber
    set termguicolors
    colorscheme tokyonight

    nnoremap <leader>ff <cmd>Telescope find_files<CR>
    nnoremap <leader>fg <cmd>Telescope live_grep<CR>
  '';
}
