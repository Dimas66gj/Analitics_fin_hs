import Data.List (sortBy, maximumBy, minimumBy)
import Data.Ord (comparing)
import System.IO
import Text.Read (readMaybe)
import Control.Monad (when)

-- 1. ОПРЕДЕЛЕНИЕ ТИПОВ ДАННЫХ

-- Тип для финансовой транзакции
data Transaction = Transaction {
    date :: String,
    amount :: Double,
    category :: String,
    ttype :: String  -- "income" (доход) или "expense" (расход)
} deriving (Show, Read, Eq)

-- Тип для статистики
data Statistics = Statistics {
    totalIncome :: Double,
    totalExpense :: Double,
    averageTransaction :: Double,
    balance :: Double,
    categoryStats :: [(String, Double)]
} deriving (Show)

-- 2. ФУНКЦИИ ДЛЯ РАБОТЫ С ТРАНЗАКЦИЯМИ

-- Общая сумма всех транзакций
totalAmount :: [Transaction] -> Double
totalAmount = sum . map amount

-- Общая сумма доходов
totalIncomeAmount :: [Transaction] -> Double
totalIncomeAmount txs = sum $ map amount $ filter (\t -> ttype t == "income") txs

-- Общая сумма расходов
totalExpenseAmount :: [Transaction] -> Double
totalExpenseAmount txs = sum $ map amount $ filter (\t -> ttype t == "expense") txs

-- Средняя сумма транзакции
averageAmount :: [Transaction] -> Double
averageAmount [] = 0
averageAmount txs = totalAmount txs / fromIntegral (length txs)

-- Фильтрация по категории
filterByCategory :: String -> [Transaction] -> [Transaction]
filterByCategory cat = filter (\t -> category t == cat)

-- Фильтрация по типу транзакции
filterByType :: String -> [Transaction] -> [Transaction]
filterByType typ = filter (\t -> ttype t == typ)

-- Фильтрация по дате
filterByDate :: String -> [Transaction] -> [Transaction]
filterByDate d = filter (\t -> date t == d)

-- Фильтрация по диапазону дат
filterByDateRange :: String -> String -> [Transaction] -> [Transaction]
filterByDateRange startDate endDate = 
    filter (\t -> date t >= startDate && date t <= endDate)

-- Наибольший расход
maxExpense :: [Transaction] -> Maybe Transaction
maxExpense [] = Nothing
maxExpense txs = 
    let expenses = filter (\t -> ttype t == "expense") txs
    in if null expenses 
       then Nothing
       else Just $ maximumBy (comparing amount) expenses

-- Наибольший доход
maxIncome :: [Transaction] -> Maybe Transaction
maxIncome [] = Nothing
maxIncome txs = 
    let incomes = filter (\t -> ttype t == "income") txs
    in if null incomes 
       then Nothing
       else Just $ maximumBy (comparing amount) incomes

-- Минимальный расход
minExpense :: [Transaction] -> Maybe Transaction
minExpense [] = Nothing
minExpense txs = 
    let expenses = filter (\t -> ttype t == "expense") txs
    in if null expenses 
       then Nothing
       else Just $ minimumBy (comparing amount) expenses

-- Подсчет статистики по категориям
categoryStatistics :: [Transaction] -> [(String, Double)]
categoryStatistics txs = 
    let categories = nub $ map category txs
        sums = map (\cat -> 
            (cat, sum $ map amount $ filter (\t -> category t == cat) txs)) 
            categories
    in sortBy (\(_,a) (_,b) -> compare b a) sums  -- сортировка по убыванию суммы

-- Удаление дубликатов (вспомогательная функция)
nub :: Eq a => [a] -> [a]
nub [] = []
nub (x:xs) = x : nub (filter (/= x) xs)

-- Вычисление полной статистики
calculateStatistics :: [Transaction] -> Statistics
calculateStatistics txs = Statistics {
    totalIncome = totalIncomeAmount txs,
    totalExpense = totalExpenseAmount txs,
    averageTransaction = averageAmount txs,
    balance = totalIncomeAmount txs - totalExpenseAmount txs,
    categoryStats = categoryStatistics txs
}

-- 3. ФУНКЦИИ ДЛЯ РАБОТЫ С ФАЙЛАМИ

-- Чтение транзакций из файла
readTransactionsFromFile :: FilePath -> IO [Transaction]
readTransactionsFromFile filename = do
    content <- readFile filename
    let linesOfFile = lines content
    return $ map parseTransaction linesOfFile
  where
    parseTransaction line = 
        case words line of
            [d, a, c, t] -> 
                case readMaybe a of
                    Just amountVal -> Transaction d amountVal c t
                    Nothing -> error $ "Некорректная сумма в строке: " ++ line
            _ -> error $ "Некорректный формат строки: " ++ line

-- Запись транзакций в файл
writeTransactionsToFile :: FilePath -> [Transaction] -> IO ()
writeTransactionsToFile filename txs = do
    let content = unlines $ map showTransaction txs
    writeFile filename content
  where
    showTransaction (Transaction d a c t) = d ++ " " ++ show a ++ " " ++ c ++ " " ++ t

-- Сохранение статистики в файл
saveStatisticsToFile :: FilePath -> Statistics -> IO ()
saveStatisticsToFile filename stats = do
    let content = "=== ФИНАНСОВАЯ СТАТИСТИКА ===\n" ++
                  "Общий доход: " ++ show (totalIncome stats) ++ "\n" ++
                  "Общий расход: " ++ show (totalExpense stats) ++ "\n" ++
                  "Средняя сумма транзакции: " ++ show (averageTransaction stats) ++ "\n" ++
                  "Баланс: " ++ show (balance stats) ++ "\n" ++
                  "\n=== СТАТИСТИКА ПО КАТЕГОРИЯМ ===\n" ++
                  unlines (map (\(cat, sum) -> cat ++ ": " ++ show sum) (categoryStats stats))
    writeFile filename content

-- 4. ФУНКЦИИ ДЛЯ ВЫВОДА ИНФОРМАЦИИ

-- Печать транзакции
printTransaction :: Transaction -> IO ()
printTransaction (Transaction d a c t) = 
    putStrLn $ "Дата: " ++ d ++ " | Сумма: " ++ show a ++ 
               " | Категория: " ++ c ++ " | Тип: " ++ t

-- Печать списка транзакций
printTransactions :: [Transaction] -> IO ()
printTransactions [] = putStrLn "Нет транзакций для отображения."
printTransactions txs = do
    putStrLn "Список транзакций:"
    putStrLn "--------------------------------------------------"
    mapM_ printTransaction txs
    putStrLn "--------------------------------------------------"
    putStrLn $ "Всего транзакций: " ++ show (length txs)

-- Печать статистики
printStatistics :: Statistics -> IO ()
printStatistics stats = do
    putStrLn "=== ФИНАНСОВАЯ СТАТИСТИКА ==="
    putStrLn $ "Общий доход: " ++ show (totalIncome stats)
    putStrLn $ "Общий расход: " ++ show (totalExpense stats)
    putStrLn $ "Средняя сумма транзакции: " ++ show (averageTransaction stats)
    putStrLn $ "Баланс: " ++ show (balance stats)
    
    putStrLn "\n=== СТАТИСТИКА ПО КАТЕГОРИЯМ ==="
    if null (categoryStats stats)
        then putStrLn "Нет данных по категориям."
        else mapM_ (\(cat, sum) -> putStrLn $ cat ++ ": " ++ show sum) (categoryStats stats)

-- 5. ИНТЕРАКТИВНОЕ МЕНЮ

-- Главное меню
mainMenu :: [Transaction] -> IO ()
mainMenu txs = do
    putStrLn "\n=== АНАЛИЗ ФИНАНСОВЫХ ТРАНЗАКЦИЙ ==="
    putStrLn "1 - Показать все транзакции"
    putStrLn "2 - Подсчитать общую статистику"
    putStrLn "3 - Найти наибольший расход"
    putStrLn "4 - Найти наибольший доход"
    putStrLn "5 - Фильтровать транзакции"
    putStrLn "6 - Загрузить транзакции из файла"
    putStrLn "7 - Сохранить транзакции в файл"
    putStrLn "8 - Сохранить статистику в файл"
    putStrLn "0 - Выход"
    putStrLn "-----------------------------------"
    putStr "Выберите пункт меню: "
    hFlush stdout
    
    choice <- getLine
    
    case choice of
        "1" -> do
            printTransactions txs
            mainMenu txs
            
        "2" -> do
            let stats = calculateStatistics txs
            printStatistics stats
            mainMenu txs
            
        "3" -> do
            case maxExpense txs of
                Nothing -> putStrLn "Нет данных о расходах."
                Just tx -> do
                    putStrLn "Наибольший расход:"
                    printTransaction tx
            mainMenu txs
            
        "4" -> do
            case maxIncome txs of
                Nothing -> putStrLn "Нет данных о доходах."
                Just tx -> do
                    putStrLn "Наибольший доход:"
                    printTransaction tx
            mainMenu txs
            
        "5" -> do
            filterMenu txs
            
        "6" -> do
            putStr "Введите имя файла для загрузки: "
            hFlush stdout
            filename <- getLine
            loadedTxs <- readTransactionsFromFile filename
            putStrLn $ "Загружено " ++ show (length loadedTxs) ++ " транзакций."
            mainMenu loadedTxs
            
        "7" -> do
            putStr "Введите имя файла для сохранения: "
            hFlush stdout
            filename <- getLine
            writeTransactionsToFile filename txs
            putStrLn "Транзакции сохранены."
            mainMenu txs
            
        "8" -> do
            putStr "Введите имя файла для сохранения статистики: "
            hFlush stdout
            filename <- getLine
            let stats = calculateStatistics txs
            saveStatisticsToFile filename stats
            putStrLn "Статистика сохранена."
            mainMenu txs
            
        "0" -> do
            putStrLn "Выход из программы."
            
        _ -> do
            putStrLn "Неверный выбор. Попробуйте снова."
            mainMenu txs

-- Меню фильтрации
filterMenu :: [Transaction] -> IO ()
filterMenu txs = do
    putStrLn "\n=== ФИЛЬТРАЦИЯ ТРАНЗАКЦИЙ ==="
    putStrLn "1 - По категории"
    putStrLn "2 - По типу (доход/расход)"
    putStrLn "3 - По дате"
    putStrLn "4 - По диапазону дат"
    putStrLn "0 - Назад"
    putStr "Выберите пункт меню: "
    hFlush stdout
    
    choice <- getLine
    
    case choice of
        "1" -> do
            putStr "Введите категорию: "
            hFlush stdout
            cat <- getLine
            let filtered = filterByCategory cat txs
            printTransactions filtered
            mainMenu txs
            
        "2" -> do
            putStr "Введите тип (income/expense): "
            hFlush stdout
            typ <- getLine
            let filtered = filterByType typ txs
            printTransactions filtered
            mainMenu txs
            
        "3" -> do
            putStr "Введите дату (YYYY-MM-DD): "
            hFlush stdout
            d <- getLine
            let filtered = filterByDate d txs
            printTransactions filtered
            mainMenu txs
            
        "4" -> do
            putStr "Введите начальную дату (YYYY-MM-DD): "
            hFlush stdout
            start <- getLine
            putStr "Введите конечную дату (YYYY-MM-DD): "
            hFlush stdout
            end <- getLine
            let filtered = filterByDateRange start end txs
            printTransactions filtered
            mainMenu txs
            
        "0" -> mainMenu txs
            
        _ -> do
            putStrLn "Неверный выбор. Попробуйте снова."
            filterMenu txs

-- 6. ТЕСТОВЫЕ ДАННЫЕ И ГЛАВНАЯ ФУНКЦИЯ

-- Пример транзакций для тестирования
sampleTransactions :: [Transaction]
sampleTransactions = [
    Transaction "2024-01-15" 50000 "зарплата" "income",
    Transaction "2024-01-16" 1500 "продукты" "expense",
    Transaction "2024-01-17" 300 "транспорт" "expense",
    Transaction "2024-01-18" 2000 "развлечения" "expense",
    Transaction "2024-01-19" 10000 "премия" "income",
    Transaction "2024-01-20" 800 "кафе" "expense",
    Transaction "2024-01-21" 1200 "продукты" "expense",
    Transaction "2024-01-22" 7000 "фриланс" "income"
    ]

-- Главная функция
main :: IO ()
main = do
    putStrLn "Добро пожаловать в программу анализа финансовых транзакций!"
    putStrLn "Используются тестовые данные. Для загрузки своих данных выберите пункт 6 в меню."
    mainMenu sampleTransactions
