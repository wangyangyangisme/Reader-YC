import bb.cascades 1.0
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart

NavigationPane {
    id: newPage
    property variant theModel: theModel
    property string whichPage: ""
    property string morePage: ""
    property string errorText: ""
    property string lastItemType: ""
    property bool busy: false

    onCreationCompleted: {
        Tart.register(newPage)
    }

    onPopTransitionEnded: {
        page.destroy();
        Application.menuEnabled = !Application.menuEnabled;
    }

    function onAddnewStories(data) {
        var stories = data.stories;
        morePage = data.moreLink;
        for (var i = 0; i < stories.length; i ++) {
            var story = stories[i];
            theModel.append({
                    type: 'item',
                    title: story[1],
                    domain: story[2],
                    points: story[3],
                    poster: story[4],
                    timePosted: story[5],
                    commentCount: story[6],
                    articleURL: story[7],
                    commentsURL: story[8],
                    hnid: story[9],
                    isAsk: story[10]
                });
        }
        busy = false;
        loading.visible = false;
        titleBar.refreshEnabled = ! busy;
    }

    function onnewListError(data) {
        var lastItem = theModel.size() - 1
        console.log(lastItemType);
        if (lastItemType == 'error') {
            theModel.removeAt(lastItem)
        }
        theModel.append({
                type: 'error',
                title: data.text
            });
        busy = false;
        loading.visible = false;
        titleBar.refreshEnabled = ! busy;
    }
    Page {
        Container {
            HNTitleBar {
                id: titleBar
                text: "Reader|YC - Newest"
                onRefreshPage: {
                    onRefreshPage: {
                        if (busy != true) {
                            busy = true;
                            Tart.send('requestPage', {
                                    source: 'newestPage',
                                    sentBy: 'newestPage'
                            });
                        console.log("pressed")
                        theModel.clear();
                        refreshEnabled = ! busy;
                        loading.visible = true;
                        }
                    }
                }
            }
            //            Label {
            //                maxHeight: 20.0
            //                text: appInfo.version
            //                textStyle.fontSize: FontSize.Small
            //                textStyle.color: Color.Black
            //            }
            Label {
                id: errorLabel
                text: ""
                visible: false
                multiline: true
                autoSize.maxLineCount: 2
                textStyle.fontSize: FontSize.Medium
                textStyle.fontStyle: FontStyle.Italic
                textStyle.textAlign: TextAlign.Center
            }
            Container {
                visible: loading.visible
                rightPadding: 220
                leftPadding: 220
                topPadding: 80
                ActivityIndicator {
                    id: loading
                    minHeight: 300
                    minWidth: 300
                    running: true
                    visible: busy
                }
            }

            ListView {
                id: theList
                dataModel: ArrayDataModel {
                    id: theModel
                }
                shortcuts: [
                    Shortcut {
                        key: "T"
                        onTriggered: {
                            theList.scrollToPosition(0, 0x2)
                        }
                    },
                    Shortcut {
                        key: "B"
                        onTriggered: {
                            theList.scrollToPosition(0, 0x2)
                        }
                    },
                    Shortcut {
                        key: "R"
                        onTriggered: {
                            if (! busy)
                                refreshPage();
                        }
                    }
                ]
                function itemType(data, indexPath) {
                    if (data.type != 'error') {
                        lastItemType = 'item';
                        return 'item';
                    } else {
                        lastItemType = 'error';
                        return 'error';
                    }
                }
                listItemComponents: [
                    ListItemComponent {
                        type: 'item'
                        HNPage {
                            id: hnItem
                            property string type: ListItemData.type
                            postComments: ListItemData.commentCount
                            postTitle: ListItemData.title
                            postDomain: ListItemData.domain
                            postUsername: ListItemData.poster
                            postTime: ListItemData.timePosted + "| " + ListItemData.points
                            postArticle: ListItemData.articleURL
                            askPost: ListItemData.isAsk
                            commentSource: ListItemData.commentsURL
                            commentID: ListItemData.hnid
                        }
                    },
                    ListItemComponent {
                        type: 'error'
                        Label {
                            id: errorItem
                            property string type: ListItemData.type
                            text: ListItemData.title
                            visible: true
                            multiline: true
                            autoSize.maxLineCount: 2
                            textStyle.fontSize: FontSize.Medium
                            textStyle.fontStyle: FontStyle.Italic
                            textStyle.textAlign: TextAlign.Center
                        }
                    }
                ]
                onTriggered: {
                    var selectedItem = dataModel.data(indexPath);
                    console.log(selectedItem.isAsk);
                    if (selectedItem.isAsk == "true") {
                        console.log("Ask post");
                        var page = commentPage.createObject();
                        newPage.push(page);
                        console.log(selectedItem.commentsURL)
                        page.commentLink = selectedItem.hnid;
                        page.title = selectedItem.title;
                        page.titlePoster = selectedItem.poster;
                        page.titleTime = selectedItem.timePosted + "| " + selectedItem.points
                        page.isAsk = selectedItem.isAsk;
                        Tart.send('requestPage', {
                                source: selectedItem.hnid,
                                sentBy: 'commentPage',
                                askPost: selectedItem.isAsk,
                                deleteComments: "false"
                            });
                    } else {
                        console.log('Item triggered. ' + selectedItem.articleURL);
                        var page = webPage.createObject();
                        newPage.push(page);
                        page.htmlContent = selectedItem.articleURL;
                        page.text = selectedItem.title;
                    }
                }
                attachedObjects: [
                    ListScrollStateHandler {
                        onAtEndChanged: {
                            if (atEnd == true && theModel.isEmpty() == false && morePage != "" && busy == false) {
                                console.log('end reached!')
                                Tart.send('requestPage', {
                                        source: morePage,
                                        sentBy: whichPage
                                });
                            busy = true;
                            }
                        }
                    }
                ]
                function pushPage(pageToPush) {
                    console.log(pageToPush)
                    var page = eval(pageToPush).createObject();
                    //                    page.title = details[0];
                    //                    page.titlePoster = details[1];
                    //                    page.titleTime = details[2];
                    newPage.push(page);
                    return page;
                }
            }
        }
        attachedObjects: [
            ApplicationInfo {
                id: appInfo
            },
            ComponentDefinition {
                id: webPage
                source: "webArticle.qml"
            },
            ComponentDefinition {
                id: commentPage
                source: "CommentPage.qml"
            },
            ComponentDefinition {
                id: userPage
                source: "UserPage.qml"
            }
        ]
    }
}