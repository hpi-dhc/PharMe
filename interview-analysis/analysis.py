import gensim.downloader as api
import nltk
nltk.download('vader_lexicon')
from nltk.sentiment.vader import SentimentIntensityAnalyzer

class NLProcessor:
    __filter_chars = ['.', ',', '?', ';', '"', '#', '\'', '!', '‘', '’', '“', '”', '…', ':', '_', '*'] 
    __stop_words_path = 'nlp-resources/stop_words_en.txt'
    __stop_words = None
    __word_vectors_id = 'word2vec-google-news-300'
    __word_vectors = None
    __sim_statement = ''
    __sentimentIA = SentimentIntensityAnalyzer()

    @staticmethod
    def __get_stop_words():
        if not NLProcessor.__stop_words:
            with open(NLProcessor.__stop_words_path, 'r') as fp:
                NLProcessor.__stop_words = fp.read().split('\n')
        return NLProcessor.__stop_words

    @staticmethod
    def __get_word_vectors():
        if not NLProcessor.__word_vectors:
            NLProcessor.__word_vectors = api.load(NLProcessor.__word_vectors_id)
        return NLProcessor.__word_vectors
    
    @staticmethod
    def __normalize(text):
        return ' '.join([word.lower() for word in text.split(' ') if word not in NLProcessor.__get_stop_words()])

    @staticmethod
    def set_word_vectors(vectors):
        NLProcessor.__word_vectors = vectors

    @staticmethod
    def ready():
        NLProcessor.__get_stop_words()
        NLProcessor.__get_word_vectors()

    @staticmethod
    def set_similarity_data(statement):
        NLProcessor.__sim_statement = NLProcessor.__normalize(statement)
    
    @staticmethod
    def similarity(phrase):
        return 1 / NLProcessor.__get_word_vectors().wmdistance(NLProcessor.__normalize(phrase), NLProcessor.__sim_statement)
    
    @staticmethod
    def sentiment(phrase):
        return NLProcessor.__sentimentIA.polarity_scores(phrase)

