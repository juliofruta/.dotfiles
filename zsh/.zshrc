# https://stackoverflow.com/questions/35098490/how-do-i-set-path this is to use RVM from bin and not the default one.
export PATH="$PATH:$HOME/.rvm/gems/ruby-3.2.2/bin"
export PATH="$PATH:$HOME/.rvm/bin"
export DOTFILES_PATH="$HOME/.dotfiles"
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:/opt/homebrew/opt/ruby/bin"
export PATH="$PATH:$HOME/.gem/ruby/3.2.0/bin"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Install Oh my zsh!
function installOhMyZshIfNeeded {
    if [ ! -d "$HOME/.oh-my-zsh" ] 
    then
        echo "🤖 Installing Oh My Zsh!"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# Install zsh autosuggestions
function installZSHAutosuggestionsIfNeeded {
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]
    then 
        echo "🤖 Installing Autosuggestions. "
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
}

function updateiTerm2DynamicProfiles {
    # set iterm profiles
    if cp $DOTFILES_PATH/iterm/Profiles.json $HOME/Library/Application\ Support/iTerm2/DynamicProfiles/Profiles.json 
    then
        echo ""
    else
        echo "👁 iTerm profiles could not update"
    fi
}

# Install syntax highlightning
function installSyntaxHighlighting {
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]
    then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
}

function installBrewIfNeeded {
    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

function installWorkCasksIfNeeded {
    # Install Github Desktop
    if [[ ! -d "/Applications/Github Desktop.app" ]]; then
        brew install github
    fi
    
    # Install iTerm2
    if [[ ! -d "/Applications/iTerm.app" ]]; then
        brew install iterm2
    fi
    
    # Install SourceTree
    if [[ ! -d "/Applications/Sourcetree.app" ]]; then
        brew install sourcetree
    fi
    
    # Install Visual Studio Code
    if [[ ! -d "/Applications/Visual Studio Code.app" ]]; then
        brew install visual-studio-code
    fi

    # Install Alfred
    if [[ ! -d "/Applications/Alfred 4.app" ]]; then
        brew install alfred
    fi

    # Install Rectangle
    if [[ ! -d "/Applications/Rectangle.app" ]]; then
        brew install --cask rectangle
    fi

    # Install Maccy
    if [[ ! -d "/Applications/Maccy.app" ]]; then 
        brew install --cask maccy
    fi

    # Install caffeine
    if [[ ! -d "/Applications/Caffeine.app" ]]; then 
       brew install --cask caffeine
    fi

    # Install Docker Desktop
    if [[ ! -d "/Applications/Docker.app" ]]; then 
       brew install --cask docker
    fi

    brew_install tmux
    brew install neovim
    brew_install gemini-cli

    # Install rvm
    if command -v rvm &> /dev/null; then
        echo "RVM is installed"
    else
        echo "RVM is NOT installed"
        source ~/.rvm/scripts/rvm # To fix RVM is not a function error
        gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \curl -sSL https://get.rvm.io | bash -s stable --ruby
        rvm install 3.2.2
        rvm --default use 3.2.2
    fi
}

function brew_install() {
    if ! brew list $1 &>/dev/null; then
       brew install $1
    fi
}

function install_nerdfonts {
    git clone https://github.com/Karmenzind/monaco-nerd-fonts /tmp/monaco-nerd-fonts
    mv /tmp/monaco-nerd-fonts ~/Library/Fonts/monaco-nerd-fonts
}

# Run installation
function run_install {
    installOhMyZshIfNeeded
    installZSHAutosuggestionsIfNeeded
    installSyntaxHighlighting
    linkConfigurationFiles
    install_nerdfonts

    # macOS Support
    updateiTerm2DynamicProfiles
    installBrewIfNeeded
    installWorkCasksIfNeeded
    removeAllItemsFromDock
}

function removeAllItemsFromDock {
    defaults write com.apple.dock persistent-apps -array
    killall Dock
}

function aliasvim {
    alias vim="nvim"
}

function changePrompt {
    # Load version control information
    autoload -Uz vcs_info
    precmd() { vcs_info }

    # Format the vcs_info_msg_0_ variable
    zstyle ':vcs_info:git:*' formats '%b'
 
    # Set up the prompt (with git branch name)
    setopt PROMPT_SUBST
    export PS1=' ➜ %1d ${vcs_info_msg_0_} \$ '
}

function linkConfigurationFiles {
    ln -s -f $DOTFILES_PATH/tmux/.tmux.conf $HOME/.tmux.conf #Link zsh.
    ln -s -f $DOTFILES_PATH/vim/.vimrc $HOME/.vimrc #Link vim config
    ln -s -f $DOTFILES_PATH/ash/.profile $HOME/.profile #Link ash profile 
    ln -s -f $DOTFILES_PATH/nvim $HOME/.config/nvim #Link nvim folder

    rm -rf $HOME/.zshrc
    # The plugin is already in the zsh config.
    ln -s $DOTFILES_PATH/zsh/.zshrc $HOME/.zshrc # link zshrc
}

function srcroot {
    defaults read ~/Library/Preferences/com.apple.dt.Xcode.plist NSNavLastRootDirectory
}

function openiTermBehavior {
    directory=$(srcroot)
    open -a iTerm "${directory:2}" # this drops the first to chars
}

# @description Opens and positions iTerm at the current directory,
# maintaining the current font size by using the default profile.
# The window is centered and sized to 800x600 pixels.



function mountFiles {
    # mounts detected folder into /mnt
    mount -t ios website /mnt
}

function loadVimMotions {
    # Enable vi keybindings
    bindkey -v
    export KEYTIMEOUT=1

    # Make ESC go to normal mode immediately
    bindkey -M viins 'jj' vi-cmd-mode

    # Enable visual mode
    autoload -Uz select-quoted select-bracketed
    zle -N select-quoted
    zle -N select-bracketed

    # Bind v in normal mode to start visual mode
    bindkey -M vicmd 'v' visual-mode

    # Visual mode keymap (selection + movement)
    bindkey -M visual 'y' vi-yank
    bindkey -M visual 'd' vi-delete
    bindkey -M visual 'w' vi-forward-word
    bindkey -M visual 'b' vi-backward-word
    bindkey -M visual 'e' vi-forward-word-end
    bindkey -M visual '^' vi-beginning-of-line
    bindkey -M visual '$' vi-end-of-line

    # Allow selecting quoted/bracketed text
    for m in visual vicmd; do
        bindkey -M $m '"' select-quoted
        bindkey -M $m "'" select-quoted
        bindkey -M $m '(' select-bracketed
        bindkey -M $m ')' select-bracketed
        bindkey -M $m '[' select-bracketed
        bindkey -M $m ']' select-bracketed
        bindkey -M $m '{' select-bracketed
        bindkey -M $m '}' select-bracketed
    done
}

function attachtmuxsession {
    # Auto tmux attach or create
    if command -v tmux &>/dev/null; then
        # if not in tmux and in an interactive shell
        if [[ -z "$TMUX" ]] && [[ -n "$PS1" ]]; then
            # Check if a session named 'default' already exists
            if ! tmux has-session -t default 2>/dev/null; then
                # If it doesn't exist, create it with two windows
                tmux new-session -d -s default -n 'caffeinate' 'caffeinate -dimsu'
                tmux new-window -t default: -n 'dotfiles-gemini' 'cd ~/.dotfiles && gemini'
                tmux new-window -t default:
            fi
            # Attach to the 'default' session
            tmux attach -t default
        fi
    fi
}

# source other .zshrc files in folders that have the prefix "dotfiles-"
function source_dotfiles_zshrcs() {
  cd $HOME
  echo "🧠 sourcing other .dotfiles"
  for dir in $(ls -a | grep -E '^\.dotfiles-[^/]+$'); do
    echo "$dir"
    for zshrc in $(find "$dir" -type f -name ".zshrc"); do
      source "$zshrc"
    done
  done
}

plugins=(
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

source_dotfiles_zshrcs
loadVimMotions
clear
changePrompt
aliasvim
attachtmuxsession

function resetDotfiles {
    rm -rf $HOME/.dotfiles
    wget https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer; chmod +x installer; ./installer
}

function updateDotfiles {
    rm -rf $HOME/.dotfiles
    zsh <(curl -s https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer)
}
