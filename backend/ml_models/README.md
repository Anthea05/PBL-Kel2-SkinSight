# Folder model ML

Taruh file model hasil training di folder ini, lalu set `ML_MODE=local` di `.env`.

- Model dari branch **Rafazl** (notebook `Tr_Oilness_PBL.ipynb`) tersimpan di
  `runs/classify/train/weights/best.pt` (YOLOv8n-cls, `imgsz=224`, kelas `combination`, `dry`,
  `normal`, `oily`). Salin menjadi `ml_models/best.pt`.
- Model TensorFlow/Keras (`.keras` / `.h5`) juga didukung. Sesuaikan `ML_LABELS` dan
  `ML_IMAGE_SIZE` dengan saat training, lalu cek TODO di `app/services/ml_service.py`.

File model tidak di-commit (lihat `.gitignore`). Di Docker, folder ini di-mount read-only ke `/app/ml_models`.
