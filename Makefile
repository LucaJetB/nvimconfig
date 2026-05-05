install:
	@echo "installing dependencies..."
	sudo apt install -y neovim ripgrep fd-find build-essential
	@if [ ! -f /usr/local/bin/fd]; then \
		  sudo ln -s $$(which fdfind) /usr/local/bin/fd; \
	fi 
	@echo "Done. Open nvim to boostrap plugins."
	
