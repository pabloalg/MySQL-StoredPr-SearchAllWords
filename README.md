# MySQL-StoredPr-SearchAllWords
A MySQL stored procedure to search for records in a column in a table that contain all the words (delimited by space) in any given order in the input text.

# Description:
Use this procedure to get records that contain every word (whole or part of it) in any order. Each word in a record may be equal or contain each of the input words depending on the 4th boolean parameter (see the examples for further explanation). Search is Case-insensitive. Each word may appear more than once.

# Procedure Parameters:
IN in_text_to_search VARCHAR(255),
IN in_table_name VARCHAR(200),
IN in_col_name VARCHAR(100),
IN in_whole_words BOOLEAN

# Usage:
CALL pr_search_records_in_column_with_every_word_in_any_order('[text to search]', '[TABLE NAME]', '[COLUMN NAME]', [TRUE | FALSE);

(A Database must have been previously selected:
USE [DataBase name];)

# Examples:
1) 4th boolean parameter = TRUE (search whole words)
Text to search: "shirt cotton blue s"

This will return all of this records:
· "dark blue s shirt made of cotton"
· "shirt blue cotton shirt s"
· "s size cotton shirt color blue"

It won't return this records:
· "blue xs shirt made of cotton"
· "s cotton shirt color lightblue"
· "dark blue cotton t-shirt s"
· "blue shirt s"

2) 4th boolean parameter = FALSE (search words inside words)
Text to search: "shirt cotton blue s"

This will return all of this records:
· "lightblue xs shirt s t-shirt made of cotton"
· "blue cotton tshirts xxs size"
· "cotton t shirt blueberry color on sale"
· "cotton s shirt blue"

It won't return this records:
· "red xs shirt made of cotton"
· "lightblue cotton skirt"
· "s blue cotton shir t"
· "blue shirt s"
