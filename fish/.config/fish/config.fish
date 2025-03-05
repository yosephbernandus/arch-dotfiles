starship init fish | source

function fish_user_key_bindings
    # git shorcuts
    bind \cg 'git status'

    bind \ca beginning-of-line
    bind \ce end-of-line
    bind \cp up-or-search
    bind \cn down-or-search

    # clear the terminal
    bind \cl "clear; commandline -f repaint"

    # directory navigation
    bind \ea "cd ..; commandline -f repaint"

    # history search
    bind \cr history-search-backward

    # word navigation
    bind \ef forward-word
    bind \eb backward-word

    # kill whole line
    bind \ck kill-whole-line
end


if status is-interactive
    fish_user_key_bindings

    # Environment Variables
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx TERM xterm-256color
    set -gx LANG en_US.UTF-8
    set -gx LC_ALL en_US.UTF-8
    
    # Path Configuration
    fish_add_path /usr/local/bin
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/.cargo/bin
    
    # Aliases
    alias ll='ls -la'
    alias la='ls -A'
    alias l='ls -CF'
    alias cls='clear'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias vim='nvim'
    alias vi='nvim'
    alias g='git'
    alias ga='git add'
    alias gc='git commit'
    alias gs='git status'
    alias gp='git push'
    alias gl='git pull'
    
    # Prompt Configuration - using starship if installed
    if command -q starship
        starship init fish | source
    end
    
    # Direnv integration if installed
    if command -q direnv
        direnv hook fish | source
    end
    
    # Simple greeting
    function fish_greeting
        echo "Welcome Yoseph!"
        date
    end
    
    # Set XDG Base Directory specification
    set -gx XDG_CONFIG_HOME $HOME/.config
    set -gx XDG_CACHE_HOME $HOME/.cache
    set -gx XDG_DATA_HOME $HOME/.local/share
end

