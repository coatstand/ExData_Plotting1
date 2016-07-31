############################################
# Script to generate plot1 of the assignment
############################################

# Load the required packages
library(dplyr)
library(lubridate)

# As the data set is large and we are creating 4 scripts to generate plots, 
# to speed this up we will only read the large file in once.
# After the initial read, the script creates a new file
# "small_power_consumption.txt" that contains data just for 01-02-2007 and
# 02-02-2007.
# In order to create the 2nd and subsequent plots, this smaller file can then
# be read in faster and used to generate the plots via different the other
# scripts. The small file creation code is included in all 4 scripts so that
# they can be run in any order.

# Check for existance of small data file
if (file.exists("small_power_consumption.txt")){
    # if it exists, read in this data
    powercon <- read.table("small_power_consumption.txt", header = TRUE,
                           sep = ";",
                           colClasses = c("character", "character", "numeric",
                                          "numeric", "numeric", "numeric",
                                          "numeric", "numeric", "numeric"))
    
    # Convert the Date column to a date object
    powercon$Date <- ymd(powercon$Date)
} else{
    # If the small file does not exist yet we need to read from the original
    # data
    # First check if we need to download the zip file
    if (!file.exists("household_power_consumption.zip")){
        download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip",
                      destfile = "household_power_consumption.zip")
    }
    
    # Then if we need to unzip it
    if (!file.exists("household_power_consumption.txt")){
        unzip("household_power_consumption.zip")
    }
    
    # Read in the data from the large file
    powercon <- read.table("household_power_consumption.txt",
                           header = TRUE,
                           sep = ";",
                           na.string = c("NA", "?"),
                           colClasses = c("character", "character", "numeric",
                                          "numeric", "numeric", "numeric",
                                          "numeric", "numeric","numeric"))
    
    # Convert the Date column to a date object
    powercon$Date <- dmy(powercon$Date)
    
    # Subset data to just the dates 01/02/2007 and 02/02/2007
    powerconfirst <- filter(powercon, Date == "2007-02-01")
    powerconsecond <- filter(powercon, Date == "2007-02-02")
    powercon <- rbind(powerconfirst, powerconsecond)
    
    # Remove ojects no longer needed
    rm(c(powerconfirst, powerconsecond))
    
    # Create the small file with just the required dates so that the script
    # can run faster next time
    write.table(powercon, file = "small_power_consumption.txt", sep = ";",
                row.names = FALSE)
}

# Include the date in the time column
powercon <- mutate(powercon, Time = paste(Date, Time))

# Convert Time column to POSIXlt object
powercon$Time <- strptime(powercon$Time, format = "%Y-%m-%d %H:%M:%S")

################
# Create Plot 1 
################

# Open the png device
png("plot1.png", width = 480, height = 480, units = "px")

# Plot the histogram for Global active power
hist(powercon$Global_active_power, col = "red", main = "Global Active Power",
     xlab = "Global Active Power (kilowatts)")

# Close the device
dev.off()

#######
# End
#######