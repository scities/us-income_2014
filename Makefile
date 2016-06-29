# Author: Remi Louf <remi@sciti.es>
# Date:   24/03/2016
#
# Download all the data necessary to analyse the income of households
# Using the ACS 2014 data


all: blockgroups tracts counties

blockgroups: income_blockgroup
tracts: income_tract
counties: income_county


###########################
# METROPOLITAN AREAS DATA #
###########################


# Download 2014 US metro atlas from repo and unzip
data/gz/master.zip:
	curl -sL https://github.com/scities-data/metro-atlas_2014/archive/$(notdir $@) -o  $@.download
	mv $@.download $@

metro-atlas_2014/Makefile: data/gz/master.zip
	unzip -d ./ $<
	mv metro-atlas_2014-master $(dir $@)


	
# Crosswalk blockgroups
metro-atlas_2014/data/crosswalks/cbsa_blockgroup.txt: metro-atlas_2014/Makefile
	cd $(dir $<) && $(MAKE) $(subst metro-atlas_2014/, ,$@)

data/crosswalks/cbsa_blockgroup.txt: metro-atlas_2014/data/crosswalks/cbsa_blockgroup.txt
	mkdir -p $(dir $@)
	cp $< $@



# Crosswalk tracts
metro-atlas_2014/data/crosswalks/cbsa_tract.txt: metro-atlas_2014/Makefile
	cd $(dir $<) && $(MAKE) $(subst metro-atlas_2014/, ,$@)


data/crosswalks/cbsa_tract.txt: metro-atlas_2014/data/crosswalks/cbsa_tract.txt
	mkdir -p $(dir $@)
	cp $< $@



# Crosswalk counties
metro-atlas_2014/data/crosswalks/cbsa_county.txt: metro-atlas_2014/Makefile
	cd $(dir $<) && $(MAKE) $(subst metro-atlas_2014/, ,$@)

data/crosswalks/cbsa_county.txt: metro-atlas_2014/data/crosswalks/cbsa_county.txt
	mkdir -p $(dir $@)
	cp $< $@






###############
# INCOME DATA #
###############



# Decompress income data
data/income/us/ACS_14_5YR_B19001.csv:
	mkdir -p $(dir $@)
	gzip -d data/gz/$(notdir $@)
	mv data/gz/$(notdir $@) $@





# Income per CBSA
## Blockgroup level 
income_blockgroup: data/income/us/ACS_14_5YR_B19001.csv data/crosswalks/cbsa_blockgroup.txt
	mkdir -p data/income/cbsa
	python2 bin/income/blockgroups.py

## Tract leve
income_tract: data/income/us/ACS_14_5YR_B19001.csv data/crosswalks/cbsa_tract.txt
	mkdir -p data/income/cbsa
	python2 bin/income/tracts.py

## County level
income_county: data/income/us/ACS_14_5YR_B19001.csv data/crosswalks/cbsa_county.txt
	mkdir -p data/income/cbsa
	python2 bin/income/counties.py





# Compute the total population
## Per CBSA
data/counts/cbsa_households.txt:
	mkdir -p $(dir $@)
	python2 bin/counts/cbsa_population.py

## In the entire US
data/counts/us_households.txt:
	mkdir -p $(dir $@)
	python2 bin/counts/us_population.py




#
# Clean
#
clean:

