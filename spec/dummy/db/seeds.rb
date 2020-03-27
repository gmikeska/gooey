f = {text:{required:true, default:"Hello World!"}}

simpleDiv = Gooey::Design.create(name:"simpleDiv",fields:f, content_template:"{text}", tag:"div")
container = Gooey::Design.create(name:"container",fields:f,options:{css_class:"container"} , content_template:"{text}", tag:"div")
