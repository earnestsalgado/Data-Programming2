# __Question 1 (50%):__

# Step 1
# Example of counting days elapsed between first day of class to now
# https://docs.python.org/3/library/datetime.html

from datetime import date

now = date.today()
day_one = date(now.year, 1, 11)

time_since_day1 = abs(day_one - now)
print(time_since_day1.days)

# Step 2
# begin with a manually created python list
my_list = [1, 0.2, 3.1416, 420, 55, 666, 777, 8, 96, 10e6]
print(my_list[:])
# * Multiply each value by 2. (Hint: look up *list comprehensions*)
times_two = [x*2 for x in my_list[:]]
print(times_two)

# * Remove all odd numbers
# https://stackoverflow.com/questions/14275118/python-remove-odd-number-from-a-list
filtered_list = list(filter(lambda x: x % 2 == 0, my_list))
print(filtered_list)

# * Print a random value from the list. 
from numpy import random

random_value = random.choice(my_list)
print(random_value)

# Step 3
# Below are cited sources for my code--
# formatting user-defined functions: https://sites.pitt.edu/~naraehan/python3/user_defined_functions.html
# isinstance function: https://pynative.com/python-isinstance-explained-with-examples/#h-example
# how to assert with multiple conditons: https://stackoverflow.com/questions/50866736/how-to-assert-once-with-multiple-conditions
# how to split on specific string: https://sites.pitt.edu/~naraehan/python3/split_join.html

def str_modify(value):
    assert isinstance(value, str) is True if len(value) >= 15 else print("Insufficient string length!")
    list_of_split_strs = value.split('.') # splits on any periods '.'
    for i in range(len(list_of_split_strs)):
        list_of_split_strs[i] = list_of_split_strs[i].lower()
        list_of_split_strs[i] = list_of_split_strs[i].capitalize()
        rejoin = '\n'.join(list_of_split_strs)
    return rejoin

# use of multiple string values to investigate my function
my_string = 'WhAt In tHe FlyINg fALaFeL Is ThIs.pLEASE EXPLAIN!?'
my_string2 = "I'm not hungry. but did you eat?"
my_string3 = "zyxwvutsrqponm"
my_string4 = 15
my_string5 = "HANG.tHe.dj.hANg.THE.Dj.Hang.ThE.dJ!"

print(str_modify(my_string5))


# +__Question 2 (50%):__

# Step 1 - load
import pandas as pd
df = pd.read_csv('employment.csv')
df2 = pd.read_csv('labor force.csv')

# merge the two dataframes on "msa"
# https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.merge.html

df.merge(df2, how = 'outer', on = 'msa') # outer join is appropriate to avoid losing data from either dataframe.

# Step 2 - redo the merge
# after merging, the "country", "year", and "month" columns diverged into x and y variables representing each df.
# https://www.analyticsvidhya.com/blog/2020/02/joins-in-pandas-master-the-different-types-of-joins-in-python/
df.merge(df2, how = 'outer', indicator = True)

# Step 3 - Modify Step 1 ... to skip footers with NaN
# https://thispointer.com/pandas-skip-rows-while-reading-csv-file-to-a-dataframe-using-read_csv-in-python/
df = pd.read_csv('employment.csv', skipfooter = 3, engine = 'python')
df2 = pd.read_csv('labor force.csv', skipfooter = 3, engine = 'python')

df_merged = df.merge(df2, how = 'outer', indicator = True)
df_merged = df_merged.dropna() # drop NaN values from rest of dataframe
print(df_merged.head(len(df_merged)))

#  Step 4 - Turn the "year" and "month" columns into a proper "date" column, with a datetime datatype.
df_merged['date'] = pd.to_datetime(df_merged[['year', 'month']].assign(DAY=1))
print(df_merged.dtypes) # check datatypes to date column is datetime

#  Step 5 - Calculate a new column that shows the unemployment rate for each MSA.

df_merged['Unemployment Rate'] = 1 - df_merged['Employment']/df_merged['Labor Force']

# Step 6 - Fix Houston MSA labor force value to 2,733,348 using _loc_, then recalculate.
# https://towardsdatascience.com/a-python-beginners-look-at-loc-part-2-bddef7dfa7f2
df_merged.loc[6, 'Labor Force'] = 2733348
df_merged['Unemployment Rate'] = 1 - df_merged['Employment']/df_merged['Labor Force']
df_commit = df_merged.head(len(df_merged))
print(df_commit.head(len(df_commit)))

# Step 7 - Use _map_ to make a new column with string formatting
# https://www.youtube.com/watch?v=uM4_SY4mXj4
# https://stackoverflow.com/questions/455612/limiting-floats-to-two-decimal-points

def formatted(x):
    percentage = '{:.2%}'.format(x)
    return percentage

# test values
x = 3.141698576
x2 = 0.953960
# print('{:,.2%}'.format(x))
# formatted(x2)

df_merged['Percent Unemployment Rate'] = df_merged['Unemployment Rate'].map(formatted)
df_merged.head(len(df_merged))
print(df_merged.dtypes)

# Step 8 - Calculate mean unemployment rate for all MSAs.  Use _loc_ to show the subset where unemployment rate > mean.
# https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html
avg_unemployment_rate = df_merged['Unemployment Rate'].mean()
print(avg_unemployment_rate)

high_unemployment_msa = df_merged.loc[df_merged['Unemployment Rate'] > avg_unemployment_rate]
high_unemployment_msa

#  Step 9 - Write the dataframe from step 6 to "data.csv" and commit it to your repo with code omitting the index.

df_commit.to_csv('data.csv', index=False)

