# remove uneeded packages
sudo pacman -R eog --noconfirm 

# symlinking dotfiles
mkdir -p ~/.config
rm -rf ~/.config/i3
cd i3-dotfiles

cp -r .config ~/
cp -r .icons ~/
cp -r .local ~/

# adding ble.sh (autocomplete in bash)
cd 
sudo pacman -S base-devel --noconfirm 
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc

# update bashrc
cd
mv ~/.config/.bashrc ~/.bashrc

# moving openvpn file to correct folder and start the service
mkdir -p ~/ovpn && touch ~/ovpn/credentials.txt

sed -i '/^auth-user-pass/c\auth-user-pass '"$HOME"'/ovpn/credentials.txt' ~/.config/us-slc.prod.surfshark.com_udp.ovpn

ovpn_string="/usr/bin/openvpn $HOME/.config/us-slc.prod.surfshark.com_udp.ovpn"
sed -i "s/^ExecStart=.*/ExecStart=$(echo $ovpn_string | sed 's/\//\\\//g')/" ~/.config/openvpn.service
sudo cp  ~/.config/openvpn.service /etc/systemd/system/openvpn.service
sudo systemctl enable openvpn.service


# add multilib and sync
sudo cp -f ~/.config/pacman.conf /etc/pacman.conf
sudo pacman -Syy --noconfirm 

# install yay
cd
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay -S --noconfirm - < ~/.config/packages.txt

# starship
echo 'eval "$(starship init bash)"' >> ~/.bashrc

# bluetooth
sudo systemctl enable bluetooth.service 
sudo systemctl start bluetooth.service

# start openvpn service
sudo systemctl start openvpn.service

# set default browser
xdg-settings set default-web-browser librewolf.desktop

# create dir for flameshot
mkdir -p ~/Images/screenshots
mkdir -p ~/Pictures

# rebooting to change everything
read -p "Would you like to reboot for changes to take effect? (Y/N): " answer

if [[ $answer =~ ^[Yy]$ ]] || [[ -z $answer ]]; then
  echo "Rebooting..."
  reboot
else
  echo "Skipping reboot..."
fi
