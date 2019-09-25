
# code to fetch data from the website #Tripadvisor 

# install.packages("rvest")
# install.packages("purrr")
# install.packages("XML")
# install.packages("plyr")
# install.packages("tidytext")
# install.packages("reshape")
# install.packages("fetch")
# install.packages("textcat")
# install.packages("cld2")
# install.packages("cld3")
# install.packages("tidyverse")

library(rvest)
library(XML)
library(plyr)
library(dplyr)
library(purrr)
library(textcat)
library(cld2)
library(cld3)
library(tidyverse)
library(tidytext) 
library(tidyr)
library(textcat)
library(tm)

## scrap airline name and Number of Totalreviews.  
# values in x vector is combine with url_base and gather the airline name,total review for each airline.  
# map df applay  function(i) to the vector  x and create dataframe with column airline_name,totalreviews.  
# sprintf  returns a  vector which is combination of url_base text and variable 'a' values.
# Read_html function will read the content from a .html file assign this value to the variable Webpage.
# html_nodes function select value of the sepecific class from the html_document.  
# html_text extract text from the html nodes output.
# Gsub is use to remove the string "reviews" assosiated with each observation in column Totalreviews. 

setwd("C:\\Users\\MOLAP\\Documents\\R\\TRIP_ADVISOR_REVIEWS")
x<-c("d8729113","d8729177","d8729108","d8729026","d15052991","d8729060","d8729020","d8729089","d8729002","d14190667","d8729125") 
url_base <- "https://www.tripadvisor.ie/Airline_Review-%s"

map_df(x, function(a) {
    webpage <- read_html(sprintf(url_base, a))  
    data.frame(AIRLINE_NAME=html_text(html_node(webpage, ".heading_height")),
   Totalreviews=gsub("reviews","",html_text(html_nodes(webpage, ".numRatings"))),
   stringsAsFactors=FALSE)
})-> AIRLINE_DETAILS 



#code is used to scrap Rating Names for the airlines.Consider only one airline as the ratings names are same for
#all the airlines.  

url1 <- 'https://www.tripadvisor.ie/Airline_Review-d8729160-Reviews-Swiss-International-Air-Lines'
webpage1<-read_html(url1)  
RATING_NAME<-rbind(html_text(html_nodes(webpage1,"#AIRLINE_DETAIL_MAIN_WRAPPER .text")))
RATING_NAME<-c("overall_rating",RATING_NAME)

# scrap overall_rating,Customer Servic,Legroom,Seat Comfort,Cleanliness,Value for Money,
# Check-in and Boarding,Food and Beverag,In-flight entertainment (WiFi, TV, films) for all the airline 
# past funuction combine tripadvisor url with element of x vector for each page and then lapply run the function on each page.
# select nodes with class .ui_bubble_rating and create list for all the ratings from all the apllied page 
# Rating contain list of 11 list one list for each  airline page.

Rating <- lapply(paste0('https://www.tripadvisor.ie/Airline_Review-', x),
                 function(url){
                   url %>% read_html() %>% 
                     html_nodes(".ui_bubble_rating") 
                 })

# Rating output is list of list. Each list contain xml_nodeset.
# Need to extraact xml attributes from xml_nodeset for each list to get the rating value 
# lapply is used to apply function to the xml_attr of each rating list to create list of data frame. 
# extracting  1st 9 rows from alt column of each dataframe as contains rating value and replacing "of 5 bubbles" using gsub  
 


df.RATING=c()
for(i in 1:11)
{
  df.RATING[[i]]<-bind_rows(lapply(xml_attrs(Rating[[i]]),function(x) data.frame(as.list(x), stringsAsFactors=FALSE)))
  df.RATING[[i]]<-gsub("of 5 bubbles","",head(df.RATING[[i]]$alt,9))
} 

#combine all char lists in df.rating into one variable of the data frame. 
df.RATING2<-data.frame(cbind((df.RATING)))

# craeting dataframe all_rating
ALL_RATINGS<-data.frame(t(sapply(df.RATING,c)))

#asssign column name to the data frame 
colnames(ALL_RATINGS)<-c(RATING_NAME) 

# combine data frame Airline details which contains airlinename and total number of reviews and 
# all_ratings which contains 9 type of ratings for each airline.
AVIATION_DF<-cbind(AIRLINE_DETAILS,ALL_RATINGS)

# remove the unwanted right spaces from the column airline name and "\n" 
AVIATION_DF$AIRLINE_NAME<-trimws(AVIATION_DF$AIRLINE_NAME, which = c( "right"))
AVIATION_DF$AIRLINE_NAME<-gsub("\n","",AVIATION_DF$AIRLINE_NAME)

# changing the airline name as per the names in DIM_airline table.
# Due to this it is easy to load the rating values and total reviews number in fact table. 
 

AVIATION_DF$AIRLINE_NAME<-revalue(AVIATION_DF$AIRLINE_NAME,c("Lufthansa" = "Lufthansa German Airlines",
                                                             "United Airlines" = "United Air Lines Inc.",
                                                             "LAN Airlines (now LATAM Airlines) (Now LATAM Airlines)" ="Lan Colombia",
                                                             "Atlas Air" ="Atlas Air Inc.",
                                                             "TAG" = "TAG Aviation Espana S.L.",
                                                             "Delta Air Lines" = "Delta Air Lines Inc.",
                                                             "American Airlines" = "American Airlines Inc.",
                                                             "Iberia"= "Iberia Air Lines Of Spain",
                                                             "Air Europa" = "Air Europa",
                                                             "Laudamotion"= "Lauda Motion GmbH",
                                                             "Norwegian" ="Norwegian Air Shuttle ASA"))

    
                        #######SENTIMENTAL ANALYSIS CODE #########

# SCRAP REVIEWS FOR AIRLINE "AIR_EUROPA" FROM TRIP ADVISOR.AND THIS MODULE IS sAME FOR ALL OTHER 10 AIRLINES. 
# THERE ARE MORE THAN  120000 REVIEWS ON TRIP ADVISOR FOR ALL 10 AIRLINES AND IT IS TAKING 5-6 HOURS TO EXECUTE THE CODE. 
# Total number of pages of "AIR_EUROPA" on tripadvisor are 108 each page conatins 10 reviews 
# x is vector which contain values from 10 to 1080 and seperated by 10 
# map df applay  function(i) to the vector  x and create dataframe.  
# sprintf  returns a  vector which is combination of url_base text and variable 'a' values.
# Read_html function will read the content from a .html file assign this value to the variable Webpage.
# html_nodes function select value of the sepecific class from the html_document.  
# html_text extract text from the html nodes output.


x<-seq(10,1080,by=10)
url_base <- "https://www.tripadvisor.ie/Airline_Review-d8729002-Reviews-or%d"
map_df(x, function(i) {
  
  webpage <- read_html(sprintf(url_base, i))
  reviews<-html_nodes(webpage,"#REVIEWS .innerBubble")
  id<-html_node(reviews,".quote a")%>%
  html_attr("id")
  quote<-html_text(html_node(reviews ,".quote span"))
  review <-html_text(html_node(reviews,".entry .partial_entry"))
  df<-data.frame(id,quote,review,Airline_name="Air Europa", stringsAsFactors = FALSE)
}) -> Air_Europa

write.csv(Air_Europa,"Air_Europa.csv",row.names = F)


# scrapped data of Airline review from trip advisor and is use as the input to the below code 
# This function will pick all the files from the working directory with file extension as .csv

temp = list.files(pattern="*.csv")                                    
for (i in 1:length(temp))                                              
assign(temp[i], read.csv(temp[i],stringsAsFactors = F))

# creating single data frame from all the dataframe
DATA<-data.frame(rbind(Air_Europa.csv,American_Airlines.csv,Delta_Air_Lines.csv,           
                       Iberia.csv,LAN_Airlines.csv,Laudmotion.csv,
                       Lufthans.csv,TAG.csv,united_airlines.csv,Norwegian.csv),stringsAsFactors = F)

# language detection mechanisam is used cld2 and cld3 are most reliable compare to textcat   



DATA$review<-gsub(pattern="\\W",replace=" ",DATA$review);
DATA$review<-gsub(pattern="\\d",replace=" ",DATA$review);
DATA$review<-tolower(DATA$review)
DATA$review<-removeWords(DATA$review,stopwords())
DATA$review<-gsub(pattern = "\\b[a-z]\\b{1}",replace=" ",DATA$review)
DATA$review<-stripWhitespace(DATA$review)


DATA<-DATA %>% mutate( 
                      Airlin_name=DATA$Airline_name,
                      cld2=cld2::detect_language(text = review ,plain_text = FALSE),    
                      cld3=cld3::detect_language(text = review)) %>%                      
                      select(review,cld2,cld3,Airline_name) %>%
                      filter(cld2=="en"& cld3=="en")


text_df<-data_frame(text=DATA$review,airline_name=DATA$Airline_name)
rm(text_df)
afin <-get_sentiments("afinn") 
bing <-get_sentiments("bing") 
nrc<-get_sentiments("nrc") 

text_df<-unique(text_df)
text_df$ID <- seq.int(nrow(text_df))
text_df<-text_df %>% unnest_tokens(word,text)

# afinsent<-text_df %>%
# inner_join(afin) %>%
# summarise(sentiment= sum(score))
#bing
####bingSent###3

bingSent <-text_df %>%
inner_join(bing)%>%
spread(sentiment, ID, fill = 0) %>%
mutate(sentiment = positive - negative)
final_sentiment<-aggregate(bingSent[, 3:5], list(bingSent$airline_name), mean)
colnames(final_sentiment)<-c("AIRLINE_NAME","POSITIVE","NEGATIVE","SENTIMENTS")
final_sentiment<-cbind(AVIATION_DF,final_sentiment[,2:4])

setwd("C:\\Users\\MOLAP\\Documents\\R")
write.csv(final_sentiment,"RAW_DATA_AIRLINE_RATING.csv",row.names = F )

# all_positive<- aggregate(bingSent$positive, by=list(Category=bingSent$airline_name), FUN=sum)
# all_negative<- aggregate(bingSent$negative, by=list(Category=bingSent$airline_name), FUN=sum)
# all_sentiments<-aggregate(bingSent$sentiment, by=list(Category=bingSent$airline_name), FUN=sum)
# final_sentiment<- data.frame(cbind(all_positive$Category,all_positive$x,all_negative$x,all_sentiments$x))
# colnames(final_sentiment)<-c("AIRLINE_NAME","POSITIVE","NEGATIVE","SENTIMENTS")
# as.data.frame((table(bingSent$airline_name)))
# aggregate(bingSent[, 3:5], list(bingSent$airline_name), mean)
# sapply(split(bingSent[,3:5],bingSent$airline_name)),mean
# by(bingSent[3:5],bingSent$airline_name,mean)
