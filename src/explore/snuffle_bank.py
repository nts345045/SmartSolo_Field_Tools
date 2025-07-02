import os, sys
from pathlib import Path
from obspy import UTCDateTime
from pyrocko import obspy_compat
from pyrocko.gui.snuffler.marker import save_markers, load_markers
from obsplus import WaveBank

ROOT = Path(__file__).parent.parent
WB_DIR = ROOT/'data'/'waveforms'/'BANK'
MARKERS = ROOT/'processed_data'/'markers'/'bulk_markers.dat'

# Apply pyrocko monkey-patch (<-- literally a term of trade)
obspy_compat.plant()

# Initialize wavebank connection
WBANK = WaveBank(base_path=WB_DIR)

# Read picks file, or make it if it does not exist
try:
    markers = load_markers(str(MARKERS))
except:
    os.system(f'touch {str(MARKERS)}')
    markers = []

# Read all waveforms
st = WBANK.get_waveforms(network='*', station='*',
                         location='*', channel='*',
                         starttime=UTCDateTime('2025-01-01'),
                         endtime=UTCDateTime())

nslc_set = set([tr.id for tr in st])

# Launch snuffler
return_tag, tmp_markers = st.snuffle(ntracks=len(nslc_set), markers=markers)

# Save markers if any were populated
if len(tmp_markers) > 0:
    save_markers(tmp_markers, str(MARKERS))
