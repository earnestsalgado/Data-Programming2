
library(tidyverse)
library(tidytext)
library(rvest)
library(udpipe)
library(nametagger)
library(SnowballC)
library(stringr)
library(anytime)
library(sf)
library(spData)
library(scales)
library(RColorBrewer)
library(tidycensus)
library(tmap)
library(ggrepel)

setwd("C:/Users/guill/OneDrive/Documents/Data and Programming II/final project")

table1 <- tibble()
one_file <- list()

for (i in 1:581) {
  url <- paste0("https://cwbchicago.com/page/",i)
  url <- read_html(url)
  main_sqr <- html_node(url, "#main-content")
  article <- html_nodes(main_sqr, "article")
  
  dates_spe <- html_nodes(article, ".entry-meta-date")
  dates <- html_text(dates_spe, "href")
  
  site_spe <- html_nodes(article, ".mh-thumb-icon")
  sites <- html_attr(site_spe, "href")
  
  table_new <- tibble(dates, sites)
   table1 <- rbind(table1, table_new)

}

table1$dates <- anytime(table1$dates)

table_sub<- subset(table1, dates >= "2019-06-01" & dates <= "2019-09-30")

# We can add a function in this line to input Date Start and Date End
# So the code below (to extract the text and plot the sentiment analysis)
# can be reactive

for (i in 1:nrow(table_sub)) {
  web <- table_sub$sites[i]
  web <- read_html(web)
  main_art <- html_node(web, "#main-content")
  main_text <- html_nodes(main_art, ".entry-content")
  content <- html_text(main_text, "p")
  only_text <- paste(content, collapse = "")
  one_file[only_text] <- only_text
}

all_text <- tibble(text_art = one_file)
one_file_df <- unnest_tokens(all_text, word_tokens, text_art, token = "words")
final_text <- anti_join(one_file_df, stop_words, by = c("word_tokens" = "word"))
write.csv(final_text,"text_data.csv", row.names = FALSE)

# sentiment analysis (general)
sentiment_nrc <-   get_sentiments("nrc")
text_nrc <- final_text %>%
  left_join(get_sentiments("nrc"), by = c("word_tokens" = "word"))

plot_nrc <- ggplot(data = filter(text_nrc, !is.na(sentiment))) +
  geom_histogram(aes(sentiment), stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Sentiment Analysis - Crimes's News Coverage",
       subtitle = "CWB Chicago, Summer 2019") +
  theme_minimal()

plot_nrc <- ggsave(filename = "Sentiment Analysis - Crimes News Coverage.png", 
                   plot = plot_nrc,
                   bg = "white")

# sentiment analysis (mental health)

web_mental <- "https://thesaurus.yourdictionary.com/mental-health"
web_mental <- read_html(web_mental)
main_syn <- html_node(web_mental, ".single-synonym-wrapper")
synonym_list <- html_nodes(main_syn, ".synonym-link-wrapper")
syn_words <- html_text(synonym_list, "span")
mental_words <- paste(syn_words, collapse = "")
mental_text <- tibble(mental_words = mental_words)
df_mental <- unnest_tokens(mental_text, word_tokens, mental_words, token = "words")
mental_final <- anti_join(df_mental, stop_words, by = c("word_tokens" = "word"))

mental_final <- unique(mental_final)
mental_final <- mental_final %>% 
  filter(!word_tokens %in% c("related","antonym", "primary", "freedom", "life"))

mental_final

# to broaden possible matches of mental health content, we consulted another webpage
new_url <- "https://www.thesaurus.com/browse/mental%20illness"
new_url <- read_html(new_url)
meanings <- html_node(new_url, "#meanings")
meanings_list <- html_nodes(meanings, ".css-1n6g4vv")
list_words <- html_text(meanings_list)
mental_words_new <- paste(list_words, collapse = "")
mental_text_new <- tibble(mental_words_new = mental_words_new)
df_mental_new <- unnest_tokens(mental_text_new, word_tokens, mental_words_new, token = "words")

add_redwords <- tibble(c("insanity", "mental disorder", "personality disorder", "schizophrenia"))
names(add_redwords) <- c("word_tokens")
df_mental_new <- df_mental_new %>% rbind(df_mental_new, add_redwords)

mental_match <- final_text %>% 
  mutate(match = ifelse(final_text$word_tokens %in% mental_final$word_tokens, "Mental health related content", "Non related to mental health content"))

sum_mental <- mental_match %>% 
  group_by(match) %>% 
  summarise(n = n()) %>%
  mutate(percent = n/sum(n)*100,
         percent = paste(round(percent, 2), "%"))

sum_mental 

plot_mental <- ggplot(mental_match, aes(match, fill = match)) +
  geom_bar() +
  labs(x = "Type of Coverage in News",
       y = "Number of Words",
       title = "Mental health Coverage in Crime-News",
       subtitle = "CWB Chicago, Summer 2019") +
  geom_text(stat = "count",
            aes(label = ..count..)) +
  theme_minimal() +
  theme(axis.text.x = element_blank())

plot_mental <- ggsave(filename = "Mental_health_coverage_CrimeNews.png", 
                      plot = plot_mental, 
                      bg = "white")

# Describe the sentiment of the podcast --------

podcast_url <- "https://news.uchicago.edu/confronting-gun-violence-data-jens-ludwig"
html <- read_html(podcast_url)

# we inspect element in html source code to identify #left-area for text
article_podcastnotes <- html_node(html, "#app")
transcript_parts <- html_nodes(article_podcastnotes, "p")
transcript_list <- html_text(transcript_parts)
text <- paste(transcript_list, collapse = "")

# save file as .txt to repo
writeLines(text, "transcript.txt")

text_df <- tibble(text = text)
word_tokens_df <- unnest_tokens(text_df, word_tokens,  text, token = "words")
no_sw_df <- anti_join(word_tokens_df, stop_words, 
                      by = c("word_tokens" = "word"))

sentiment_nrc <- get_sentiments("nrc")
podcast_text_nrc <- no_sw_df %>%
  left_join(get_sentiments("nrc"), by = c("word_tokens" = "word"))

podcast_plot_nrc <- ggplot(data = filter(podcast_text_nrc, !is.na(sentiment))) +
  geom_histogram(aes(sentiment), stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Sentiment Analysis - Big Brains Podcast Ep 82",
       subtitle = "NRC Sentiment") +
  theme_minimal()

podcast_plot_nrc <- ggsave(filename = "Sentiment Analysis - Big Brains Podcast Ep 82.png", 
                   plot = podcast_plot_nrc,
                   bg = "white")

#end