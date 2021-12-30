echo "Welcome to haukkagu's dots-installer!"

echo "Configuring pacman..."
sudo grep -q "ILoveCandy" /etc/pacman.conf || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sudo sed -i "s/^#ParallelDownloads = 8$/ParallelDownloads = 5/;s/^#Color$/Color/" /etc/pacman.conf

echo "Does your computer have an amd (1) or intel (2) cpu?"
read cpu_type
echo "Installing appropriate microcode updates..."
if [ $cpu_type == 1 ]; then
	sudo pacman --noconfirm -S amd-ucode
elif [ $cpu_type == 2 ]; then
	sudo pacman --noconfirm -S intel-ucode
else
	echo "No cpu selected. No microcode updates installed..."
fi

echo "Does your computer have an amd (1), intel (2) or nvidia (3) gpu?"
read gpu_type
echo "Installing appropriate video drivers..."
if [ $gpu_type == 1 ]; then
	sudo pacman --noconfirm -S xf86-video-amdgpu mesa
elif [ $gpu_type == 2 ]; then
	sudo pacman --noconfirm -S xf86-video-intel mesa
elif [ $gpu_type == 3 ]; then
	sudo pacman --noconfirm -S nvidia nvidia-utils
else
	echo "No gpu selected. No video drivers installed..."
fi

echo "Installing packages..."
sudo pacman --noconfirm -S git base-devel \
	xorg xorg-xinit libx11 libxinerama freetype2 \
	feh picom dunst sxhkd \
	vim firefox emacs sxiv flameshot gimp htop neofetch \
	pulseaudio pulsemixer pamixer \
	ttf-liberation terminus-font ttf-joypixels ttf-nerd-fonts-symbols-mono noto-fonts-cjk \
	papirus-icon-theme

echo "Installing yay..."
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

echo "Installing AUR packages..."
yay -S libxft-bgra-git ly ncspot-bin

echo "Installing dotfiles..."
cd /tmp
git clone https://github.com/haukkagu/dots
mv dots/* ~/

echo "Installing dwm..."
cd ~/.config/dwm
sudo make install clean

sudo cp dwm.desktop /usr/share/xsessions/
cd ~
cp .xinitrc .xsession

echo "Installing slstatus..."
cd ~/.config/slstatus
sudo make install clean

echo "Installing st..."
cd ~/.config/st
sudo make install clean

echo "Installing dmenu..."
cd ~/.config/dmenu
sudo make install clean

echo "Installing doom-emacs..."
cd ~
git clone --depth 1 https://github.com/hlissner/doom-emacs .emacs.d
./.emacs.d/bin/doom install

echo "Installing keyboard layout..."
cd /tmp
git clone https://github.com/joleeee/nous
cd nous
sudo cp nous /usr/share/X11/xkb/symbols
sudo echo -e \
'Section "InputClass"\n'\
'	Identifier "system-keyboard"\n'\
'	MatchIsKeyboard "on"\n'\
'	Option "XkbLayout" "nous"\n'\
'	Option "XkbModel" "pc102"\n'\
'	Option "XkbOptions" "caps:swapescape"\n'\
'EndSection' >> /etc/X11/xorg.conf.d/00-keyboard.conf

echo "Installing Klaus..."
cd ~
mkdir .themes
git clone https://github.com/tsbarnes/Klaus .themes/Klaus

echo "Configuring gtk..."
GTK_THEME="Klaus"
GTK_ICONS="Papirus-Dark"
GTK_FONT="Terminus 11"
cd ~
echo -e \
	"gtk-theme-name = \"$GTK_THEME\"\n"\
	"gtk-icon-theme-name = \"$GTK_ICONS\"\n"\
	"gtk-font-name = \"$GTK_FONT\"\n"\
	>> .gtkrc-2.0
mkdir .config/gtk-3.0
echo -e \
	"[Settings]\n"\
	"gtk-theme-name = \"$GTK_THEME\"\n"\
	"gtk-icon-theme-name = \"$GTK_ICONS\"\n"\
	"gtk-font-name = \"$GTK_FONT\"\n"\
	>> .config/gtk-3.0/settings.ini

echo "Enabling ly..."
sudo systemctl enable ly.service

echo "Setting up the home directory..."
cd ~
mkdir docs dls pics scripts projs
echo -e \
	'XDG_DOWNLOAD_DIR  = "$HOME/dls"\n'\
	'XDG_DOCUMENTS_DIR = "$HOME/docs"\n'\
	'XDG_PICTURES_DIR  = "$HOME/pics"\n'\
	>> .config/user-dirs.dirs

echo "Starting pulseaudio..."
pulseaudio --start

echo "Done! Do 'reboot' to apply all changes."
