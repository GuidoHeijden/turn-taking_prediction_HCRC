# Author: Guido van der Heijden
# January 2021
# Acknowledgement: this script reuses a lot of the code written in Khiet Trong's split_tg.praat script.

# Start by clearing the info window
clearinfo

# Get all TextGrid files in a directory
Create Strings as file list: "text_grid_list","C:\\Users/Guido vd Heijden/Documents/School/Master - year 1 - 1b/Speech Processing/Praat/HCRC/TextGrids_moves/*.TextGrid"

# Get the total number of strings of the list 
n_tg = Get number of strings

for i from 1 to 2 
# n_tg
	
	selectObject: "Strings text_grid_list"
	name_file$ = Get string: i
	
	# Open the TextGrid file in Praat
	Read from file: "C:\\Users/Guido vd Heijden/Documents/School/Master - year 1 - 1b/Speech Processing/Praat/HCRC/TextGrids_moves/" + name_file$

	# The object is automatically selected. Get the name of this object so we can refer to it later.
	name_object$ = selected$("TextGrid")
	appendInfoLine: name_object$

	# Extract tier 2 and 4 (these are the dialog acts for both the instruction giver and follower respectively) and merge them
	Extract one tier: 2
	name_tier2$ = selected$("TextGrid")
	selectObject: "TextGrid " + name_object$
	Extract one tier: 4
	name_tier4$ = selected$("TextGrid")
	selectObject: "TextGrid " + name_tier2$
	plusObject: "TextGrid " + name_tier4$
	Merge
	
	# Select the new TextGrid (merge of tiers 2 and 4) and replace all the "<empty>" labels in tiers 1 and 2 with "silent", and all other dialog acts with "speech"
	Replace interval texts: 1, 1, 0, "\<empty\>", "silent", "Regular Expressions"
	Replace interval texts: 1, 1, 0, "^(?!.*silent).*$", "speech", "Regular Expressions"
	Replace interval texts: 2, 1, 0, "\<empty\>", "silent", "Regular Expressions"
	Replace interval texts: 2, 1, 0, "^(?!.*silent).*$", "speech", "Regular Expressions"

	# Save the new TextGrid
	session$ = mid$(name_object$,1,5)
	Save as text file: "C:\\Users/Guido vd Heijden/Documents/School/Master - year 1 - 1b/Speech Processing/Praat/HCRC/TextGrids_moves/" + session$ + ".merged.moves.TextGrid"

endfor