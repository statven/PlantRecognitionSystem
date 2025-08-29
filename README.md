# PlantRecognitionSystem

## Intelligent System for Plant and Mutation Recognition

### Project Description
Development of a mobile application for identification of plant species and their genetic mutations using CNN. 

**Problem Statement**: 
- Subjectivity of manual identification
- Inefficiency with large volumes of data
- Lack of accessible tools for mutation recognition

**Solution Approach**:
- Cross-platform mobile application (Flutter)
- EfficientNetB0 model with Kaggle augmentation (>90% accuracy)
- Offline-capable system (TensorFlow Lite)
- Image preprocessing module (OpenCV)

### Project Structure
PlantRecognitionSystem/
├── data/ # Datasets and processed data
├── docs/ # Project documentation
├── models/ # Trained ML models
├── mobile_app/ # Flutter mobile application
├── notebooks/ # Jupyter notebooks for development
└── README.md # This file

### Getting Started
1. Clone the repository
2. Install Python dependencies: `pip install -r requirements.txt`
3. Run data preparation: `python data_preparation.py`
4. Train model: `python model_training.py`
5. Open mobile_app in Android Studio/VSCode
6. Run `flutter pub get` to install dependencies
7. Run on device/emulator
