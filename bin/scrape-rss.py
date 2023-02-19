import requests
from bs4 import BeautifulSoup
from podgen import Podcast, Episode, Media

def get_podcast_page():
    """Load the page of PA podcast links"""
    URL = "https://pennyarcade.fandom.com/wiki/List_of_D%26D_Podcasts"
    page = requests.get(URL)
    soup = BeautifulSoup(page.content, "html.parser")
    return soup

def init_podcast():
    """Initialize Podcast object with title, website, etc."""
    p = Podcast(
      name = "Penny Arcade Dungeons and Dragons.",
      description = "Omin, Binwin, and Jim Darkmagic and friends go on some adventures.",
      website = "https://pennyarcade.fandom.com/wiki/List_of_D%26D_Podcasts",
      explicit = False,
      image = "https://assets.acq-inc.com/uploads/staff/img_omin.png",
    )
    return p

def main():
    """Min routine loads list of podcast episodes, parses through them and generates an RSS feed."""
    page = get_podcast_page()
    first = init_list(page)
    header = extract_header(first)
    next = next_element(first)
    print(f"\nINITIAL HEADER: {header}\n")

    pod = init_podcast()

    # Step through the next set of H3 or A tags, gathering episodes by their header
    while True:
        # Determine if it's a new h3 or an a tag.
        if next.name == "h3":
            header = extract_header(next)
            print(f"\nHEADER: {header}")

        if next.name == "a":
            handle_episode(next, header, pod)

        # Find the next element, and break the loop if it's the lsat one.
        next = next_element(next)
        #next = next.find_next(["a", "h3"])
        if is_last_element(next):
            break;

    print("DONE")
    pod.rss_file('PA_DND_rss.xml')

def handle_episode(element, header, pod):
    """Determine if this episode is an MP3, and if so, add it to the podcast feed."""
    (text, link) = extract_link(element)

    print(f"LINK: [{text}]({link})")

    if link.endswith("mp3"):
        e = create_episode(link, text, header)
        if not e:
            return

        pod.add_episode(create_episode(link, text, header))

def create_episode(link, text, header):
    """Create a podcast episode item for the feed"""
    e = Episode()
    m = create_media(link)
    if not m:
        return None

    e.title = f"{header} :: {text}"
    e.media = create_media(link)
    return e

def create_media(link):
    """Create a media item based on a link to it."""
    try:
        m = Media.create_from_server_response(link)
        m.fetch_duration()
        return m
    except:
        return None

def init_list(soup):
    """Search for all "external text" links, and then backtrack to the first h3 to identify the series"""
    links = soup.find_all("a", class_="external text")
    first_h3 = links.pop().find_all_previous("h3").pop()
    return first_h3

def next_element(element):
    """Find the next A or H3 tag in the list."""
    return element.find_next(["a", "h3"])

def extract_header(element):
    """Pull the header text out of the element."""
    h = element.find("span", class_="mw-headline")
    return h.contents[0]

def extract_link(element):
    """Pull the link and text components of an Anchor tag."""
    text = element.contents[0]
    link = element.get_attribute_list("href")[0]
    return (text, link)

def is_last_element(next):
    """Is this the end o where we should process the list?"""

    if next.contents[0] == "Series 8 PAX\xa0East 2014 Celebrity Game Video":
        return True

    attrs = next.get_attribute_list("class")
    for attr in attrs:
        if attr == "categoriesLink":
            return True

if __name__ == "__main__":
    main()
