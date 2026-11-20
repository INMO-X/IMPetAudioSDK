# YAMNet model notice

- Artifact: `yamnet.tflite`
- Source: `https://storage.googleapis.com/mediapipe-models/audio_classifier/yamnet/float32/latest/yamnet.tflite`
- Downloaded for the original local validation: 2026-07-24
- Size: 4,126,810 bytes
- SHA-256: `4d8b4a53282dc83ef04e3e7dbc4fbc98082e34e44ed798e16c3a0cdd4c584faf`
- Contract: float32 waveform input `1 x 15600`, AudioSet/YAMNet 521-class output.
- Upstream: `https://github.com/tensorflow/models/tree/master/research/audioset/yamnet`
- Upstream repository license: Apache License 2.0.
- Android runtime: `com.google.mediapipe:tasks-audio:0.10.35` (Apache License 2.0).

This SDK uses the model for local inference only. It does not train the model,
persist embeddings, capture audio, or upload source audio. Before external or
production distribution, legal review must re-check the model artifact and
dependency notices against the then-current upstream distribution.
