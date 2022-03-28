# +__Question 1 (30%):__ 
library(tidyverse)
library(tidytext)
library(rvest)
library(udpipe)
library(nametagger)
library(SnowballC)
library(stringr)
library(countrycode)

# Describe the sentiment of the article --------

# We first read in text using this helpful rvest page
# https://www.rdocumentation.org/packages/rvest/versions/0.3.6
unbrief_0128 <- "https://www.unhcr.org/refugeebrief/the-refugee-brief-28-january-2022/"
html_0128 <- read_html(unbrief_0128)

# we inspect element in html source code to identify #left-area for text
left_area <- html_node(html_0128, "#left-area")
brief_par <- html_nodes(left_area, "p")
par_list <- html_text(brief_par)
text <- paste(par_list, collapse = "")
# save file as .txt to repo
writeLines(text, "TheRefugeeBrief_012822.txt")

text_df <- tibble(text = text)
word_tokens_df <- unnest_tokens(text_df, word_tokens, text, token = "words")
count(word_tokens_df, word_tokens, sort = TRUE)
no_sw_df <- anti_join(word_tokens_df, stop_words, by = c("word_tokens" = "word"))
count(no_sw_df, word_tokens, sort = TRUE)

# sentiment analysis
sentiment_nrc <- get_sentiments("nrc")   # manually created via crowdsourcing, ten categories, not unique!
sentiment_afinn <- get_sentiments("afinn") # product of one researcher, pos/neg integer values
sentiment_bing <- get_sentiments("bing")  # built on online reviews, pos/neg only

for (s in c("nrc", "afinn", "bing")) {
  no_sw_df <- no_sw_df %>%
    left_join(get_sentiments(s), by = c("word_tokens" = "word")) %>%
    plyr::rename(replace = c(sentiment = s, value = s), warn_missing = FALSE)
}

# simple plot displaying nrc sentiment
question1_plot = ggplot(data = filter(no_sw_df, !is.na(nrc))) + 
  geom_histogram(aes(nrc), stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  xlab("Sentiment in NRC") +
  ylab("Count") +
  ggtitle("The Refugee Brief - Edition 01/28/2022") + 
  theme(plot.title = element_text(hjust = .5))

ggsave(question1_plot, file = "question1_plot.png", 
       width = 14, height = 10)

# Describe the sentiment of the article
# The Refugee Brief of Jan 28 2022 sentiment in terms of nrc is mostly negative
# followed by fear and then positive. Negative led the way with over 60 words.
# The pairing of negative and fear suggests this newsletter was not particularly
# hopeful in outlook, or reporting. This is supported by the fact that the
# fourth most frequent sentiment is sadness.

# show which countries are discussed in the article. --------

parsed <- udpipe(par_list, "english")
parsed$stem <- wordStem(parsed$token, language = "porter")

# we retrieve a comprehensive list of countries from countrycode package:
# https://cran.r-project.org/web/packages/countrycode/countrycode.pdf
countries_list <- unique(countryname_dict$country.name.en)
countries_df <- tibble(countries_list = countries_list)

article_countries <- parsed %>%
  select("token", "stem", "lemma", "upos") %>%
  filter(upos == "PROPN") %>%
  mutate("discussed_country" = 
           ifelse(token %in% countries_df$countries_list,"Yes","No"))

# we check the df we made for accuracy and make replacements as needed
article_countries$token <- str_replace_all(article_countries$token, "Burkina", "Burkina Faso")
article_countries$token <- str_replace_all(article_countries$token, "Côte", "Côte d’Ivoire")
article_countries$token <- str_replace_all(article_countries$token, "United", "United States")
article_countries$token <- str_replace_all(article_countries$token, "US", "United States")
article_countries$token <- str_replace_all(article_countries$token, "Eritrean", "Eritrea")
article_countries$token <- str_replace_all(article_countries$token, "Eritreans", "Eritrea")

article_countries <- article_countries %>%
  mutate("discussed_country" = 
           ifelse(token %in% countries_df$countries_list,"Yes","No"))
article_countries <- filter(article_countries, discussed_country  == "Yes") %>%
  distinct(token) %>%
  arrange(token)

print(article_countries)

# the output is a list of 18 unique countries discussed in the article!
# 1    Afghanistan
# 2        Bahamas
# 3        Belarus
# 4   Burkina Faso
# 5  Côte d’Ivoire
# 6           Cuba
# 7          Egypt
# 8        Eritrea
# 9       Ethiopia
# 10         Haiti
# 11          Iraq
# 12     Lithuania
# 13        Mexico
# 14        Poland
# 15        Rwanda
# 16       Somalia
# 17         Syria
# 18 United States

# we compare our results with a named entity recognition model
options(timeout = 120)
model <- nametagger_download_model("english-conll-140408", model_dir = tempdir())
model_predict <- predict(model, rename(parsed, text = token))

entities <- model_predict %>% 
  filter(entity %in% c("B-PER","B-LOC","B-MISC","B-ORG")) %>% 
  filter(term %in% countries_df$countries_list) %>%
  group_by(term) %>% 
  summarise(n = n())

print(entities)

# the output is a list of only 7 unique countries compared to our 18 found
# using 'countrycode_dict'

# A tibble: 7 × 2
# term            n
# <chr>       <int>
# 1 Afghanistan     1
# 2 Egypt           4
# 3 Ethiopia        1
# 4 Iraq            1
# 5 Lithuania       1
# 6 Mexico          1
# 7 Poland          3

# end