
# 🌱 Intelligent System for Plant & Mutation Recognition

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=flat&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![GitHub repo size](https://img.shields.io/github/repo-size/statven/PlantRecognitionSystem?style=flat)](https://github.com/statven/PlantRecognitionSystem)



## TL;DR

Mobile application + ML pipeline that classifies plant species and detects leaf mutations/diseases using a compact CNN (EfficientNetB0). The app performs **offline inference** with a quantized TensorFlow Lite model and stores scan results locally (SQLite).


---

## Key features

- Offline on-device inference (TFLite INT8)  
- EfficientNetB0-based training, evaluation and quantization pipeline  
- Camera & gallery input (Flutter)  
- Persistent scan history (SQLite)  
- Preprocessing utilities (OpenCV) and reproducible Jupyter notebooks  
- Simple conversion script for `.h5` → `.tflite` with representative dataset

---

## Project structure (essential)

```

PlantRecognitionSystem/
├─ mobile\_app/                     # Flutter app (UI + TFLite integration)
│  ├─ android/, ios/, web/         # Flutter platform folders
│  ├─ assets/
│  │  └─ labels.txt                # label order used by the app
│  └─ lib/
│     ├─ screens/                  # Camera, Gallery, Result, History
│     ├─ services/                 # tflite\_service.dart, database\_service.dart
│     └─ widgets/                  # UI components (confidence bar, etc.)
│
├─ models/                         # Trained artifacts (.h5, .tflite) — normally kept out of git
├─ data/
│  ├─ raw/                         # Original images (large — not recommended in repo)
│  └─ processed/                   # Cleaned / split dataset for training
│
├─ notebooks/
│  ├─ data\_preparation.ipynb       # cleaning, augmentation, splits
│  ├─ model\_development.ipynb      # model training & evaluation
│  └─ new\_test.ipynb               # inference tests
│
├─ scripts/
│  └─ new\_test.py                  # example inference script for TFLite model
├─ models\_report/                  # model card, confusion matrices, benchmark results
├─ .gitignore
└─ README.md

````

> **Important:** `mobile_app/build/`, `models/`, and large `data/` directories should be excluded via `.gitignore`. Use Git LFS for large model files if needed.

---

## WBS (mapping to repo)

- **1. Research & Planning** — docs, UI mockups, dataset inventory (`/notebooks` + design docs)  
- **2. Data Preparation** — `notebooks/data_preparation.ipynb` (cleaning, augmentation, class balance)  
- **3. Model Development** — `notebooks/model_development.ipynb` → `models/*.h5` → quantized `models/*.tflite`  
- **4. App Implementation** — `mobile_app/` (camera/gallery, TFLite inference, UI)  
- **5. Enhancements** — history (`mobile_app/lib/services/database_service.dart`), result explanation UI (`mobile_app/lib/screens/result_screen.dart`)  
- **6. Testing & Deployment** — notebooks tests, `models_report/`, signed APK

---

## Timeline (example)

| Week | Focus                | Deliverable |
|------|----------------------|-------------|
| 1    | Research & design    | Spec, UI mockups, data inventory |
| 2    | Data prep            | Curated dataset + augmentation pipeline |
| 3–4  | Model dev            | Trained model + TFLite INT8 + evaluation report |
| 5–6  | App implementation   | Camera/gallery + TFLite integration + prototype APK |
| 7    | Enhancements         | SQLite history + explanation UI + performance tuning |
| 8    | Testing & release    | Final APK, test report, documentation |

---

## Class ordering (CRITICAL)

Make sure labels used by the mobile app match the training mapping:

```json
{"Bacteria":0,"Early_blight":1,"Fungi":2,"Healthy":3,"Late_blight":4,"Nematode":5,"Pest":6,"Phytopthora":7,"Virus":8}
````

The `mobile_app/assets/labels.txt` or `data/processed/class_indices.json` must reflect this exact ordering.

---

---

### `data_preparation.ipynb` — Data preparation & splitting

**Purpose**
Prepare raw images for training: cleaning, resizing/cropping, class balancing, augmentation and splitting into `train / val / test` folders. Also saves metadata and class ↔ index mapping.

**Inputs**

* `data/raw/` — original images organized by class subfolders.
* Notebook parameters (image size, split ratios).

**Outputs**

* `data/processed/train/`, `data/processed/val/`, `data/processed/test/`
* `data/processed/class_indices.json` (mapping used by model & app)
* `data/processed/*.csv` (train/val/test metadata)
* diagnostic plots (e.g., class distribution)

**Run (interactive)**

```bash
# create & activate env, install deps first
python -m venv .venv
source .venv/bin/activate   # or .venv\Scripts\Activate.ps1 on Windows
pip install -r requirements.txt

jupyter lab
# open notebooks/data_preparation.ipynb and run cells
```

**Run (headless / CI)**

```bash
jupyter nbconvert --to notebook --execute notebooks/data_preparation.ipynb \
  --ExecutePreprocessor.timeout=600 --output notebooks/data_preparation.executed.ipynb
```

---

### `model_development.ipynb` — Model training, validation & export

**Purpose**
Train EfficientNetB0 (or load existing), monitor metrics, produce test evaluation, save best `.h5` model and convert to a quantized `.tflite` using a representative dataset.

**Inputs**

* `data/processed/` (train/val/test folders and class\_indices.json)
* training hyperparameters (batch size, epochs, learning rate)
* optional pre-trained weights or existing `models/best_model.h5`

**Outputs**

* `models/best_model.h5` (best checkpoint)
* `models/model_quant.tflite` (INT8 quantized TFLite)
* `models/training_history.png`, `models/model_report.json`, confusion matrix plots

**Run (interactive)**

```bash
# in activated venv from above
jupyter lab
# open notebooks/model_development.ipynb and run cells
```

**Run (headless / script mode)**
If you also export training to a script:

```bash
python scripts/train_model.py --config configs/train.yaml
# or run notebook:
jupyter nbconvert --to notebook --execute notebooks/model_development.ipynb \
  --ExecutePreprocessor.timeout=3600 --output notebooks/model_development.executed.ipynb
```

**Notes**

* The TFLite conversion in the notebook uses a `representative_dataset()` generator (required for INT8). Keep `class_indices.json` ordering consistent with app labels.

---

### `new_test.ipynb` / `scripts/new_test.py` — Inference & smoke tests

**Purpose**
Run inference on individual images using the exported TFLite model; verify preprocessing, dequantization and label mapping. Useful for quick checks and generating example outputs for README or app UI.

**Inputs**

* `models/model_quant.tflite` (or float model)
* sample images (`samples/` or `data/new_test_images/`)
* `data/processed/class_indices.json` or `mobile_app/assets/labels.txt`

**Outputs**

* Console results: predicted class + confidence
* Saved visualization `models/new_images_test.png` (optional)
* per-image logs for debugging

**Run (script)**

```bash
# interactive: open new_test.ipynb in Jupyter and run cells
# script:
python scripts/new_test.py --model models/model_quant.tflite --image samples/test1.jpg
```

**Important checks performed by script**

* correct resize (`224x224` by default)
* use of `efficientnet.preprocess_input` (same preprocessing as training)
* dtype matching (if TFLite is INT8 — input must be `uint8`)
* dequantization: `(out - zero_point) * scale` to get real scores



## Quickstart — ML (training & testing)

### Prerequisites

* Python 3.8+
* `pip` and virtual environment (venv / conda)
* (Optional) GPU for faster training

### Install

```bash
cd /path/to/PlantRecognitionSystem
python -m venv .venv
# macOS / Linux
source .venv/bin/activate
# Windows (PowerShell)
# .venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

**Suggested `requirements.txt`**

```
tensorflow>=2.9
numpy
pandas
opencv-python
matplotlib
scikit-learn
tqdm
```

### Run notebooks

```bash
jupyter lab
# Open notebooks/data_preparation.ipynb and notebooks/model_development.ipynb
```

### Example inference (TFLite)

A minimal script (`scripts/new_test.py`) should:

* load `models/model_quant.tflite` via `tf.lite.Interpreter`
* preprocess the image using `tensorflow.keras.applications.efficientnet.preprocess_input`
* set input tensor (dtype must match model: `uint8` for INT8 quantized models)
* call `interpreter.invoke()`
* read output and **dequantize** using `output_details['quantization']` (scale, zero\_point)
* print class name and confidence

Run:

```bash
python scripts/new_test.py --model models/model_quant.tflite --image samples/test1.jpg
```

---

## Quickstart — Flutter app

### Prerequisites

* Flutter SDK (stable) — [https://flutter.dev](https://flutter.dev)
* Android SDK (for emulator or device)
* (macOS only) Xcode for iOS builds

### Dev run

```bash
cd mobile_app
flutter pub get
flutter run
```

### Build release APK

```bash
# generate keystore (example):
keytool -genkey -v -keystore /path/to/keystore.jks -alias serhievich_key -keyalg RSA -keysize 2048 -validity 10000

# reference keystore in android/key.properties, then:
flutter build apk --release
# APK located at: build/app/outputs/flutter-apk/app-release.apk
```

### App usage

1. Open app and allow camera permission.
2. Capture or pick an image from gallery.
3. View predicted class, confidence and recommendations.
4. Save result — stored in local SQLite history. Tap history items to re-open result screen.

---

## Model conversion (recommended pattern)

Use a representative dataset for INT8 quantization:

```python
converter = tf.lite.TFLiteConverter.from_keras_model(keras_model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

def representative_dataset():
    for _ in range(100):
        batch = next(train_generator)  # float32 batch, shape [N,H,W,C]
        yield [batch[0].astype(np.float32)]

converter.representative_dataset = representative_dataset
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.uint8
converter.inference_output_type = tf.uint8
tflite_model = converter.convert()
open('models/model_quant.tflite','wb').write(tflite_model)
```

**Note:** On inference you must use `output_details[0]['quantization']` to dequantize logits:

```
real_output = (raw_output.astype(np.float32) - zero_point) * scale
```

---

## Example output format

```
Predicted class: Early_blight
Confidence: 87.42%
```

Result screen should display:

* formatted class name (`EARLY BLIGHT`)
* confidence percent and graphical confidence bar (0–100%)
* concise, actionable recommendations

---

## Git / Storage recommendations

* Add to `.gitignore`: `mobile_app/build/`, `models/`, `data/raw/`, `data/processed/`
* Use **Git LFS** for large model files (if you want to version them):

```bash
git lfs install
git lfs track "*.tflite"
git add .gitattributes
git add models/model_quant.tflite
git commit -m "Track tflite via LFS"
git push origin main
```

* **Do not** commit build artifacts (`*.so`, `*.apk`, `build/`).

---

## Evaluation artifacts (where to find)

* Confusion matrices & classification reports → `models_report/` (PNG / CSV)
* Latency & benchmark results → `models_report/benchmark.md`
* Model card (intended use, accuracy, limitations) → `models_report/model_card.md`

When preparing reports include: precision, recall, F1 per class, confusion matrix, ROC/AUC if applicable, and type I/II error rates.


