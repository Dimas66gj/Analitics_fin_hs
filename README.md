# Financial Transaction Analyzer

A Haskell-based application for analyzing financial transactions using functional programming principles.

## Overview

Financial Transaction Analyzer is a command-line program designed to process and analyze personal financial transactions. The application demonstrates core concepts of functional programming in Haskell, including pure functions, higher-order functions, immutability, and algebraic data types.

## Features

### 1. Transaction Analysis
- Calculate total income and expenses
- Compute average transaction amount
- Generate category-based statistics
- Calculate overall balance

### 2. Transaction Filtering
- Filter by transaction type (income/expense)
- Filter by category
- Filter by specific date
- Filter by date range

### 3. Transaction Insights
- Identify largest expense
- Identify largest income
- View all transactions
- Sort transactions by various criteria

### 4. Data Management
- Load transactions from text files
- Save transactions to files
- Export statistics to files
- Use built-in sample data for testing

## Installation

### Prerequisites
- [Glasgow Haskell Compiler (GHC)](https://www.haskell.org/ghc/) version 8.0 or higher
- [Cabal](https://www.haskell.org/cabal/) (optional, for dependency management)

### Compilation
```bash
# Clone the repository (if applicable)
# git clone <repository-url>
# cd financial-transaction-analyzer

# Compile the program
ghc -o finance-analyzer Main.hs

# Run the compiled program
./finance-analyzer
```

## File Format

The program reads and writes transactions in a simple text format:
```
YYYY-MM-DD AMOUNT CATEGORY TYPE
```

Where:
- `YYYY-MM-DD`: Date in ISO format (e.g., 2024-01-15)
- `AMOUNT`: Transaction amount as a decimal number (e.g., 1500.50)
- `CATEGORY`: Transaction category (e.g., "groceries", "salary")
- `TYPE`: Transaction type - either "income" or "expense"

### Example File (`transactions.txt`)
```
2024-01-15 50000 salary income
2024-01-16 1500 groceries expense
2024-01-17 300 transportation expense
2024-01-18 2000 entertainment expense
2024-01-19 10000 bonus income
```

## Usage

### Starting the Program
```
./finance-analyzer
```

You'll see the main menu with the following options:

### Main Menu Options

1. **Show All Transactions** - Display all loaded transactions
2. **Calculate Overall Statistics** - Generate and display comprehensive statistics
3. **Find Largest Expense** - Identify the transaction with the highest expense amount
4. **Find Largest Income** - Identify the transaction with the highest income amount
5. **Filter Transactions** - Access the filtering submenu
6. **Load Transactions from File** - Import transactions from a text file
7. **Save Transactions to File** - Export current transactions to a file
8. **Save Statistics to File** - Export statistical analysis to a file
0. **Exit** - Quit the program

### Filter Menu Options

1. **By Category** - Filter transactions by specific category
2. **By Type** - Filter by transaction type (income/expense)
3. **By Date** - Filter by specific date
4. **By Date Range** - Filter transactions within a date range
0. **Back** - Return to main menu

## Code Structure

### Core Data Types
```haskell
-- Transaction record
data Transaction = Transaction {
    date :: String,
    amount :: Double,
    category :: String,
    ttype :: String  -- "income" or "expense"
}

-- Statistics record
data Statistics = Statistics {
    totalIncome :: Double,
    totalExpense :: Double,
    averageTransaction :: Double,
    balance :: Double,
    categoryStats :: [(String, Double)]
}
```

### Key Functions

#### Pure Functions (No Side Effects)
```haskell
-- Calculate total amount
totalAmount :: [Transaction] -> Double
totalAmount = sum . map amount

-- Filter by category
filterByCategory :: String -> [Transaction] -> [Transaction]
filterByCategory cat = filter (\t -> category t == cat)

-- Calculate statistics
calculateStatistics :: [Transaction] -> Statistics
```

#### Higher-Order Functions
- `map` for transforming data
- `filter` for selecting data
- `foldr` for aggregation
- Function composition (`.` operator)

#### IO Functions (With Side Effects)
```haskell
-- File operations
readTransactionsFromFile :: FilePath -> IO [Transaction]
writeTransactionsToFile :: FilePath -> [Transaction] -> IO ()

-- User interaction
mainMenu :: [Transaction] -> IO ()
printStatistics :: Statistics -> IO ()
```

## Functional Programming Concepts Demonstrated

### 1. Pure Functions
- All calculation functions are pure (no side effects)
- Same input always produces same output
- No modification of global state

### 2. Immutability
- All data structures are immutable
- Functions return new data instead of modifying existing data

### 3. Higher-Order Functions
- Functions that take other functions as arguments
- Functions that return functions as results

### 4. Pattern Matching
- Exhaustive case analysis on data types
- Clean handling of different input scenarios

### 5. Algebraic Data Types
- Custom types for transactions and statistics
- Type safety throughout the application

### 6. Lazy Evaluation
- Efficient processing of large datasets
- On-demand computation

## Example Usage Session

```
=== FINANCIAL TRANSACTION ANALYZER ===
1 - Show all transactions
2 - Calculate overall statistics
3 - Find largest expense
4 - Find largest income
5 - Filter transactions
6 - Load transactions from file
7 - Save transactions to file
8 - Save statistics to file
0 - Exit
-----------------------------------
Choose menu item: 2

=== FINANCIAL STATISTICS ===
Total Income: 60000.0
Total Expenses: 5800.0
Average Transaction: 6587.5
Balance: 54200.0

=== CATEGORY STATISTICS ===
salary: 50000.0
freelance: 7000.0
groceries: 2700.0
entertainment: 2000.0
...
```

## Error Handling

The program includes basic error handling:
- Safe file operations with error messages
- Graceful handling of empty transaction lists
- Input validation for dates and amounts
- Use of `Maybe` type for optional values

## Testing

The program includes sample data for immediate testing:
```haskell
sampleTransactions = [
    Transaction "2024-01-15" 50000 "salary" "income",
    Transaction "2024-01-16" 1500 "groceries" "expense",
    -- ... more sample transactions
    ]
```

## Extending the Program

To add new features:

1. **Add new filtering criteria**: Create new pure functions similar to `filterByCategory`
2. **Add new statistical calculations**: Extend the `Statistics` data type and `calculateStatistics` function
3. **Support new file formats**: Implement new parsers for CSV or JSON formats
4. **Add visualization**: Integrate with charting libraries for graphical output

## Dependencies

- Base Haskell libraries only (no external dependencies required)
- Tested with GHC 8.10.7 and 9.0.2

## Limitations

- Basic text-based interface
- Simple date handling (no calendar calculations)
- No database persistence
- No multi-user support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Ensure all functions remain pure where possible
4. Add tests for new functionality
5. Submit a pull request

## License

This project is intended for educational purposes. Feel free to use, modify, and distribute as needed.

---
*This program demonstrates how to build practical applications using pure functional programming techniques in Haskell.*
