import pandas as pd
import pickle
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from xgboost import XGBClassifier
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import roc_curve, auc

# Load dataset
df = pd.read_csv("dataset.csv")

print("Dataset Shape:", df.shape)

# Drop ID column if exists
if 'id' in df.columns:
    df = df.drop('id', axis=1)

# Remove missing values
df = df.dropna()

# Convert categorical columns
for col in df.select_dtypes(include=["object", "string"]).columns:
    df[col] = df[col].astype("category").cat.codes


# Separate features and target
X = df.drop("stroke", axis=1)
y = df["stroke"]

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Calculate imbalance ratio
scale_weight = len(y_train[y_train == 0]) / len(y_train[y_train == 1])

# Train XGBoost model
model = XGBClassifier(
    n_estimators=300,
    learning_rate=0.05,
    max_depth=5,
    scale_pos_weight=scale_weight,
    eval_metric="logloss",
    random_state=42
)

model.fit(X_train, y_train)

# Get prediction probabilities
y_probs = model.predict_proba(X_test)[:, 1]

# Adjust threshold to improve recall
y_pred = (y_probs > 0.25).astype(int)

# Evaluation
print("\nAccuracy:", accuracy_score(y_test, y_pred))
print("\nClassification Report:\n", classification_report(y_test, y_pred))
print("\nConfusion Matrix:\n", confusion_matrix(y_test, y_pred))


# --- Confusion Matrix Plot ---
cm = confusion_matrix(y_test, y_pred)

plt.figure()
sns.heatmap(cm, annot=True, fmt='d')
plt.title("Confusion Matrix")
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.savefig("confusion_matrix.png")
plt.close()


# Save model
pickle.dump(model, open("stroke_model.pkl", "wb"))
print("\nModel saved as stroke_model.pkl")
