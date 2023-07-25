# LPCyNet

LPCyNet is a Cython wrapper that allows Python access to the high-performance C version of LPCNet.

This wrapper was designed for the latest 2019 version of LPCNet but may work with more recent versions.

## Setup

1. Download and compile [this version](https://github.com/xiph/LPCNet/tree/3a7ef33dcbade95ec08b85839b6268e35b8d3366) of LPCNet.
2. Copy the following files from LPCNet into the `./lpcnet` folder of LPCyNet:
```
./libs/liblpcnet.so
./libs/liblpcnet.so.0
./libs/liblpcnet.so.0.0.0
```
3. Copy the `./include/lpcnet.h` file from LPCNet into the `./include` LPCyNet folder.
4. Run `sh build.sh`.
5. You should now have a `lpcynet.cpython-*.so` file that you can include from Python using `import lpcynet`.

## Usage

```python
import lpcynet
from scipy.io import wavfile

sampling_rate, pcm = wavfile.read("test.wav")
# Your wav file should be compatible with LPCNet
assert sampling_rate == 16000 and pcm.dtype == "int16"

# Returns a float32 numpy array of shape (frame_number, features_dimension)
# features_dimension = 20, with the first 18 numbers representing the ceptrum
# and the last 2 representing respectively the period and the correlation parameters
lpcnet_features = lpcynet.analyze_frames(pcm)

resynthesized_pcm = lpcynet.synthesize_frames(lpcnet_features)

wavfile.write("resynth.wav", 16000, resynthesized_pcm)
```
