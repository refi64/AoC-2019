getFuel :: Int -> Int
getFuel = max 0 . flip (-) 2 . flip div 3

scanWhile :: (a -> Bool) -> (a -> a) -> a -> [a]
scanWhile test func value = tail . takeWhile test $ iterate func value

loadModules :: IO [Int]
loadModules = ((map read) . lines) <$> readFile "input"

part1 = sum . map getFuel
part2 = sum . concat . map (scanWhile (/= 0) getFuel)

main = do
  modules <- loadModules
  putStrLn $ "part 1: " ++ (show $ part1 modules)
  putStrLn $ "part 2: " ++ (show $ part2 modules)
