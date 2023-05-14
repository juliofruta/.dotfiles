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

    # Install caffeine
    if [[ ! -d "/Applications/Caffeine.app" ]]; then 
       brew install --cask caffeine
    fi

    # Install Docker Desktop
    if [[ ! -d "/Applications/Docker.app" ]]; then 
       brew install --cask docker
    fi

    # Install RDM 
    if [[ ! -d "/Applications/RDM.app" ]]; then 
       brew install --cask avibrazil-rdm
    fi

    brew_install neoviapk update
    apk add git build-base cmake automake autoconf libtool pkgconf coreutils curl unzip gettext-tiny-devm
    brew_install fzf
    brew_install tmux
    brew_install cmatrix    
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
      echo ""
    else
      # The package is not installed
      brew install m-cli 
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

function saveKarabinerConfig {
    cp -R $HOME/.config/karabiner/karabiner.json $DOTFILES_PATH/karabiner/karabiner.json
    git -C $DOTFILES_PATH add $DOTFILES_PATH/karabiner/karabiner.json
    git -C $DOTFILES_PATH commit -m "Save karabiner config"
    git -C $DOTFILES_PATH push origin main
}

function installKarabinerConfig {
    cp -R $DOTFILES_PATH/karabiner/karabiner.json $HOME/.config/karabiner/karabiner.json
}

function installNeoVimOnASH {
    echo https://dl-cdn.alpinelinux.org/alpine/edge/main > /etc/apk/repositories
    echo https://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
    apk update
    apk upgrade
    apk add neovim
}

# Run installation
function run_install {
    installOhMyZshIfNeeded
    installZSHAutosuggestionsIfNeeded
    installSyntaxHighlighting
    linkConfigurationFiles
    
    # ash support
    if [ "$SHELL" = "/bin/ash" ]
    then
        installNeoVimOnASH
        installAPKsIfNeeded
    fi

    # macOS Support
    if [[ $OSTYPE == 'darwin'* ]]; then
        echo '🤖 macOS detected macOS configuration'
        updateiTerm2DynamicProfiles
        installBrewIfNeeded
        installWorkCasksIfNeeded
        installPersonalCasksIfNeeded
        installFormulaeIfNeeded
        installKarabinerConfig
        removeAllItemsFromDock
    else
        installSwift
    fi
}

function removeAllItemsFromDock {
    defaults write com.apple.dock persistent-apps -array
}

# Find and set branch name var if in git repository.
function git_branch_name {
    echo $(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
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

function shortcutTKey {
    open -a iTerm 
}

# Karabiner elements issue
# https://github.com/pqrs-org/Karabiner-Elements/issues/1573
function shortcutJKey {
    openiTermBehavior
}

function shortcutKKey {
    m wallpaper $HOME/Pictures/Photos\ Library.photoslibrary/originals/E/EE0ED416-71F8-4434-8F02-1A5F89AAD138.jpeg
}

function runIfAshDetected {
    if [ "$SHELL" = "/bin/ash" ]
    then 
        $1
    fi
}

function mountFiles {
    # mounts delected foldes into /mnt
    mount -t ios website /mnt
}

function apkIfNeeded {
    if ! which $1 &> /dev/null
    then
        echo "$1 could not be found installing 🤖"
        apk add $1
    fi
}

function installAPKsIfNeeded {
    apkIfNeeded zsh-vcs
    apkIfNeeded sudo
}

function installSwift {
    # install dependencies as in https://gist.github.com/Jswizzy/408af5829970f9eb18f9b45f891910bb
    
    sudo apt install clang libpython2.7 libpython2.7-dev

    # ash support
    if [ "$SHELL" = "/bin/ash" ]
    then
          
        apk add clang
        apk add libpython2.7
        apk add libpython2.7-dev
    fi

    if ! command -v swift &> /dev/null ; then
        # Download Swift 5.7.1
        #x86_64 https://download.swift.org/swift-5.7.1-release/ubuntu2004/swift-5.7.1-RELEASE/swift-5.7.1-RELEASE-ubuntu20.04.tar.gz
        #aarch64 https://download.swift.org/swift-5.7.1-release/ubuntu2004-aarch64/swift-5.7.1-RELEASE/swift-5.7.1-RELEASE-ubuntu20.04-aarch64.tar.gz
        wget https://download.swift.org/swift-5.7.1-release/ubuntu2004-aarch64/swift-5.7.1-RELEASE/swift-5.7.1-RELEASE-ubuntu20.04-aarch64.tar.gz
        # extract tar 
        tar xzf swift-5.7.1-RELEASE-ubuntu20.04-aarch64.tar.gz
        sudo mv swift-5.7.1-RELEASE-ubuntu20.04-aarch64 /usr/share/swift
        sudo echo "export PATH=/usr/share/swift/usr/bin:$PATH" >> ~/.zshrc
        source ~/.zshrc
        swift -v
    else
        echo "installation failed: check if you have swift installed. If not this is a bug."
    fi
}

plugins=(
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

clear
changePrompt
