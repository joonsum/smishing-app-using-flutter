from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
from sklearn.feature_extraction.text import TfidfVectorizer

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes

# Load the model and vectorizer
with open('model.pkl', 'rb') as f:
    clf, vectorizer = pickle.load(f)

@app.route('/predict', methods=['POST'])
def predict():
    # Get the link from the POST request
    data = request.get_json(force=True)
    link = data['link']

    # Convert the link to a matrix of TF-IDF features
    link_tfidf = vectorizer.transform([link])

    # Predict the classification for the link
    prediction = clf.predict(link_tfidf)

    # Return the prediction
    return jsonify({'prediction': prediction[0]})

if __name__ == '__main__':
    app.run(port=8000, debug=True)