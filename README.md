# dotfiles

```sh
sudo apt install stow
git clone git@github.com:pmatsson/dotfiles.git ~/git/personal/dotfiles
cd ~/git/personal/dotfiles && stow --target="$HOME" */
```

Or pick individual packages: `stow --target="$HOME" nvim zsh`
