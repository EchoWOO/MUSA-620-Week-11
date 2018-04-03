
require(RSelenium)
require(rvest)

# java -jar selenium-server-standalone-3.9.1.jar
remDr <- remoteDriver(browserName = "chrome")

remDr$open()
remDr$navigate("http://property.phila.gov/")

searchBar <- remDr$findElement("css selector","#search-address")
searchBar$sendKeysToElement(list("224-30 W RITTENHOUSE SQ"))
searchBar2 <- remDr$findElement("css selector","#search-unit")
searchBar2$sendKeysToElement(list("1003"))

searchBar2$sendKeysToElement(list(key = 'enter'))


# some of the different CSS selectors for grabbing the valuation table

mytable <- remDr$findElement("css selector",".tablesaw-stack > tbody > tr:nth-child(1) > td:nth-child(2) > span")
mytable$getElementText()

mytable <- remDr$findElement("css selector","table > tbody > tr:nth-child(1) > td:nth-child(2) > span")
mytable$getElementText()

mytable <- remDr$findElement("css selector","[data-hook='valuation-table'] > tbody > tr:nth-child(1) > td:nth-child(2) > span")
mytable$getElementText()

mytable <- remDr$findElement("css selector","tbody > tr:nth-child(1) > td:nth-child(2) > span")
mytable$getElementText()

mytable <- remDr$findElement("css selector","tr:nth-child(1) > td:nth-child(2) > span")
mytable$getElementText()


