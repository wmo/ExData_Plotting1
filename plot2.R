library(data.table) 

## filenames -----------------------------------------------------------------
filename<-"household_power_consumption.txt"
filename_subset<-"household_power_consumption_SUBSET.txt"
outputfilename<-"plot2.png"
## --------------------------------------------------------------------------

# if the subset file doesn't exist yet, then create it
if(!file.exists(filename_subset)) {
    # if the original datafile is missing, then we can't do anything
    if(!file.exists(filename)) {
        print(paste("Original data file '",filename,"' is missing from working directory!",sep=""))
        return
    }
    # read the data into a data.table (for speed reasons). All columns are character type, to avoid conversions.
    dt<-fread( filename, sep=";", colClasses=rep("character",9), na.strings="?")
    # subset the data
    dtsub<-dt[Date %in% c("1/2/2007","2/2/2007")]
    # merge the date+time column into 1 column
    dtsub[, Date:=paste(Date, Time)]
    # drop the time column
    dtsub[, Time:=NULL]
    # now write everything out to the subset file
    write.table(dtsub,filename_subset,row.names=F,sep="\t",quote=F)
}

# open a PNG graphics device
png(filename=outputfilename, width = 480, height = 480) 

# read the subset of data into a dataframe, taking care of the datetime conversion
setClass("customDateTime")
setAs("character","customDateTime", function(from) strptime(from, format="%d/%m/%Y %H:%M:%S") )
customColClasses <- c("customDateTime", rep("numeric",7) )
df<-read.table( filename_subset , header=T, sep="\t", na.strings="?", colClasses=customColClasses)

# ------------------------------------------------------------------------------------------------------------ 
# the plotting code 
plot(df$Date, df$Global_active_power, type="l", ylab="Global Active Power (kilowatts)", xlab="" )

# ------------------------------------------------------------------------------------------------------------ 

# close the device 
dev.off()
print( paste( "File produced:", outputfilename))

