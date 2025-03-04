# https://stackoverflow.com/questions/35098490/how-do-i-set-path this is to use RVM from bin and not the default one.
export PATH="$PATH:$HOME/.rvm/gems/ruby-3.2.2/bin"
export PATH="$PATH:$HOME/.rvm/bin"
export DOTFILES_PATH="$HOME/.dotfiles"
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:/opt/homebrew/opt/ruby/bin"
export PATH="$PATH:$HOME/.gem/ruby/3.2.0/bin"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Takes all the PR titles between commitA and commitB and prints them on the stdout requires github cli to be installed.
# $1 - Github org
# $2 - Github repo
# $3 - CommitA
# $4 - CommitB
function prtitles { 
    git log --oneline $3...$4 | ggrep -oP '#\K[0-9]*' | xargs -I _ sh -c "gh pr view _ --repo $1/$2 | head -n 1" 
}

# Review a PR -- consider that this will get rid of all your current changes. and stash them.
function review {
    git add .; git stash; git add .; git reset --hard; git checkout $1; git pull; git checkout main; git pull; git checkout -b review; git merge $1; git reset --soft origin/main;
}

# Cleans the development branch positioning yourself in the develeopment branch
function reviewClean {
    git add .; git reset --hard; git checkout main; git branch -D review;
}

# code-freeze release/version development
function codeFreeze {
    git add .;
    git reset --hard; 
    git checkout release-candidate; 
    git checkout -b $1
    git merge -X theirs $2 --no-commit;
    git diff --no-color $1 $2 | git apply;
    git add .;
    git merge --continue;
    git diff $1 $2;
    git diff $2 $1;
}

# Install Oh my zsh!
function installOhMyZshIfNeeded {
    if [ ! -d "$HOME/.oh-my-zsh" ] 
    then
        echo "🤖 Installing Oh My Zsh!"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        rm -rf $HOME/.zshrc 
        # The plugin is already in the zsh config.
        ln -s $DOTFILES_PATH/zsh/.zshrc $HOME/.zshrc #Link zsh.
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

function resetDotfiles {
    rm -rf $HOME/.dotfiles
    wget https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer; chmod +x installer; ./installer
}

function updateDotfiles {
    rm -rf $HOME/.dotfiles
    zsh <(curl -s https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer)
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
    export PS1='✈️ ➜ %1d ${vcs_info_msg_0_} \$ '
}

function linkConfigurationFiles {
    ln -s -f $DOTFILES_PATH/tmux/.tmux.conf $HOME/.tmux.conf #Link zsh.
    ln -s -f $DOTFILES_PATH/vim/.vimrc $HOME/.vimrc #Link vim config
    ln -s -f $DOTFILES_PATH/ash/.profile $HOME/.profile #Link ash profile 
    ln -s -f $DOTFILES_PATH/nvim $HOME/.config/nvim #Link nvim folder
}

function srcroot {
    defaults read ~/Library/Preferences/com.apple.dt.Xcode.plist NSNavLastRootDirectory
}

function openiTermBehavior {
    directory=$(srcroot)
    open -a iTerm "${directory:2}" # this drops the first to chars
}

function mountFiles {
    # mounts delected foldes into /mnt
    mount -t ios website /mnt
}

fix_ruby() {
  echo "🔍 Checking Ruby installation..."
  if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby not found. Proceeding with reinstallation..."
  else
    echo "✅ Ruby is installed: $(ruby -v)"
    return
  fi

  echo "🧹 Removing any leftover RVM installation..."
  if command -v rvm &> /dev/null; then
    rvm implode
    rm -rf ~/.rvm
    echo "✅ RVM removed."
  else
    echo "✅ RVM is not installed."
  fi

  echo "📥 Installing rbenv for Ruby version management..."
  if ! command -v rbenv &> /dev/null; then
    brew install rbenv
    rbenv init
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc
    source ~/.zshrc
  fi

  echo "🔄 Installing Ruby 3.2.2 using rbenv..."
  rbenv install 3.2.2
  rbenv global 3.2.2

  echo "✅ Ruby installation completed. Version: $(ruby -v)"
}


plugins=(
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

clear
changePrompt
aliasvim
