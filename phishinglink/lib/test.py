from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib

app = Flask(__name__)

# Load the model and vectorizer
classifier = joblib.load('modelmess.pkl')
vectorizer = joblib.load('vectorizer.pkl')

@app.route('/classifyMessage', methods=['POST'])
def classify_message():
    try:
        # Get the message from the request
        message = request.json['message']

        # Transform the message into a vector
        vector = vectorizer.transform([message])

        # Use the classifier to make a prediction
        prediction = classifier.predict(vector)
        prediction_proba = classifier.predict_proba(vector)

        # Map the prediction to the corresponding class label
        class_label = 'smish' if prediction[0] == 1 else 'ham'

        # Extract the probability of the positive class
        proba = prediction_proba[0][1]

        # Extract the keywords
        keywords = vectorizer.inverse_transform(vector)

        # Convert the numpy arrays to Python lists
        keywords = [word.tolist() for word in keywords]

        # Return the classification result along with the probability and keywords
        return jsonify({'result': class_label, 'probability': proba, 'keywords': keywords[0]})
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': 'Failed to classify message'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)