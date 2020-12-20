export ZSH="$HOME/.oh-my-zsh"
plugins=(
    git
    dnf
    pass
    zsh-autosuggestions
    osx
    web-search
    xcode
    command-not-found
)
source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# https://stackoverflow.com/questions/35098490/how-do-i-set-path this is to use RVM from bin and not the default one.
export PATH="$PATH:$HOME/.rvm/bin"


# Takes all the Inspect PR titles between commitA ($1) and commitB ($2) and prints them on the stdout 
# $1 - CommitA
# $2 - CommitB
# $3 - Github org
# $4 - Github repo
function inspectprs { 
    git log --oneline $1...$2 | ggrep -oP '#\K[0-9]*' | xargs -I _ sh -c "gh pr view _ --repo $3/$4 | head -n 1" 
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

