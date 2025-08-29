```markdown
# 🌱 Intelligent System for Plant & Mutation Recognition

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=flat&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![GitHub repo size](https://img.shields.io/github/repo-size/statven/PlantRecognitionSystem?style=flat)](https://github.com/statven/PlantRecognitionSystem)

---

## TL;DR

Mobile application + ML pipeline that classifies plant species and detects leaf mutations/diseases using a compact CNN (EfficientNetB0). The app performs **offline inference** with a quantized TensorFlow Lite model and stores scan results locally (SQLite).

**Author:** Serhievich

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

---

## Troubleshooting & common pitfalls

* **Wrong labels shown**: ensure `labels.txt` / `class_indices.json` in `mobile_app/assets/` matches training order.
* **Constant predictions / low confidence**: verify preprocessing (EfficientNet `preprocess_input`), input dtype (`uint8` vs `float32`) and that representative dataset was used for quantization.
* **Large files rejected by GitHub**: remove them from commits and use `.gitignore` or Git LFS.
* **Flutter plugin issues (IDE)**: try `flutter pub get` and `flutter run` from terminal if IDE plugin fails.

---

## References

* Tan, M., & Le, Q. V. (2019). EfficientNet: Rethinking Model Scaling for CNNs. *ICML*.
* TensorFlow Lite — [https://www.tensorflow.org/lite](https://www.tensorflow.org/lite)
* PlantVillage dataset (Kaggle): [https://www.kaggle.com/datasets/emmarex/plantdisease](https://www.kaggle.com/datasets/emmarex/plantdisease)
* Potato Leaf Disease dataset (Kaggle)

---

## Contact & License

**Author:** Serhievich
**License:** MIT — see `LICENSE`

---

If you want, I can:

* generate a `requirements.txt` (finalized list),
* add a ready `.gitattributes` for Git LFS,
* scaffold `scripts/` with `train.py`, `convert_to_tflite.py`, and `test_inference.py`.

```
::contentReference[oaicite:0]{index=0}
```
