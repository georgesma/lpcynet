cdef extern from "include/lpcnet.h":
  cdef short NB_FEATURES
  cdef short NB_TOTAL_FEATURES
  cdef short LPCNET_FRAME_SIZE
  cdef short LPCNET_PACKET_SAMPLES

  struct LPCNetState:
    pass

  struct LPCNetEncState:
    pass

  LPCNetState* create "lpcnet_create"()
  int init "lpcnet_init"(LPCNetState *lpcnet)
  void synthesize "lpcnet_synthesize"(LPCNetState *st, const float *features, short *output, int N)

  LPCNetEncState* create_encoder "lpcnet_encoder_create"()
  int init_encoder "lpcnet_encoder_init"(LPCNetEncState *st)
  int compute_features "lpcnet_compute_features"(LPCNetEncState *st, const short *pcm, float features[4][55])
