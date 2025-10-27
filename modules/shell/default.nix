{
  # ===========================================================
  # ⚙️ Shell (bash) customizations
  # ===========================================================
  programs.bash = {
    enable = true;   # use Bash as shell
    initExtra = ''
      # "root" helper command:
      # - If you run `root code file`, it opens VSCode as root
      # - If you run `root apt install xyz`, it just runs `sudo apt install xyz`
      root() {
        if [ "$1" = "code" ]; then
          shift
          root-code "$@"
        else
          sudo "$@"
        fi
      }
    '';
  };

  # Default text editors for the system
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}

