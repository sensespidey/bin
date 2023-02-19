import requests
from bs4 import BeautifulSoup

# Load the page of PA podcast links
URL = "https://pennyarcade.fandom.com/wiki/List_of_D%26D_Podcasts"
page = requests.get(URL)
soup = BeautifulSoup(page.content, "html.parser")

# Search for all "external text" links, and then backtrack to the first h3 to
# identify the series
links = soup.find_all("a", class_="external text")
first_h3 = links.pop().find_all_previous("h3").pop()

print(first_h3.get_text())

# Now
rest = first_h3.find_all_next(["a", "h3"])
for r in rest:
    print(r.prettify())


while True:
    next = first_h3.find_next(["a", "h3"])
    next.get_attribute_list("class").contains("categoriesLink"):
        break

    print("Next element:\n")
    print(next.prettify())
