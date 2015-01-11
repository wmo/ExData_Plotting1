library(data.table) 

## filenames -----------------------------------------------------------------
filename<-"household_power_consumption.txt"
filename_subset<-"household_power_consumption_SUBSET.txt"
outputfilename<-"plot4.png"
## --------------------------------------------------------------------------

# STEP 1: because the different programs are going to use the same subset of 
# the data, this subset is first created and stored in a file, if it doesn't exist yet. 
if(!file.exists(filename_subset)) {
    if(!file.exists(filename)) {
        # if the original datafile is missing, then we can't do anything
        print(paste("Original data file '",filename,"' is missing from working directory!",sep=""))
        return
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
par(mfrow=c(2,2))
    # plot 1
plot(df$Date, df$Global_active_power, type="l", ylab="Global Active Power (kilowatts)", xlab="" )
    # plot 2
plot(df$Date, df$Voltage, type="l", ylab="Voltage", xlab="datetime" )
    # plot 3
with( df, plot( Date, Sub_metering_1, type="n", ylab="Enegry sub metering", xlab="") )
with( df, lines( Date, Sub_metering_1, col="black") )
with( df, lines( Date, Sub_metering_2, col="red") )
with( df, lines( Date, Sub_metering_3, col="blue") )
legend("topright", lty=1, col = c("black","red","blue"), legend = c("Sub_metering_1", "Sub_metering_2","Sub_metering_3"))
    # plot 4
plot(df$Date, df$Global_reactive_power, type="l", ylab="Global_reactive_power", xlab="datetime" )


# STEP 4: wind down
dev.off()
print( paste( "File produced:", outputfilename))

