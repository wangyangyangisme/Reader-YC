import urllib.request
from bs4 import BeautifulSoup
import re

class HackerNewsUserAPI:

    def getSource(self, url):
        """Returns the HTML source code for a URL.
        """

        print("curling page: " + url)
        with urllib.request.urlopen(url) as url:
            source = url.read()
        print("page curled")
        return source

    def getUserPage(self, source):
        """Looks through the user page source,
           and returns the account details
        """
        source = self.getSource(source)
        if (str(source) == "b'No such user.'"):
            raise Exception
        soup = BeautifulSoup(source)

        details = [] # List of details extracted from the source
        results = [] # List of results to return
        usefulCount = 0 # We don't want all elements from our comprehesion
        for item in soup.findAll('tr'):
            usefulCount = usefulCount + 1
            if (usefulCount > 4):
                details.append(item)

        usefulCount = 0 # Reset for the next list comprehesion
        for item in details:
            usefulCount = usefulCount + 1
            if (usefulCount <= 5): # The first 5 results are just text:
                                   # username, created, karma, avg, about
                start = str(item).find('<td>') + 4
                end = str(item).find('</td', start)
                result = str(item)[start:end]
                results.append(result)
            else: # The other two are links to the user's comments and submissions
                start = str(item).find('="') + 2
                end = str(item).find('><u', start) - 1
                result = "http://news.ycombinator.com/" +  str(item)[start:end]
                results.append(result)
        return results