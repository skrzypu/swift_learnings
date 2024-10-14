!pip install coremltools

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import coremltools as ct

# Replace 'APODAnalytics.csv' with the exact filename if different
data = pd.read_csv('/kaggle/input/apod-analytics-data/apod-data-mock-opened.csv', sep= ';')

# Fill empty copyright values with 'Unknown'
data['copyright'].fillna('Unknown', inplace=True)

# Feature selection
X = data[['media_type', 'tags']]
y = data['opened']

# Convert categorical variable 'media_type' into dummy/indicator variables
X = pd.get_dummies(X, columns=['media_type'], drop_first=True)

# Split 'tags' into separate columns
tags_df = X['tags'].str.get_dummies(sep=',')
X = pd.concat([X.drop('tags', axis=1), tags_df], axis=1)

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train Random Forest Classifier
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Make predictions
y_pred = model.predict(X_test)

# Evaluate the model
print("Classification Report:")
print(classification_report(y_test, y_pred))

print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred))
print("Accuracy Score:", accuracy_score(y_test, y_pred))

# Convert the Random Forest model to Core ML
feature_names = X.columns.tolist()
print("Feature Names:", feature_names)

# Convert to Core ML
coreml_model = ct.converters.sklearn.convert(
    model,
    input_features=feature_names
)

# Add metadata to the Core ML model
coreml_model.author = 'Your Name'
coreml_model.short_description = 'Predicts the likelihood of an APOD item being opened based on media type and tags.'

# Save the Core ML model
coreml_model.save('APODOpenedPredictor_RandomForest.mlmodel')
