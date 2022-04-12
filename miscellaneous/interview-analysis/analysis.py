import gensim.downloader as api
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize

class NLProcessor:
    __stopwords = set(stopwords.words('english'))
    __word_vectors_id = 'word2vec-google-news-300'
    __word_vectors = None
    __sim_compare = None
    __sentimentIA = SentimentIntensityAnalyzer()

    # MARK: NORMALIZATION
    # word-tokenizes document and removes all non-alphanumeric characters
    # optionally clears stopwords
    @staticmethod
    def __normal_tokens(doc, clear_stopwords=True):
        return [token for token in word_tokenize(''.join([
            char.lower() for char in doc if char.isalnum() or char.isspace()
        ])) if not clear_stopwords or token not in NLProcessor.__stopwords]

    # normalize document
    @staticmethod
    def normalize(doc):
        return ' '.join(NLProcessor.__normal_tokens(doc))

    # MARK: WORD MOVER'S DISTANCE
    # setup - lazily loaded word vectors
    @staticmethod
    def __get_word_vectors():
        if not NLProcessor.__word_vectors:
            NLProcessor.__word_vectors = api.load(NLProcessor.__word_vectors_id)
        return NLProcessor.__word_vectors
    @staticmethod
    def set_word_vectors(vectors): NLProcessor.__word_vectors = vectors

    # skip lazy initialization
    @staticmethod
    def ready_similarity(compare_doc):
        NLProcessor.__sim_compare = NLProcessor.__normal_tokens(compare_doc)
        NLProcessor.similarity('Lazy init.')

    # wrapper for word movers distance
    @staticmethod
    def similarity(doc1):
        return 1 / NLProcessor.__get_word_vectors().wmdistance(NLProcessor.__normal_tokens(doc1), NLProcessor.__sim_compare)

    # MARK: SENTIMENT ANALYSIS
    @staticmethod
    def sentiment(doc):
        return NLProcessor.__sentimentIA.polarity_scores(NLProcessor.normalize(doc))

