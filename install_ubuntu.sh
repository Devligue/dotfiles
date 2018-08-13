#!/bin/bash

# Sanity check
[ -f /etc/lsb-release ] || { error "This script if for Ubuntu"; exit 127; }

# Repo download and unzip
rm -rf /tmp/repo &>/dev/null
mkdir -p /tmp/repo
cd /tmp/repo
curl -L https://github.com/devligue/dotfiles/archive/master.zip > repo.zip
sudo apt install unzip
unzip repo.zip
rm repo.zip
mv dotfiles* ~/.dotfiles
cd ~/.dotfiles
rm -rf /tmp/repo

source ./lib_sh/echos.sh
bot "Hi! I'm going to setup this machine. Here I go..."

bot "Configuring git. I'm gonna need your help..."
grep 'user = GITHUBUSER' ./homedir/.gitconfig > /dev/null 2>&1
if [[ $? = 0 ]]; then
    read -r -p "What is your github.com username? " githubuser
    read -r -p "What is your first name? " firstname
    read -r -p "What is your last name? " lastname
    read -r -p "What is your email? " email
    fullname="$firstname $lastname"
    bot "Greatings $fullname, "
    sed -i "s/GITHUBFULLNAME/$firstname $lastname/" ./homedir/.gitconfig > /dev/null 2>&1
    sed -i 's/GITHUBEMAIL/'$email'/' ./homedir/.gitconfig
    sed -i 's/GITHUBUSER/'$githubuser'/' ./homedir/.gitconfig
fi

bot "Configuring system repository..."
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:neovim-ppa/stable

bot "Updating packages..."
sudo apt-get update

bot "Installing python and other necessary tools"
sudo apt install python-pip
sudo apt install python3-pip
pip install --user neovim
pip3 install --user pipenv neovim flake8 black

bot "Installing neovim..."
sudo apt-get install neovim

bot "Creating symlinks for project dotfiles..."
pushd homedir > /dev/null 2>&1
now=$(date +"%Y.%m.%d.%H.%M.%S")

for file in .*; do
  if [[ $file == "." || $file == ".." ]]; then
    continue
  fi
  # if the file exists:
  if [[ -e ~/$file ]]; then
      mkdir -p ~/.dotfiles_backup/$now
      mv ~/$file ~/.dotfiles_backup/$now/$file
      echo "backup saved as ~/.dotfiles_backup/$now/$file"
  fi
  # symlink might still exist
  unlink ~/$file > /dev/null 2>&1
  # create the link
  ln -s ~/.dotfiles/homedir/$file ~/$file
  echo -en linking ${file}; ok
done

popd > /dev/null 2>&1


# Configure BASH
# mkdir -p ~/bin
# grep 'source ~/.profile' ~/.bashrc || echo "source ~/.profile" >> ~/.bashrc

bot "Setting up neovim..."
sudo apt install exuberant-ctags
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim_runtime/bundle/Vundle.vim
nvim +PluginInstall +qall
#sudo reboot