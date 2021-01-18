# Author: Guido van der Heijden
# January 2021

################# set-up ##################

# Start by clearing the info window
clearinfo

# Blanc line for the output
appendInfoLine: ""

form Fill attributes
	sentence Session_id      "NO_SESSION"
	sentence Speaker         ""
	real     utterance_start -1.0  
    real     pause_start     -1.0
	sentence Transition      "MISSING"
	boolean  verbose         0
endform
# 

############# start of script #############

Create Strings as file list: "sound_file_list", "C:\\Users/Guido vd Heijden/Documents/School/Master - year 1 - 1b/Speech Processing/Praat/HCRC/wav/" + session_id$ + ".*." + speaker$ + ".wav"

selectObject: "Strings sound_file_list"
name_file$ = Get string: 1

Read from file: "C:\\Users/Guido vd Heijden/Documents/School/Master - year 1 - 1b/Speech Processing/Praat/HCRC/wav/" + name_file$

# Save properties of the sound file for later
obj$ = selected$("Sound")
soundid = selected("Sound")
originaldur = Get total duration

# Print formatted input to screen if verbose
if verbose
	appendInfo:     name_file$ + "  "
	appendInfo:     utterance_start
	appendInfo:     "-"
	appendInfo:     pause_start
	appendInfoLine: "  "+ transition$
endif


# The utterance can be shorter than the feature is engineered for, e.g. the mean pitch over 1000ms 
# should be taken over the duration of the utterance if utterance_duration < 1000ms
start_200ms  = max(utterance_start, pause_start-0.2)
start_300ms  = max(utterance_start, pause_start-0.3)
start_500ms  = max(utterance_start, pause_start-0.5)
start_1000ms = max(utterance_start, pause_start-1.0)



# Extract fundamental frequency (f0) features
# - absolute value of the f0 slope over the last 200 and 300 ms of speech before the silence
select 'soundid'
To Pitch... 0.01 75.0 500.0
f0id = selected("Pitch")
Down to PitchTier
pitchtierid = selected("PitchTier")

select 'pitchtierid'
index_pause_start = Get nearest index from time... pause_start
pitch_pause_start = Get value at index... index_pause_start

select 'pitchtierid'
index_200ms       = Get nearest index from time... start_200ms
pitch_200ms       = Get value at index... index_200ms

select 'pitchtierid'
index_300ms       = Get nearest index from time... start_300ms
pitch_300ms       = Get value at index... index_300ms

pitch_slope_200ms  = abs(pitch_pause_start-pitch_200ms)  / (pause_start-start_200ms)
pitch_slope_300ms = abs(pitch_pause_start-pitch_300ms) / (pause_start-start_300ms)


# Extract speaking rate feature
# - Speaking rate, measured in syllable nuclei per second over the whole utterance before the pause
#
# Syllable nuclei where annotated using Praat_Script_Syllable_Nuclei.praat
# Input arguments to script: 0 2 yes
# Source: https://sites.google.com/site/speechrate/Home/praat-script-syllable-nuclei
# Paper:  www.doi.org/10.3758/BRM.41.2.385
Create Strings as file list: "syllable_nuclei_file_list", "C:\\Users/Guido vd Heijden/Documents/School/Master - year 1 - 1b/Speech Processing/Praat/HCRC/wav/" + session_id$ + "_*_" + speaker$ + ".syllables.TextGrid"

selectObject: "Strings syllable_nuclei_file_list"
name_file$ = Get string: 1

Read from file: "C:\\Users/Guido vd Heijden/Documents/School/Master - year 1 - 1b/Speech Processing/Praat/HCRC/wav/" + name_file$

syllablenucleiid = selected("TextGrid")
select 'syllablenucleiid'

syllable_start = Get high index from time... 1 utterance_start
syllable_end   = Get low index from time...  1 pause_start

syllable_nuclei_per_second_utterance = (syllable_end-syllable_start+1) / (pause_start-utterance_start)


# Extract intensity features 
# - mean intensity over the last 500 and 1000 ms before the silence
select 'soundid'
To Intensity... 50.0 0.0 yes
intensityid = selected("Intensity")

select 'intensityid'
mean_intensity_500ms  = Get mean... start_500ms pause_start energy
mean_intensity_1000ms = Get mean... start_1000ms pause_start energy


# Extract pitch features 
# - mean pitch over the last 500 and 1000 ms before the silence
select 'soundid'
To Pitch... 0.01 75.0 600.0
pitchid = selected("Pitch")

select 'pitchid'
mean_pitch_500ms  = Get mean... start_500ms pause_start Hertz
mean_pitch_1000ms = Get mean... start_1000ms pause_start Hertz


# Extract utterance duration feature
# - utterance duration in ms
utterance_duration = pause_start-utterance_start


# Extract jitter feature
# - jitter last 500 ms before the silence
select 'soundid'
To PointProcess (periodic, cc)... 75.0 500.0
pointprocessid = selected("PointProcess")
select 'pointprocessid'
jitter_500ms = Get jitter (local)... start_500ms pause_start 0.0001 0.02 1.3

# Extract shimmer feature
# - shimmer last 500 ms before the silence
select 'soundid'
plus 'pointprocessid'
shimmer_500ms = Get shimmer (local)... start_500ms pause_start 0.0001 0.02 1.3 1.6


# Extract noise-to-harmonics feature
# - noise-to-harmonics last 500 ms before the silence
select 'soundid'
To Harmonicity (cc)... 0.01 75.0 0.01 1.0
harmonicityid = selected("Harmonicity")
select 'harmonicityid'
noise_to_harmonics_500ms = Get mean... start_500ms pause_start




# Local features are printed to the info window (or cmd when run from there) if verbose
if verbose
	appendInfo:     "f0 slope 200ms:                       "
	appendInfoLine: pitch_slope_200ms
	appendInfo:     "f0 slope 300ms:                       "
	appendInfoLine: pitch_slope_300ms
	appendInfo:     "Syllable nuclei / second (utterance): "
	appendInfoLine: syllable_nuclei_per_second_utterance
	appendInfo:     "Mean intensity 500ms:                 "
	appendInfoLine: mean_intensity_500ms
	appendInfo:     "Mean intensity 1000ms:                "
	appendInfoLine: mean_intensity_1000ms
	appendInfo:     "Mean pitch 500ms:                     "
	appendInfoLine: mean_pitch_500ms
	appendInfo:     "Mean pitch 1000ms:                    "
	appendInfoLine: mean_pitch_1000ms
	appendInfo:     "Utterance duration                    "
	appendInfoLine: utterance_duration
	appendInfo:     "Jitter 500ms:                         "
	appendInfoLine: jitter_500ms
	appendInfo:     "Shimmer 500ms:                        "
	appendInfoLine: shimmer_500ms
	appendInfo:     "Noise-to-harmonics ratio 500ms        "
	appendInfoLine: noise_to_harmonics_500ms
endif




# Write output to file
appendFileLine: "HCRC/local_features/local_features_"+ session_id$ + "_" + speaker$ +".csv", pause_start, ",", pitch_slope_200ms, ",", pitch_slope_300ms, ",", syllable_nuclei_per_second_utterance, ",", mean_intensity_500ms, ",", mean_intensity_1000ms, ",", mean_pitch_500ms, ",", mean_pitch_1000ms, ",", utterance_duration, ",", jitter_500ms, ",", shimmer_500ms, ",", noise_to_harmonics_500ms


# Note: all features are z-normalized in a separate Jupyter Notebook
