cimport lpcnet
from lpcnet cimport NB_FEATURES, LPCNET_FRAME_SIZE, LPCNetState, LPCNetEncState, LPCNET_PACKET_SAMPLES
import numpy as np

cdef LPCNetState* state = lpcnet.create()
cdef LPCNetEncState* encoder_state = lpcnet.create_encoder()

## Synthesis
def reset_synth_state():
  lpcnet.init(state)

def synthesize_frame(frame_features, pcm=None):
  features = np.zeros(NB_FEATURES, dtype='float32')
  assert features.flags['C_CONTIGUOUS']
  cdef float[:] features_view = features
  features[0:18] = frame_features[0:18]
  features[36:38] = frame_features[18:20]

  if pcm is None:
    pcm = np.empty(LPCNET_FRAME_SIZE, dtype='int16')
  assert pcm.flags['C_CONTIGUOUS']
  cdef short[:] pcm_view = pcm

  lpcnet.synthesize(state, &features_view[0], &pcm_view[0], LPCNET_FRAME_SIZE)
  return pcm

def synthesize_frames(frames_features, reset_state=True):
  if reset_state:
    reset_synth_state()

  cdef Py_ssize_t nb_frames = len(frames_features)

  features = np.zeros(NB_FEATURES, dtype='float32')
  assert features.flags['C_CONTIGUOUS']
  cdef float[:] features_view = features

  pcm = np.empty(nb_frames * LPCNET_FRAME_SIZE, dtype='int16')
  assert pcm.flags['C_CONTIGUOUS']
  cdef short[:] pcm_view = pcm

  cdef Py_ssize_t i_frame
  for i_frame in range(nb_frames):
    features[0:18] = frames_features[i_frame, 0:18]
    features[36:38] = frames_features[i_frame, 18:20]
    lpcnet.synthesize(state, &features_view[0], &pcm_view[i_frame * LPCNET_FRAME_SIZE], LPCNET_FRAME_SIZE)

  return pcm

## Features extraction
def reset_encoder_state():
  lpcnet.init_encoder(encoder_state)

cdef float[4][55] out_features
cdef float[:, :] out_features_view = out_features
def analyze_frame(pcm, features=None):
  assert pcm.flags['C_CONTIGUOUS']
  cdef short[:] pcm_view = pcm

  lpcnet.compute_features(encoder_state, &pcm_view[0], out_features)

  if features is None:
    features = np.empty((4, 20), dtype='float32')
  assert features.flags['C_CONTIGUOUS']

  cdef float[:, :] features_view = features
  features_view[:, 0:18] = out_features_view[:, 0:18]
  features_view[:, 18:20] = out_features_view[:, 36:38]

  return features

def analyze_frames(pcm, clean_state=True):
  if clean_state:
    reset_encoder_state()

  nb_superframes = int(len(pcm) / 160 / 4)
  nb_frames = nb_superframes * 4
  features = np.empty((nb_frames, 20), dtype="float32")

  cdef Py_ssize_t i
  for i in range(nb_superframes):
    analyze_frame(pcm[i*4*160:(i+1)*4*160], features[i*4:(i+1)*4])

  return features

