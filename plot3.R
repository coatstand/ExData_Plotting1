############################################
# Script to generate plot3 of the assignment
############################################

# Load the required packages
library(dplyr)
library(lubridate)

# As the data set is large and we are using 4 scripts to generate 4 plots using
# the same data set, we will speed up the execution by only reading the large
# file once.
# After the initial read, the script creates a new file
# "small_power_consumption.txt" that contains the data just for 01-02-2007 and
# 02-02-2007 (as these are the only 2 dates we are looking at).
# When the other scripts are run to generate the subsequent plots, if the file
# "small_power_consumpiton.txt" exists in the working directly, then this will
# be read into R instead of the large file.
# All 4 scripts include this code to either read or create the small file so
# that the scripts can be run independently and in any order.

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
    
    # Then if we need to unzip it (if this has not already been done)
    if (!file.exists("household_power_consumption.txt")){
        unzip("household_power_consumption.zip")
    }
    
    # Now we can read in the data from the large file
    powercon <- read.table("household_power_consumption.txt",
                           header = TRUE,
                           sep = ";",
                           na.string = c("NA", "?"),
                           colClasses = c("character", "character", "numeric",
                                          "numeric", "numeric", "numeric",
                                          "numeric", "numeric","numeric"))
    
    # Convert the Date column to a date object
    powercon$Date <- dmy(powercon$Date)
    
    # Extract data just for the dates 01/02/2007 and 02/02/2007
    powerconfirst <- filter(powercon, Date == "2007-02-01")
    powerconsecond <- filter(powercon, Date == "2007-02-02")
    powercon <- rbind(powerconfirst, powerconsecond)
    
    # Remove the ojects that are no longer needed
    rm(list = c("powerconfirst", "powerconsecond"))
    
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
# Create Plot 3
################

# Open the png device
png("plot3.png", width = 480, height = 480, units = "px")

# Start with line plot of sub metering 1
plot(powercon$Time, powercon$Sub_metering_1, type = "l",
     ylab = "Energy sub metering", xlab = "")

# Add in sub metering 2
points(powercon$Time, powercon$Sub_metering_2, type = "l", col = "red")

# Add in sub metering 3
points(powercon$Time, powercon$Sub_metering_3, type = "l", col = "blue")

# Add the legend
legend("topright", col = c("black", "red", "blue"), lwd = 2,
       legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

# Close the device
dev.off()

#######
# End
#######