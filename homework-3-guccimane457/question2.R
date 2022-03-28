# __Question 2 (70%):__ 
library(tidyverse)
library(rvest)
library(tidytext)
library(udpipe)
library(nametagger)
library(SnowballC)
library(countrycode)

# Describe the sentiment of all 10 articles --------
unbrief_0211 <- "https://www.unhcr.org/refugeebrief/the-refugee-brief-11-february-2022/"
trb_webpage <- read_html(unbrief_0211)
sidebar <- html_node(trb_webpage, "#sidebar")
briefs <- html_nodes(sidebar, "a")
links <- html_attr(briefs, "href")
all_newsletters <- html_text(briefs, trim = FALSE)
n <- length(all_newsletters)

# we use countrycode again for countries recognition
countries_list <- unique(countryname_dict$country.name.en)
countries_df <- tibble(countries_list = countries_list)

# referencing code making loop iterate over all 10 links
# https://stackoverflow.com/questions/30917537/r-for-loop-only-completing-first-iteration
for (i in 1:n){
  
# scraping all the pages
  data <- read_html(links[[i]])
  left_area <- html_node(data, "#left-area")
  briefs_par <- html_nodes(left_area, "p")
  text <- html_text(briefs_par)
  text <- paste(text, collapse = "")

  text_df <- tibble(text = text)
  word_tokens_df <- unnest_tokens(text_df, word_tokens,  text, token = "words")
  no_sw_df <- anti_join(word_tokens_df, stop_words, 
                        by = c("word_tokens" = "word"))
# here we learned how to write lines and append without overwriting 
# https://stackoverflow.com/questions/21668640/how-to-append-to-an-existing-file-in-r-without-overwriting-it
  write_lines(text, file = paste0(all_newsletters[[i]],".txt"))

  # sentiment analysis
  sentiment_nrc <- get_sentiments("nrc")   # manually created via crowdsourcing, ten categories, not unique!
  sentiment_afinn <- get_sentiments("afinn") # product of one researcher, pos/neg integer values
  sentiment_bing <- get_sentiments("bing")  # built on online reviews, pos/neg only
  
  for (s in c("nrc", "afinn", "bing")) {
    no_sw_df <- no_sw_df %>%
      left_join(get_sentiments(s), by = c("word_tokens" = "word")) %>%
      plyr::rename(replace = c(sentiment = s, value = s), 
                   warn_missing = FALSE)
  }
  {
    # plot for the 10 articles  
    question2_plot = ggplot(data = filter(no_sw_df, !is.na(nrc))) + 
      geom_histogram(aes(nrc), stat = "count") +
      scale_x_discrete(guide = guide_axis(angle = 45)) +
      xlab("Sentiment in NRC") +
      ylab("Count") +
      ggtitle(all_newsletters[[i]]) + 
      theme(plot.title = element_text(hjust = .5))
    
    ggsave(question2_plot, file=paste0(all_newsletters[[i]],".png"), 
           width = 14, height = 10)
  }
  # show which countries are discussed in the article.
  parsed <- udpipe(text, "english")
  parsed$stem <- wordStem(parsed$token, language = "porter")
  
  article_countries <- parsed %>%
    select("token", "stem", "lemma", "upos") %>%
    filter(upos == "PROPN") %>%
    mutate("discussed_country" = 
             ifelse(token %in% countries_df$countries_list,"Yes","No"))
  
  article_countries <- filter(
    article_countries, discussed_country  == "Yes") %>% 
    distinct(token) %>%
    arrange(token)
  
  print(article_countries)
}

# creating one .csv file --------
papers <- c("The Refugee Brief – 3 December 2021",
            "The Refugee Brief – 7 January 2022",
            "The Refugee Brief – 10 December 2021",
            "The Refugee Brief – 11 February 2022",
            "The Refugee Brief – 14 January 2021",
            "The Refugee Brief – 17 December 2021",
            "The Refugee Brief – 19 November 2021",
            "The Refugee Brief – 21 January 2022",
            "The Refugee Brief – 26 November 2021",
            "The Refugee Brief – 28 January 2022")

all_text <- list()
for (paper in papers) {
  all_text[paper] <- read_file(paste0(paper, ".txt"))
  {
    dat <- tibble(edition = names(all_text), text = all_text)
    dat <- unnest_tokens(dat, token, text, token = "words")
    
    summary <- dat %>%
      left_join(get_sentiments("nrc"), by = c("token" = "word")) %>%
      plyr::rename(replace = c(sentiment = "nrc")) %>% 
      count(edition, nrc) %>% 
      filter(!is.na(nrc))
    
    wide <- pivot_wider(summary, id_cols = edition, names_from = nrc, 
                        values_from = n)
    
    print(wide)
    write.csv(wide,"sentiments.csv", row.names = FALSE)
  }
  {
    # we create an aggregate plot for all newsletters' NRC sentiment 
    alltxt_nrc <- dat %>%
      left_join(get_sentiments("nrc"), by = c("token" = "word")) %>%
      plyr::rename(replace = c(sentiment = "nrc"))
    
    alltxt_plot = ggplot(data = filter(alltxt_nrc, !is.na(nrc))) + 
      geom_histogram(aes(nrc), stat = "count") +
      scale_x_discrete(guide = guide_axis(angle = 45)) +
      xlab("Sentiment in NRC") +
      ylab("Count") +
      ggtitle("NRC Sentiment TRB Nov21-Feb22") + 
      theme(plot.title = element_text(hjust = .5))
    
    ggsave(alltxt_plot, file= 
             "NRC Sentiment TRB Nov21-Feb22.png", 
           width = 14, height = 10)
  }
}

# end