/*
DESCRIPTION:
Use this procedure to get records in a column of a table that contain all the written words (delimited by space) in any given order. Each word may be equal or contain each of the input words depending on the 4th boolean parameter (see the examples for further explanation). Search is Case-insensitive. Each word may appear more than once.

PROCEDURE PARAMETERS:
IN in_text_to_search VARCHAR(255),
IN in_table_name VARCHAR(200),
IN in_col_name VARCHAR(100),
IN in_whole_words BOOLEAN

USAGE:
CALL pr_search_records_in_column_with_every_word_in_any_order('[text to search]', '[TABLE NAME]', '[COLUMN NAME]', [TRUE | FALSE);

(A Database must have been previously selected:
USE [DataBase name];)

EXAMPLES:
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


(
	For developing and testing purposes, a sample dabatase was used from MysqlTutorial.org
	https://www.mysqltutorial.org/mysql-sample-database.aspx

	USE classicmodels;
)
*/

DROP PROCEDURE IF EXISTS pr_singleword_clause;
DROP PROCEDURE IF EXISTS pr_build_unified_clause;
DROP PROCEDURE IF EXISTS pr_build_where_clause_for_search_of_multiple_words;
DROP PROCEDURE IF EXISTS pr_search_records_in_column_with_every_word_in_any_order;

DELIMITER $$
/*
	Text in "in_word_written" parameter gets wrapped around wildcard character: "%".
	"in_nospace0_spaceatstart1_spaceatend2" parameter indicates:
	0: no space is added
	1: a space is added at the beginning of text
	2: a space is appended at the end of text.
*/
CREATE PROCEDURE pr_singleword_clause
(
	IN in_word_written VARCHAR(200),
	IN in_nospace0_spaceatstart1_spaceatend2 INT,
    OUT out_res VARCHAR(200)
) 
READS SQL DATA
BEGIN
	DECLARE invalid_num_in_parameter CONDITION FOR SQLSTATE '45000';
	
    DECLARE EXIT HANDLER FOR invalid_num_in_parameter
    BEGIN
		RESIGNAL SET MESSAGE_TEXT = 'Invalid value in last parameter. Valid values are 0, 1 or 2.';
	END;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- SELECT 'An error has occurred, so the stored procedure has been terminated.' as ErrorMessage;
	END;
	
	CASE in_nospace0_spaceatstart1_spaceatend2
		WHEN 0 THEN
			SET out_res = CONCAT(CONCAT('%', in_word_written), '%');
		WHEN 1 THEN
			SET out_res = CONCAT(CONCAT('% ', in_word_written), '%');
		WHEN 2 THEN
			SET out_res = CONCAT(CONCAT('%', in_word_written), ' %');
		ELSE
			BEGIN
				SIGNAL invalid_num_in_parameter;
            END;
	END CASE;
END$$
DELIMITER ;


DELIMITER $$
-- Builds "unified_clause" depending on "in_whole_words" boolean.
CREATE PROCEDURE pr_build_unified_clause
(
	IN in_word_written VARCHAR(200),
	IN in_whole_words BOOLEAN,
	IN in_tablename_and_likeoperator VARCHAR(200),
    OUT out_unified_clause VARCHAR(200)
) 
READS SQL DATA
BEGIN	
	DECLARE left_clause VARCHAR(200);
	DECLARE right_clause VARCHAR(200);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	END;
	
	IF in_whole_words = TRUE THEN
		-- (search for whole words)
		
		CALL pr_singleword_clause(in_word_written, 2, @res_pr_singleword_clause);
		SET left_clause = CONCAT(in_tablename_and_likeoperator, @res_pr_singleword_clause, '''');
		
		CALL pr_singleword_clause(in_word_written, 1, @res_pr_singleword_clause);
		SET right_clause = CONCAT(in_tablename_and_likeoperator, @res_pr_singleword_clause, '''');
		
		SET out_unified_clause = CONCAT(CONCAT(left_clause, ' OR '), right_clause);
		SET out_unified_clause = CONCAT(CONCAT('(', out_unified_clause), ')');
	ELSE
		-- (search letters inside words)
		
		CALL pr_singleword_clause(in_word_written, 0, @res_pr_singleword_clause);		
		SET out_unified_clause = CONCAT(in_tablename_and_likeoperator, @res_pr_singleword_clause, '''');
	END IF;
END$$
DELIMITER ;


DELIMITER $$
-- Builds "WHERE" clause, which consists of: '[Column name] LIKE [word] AND ' [etc.]
CREATE PROCEDURE pr_build_where_clause_for_search_of_multiple_words
(
	IN in_text_written VARCHAR(200),
    IN in_col_name VARCHAR(200),
	IN in_whole_words BOOLEAN,
    OUT out_res VARCHAR(200)
) 
sp: BEGIN
    DECLARE tablename_and_likeoperator VARCHAR(200);
    DECLARE unified_clause VARCHAR(200);
    DECLARE left_word VARCHAR(200);
    DECLARE pos_delimit INT;
	DECLARE delimit VARCHAR(1);
    DECLARE aux_text VARCHAR(200);
    DECLARE rest_of_text_processed VARCHAR(200);
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- SELECT 'An error has occurred, so the stored procedure has been terminated.' as ErrorMessage;
	END;
	
    SET autocommit = 0;
    
    START TRANSACTION;
	
	SET max_sp_recursion_depth=50; 
    
    SET in_text_written = TRIM(in_text_written);
    SET tablename_and_likeoperator = CONCAT(in_col_Name, ' LIKE ', '''');
    SET aux_text = in_text_written;
	SET delimit = ' ';
    
    SET pos_delimit = INSTR(aux_text,delimit);
    
	-- Begin of Recursion:
	IF pos_delimit > 0 THEN
		-- (text has at least one delimiter character -> space)
		
		SET left_word = TRIM(LEFT(aux_text, pos_delimit-1));
		
        CALL pr_build_unified_clause(left_word, in_whole_words, tablename_and_likeoperator, @res_build_unified_clause);
		SET unified_clause = @res_build_unified_clause;
		
		-- Divide text:
		SET aux_text = TRIM(SUBSTRING(aux_text, pos_delimit)); -- now aux_text = the rest of initial whole text without first word
		
		CALL pr_build_where_clause_for_search_of_multiple_words(aux_text, in_col_name, in_whole_words, @rest_of_text_processed);
		
		SET out_res = CONCAT(unified_clause,' AND ',@rest_of_text_processed);
	ELSEIF pos_delimit = 0 THEN
		-- (Recursion's BASE CASE)
		
		CALL pr_build_unified_clause(aux_text, in_whole_words, tablename_and_likeoperator, @res_build_unified_clause);		
		SET unified_clause = @res_build_unified_clause;
		
		SET out_res = unified_clause;
	END IF;
    
    COMMIT;
    
    SET autocommit = 1;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE pr_search_records_in_column_with_every_word_in_any_order
(
	IN in_text_to_search VARCHAR(255),
	IN in_table_name VARCHAR(200),
	IN in_col_name VARCHAR(100),
	IN in_whole_words BOOLEAN
)
SQL SECURITY INVOKER
BEGIN	
    DECLARE qty_of_columns_in_table INT;
	DECLARE orderby_order VARCHAR(3);
	DECLARE invalid_table_column_msg VARCHAR(200);
	
	DECLARE invalid_table_column_name CONDITION FOR SQLSTATE '45000';
	
	DECLARE EXIT HANDLER FOR invalid_table_column_name
    BEGIN
		SET invalid_table_column_msg = 'Invalid table / column name provided.';
		-- SELECT invalid_table_column_msg as ErrorMessage;
		RESIGNAL SET MESSAGE_TEXT = invalid_table_column_msg;
	END;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- SELECT 'An error has occurred, so the stored procedure has been terminated.' as ErrorMessage;
	END;
	
    SET orderby_order = 'ASC';
    
	SELECT COUNT(*)
	INTO qty_of_columns_in_table
	FROM information_schema.columns
	WHERE table_name=in_table_name AND column_name IN (in_col_name);

	IF (qty_of_columns_in_table <1) THEN
		SIGNAL invalid_table_column_name;
	ELSE
		SET autocommit = 0;	
	
		START TRANSACTION;
	
		set max_sp_recursion_depth=50; 
        
        CALL pr_build_where_clause_for_search_of_multiple_words(
        in_text_to_search, in_col_name, in_whole_words, @where_conditions_clause);

		SET @dynamic_sql_query:=CONCAT('SELECT ' , in_col_name,
        ' FROM ' , in_table_name,' WHERE ', @where_conditions_clause, 
        ' ORDER BY ', in_col_name, ' ', orderby_order);
        
		PREPARE dynamic_statement FROM @dynamic_sql_query;
		EXECUTE dynamic_statement;
		
		COMMIT;
    
		SET autocommit = 1;
		
		DEALLOCATE PREPARE dynamic_statement;
	END IF;
 END$$
DELIMITER ;
 
/*
Call example using Sample Database from MySqlTutorial.org:
CALL pr_search_records_in_column_with_every_word_in_any_order('model a', 'products', 'productName', TRUE);
*/
