export PATH=$HOME/.docker/bin/:$HOME/.composer/vendor/bin:$PATH

for file in ~/.config/zsh/*.zsh; do
    [ -r "$file" ] && source "$file"
done