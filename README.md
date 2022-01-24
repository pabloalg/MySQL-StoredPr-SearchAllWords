# MySQL-StoredPr-SearchAllWords
A MySQL stored procedure to search for records in a column in a table that contain all the words (delimited by space) in any given order in the input text.

# Description
Use this procedure to get records that contain every word (whole or part of it) in any order. Each word in a record may be equal or contain each of the input words depending on the 4th boolean parameter (see the examples for further explanation). Search is Case-insensitive. Each word may appear more than once.

# Usage
__CALL pr_search_records_in_column_with_every_word_in_any_order ('[text to search]', '[_Table name_]', '[_Column name_]', [_TRUE | FALSE_]);__

(A Database must have been previously selected: <br>
__USE [_DataBase name_];__)

## Procedure Parameters
1. IN in_text_to_search VARCHAR(255),
2. IN in_table_name VARCHAR(200),
3. IN in_col_name VARCHAR(100),
4. IN in_whole_words BOOLEAN

# Examples
1. Fourth boolean parameter = __TRUE__ (search whole words)<br>
Text to search: "__shirt cotton blue s__"

   This __will return__ all of this records:
   - "dark __blue s shirt__ made of __cotton__"
   - "__shirt blue cotton shirt s__"
   - "__s__ size __cotton shirt__ color __blue__"

   It __won't return__ this records:
   - "__blue__ xs __shirt__ made of __cotton__" [__"s"__ missing]
   - "__s cotton shirt__ color lightblue" [__"blue"__ missing]
   - "dark __blue cotton__ t-shirt __s__" [__"shirt"__ missing]
   - "__blue shirt s__" [__"cotton"__ missing]

2. Fourth boolean parameter = __FALSE__ (search words inside words)<br>
Text to search: "__shirt cotton blue s__"<br>

   This __will return__ all of this records:
   - "light<b>blue</b> x<b>s</b> __shirt s__ t-<b>shirt</b> made of __cotton__"
   - "__blue cotton__ t<b>shirts</b> xx<b>s s</b>ize"
   - "__cotton__ t __shirt__ blue<b>berry</b> color on <b>s</b>ale"
   - "__cotton s shirt blue__"

   It __won't return__ this records:
   - "red x<b>s shirt</b> made of __cotton__" [__"blue"__ missing]
   - "light<b>blue cotton s</b>kirt" [__"shirt"__ missing]
   - "<b>s blue cotton s</b>hir t" [__"shirt"__ missing]
   - "__blue shirt s__" [__"cotton"__ missing]

## Installation
1. Load an run script.
2. Call the stored procedure filling the input parameters (see <a href="https://github.com/pabloalg/MySQL-StoredPr-SearchAllWords/blob/main/README.md#usage"> Usage</a>).
