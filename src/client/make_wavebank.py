import glob, os, sys
from pathlib import Path
from obsplus import WaveBank
from obspy import UTCDateTime, read, stream

REPO_ROOT = Path(__file__).parent.parent
WB_DIR = REPO_ROOT/'data'/'waveforms'/'BANK'
WF_DIR = REPO_ROOT/'example_data'

DT = 600 # [sec] record lengths to write to wavebank

# Create WaveBank base path
os.makedirs(str(WB_DIR), exist_ok=True)
# Initialize Wavebank
WBANK = WaveBank(base_path=WB_DIR,
                 path_structure='{network}/{station}',
                 name_structure='{nslc}_{starttime}.mseed')

# Get list of waveforms
wf_list = glob.glob(str(WF_DIR/'*.mseed'))

# Iterate across miniseed files
for _f in wf_list:
    # load miniseed file 
    st = read(_f)
    # Iterate across traces in miniseed file
    for tr in st:
        # Produce DT-second long windows with no overlap
        for w_tr in tr.slide(window_length=DT, step=DT):
            # save a copy of windowed data to the WaveBank
            WBANK.put_waveforms(w_tr)
    