# Interview analysis

This is a small tool that aims to visualize and help analyze interview results using basic natural language processing to evaluate sentiment and topic relatedness. The data visualization part of it lives in `notebook.ipynb`, which is also the file you will most likely want to play with.

Aside from analyzing data given in a `.csv` file, this tool also provides infrastructure to download resources from a Google Sheet and translate replies to a common English language using [Deepl.com's API](https://www.deepl.com/docs-api). To use these features, set up your `.env` file accordingly. Note that pretrained NLP models are used, which constrains functionality to English language.

## Setup

To set up the project, simply run `./setup.sh` to install and download all necessary resources. From there on out, run `source activate` whenever you want to use the tool and later `deactivate` once you're done.

To reset / uninstall your setup, simply delete the directory `.venv`.

## Visualizing data

Check out & adjust the notebook to your needs! :) (Make sure Jupyter is set to use the Python kernel in `.venv/bin/python`)

Running all cells as they are without changing anything will show you a visualization of the provided mock data.

## Important note

In case you are working with private interview data, make sure you don't accidently commit the notebook with its outputs to a public repository.

