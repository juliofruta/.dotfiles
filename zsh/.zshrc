
#### FIG ENV VARIABLES ####
# Please make sure this block is at the start of this file.
[ -s ~/.fig/shell/pre.sh ] && source ~/.fig/shell/pre.sh
#### END FIG ENV VARIABLES ####
# https://stackoverflow.com/questions/35098490/how-do-i-set-path this is to use RVM from bin and not the default one.
export PATH="$PATH:$HOME/.rvm/bin"
export DOTFILES_PATH="$HOME/.dotfiles"
export ZSH="$HOME/.oh-my-zsh"

# Review a phab -- consider that this will get rid of all your current changes. and stash them.
function review {
    git add . && git stash && git add . && git reset --hard && arc restore $1 && git checkout -b reviewHelp;
    git checkout master && git pull && make clean && make bootstrap && git submodule update && git checkout -b review && git merge reviewHelp && git reset --soft master;
    git branch -D reviewHelp;
}

# Cleans the development branch positioning yourself in the develeopment branch
function reviewClean {
    git add .; git reset --hard; git checkout master; git branch -D review;
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

function installWorkCasksIfNeeded {
    # Install Github Desktop
    if [[ ! -d "/Applications/Github Desktop.app" ]]; then
        brew install github
    fi
    
    # Install iTerm2
    if [[ ! -d "/Applications/iTerm.app" ]]; then
        brew install iterm2
    fi
    
    # Install Karabiner Elements
    if [[ ! -d "/Applications/Karabiner-Elements.app" ]]; then
        brew install karabiner-elements
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

    brew_install neovim
    brew_install fzf
    brew_install tmux
    
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

    # Install min
    if [[ ! -d "/Applications/Min.app" ]]; then 
       brew install --cask min
    fi
}

function installFormulaeIfNeeded {
    # Install m-cli
    if brew ls --versions m-cli > /dev/null; then
      # The package is installed
    else
      # The package is not installed
      brew install m-cli 
    fi
}

function resetDotfiles {
    rm -rf $HOME/.dotfiles
    bash <(curl -s https://raw.githubusercontent.com/juiiocesar/.dotfiles/main/installer)
}

function saveKarabinerConfig {
    cp -R $HOME/.config/karabiner/karabiner.json $DOTFILES_PATH/karabiner/karabiner.json
    git -C $DOTFILES_PATH add $DOTFILES_PATH/karabiner/karabiner.json
    git -C $DOTFILES_PATH commit -m "Save karabiner config"
    git -C $DOTFILES_PATH push origin main
}

function installKarabinerConfig {
    cp -R $DOTFILES_PATH/karabiner/karabiner.json $HOME/.config/karabiner/karabiner.json
}

# Run installation
function install {
    installOhMyZshIfNeeded
    installZSHAutosuggestionsIfNeeded
    installSyntaxHighlighting
    updateiTerm2DynamicProfiles
    installBrewIfNeeded
    installWorkCasksIfNeeded
    installPersonalCasksIfNeeded
    installFormulaeIfNeeded
    installKarabinerConfig
    linkConfigurationFiles
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


function shortcutTKey {
    open -a iTerm 
}

function shortcutJKey {
    m wallpaper /Users/juliocesarguzmanvillanueva/Pictures/Photos\ Library.photoslibrary/originals/4/4E2DDF54-3B2F-4485-AC18-ADA520402980.jpeg
}

function shortcutKKey {
    m wallpaper /Users/juliocesarguzmanvillanueva/Pictures/Photos\ Library.photoslibrary/originals/E/E1243D73-F566-4FF9-A23B-500C2455FAA6.png
}

plugins=(
    git
    dnf
    pass
    zsh-autosuggestions
    zsh-syntax-highlighting
    macos
    web-search
    xcode
    command-not-found
)

source $ZSH/oh-my-zsh.sh

clear
showUnicorn
changePrompt


#### FIG ENV VARIABLES ####
# Please make sure this block is at the end of this file.
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
#### END FIG ENV VARIABLES ####
