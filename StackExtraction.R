#A little script for reading in Aus.Stack. Note: Alex is from far an expert and has 
  #plugged in code that appears to work. Feel free to add notes or required changes

#Packages required: 
library(raster)
library(sf)

#Required data: the camelot full export, as augmented by Barry's wonder code

### Camelot Survey .CSV analysis script -- BW Brook Oct 2020 ####################################################################
rm(list=ls()); options(scipen=999,digits=9) 
source('camelot_analysis_func.r')

###############YOU MAY NEED TO UPDATE THESE FILES################
op.df <- read.csv("opt_time_2021-5-10.csv") # read camera operating schedule
survey.df <- preproc_survey("full-export_2021-06-10_1643.csv") # read Camelot DB

#Note: Barry's code has much more than this and a detailed list of commands. 
  #Not included here to keep it simple. 
#################################################################




###########################R-R-R-Raster time ###########################################
#load in the raster file. Need to copy and paste the file location on the computer
  #NOTE make sure you use \\ instead of \ or /, as these result in errors. 
  #Change the location for your computer. 
f <- ("D:\\2020\\OneDrive - University of Tasmania\\CatPHD\\CatBehaviourCamera\\FlashAnalysis\\aus.stack.grd") ##If working from home change to F: 
stackTAS <- stack(f)#Tell R the file is a stack

#You need to extract your GPS points from the full export
cameraGPS <- unique(survey.df [c("cam", "lat", "lon")]) #Identifies rows with unique values for all three of these,
cameraGPSDF <- as.data.frame(cameraGPS) #Make this a dataframe 
shpt <- cameraGPSDF[, c(1, 3, 2)] #Reorder the columns to have lon second
colnames(shpt) <- c("Camera", "lon", "lat") #rename columns for easy reading 
shpt #Check all is okay, ready to be turned into an sf object  

p.sf <- st_as_sf(shpt, coords = c("lon", "lat")) 
p.sf
camera_points_sp <- as(p.sf, "Spatial") #Make this a spatial object 

#########Extract the stack information using our spatial GPS points!!!########
pop_dnb_df <- extract(stackTAS, camera_points_sp, df=TRUE)  ###Extract information for each camera GPS point 
#^ THIS MAY TAKE AWHILE!!! Don't be worried! Give it a few minutes. 
  #To make it faster, subset your data to the relevant sites BEFORE extracting the GPS points etc. 


#Now we need to add the camera names back to this dataframe. 
#In theory, these points should extract in the same order of the original frame. 
  #This way, we can just cbind out camera column back on.
    #FOR SAFETY: Sanity check a few random rows to make sure the camera-trap 
    #name corresponds to the correct row, as shown below. It is tedious but I havne't 
  #thought of a better way. 

##If you get paranoid that the below code won't merge correctly, put in sample 
##GPS points below and run the code and normal to cross check that it works. It does, btw
lon <- c(147.846780) 
lat <- c(-42.249070)
cam <- c("10_2")
shpt <- data.frame(cam, lon, lat) #Then run this dataframe using the code above,
  #Check if the environmental output matches that in the dataframe with all points 

pop_dnb_df$cam <- cameraGPS$cam
pop_dnb_df #Check it is all okay. TESTED FINE 12/01/2022
#NOTE: Not all cameras will have environmental info for all columns, check these before analysis! 
###############################################################################################################

#Now you can tamper with this data, making sure it reads correctly etc. 
#E.g. 
str(pop_dnb_df) #Check the structure of the dataframe. 
pop_dnb_df$Land.Use <- as.factor(pop_dnb_df$Land.Use)

#Can then merge this back into the original dataframe, or into a subset of camera traps from 
#The full export using the merge function. 
  #NOTE: sometimes this function messes up, so look for NAs. You can also 
    #google alternatives to the merge function 

survey.df.covariates<- merge(survey.df, pop_dnb_df, by = "cam")
#You should now has the original export file, but with additional columns with environmental covariates provided by AUS.Stack 





