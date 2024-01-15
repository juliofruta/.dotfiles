# https://stackoverflow.com/questions/35098490/how-do-i-set-path this is to use RVM from bin and not the default one.
export PATH="$PATH:$HOME/.rvm/bin"
export DOTFILES_PATH="$HOME/.dotfiles"
export ZSH="$HOME/.oh-my-zsh"

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
}

function brew_install() {
    if ! brew list $1 &>/dev/null; then
       brew install $1
    fi
}

function installPersonalCasksIfNeeded {
    
    # Only install these if on personal computer.
    if [[ ! "Julios-MacBook-Air.local" = "$(hostname -f)" ]]; then
        echo "Work computer detected." # > /dev/null
        return
    fi

    # Install Google Chrome
    if [[ ! -d "/Applications/Google Chrome.app" ]]; then
        brew install google-chrome
    fi
    
    # Install WhatsApp
    if [[ ! -d "/Applications/WhatsApp.app" ]]; then
        brew install whatsapp
    fi
        
    # Install Telegram
    if [[ ! -d "/Applications/Telegram.app" ]]; then
        brew install telegram
    fi
    
    # Install Blender
    if [[ ! -d "/Applications/Blender.app" ]]; then
        brew install blender
    fi

    # Install Epic Games Launcher
    if [[ ! -d "/Applications/Epic Games Launcher.app" ]]; then
        brew install epic-games
    fi

    # Install Steam
    if [[ ! -d "/Applications/Steam.app" ]]; then
        brew install steam
    fi

    # Install Discord
    if [[ ! -d "/Applications/Discord.app" ]]; then
        brew install discord
    fi
    
    # Install OBS
    if [[ ! -d "/Applications/OBS.app" ]]; then
        brew install --cask obs
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

# Run installation
function run_install {
    installOhMyZshIfNeeded
    installZSHAutosuggestionsIfNeeded
    installSyntaxHighlighting
    linkConfigurationFiles

    # macOS Support
    updateiTerm2DynamicProfiles
    installBrewIfNeeded
    installWorkCasksIfNeeded
    installPersonalCasksIfNeeded
    removeAllItemsFromDock
}

function removeAllItemsFromDock {
    defaults write com.apple.dock persistent-apps -array
    killall Dock
}

function changePrompt { 
    # Load version control information
    autoload -Uz vcs_info
    precmd() { vcs_info }

    # Format the vcs_info_msg_0_ variable
    zstyle ':vcs_info:git:*' formats '%b'
 
    # Set up the prompt (with git branch name)
    setopt PROMPT_SUBST
    export PS1='🧠 ➜ %1d ${vcs_info_msg_0_} \$ '
}

function linkConfigurationFiles {
    ln -s -f $DOTFILES_PATH/tmux/.tmux.conf $HOME/.tmux.conf #Link zsh.
    ln -s -f $DOTFILES_PATH/vim/.vimrc $HOME/.vimrc #Link vim config
    ln -s -f $DOTFILES_PATH/ash/.profile $HOME/.profile #Link ash profile 
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

plugins=(
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

clear
changePrompt
