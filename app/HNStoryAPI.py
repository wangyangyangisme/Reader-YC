import urllib.request
from bs4 import BeautifulSoup
import re

import tart

class HackerNewsStoryAPI:
    """The class for slicing and dicing the HTML and turning it into
       HackerNewsStory objects.
    """

    numberOfStoriesOnFrontPage = 0

    def getSource(self, url):
        """Returns the HTML source code for a URL.
        """
        print("curling page: " + url)
        with urllib.request.urlopen(url) as url:
            source = url.read()
        print("page curled")
        return source

    def getStoryNumber(self, source):
        """Parses HTML and returns the number of a story.
        """

        numberStart = source.find('>') + 1
        numberEnd = source.find('.')
        return int(source[numberStart:numberEnd])

    def getStoryURL(self, source):
        """Gets the URL of a story.
        """

        ask = "false"
        URLStart = source.find('href="') + 6
        URLEnd = source.find('">', URLStart)
        url = source[URLStart:URLEnd]
        # Check for "Ask HN" links.
        if url[0:4] == "item": # "Ask HN" links start with "item".
            url = "http://news.ycombinator.com/" + url
            ask = "true"

        # Remove 'rel="nofollow' from the end of links, since they were causing some bugs.
        if url[len(url)-13:] == "rel=\"nofollow":
            url = url[:len(url)-13]

        # Weird hack for URLs that end in '" '. Consider removing later if it causes any problems.
        if url[len(url)-2:] == "\" ":
            url = url[:len(url)-2]
        return url, ask

    def getStoryDomain(self, source):
        """Gets the domain of a story.
        """

        domainStart = source.find('comhead">') + 10
        domainEnd = source.find('</span>')
        domain = source[domainStart:domainEnd]
        # Check for "Ask HN" links.
        if domain[0] == '=':
            return "http://news.ycombinator.com"
        return "http://" + domain[1:len(domain)-2]

    def getStoryTitle(self, source):
        """Gets the title of a story.
        """

        titleStart = source.find('>', source.find('>')+1) + 1
        titleEnd = source.find('</a>')
        title = source[titleStart:titleEnd]
        title = title.lstrip() # Strip trailing whitespace characters.
        return title

    def getStoryScore(self, source):
        """Gets the score of a story.
        """

        scoreStart = source.find('>', source.find('>')+1) + 1
        scoreEnd = source.find(' ', scoreStart)
        try:
            score = int(source[scoreStart:scoreEnd])
            if score == 1:
                return str(score) + ' point'
            else:
                return str(score) + ' points'
        except ValueError:
            return ' HN Jobs'

    def getStoryDetails(self, source):
        """Gets the poster username and the time it was posted
        """

        submitterStart = source.find('user?id=')
        realSubmitterStart = source.find('=', submitterStart) + 1
        submitterEnd = source.find('"', realSubmitterStart)
        submitter = source[realSubmitterStart:submitterEnd]
        if submitter == '<td class=': # If the post is a 'Job post', there is no submitter.
            submitter = 'ycombinator'

        timeStart = source.find(submitter + '</a>') + len(submitter) + 5
        timeEnd = source.find('|', timeStart) - 1
        time = source[timeStart:timeEnd]
        if 'ext' in time:
            time = re.findall(r"(\d+ .* ago)", source) # regex to find time
            time = str(time[0]) + ' '
            #print(time)

        return submitter, time

    def getCommentCount(self, source):
        """Gets the comment count of a story.
        """

        commentStart = source.find('item?id=')
        commentCountStart = source.find('>', commentStart) + 1
        commentEnd = source.find('</a>', commentStart)
        commentCountString = source[commentCountStart:commentEnd]
        if commentCountString == "discuss":
            return 0
        elif commentCountString == "":
            return 0
        else:
            commentCountString = commentCountString.split(' ')[0]
            if commentCountString == "comments":
                return 0
            return commentCountString

    def getHNID(self, source):
        """Gets the Hacker News ID of a story.
        """

        urlStart = source.find('score_') + 6
        urlEnd = source.find('"', urlStart)
        try:
            return int(source[urlStart:urlEnd])
        except ValueError:
            return -1


    def getCommentsURL(self, source):
        """Gets the comment URL of a story.
        """

        return "http://news.ycombinator.com/item?id=" + str(self.getHNID(source))


    def getMoreLink(self, page):
        """Gets the link for more posts found at the bottom of every page.
        """

        soup = BeautifulSoup(page)
        story_details = soup.findAll("td", {"class" : "title"})
        source = str(story_details[len(story_details) - 1])
        linkStart = source.find('href="') + 6

        if len(source) > 49:
            linkStart = linkStart + 1
            linkEnd = source.find('rel=') - 2
            moreLink = source[linkStart:linkEnd]
            return moreLink
        else:
            linkEnd = source.find('>More<') - 1
            moreLink = source[linkStart:linkEnd]
            return moreLink


    def getStories(self, source):
        """Looks at source, makes stories from it, returns the stories.
        """

        # Decodes source to utf-8
        source = source.decode('utf-8')
        # print(source)
        self.numberOfStoriesOnFrontPage = source.count('</center></td><td class="title">') # There was a counting method, but it always gave the wrong number of stories.
        print(self.numberOfStoriesOnFrontPage)
        # Create the empty stories.
        newsStories = []
        for i in range(0, self.numberOfStoriesOnFrontPage):
            story = HackerNewsStory()
            newsStories.append(story)

        soup = BeautifulSoup(source)
        # Gives URLs, Domains and titles.
        story_details = soup.findAll("td", {"class" : "title"})
        # Gives score, submitter, comment count and comment URL.
        story_other_details = soup.findAll("td", {"class" : "subtext"})

        # Get story numbers.
        storyNumbers = []
        for i in range(0,len(story_details) - 1, 2):
            story = str(story_details[i]) # otherwise, story_details[i] is a BeautifulSoup-defined object.
            storyNumber = self.getStoryNumber(story)
            storyNumbers.append(storyNumber)

        storyURLs = []
        storyAsk = []
        storyDomains = []
        storyTitles = []
        storyScores = []
        storySubmitters = []
        storyCommentCounts = []
        storyCommentURLs = []
        storyTimes = []
        storyIDs = []

        for i in range(1, len(story_details), 2): # Every second cell contains a story.
            story = str(story_details[i])
            url, isAsk = self.getStoryURL(story)
            storyURLs.append(url)
            storyAsk.append(isAsk)
            storyDomains.append(self.getStoryDomain(story))
            storyTitles.append(self.getStoryTitle(story))

        for s in story_other_details:
            story = str(s)
            storyScores.append(self.getStoryScore(story))
            storySubmitter, storyTime = self.getStoryDetails(story)
            storySubmitters.append(storySubmitter)
            storyTimes.append(storyTime)
            storyCommentCounts.append(self.getCommentCount(story))
            storyCommentURLs.append(self.getCommentsURL(story))
            storyIDs.append(self.getHNID(story))


        # Associate the values with our newsStories.
        for i in range(0, self.numberOfStoriesOnFrontPage):
            newsStories[i].number = storyNumbers[i]
            newsStories[i].askPost = storyAsk[i]
            newsStories[i].URL = storyURLs[i]
            newsStories[i].domain = storyDomains[i]
            newsStories[i].title = storyTitles[i]
            newsStories[i].score = storyScores[i]
            newsStories[i].submitter = storySubmitters[i]
            newsStories[i].time = storyTimes[i]
            newsStories[i].commentCount = storyCommentCounts[i]
            newsStories[i].commentsURL = storyCommentURLs[i]
            newsStories[i].id = storyIDs[i]

        return newsStories

    def getPage(self, page):
        """Gets the stories from the specified Hacker News page.
        """

        source = self.getSource(page)
        moreLink = self.getMoreLink(source)
        stories = self.getStories(source)
        return stories, moreLink

class HackerNewsStory:
    """A class representing a story on Hacker News.
    """

    id = 0 # The Hacker News ID of a story.
    number = -1 # What rank the story is on HN.
    title = "" # The title of the story.
    domain = "" # The website the story is from.
    URL = "" # The URL of the story.
    askPost = "false"
    score = -1 # Current score of the story.
    submitter = "" # The person that submitted the story.
    commentCount = -1 # How many comments the story has.
    commentsURL = "" # The HN link for commenting (and upmodding).
    time = "" # The time the HN link was posted

    def getDetails(self):
        """Creates a tuple of the story's details
        """
        self.number = '%03d' % self.number # prepends zeroes to the article number
        detailList = (str(self.number), self.title, self.domain, str(self.score), self.submitter, self.time, str(self.commentCount), self.URL, self.commentsURL, str(self.id), str(self.askPost))
        return detailList