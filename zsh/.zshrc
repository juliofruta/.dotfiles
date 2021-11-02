# https://stackoverflow.com/questions/35098490/how-do-i-set-path this is to use RVM from bin and not the default one.
export PATH="$PATH:$HOME/.rvm/bin"
export DOTFILES_PATH="$HOME/.dotfiles"
export ZSH="$HOME/.oh-my-zsh"

# Takes all the Inspect PR titles between commitA and commitB and prints them on the stdout requires github cli to be installed. 
# $1 - Github org
# $2 - Github repo
# $3 - CommitA
# $4 - CommitB
function prtitles { 
    git log --oneline $3...$4 | ggrep -oP '#\K[0-9]*' | xargs -I _ sh -c "gh pr view _ --repo $1/$2 | head -n 1" 
}

# Review a PR -- consider that this will get rid of all your current changes. and stash them.
function review {
    git add .; git stash; git add .; git reset --hard; git checkout $1; git pull; git checkout development; git pull; git checkout -b review; git merge $1; git reset --soft development;
}

# Same but with master instead of dev
function review2 {
    git add .; git stash; git add .; git reset --hard; git checkout $1; git pull; git checkout master; git pull; git checkout -b review; git merge $1; git reset --soft master;
}

# Cleans the development branch positioning yourself in the develeopment branch
function reviewClean {
    git add .; git reset --hard; git checkout development; git branch -D review;
}

# Same but with master instead of dev
function reviewClean2 {
    git add .; git reset --hard; git checkout master; git branch -D review;
}


# code-freeze release/version development
function code-freeze {
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
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

function updateDotfiles {
    rm -rf .dotfiles
    bash <(curl -s https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer)
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

function installCasksIfNeeded {
    # Install Visual Studio Code
    if [[ ! -d "/Applications/Visual Studio Code.app" ]]; then
        brew install visual-studio-code
    fi
    
    # Install WhatsApp
    if [[ ! -d "/Applications/WhatsApp.app" ]]; then
        brew install whatsapp
    fi
    
    # Install Github Desktop
    if [[ ! -d "/Applications/Github Desktop.app" ]]; then
        brew install github
    fi
    
    # Install iTerm2
    if [[ ! -d "/Applications/iTerm.app" ]]; then
        brew install iterm2
    fi
    
    # Install Telegram
    if [[ ! -d "/Applications/Telegram.app" ]]; then
        brew install telegram
    fi
}

function installToolsIfNeeded {
    installOhMyZshIfNeeded
    installZSHAutosuggestionsIfNeeded
    installSyntaxHighlighting
    updateiTerm2DynamicProfiles
    installBrewIfNeeded
    installCasksIfNeeded
}

function changePrompt {
    export PS1="🦄 %1d \$ "
}

function showUnicorn {
    cat $DOTFILES_PATH/zsh/unicorn.ans
}

function linkConfigurationFiles {
    ln -s -F $DOTFILES_PATH/tmux/.tmux.conf $HOME/.tmux.conf #Link zsh.
    ln -s -F $DOTFILES_PATH/vim/.vimrc $HOME/.vimrc #Link vim config
} 

plugins=(
    git
    dnf
    pass
    zsh-autosuggestions
    zsh-syntax-highlighting
    osx
    web-search
    xcode
    command-not-found
)

source $ZSH/oh-my-zsh.sh

clear
showUnicorn
installToolsIfNeeded
changePrompt
linkConfigurationFiles
