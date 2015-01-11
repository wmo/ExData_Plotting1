library(data.table) # for speed reasons

## filenames -----------------------------------------------------------------
filename<-"household_power_consumption.txt"
filename_subset<-"household_power_consumption_SUBSET.txt"
outputfilename<-"plot1.png"
## --------------------------------------------------------------------------

# STEP 1: because the different programs are going to use the same subset of 
# the data, this subset is first created and stored in a file, if it doesn't exist yet. 
if(!file.exists(filename_subset)) {
    if(!file.exists(filename)) {
        # if the original datafile is missing, then we can't do anything
        stop("Original data file '",filename,"' is missing from working directory!")
    }
    # read the data into a data.table (for speed reasons). All columns are character type, to avoid automatic conversions.
    dt<-fread( filename, sep=";", colClasses=rep("character",9), na.strings="?")
    # subset the data: only the required dates
    dtsub<-dt[Date %in% c("1/2/2007","2/2/2007")]
    # merge the date+time column into 1 column
    dtsub[, Date:=paste(Date, Time)]
    # drop the time column
    dtsub[, Time:=NULL]
    # now write everything out to the subset file
    write.table(dtsub,filename_subset,row.names=F,sep="\t",quote=F)
}

# STEP 2: prepare to plot the data 
png(filename=outputfilename, width = 480, height = 480)     # open a PNG graphics device

# read the subset of data into a dataframe, taking care of the datetime conversion
setClass("customDateTime")
setAs("character","customDateTime", function(from) strptime(from, format="%d/%m/%Y %H:%M:%S") )
customColClasses <- c("customDateTime", rep("numeric",7) )
df<-read.table(filename_subset, header=T, sep="\t", colClasses=customColClasses)

# STEP 3: the actual plotting 
hist( df$Global_active_power, col="red", main="Global Active Power", xlab="Global Active Power (kilowatts)" )

# STEP 4: wind down
dev.off()
print( paste( "File produced:", outputfilename))
