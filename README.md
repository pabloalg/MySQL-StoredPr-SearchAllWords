# MySQL-StoredPr-SearchAllWords
A MySQL stored procedure to search for records in a column in a table that contain all the words (delimited by space) in any given order in the input text.

# Description:
Use this procedure to get records that contain every word (whole or part of it) in any order. Each word in a record may be equal or contain each of the input words depending on the 4th boolean parameter (see the examples for further explanation). Search is Case-insensitive. Each word may appear more than once.

# Usage:
CALL __pr_search_records_in_column_with_every_word_in_any_order__ ('__[text to search]__', '__[TABLE NAME]__', '__[COLUMN NAME]__', __[TRUE | FALSE)__;

(A Database must have been previously selected: <br>
USE [DataBase name];)

## Procedure Parameters:
1. IN in_text_to_search VARCHAR(255),
2. IN in_table_name VARCHAR(200),
3. IN in_col_name VARCHAR(100),
4. IN in_whole_words BOOLEAN

# Examples:
1. Fourth boolean parameter = __TRUE__ (search whole words)<br>
Text to search: "shirt cotton blue s"<br>

   This __will return__ all of this records:
   - "dark blue s shirt made of cotton"
   - "shirt blue cotton shirt s"
   - "s size cotton shirt color blue"

   It __won't return__ this records:
   - "blue xs shirt made of cotton"
   - "s cotton shirt color lightblue"
   - "dark blue cotton t-shirt s"
   - "blue shirt s"
<br>
2. Fourth boolean parameter = __FALSE__ (search words inside words)<br>
Text to search: "shirt cotton blue s"<br>

   This __will return__ all of this records:
   - "lightblue xs shirt s t-shirt made of cotton"
   - "blue cotton tshirts xxs size"
   - "cotton t shirt blueberry color on sale"
   - "cotton s shirt blue"

   It __won't return__ this records:
   - "red xs shirt made of cotton"
   - "lightblue cotton skirt"
   - "s blue cotton shir t"
   - "blue shirt s"
