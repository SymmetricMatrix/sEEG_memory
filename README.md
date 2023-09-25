# sEEG analysis code

## Main Parts
1. iEEG visualization - `ieeg_viz`
2. iEEG preprocess - in this folder
3. Navigation task - `navigation`
4. Memory task - `memory`

## iEEG Preprocess
Before running this code, make sure you have completed the following steps:
1. Brainstorm for electrode localization
2. Update table to `/bigvault/Projects/seeg_pointing/gather`
3. Update `event_code.m`

### Main Executive Function Description
1. `check_data.m`
   Check trigger and channel label in EDF file
2. `main_process.m`
The main preprocessing scripts include the following step:
a. iEEG data preprocess: `seeg_pre.m`
    - `pre_filter.m`
    - `pre_epoch.m`
    - `pre_sw.m`
b. Calculate Representational similarity: `seeg_rsa`
3. Result check
4. Load this subject data into the group:

## Navigation

## Memory
### Object
### Sequence
- `sequence_trigger_change.m` (notice: not well organized)
- `sequence_pre.m`
- `sequence_wavelet.m`
- `sequence_sw_and_obj2seq_rsa.m`

#### Plot Figure
- `sequence_plt_rsa_region123.m`

## Function
- `seegpre.m`
- `object_epoch.m`
- `ft_trialfun_edf.m`
- `sequence_epoch.m`
- `event_code.m` (notice: needs to be updated)
- `rsa_pre.m`
- `pic_sort.m`
- `obj_seq_rsa.m`
- `get_pic_label.m`

## Contributing

Billion (contact me: wxcw99@foxmail.com)
 
PRs accepted.

## License

MIT © Richard McRichface
