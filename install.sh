SELF_PATH="$( cd "$( dirname "$0" )" && pwd )"


curl -fLo $SELF_PATH/vim.symlink/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Create symlinks
# use -d flag to overwrite all
should_overwrite_all=$1
if [[ $should_overwrite_all == "-d" ]]; then
  echo $should_overwrite_all
fi


for file in `find $SELF_PATH -maxdepth 1 -name \*.symlink`; do
	src_file=`basename "$file"`
	dest_file=`echo "$HOME/.$src_file" | sed "s/\.symlink$//g"`
	if [ -e $dest_file ]; then
    if [[ $should_overwrite_all == "-d" ]]; then
      rm -rf $dest_file
      ln -sv $SELF_PATH/$src_file $dest_file
    else
      echo "$dest_file already exists; skipping it..."
    fi
	else
		ln -sv $SELF_PATH/$src_file $dest_file
	fi
done

nvim_src=$SELF_PATH/nvim
nvim_dest=$HOME/.config/nvim

if [ -e $nvim_dest ]; then
  if [[ $should_overwrite_all == "-d" ]]; then
    rm -rf $nvim_dest
    ln -sv $nvim_src $nvim_dest
  else
    echo "$nvim_dest already exists; skipping it..."
  fi
else
	ln -sv $nvim_src $nvim_dest
fi


