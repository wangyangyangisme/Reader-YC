import bb.cascades 1.2
import bb.system 1.2
import "tart.js" as Tart
import "global.js" as Global

Container {
    id: submitItem
    property string link: ""
    property alias text: commentText.text
    onCreationCompleted: {
        Tart.register(submitItem)
    }

    function onCommentPosted(data) {
        console.log("comment posted!!");
        console.log(data.result);
        replyItem.ListItem.view.updateComment(data.result, data);
        if (data.result == "true") {
            commentToast.body = "Comment posted!";
            lastItemType = 'item';
        } else {
            commentToast.body = "Posting comment failed!";
            console.log("Error sending comment!")
        }
        commentToast.cancel();
        commentToast.show();
        replyButton.enabled = true;
    }

    
    leftPadding: 10
    rightPadding: 10
    topPadding: 10
    bottomPadding: 10
    attachedObjects: [
        SystemToast {
            id: commentToast
            body: "COMMENT"
        },
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
//            fontSize: FontSize.PointValue
//            fontSizeValue: 7
            fontWeight: FontWeight.W300
        },
        ImagePaintDefinition {
            imageSource: "asset:///images/text.amd"
            id: background
        }
    ]

    Container {
        background: background.imagePaint

        TextArea {
            onCreationCompleted: {
                focused:
                true;
            }
            autoSize.maxLineCount: 10
            backgroundVisible: false
            enabled: true
            editable: true
            text: ""
            id: commentText
            verticalAlignment: VerticalAlignment.Fill
            textStyle.color: Color.create("#262626")
            hintText: "Enter your comment"

            onTextChanging: {
                if (text == "") {
                    replyButton.enabled = false;
                } else {
                    replyButton.enabled = true;
                }
            }
        }
    }
    Container {
        id: helpContainer
        visible: false
        Label {
            text: "Text surrounded by asterisks will be italicized"
            bottomMargin: 0
            topMargin: 0
            textStyle.fontSizeValue: 5
            textStyle.base: lightStyle.style
            textStyle.fontStyle: FontStyle.Italic
        }
        Label {
            text: "Lines starting with 4 spaces will be wrapped in code tags" 
            bottomMargin: 0
            topMargin: 0
            textStyle.fontSizeValue: 5
            textStyle.base: lightStyle.style
            textStyle.fontStyle: FontStyle.Italic
        }
        Label {
            text: "Posting as: " + "<span style='color:#f99925'>" + Global.username + "</span>"
            bottomMargin: 0
            textStyle.fontSizeValue: 6
            topMargin: 0
            textStyle.base: lightStyle.style
            textFormat: TextFormat.Html
            textStyle.fontStyle: FontStyle.Italic
            autoSize.maxLineCount: -1
        }
    }
    Container {
        bottomPadding: 10
        topPadding: 10
        horizontalAlignment: HorizontalAlignment.Right
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        Button {
            id: replyButton
            enabled: false
            maxWidth: 100
            horizontalAlignment: HorizontalAlignment.Right
            rightMargin: 10
            imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/icons/ic_comments.png" : "asset:///images/icons/ic_comments_dk.png"
            onClicked: {
                enabled = false;
                Tart.send('sendComment', {
                        source: link,
                        text: commentText.text
                    });
            }
        }
        Button {
            id: helpButton
            enabled: true
            maxWidth: 100
            horizontalAlignment: HorizontalAlignment.Right
            rightMargin: 10
            imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/icons/ic_help.png" : "asset:///images/icons/ic_help_dk.png"
            onClicked: {
                if (helpContainer.visible) {
                    helpContainer.visible = false;
                } else {
                    helpContainer.visible = true;
                }
            }
        }
        Button {
            maxWidth: 100
            enabled: true
            imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/icons/ic_cancel.png" :  "asset:///images/icons/ic_cancel_dk.png"
            onClicked: {
                Application.menuEnabled = true;
                helpContainer.visible = false;
                commentText.text = "";
                replyItem.ListItem.view.cancelComment(submitItem.ListItem.indexInSection)
            }
        }
    }
}
