# Data Skills 2 - R
## Winter Quarter 2022

## Homework 3
## Due: Sunday February 20th before midnight on GitHub Classroom

### Rubric 

- Grader: Yangzhou

- Comments:
Good job!                     


- (40%) - Questions 1 & 2

    - (20%) - Question 1
            - 8/8 Provides files: question1.R, question1_plot.png
            - 6/6 Sentiment Analysis
            - 6/6 List of countries


    - (20%) - Quesiton 2
            - 8/8 Provides files: question2.R, question2_plot_X.png
            - 8/8 Properly scrape all relevant reports (sentiment and countries)
            - 4/4 Generalize scrape logic
        

- (20%) - Code runs without errors
        - 15/15 - No major errors
        - 5/5 - No minor errors
        
- (10%) - 10/10 Uses methods taught in class

- (10%) - Uses GitHub to commit assignment on time
        - 1/1 - Good use of commits
        - 9/9 - Pushed on time

- (10%) - 10/10 Clear code style with succinct logic

- (10%) - 10/10 Properly generalizes code

- Total: 100/100



Note that there is a lot of flexibility in how you approach these questions and what your final results will look like.  Being comfortable with that sort of assignment is an explicit course goal; real-world research is much more likely to come with open-ended assignments rather than explicit goals to start with X and accomplish exactly Y.  Use short comments (1-3 lines max) to explain any choices that you think need explaining.  Remember wherever possible to focus on "why" in your comments, and not "what".

__Question 1 (30%):__ You are working as a research assistant at a think tank studying international refugees.  The senior researcher you work for tries to follow [the Refugee Brief](https://www.unhcr.org/refugeebrief/) from the UNHCR, but they have been too busy lately to keep up with it.  They ask you to read in the report (from the text file inlcuded in the repo) and parse it using natural language processing:

Describe the sentiment of the article, and show which countries are discussed in the article.

Output to save to your repo for this question:
  * question1.R file with the code - summary statistics can be displayed with print or View
  * question1_plot.png file for the plot you generate

__Question 2 (70%):__ Your senior researcher is very happy with the results you achieved on the most recent report, so they ask you to generalize your code to parse more of the newsletters.  They come out every Friday, except for around Christmas.  

Use basic web scraping to collect every report between now (January 28th, 2022) and November 5th, 2021.  The first one can be found [here](https://www.unhcr.org/refugeebrief/the-refugee-brief-28-january-2022/); you can find the rest from there.

Do not use the text file from question 1, but do reuse as much code as you can from question 1 (i.e. copy and paste any relevant code from question 1 and then change it to generalize).  Keep in mind that your code for question 2 needs to potentially be able to generalize to more than dates specified, so good generalization is crucial.  Note that any slight variation in results from the text file in question 1 and the parsed html content for question 2 is acceptable, due to differences in the web formatting.

You may use any sensible combination of figures and summary statistics to answer the same two questions as in part 1; what is the overall sentiment, and which countries are discussed.

Output to save to your repo for this question:
  * question2.R file with the code - summary statistics can be displayed with print or View
  * question2_plot_X.png files for the plot(s) you generate
  * A csv document in tidy format of sentiment results for the colletion of briefs
