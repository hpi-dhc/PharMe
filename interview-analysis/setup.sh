if [ -z "$ZSH_VERSION" -a -z "$BASH_VERSION" ]; then
    echo "please run $(basename $0) with zsh or bash."
    exit 1
fi

print_bold() {
    printf "\\033[1m$1\\033[0m\n"
}

ROOT_DIR=`dirname $(realpath $0)`
VENV_DIR=$ROOT_DIR/.venv
PY='/usr/bin/env python3'

print_bold "initializing python environment"
test -f $ROOT_DIR/.env || cp $ROOT_DIR/.env.example $ROOT_DIR/.env
$PY -m venv --prompt 'interview-analysis' $VENV_DIR
source $ROOT_DIR/activate

print_bold "installing modules"
$PY -m pip install -r $ROOT_DIR/requirements.txt

print_bold "downloading nltk resources"
read -r -d '' NLTK_DOWNLOAD <<- EOM
    import nltk.downloader;
    nltk.download('vader_lexicon', download_dir='$VENV_DIR/nltk_data');
    nltk.download('punkt',         download_dir='$VENV_DIR/nltk_data');
    nltk.download('stopwords',     download_dir='$VENV_DIR/nltk_data');
EOM
$PY -c "$(echo $NLTK_DOWNLOAD)"
print_bold "downloading gensim resources"
# make dir because gensim thinks it doesn't have permission to do it
test -d $VENV_DIR/gensim-data || mkdir $VENV_DIR/gensim-data
$PY -m gensim.downloader --download 'word2vec-google-news-300'

print_bold "done!"

