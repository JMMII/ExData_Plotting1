#-----
#This R code is for Project 1 from Coursera's Exploratory Data Analysis course.
#-----

#load raw data txt filenames
txtrawfile <- "household_power_consumption.txt"

#if txt data file doesn't exist within working directory, check for zip file. If neither exists, create new directory, set wd to new directory, download zip file, and unzip the data file.
if( ! file.exists(txtrawfile)) {
        if( ! file.exists(ziprawfile)) {
                #create subdirectory within working directory to store project files, then set wd
                dir.create("EDAProject1")
                workdir <- getwd()
                projectfolder <- paste(workdir,"EDAProject1", sep="/")
                setwd(projectfolder)
                
                #load the raw data zip file download location
                zipfileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
                
                #load raw data zip filename
                ziprawfile <- "household_power_consumption.zip"
                
                #download the zip file into the working directory and name the file rawdata.zip
                download.file(zipfileURL, destfile = "rawdata.zip", method = "curl")                
                
                #unzip the file into working directory
                unzip("rawdata.zip") 
        } 

}


#At this point, we have downloaded and extracted the txt data file that we need, but we still need to load parts of it into R.
#It is a large txt file with over 2 million rows, and we only want data from days 2007-02-01 and 2007-02-02.
#Note: the dates in the txt file are in a different format.

#As a note to methods used to analyze a large data file, pull in the first few rows
#to see what the data starts to look like. 
#To do this, I used read.csv to pull in the first 10 rows to get a sense of
#the headers and data formats in the rows.

#In looking at the readme file from the Project parameters, the sep char is sep=";" and the NA.char = "?"

readsample <- read.table(txtrawfile,header=TRUE, nrows=10,sep=";",na.strings = "?", stringsAsFactors = FALSE)
#head(readsample)

#In looking at the file, the date column is "day/month/year". This means we
#need to tell R that the format is strptime(txtrawfile, %d/%m/%y).
#We need to do a subset(txtrawfile, Date >= "2007-02-01" & Date <= "02/02/2007")

#Now, we need to figure out the class of each column to help reduce time to 
#load the full file (filtered) into R, not just this small sample.
txtClasses <- sapply(readsample,class)

#The Date and Time classes are shown as 'character'. The rest are classed as 'numeric'.
#See if we can reload the first few rows as before, but set the classes during the load.
#We can use txtClasses to specify the classes of the columns when loading the data.

#Once the data is loaded, we can use strptime() to convert factors to POSIXlt.
#Because we loaded read.table and the Date and Time are char vectors, we use
#strptime().

#We could also use the Lubridate package. For this project, to not have to code
#how to check whether a package is installed, I'm sticking with using strptime()
#for this project.

#Based on the above, reload the sample data using the following:
#readsample <- read.table(txtrawfile, header = TRUE, colClasses=txtClasses, nrows=10,sep=";",na.strings = "?", stringsAsFactors = FALSE)

#Side Note: I found a great explanation of the stringsAsFactors at http://simplystatistics.org/2015/07/24/stringsasfactors-an-unauthorized-biography/

#Because the Date column is character, need to change it to POSIX

#Use strptime() to convert Date and Time columns into POSIXlt, and reload into data.

#readsample$Date <- strptime(readsample$Date, format = '%d/%m/%Y')
#readsample$Time <- strptime(readsample$Time, format = '%H:%M')

#At this point, I know how to clean the data that I need, but I still need to 
#extract the full data from those two days, and only those two days, from the full dataset
#as specified in the Project. Will use read.csv.sql()

projData <- read.csv.sql(txtrawfile,sql = "SELECT * FROM file WHERE (Date='1/2/2007' OR Date='2/2/2007') ", header = TRUE, sep = ";", colClasses = txtClasses)
#This should give you a dataset with 2880 observations. This makes sense because 
#the date range is two days, which is 48 hours, and an obs is made each minute.
#48 hours/period x 60 obs/hour = 2880 obs.

#Note: the raw file Date field when in a char string is not dd/mm/yyyy. So, the leading zeros aren't needed. 
#If you put them in, you will get zero rows in projData. 

#The Project 1 readme tells us to use "?" as the na.char. read.csv.sql() does
#not have the na.char parameter to remove those. So, there may be some in the data
#that have to be removed. 

#reclassify the Date and Time fields into POSIX
projData$Date <- strptime(projData$Date, format = '%d/%m/%Y')
projData$Time <- strptime(projData$Time, format = '%H:%M')

#We now have a dataset to use that didn't take forever to load, and one we can 
#use to make the plots required by Project 1.

#Plot 1 code

#open graphics device, create filename and set width and height 
png(filename = "Plot1.png", width = 480, height = 480)

#create the plot
with(projData,hist(projData$Global_active_power, col="red", main = "Global Active Power", xlab = "Global Active Power (kilowatts)"))

#turn off the graphics device
dev.off()
