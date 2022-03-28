# Data Skills 2 - R
## Winter Quarter 2021

## Homework 4
## Due: Sunday February 27th before midnight on GitHub Classroom

## Rubric - Grader: Sebastian Clavijo

- `my_list[:]` and `my_list` is the same. 
- try to use list comprehension when possible
- `str_modify` doesn't check word length but rather character length,
	- `len(value)` versus `len(value.split())`
- your `formatted()` function is rather inefficient. You created a function, that essentially runs one line of code.
	You could have simple run the `format()` logic within the `map()` as opposed to creating a new function.
- great job using test values to check your work!

- 23.5/25 - Question 1
  - /4 - Correctly gets date elapsed
	- /4 - Date Elapsed
  - /6 Python List
	- /2 - Multiply each value by 2
	- /2 - Remove all odd numbers
	- /2 - Print a random value from the list. 
	
 - 13.5/15  Function Writing
    - 1.5/3 Test that the argument is a string, and that its length is at least 15 words.
    - /3 Split the string on any periods=.
    - /3 Each string in the list begin with a capital letter, with all other letters lowercase.
    - /3 Join the strings back together into one string with the newline character ("\n") between each string
    - /3 Return string and print
	
- 25/25 - Question 2
  - /2.5 - Load and merge the two dataframes on "msa"
  - /2.5 - Explain in a 1-2 line comment which type of join is the appropriate one.
  - /2.5 - Identified merge issue and fixed merge issue 
  - /2.5 - Identified issues with bottom row and applied fix
  - /2.5 - "year" and "month" column are datetime datatype.
` - /2.5 - Calculate a new column that shows the unemployment rate for each MSA.
  - /2.5 - Fix data to 2,733,348 using loc, then recalculate.
  - /2.5 - Applies map to make new column with unemployment rate
  - /2.5 - Calculates average unemployment and uses loc to show subset of rows that unemployment rate is higher than mean
  - /2.5 - Writes to csv with no index.
  
- 20/20 - Code runs without errors
	- /15 - No major errors
	- /5 - No minor errors
	
- 10/10 - Uses methods taught in class
	- datetime, pandas
	
- 10/10 - Uses GitHub to commit assignment on time
	- /1 - Good use of commits
	- /9 - Pushed on time
	
- 8/10 - Clear code style with succinct logic and properly generalizes code
	- See above.
	
- Total: 95/100

__Question 1 (50%):__ Python Skills Questions: As experts in R, you will need to develop your ability to look up the things you want to accomplish in Python while, wherever possible, leveraging what you already know about the relevant principles from R.  Do not forget to cite your sources, as laid out in the academic integrity guide.

  1. The first day of class was January 11th, 2021.  Write code that shows how many days have elapsed between then and now, where "now" is the date someone runs your code. (Hint: look up the _datetime_ standard Python library.)
  2. Write code that begins with a Python list, containing some number of integers or floats. From the original list, perform each of these separately:
     * Multiply each value by 2. (Hint: look up *list comprehensions*)
     * Remove all odd numbers
     * Print a random value from the list. (Hint: look up the _random_ standard Python library, or the _random_ section of the NumPy library.)
  3. Write a Python **function** that takes a string as an argument, then returns a modified string.  Your function should:
     * First, test that the argument is a string, and that its length is at least 15 words. (Hint: look up the _assert_, _isinstance_, and _len_ standard Python functions.)
     * Second, split the string on any periods.  The result will be a list with strings in it.
     * Third, make each string in the list begin with a capital letter, with all other letters lowercase.
     * Fourth, join the strings back together into one string with the newline character ("\n") between each
     * Return the resulting string, then display it with a _print_ function.
    
__Question 2 (50%):__ Pandas: Use the two small datasets included in the repo to do the following:

  1. Load and merge the two dataframes on "msa".  Explain in a 1-2 line comment which type of join is the appropriate one.
  2. Look at what happened to the "country", "year", and "month" columns after the merge.  Redo the merge to fix the issue.
  3. Look at the bottom few rows of each dataframe - modify your code from step 1 to fix the issue.
  4. Turn the "year" and "month" columns into a proper "date" column, with a datetime datatype.
  5. Calculate a new column that shows the unemployment rate for each MSA.
  6. Oops!  Something is clearly wrong with the Houston MSA.  The correct labor force value is 2,733,348, but in reproducible research, we should never directly modify the raw data, even when there are mistakes.  Fix the value using _loc_, then recalculate.
  7. Use the _map_ method to make a new column that shows the unemployment rate formatted neatly as a percentage, with two decimal points and the % symbol after it.  Note that you can do this other ways than with map, but for this question use map. (Hint: look up Python string formatting)
  8. Calculate the average unemployment rate for all of the MSAs.  Now use _loc_ to show only the subset of rows for which the unemployment rate is higher than the mean.
  9. Write the dataframe calculated in step 6 to a new file named "data.csv" and commit it to your repo with your code.  Since the dataframe index is not meaningful here, write it without the index.

