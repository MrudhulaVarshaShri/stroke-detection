import pickle
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
import pandas as pd
import os

# Create sample training data
np.random.seed(42)
n_samples = 1000

# Generate synthetic data for stroke prediction
data = {
    'age': np.random.randint(20, 85, n_samples),
    'hypertension': np.random.randint(0, 2, n_samples),
    'heart_disease': np.random.randint(0, 2, n_samples),
    'avg_glucose_level': np.random.uniform(50, 300, n_samples),
    'bmi': np.random.uniform(15, 40, n_samples),
    'smoking_status': np.random.randint(0, 3, n_samples),
    'stroke': np.random.randint(0, 2, n_samples)
}

df = pd.DataFrame(data)

# Separate features and target
X = df[['age', 'hypertension', 'heart_disease', 'avg_glucose_level', 'bmi', 'smoking_status']]
y = df['stroke']

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train Random Forest model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluate
y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)

print(f"Model Accuracy: {accuracy:.4f}")
print("\nClassification Report:")
print(classification_report(y_test, y_pred))

# Save model
os.makedirs('.', exist_ok=True)
with open('stroke_model.pkl', 'wb') as f:
    pickle.dump(model, f)
print("\nModel saved as stroke_model.pkl")

# Save feature importance
feature_names = ['age', 'hypertension', 'heart_disease', 'avg_glucose_level', 'bmi', 'smoking_status']
importances = model.feature_importances_
print("\nFeature Importance:")
for name, importance in zip(feature_names, importances):
    print(f"{name}: {importance:.4f}")
