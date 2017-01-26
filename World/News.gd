extends RichTextLabel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_scroll_follow(true)
	clear()

func message(text):
	append_bbcode(text+'\n')
