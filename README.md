# Todos on Rails

## 1. *Create a new rails project*

    $ rails new todos_rails

## 2. *Add to Git*

    $ cd todos_rails
    $ git init .
    $ git add .
    $ git commit -m "New rails app"


## 3. Clone TodoMVC and extract the backbone implementation

    $ cd ..
    $ git clone https://github.com/addyosmani/todomvc.git
    $ cd todomvc/architecture-examples/backbone
    $ mkdir ../../..todomvc-backbone
    $ cp -r * ../../../todomvc-backbone
    $ cd ../../../todomvc-backbone

Open the file index.html in a browser to ensure that it works

    $ open index.html

Explore the files provided. These will become assets in the rails app. View source in your browser and note which CSS and JavaScript assets will be loaded with the HTML.

Open the todomvc-backbone project in a new edtor.

## 4. Create a home controller

Go back to Rails Project

    $ cd ../todos_rails

Use a generator to create a home controller with an index action

    $ rails generate controller Home index

Edit the file `config/routes.rb` to replace the line `get "home#index"` by `root :to => "home#index"`.
Delete the file `public/index.html`.

    $ git rm public/index.html

In a new window, open the rails server

    $ rails server

Open a new window in your browser and navigate to <http://localhost:3000>. You should see the contents 
of the Erb template file `app/views/home.html.erb` rendered as the contents of the `views/layouts/application.html.erb` layout.

We will be replacing this with our TodoMVC Backbone client shortly.

Before proceeding, check your changes into version control.
 
    $ git add .
    $ git commit -m "Add Home controller and remove default index.html."

## 5. Recreate the Backbone SPA as a Rails App.

Combine the head from `backbone-todomvc/index.html` with that of `app/views/layouts/application.html.erb`. The result will be:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>Backbone.js • TodoMVC  • Rails</title>
    <%= stylesheet_link_tag    "application", :media => "all" %>
    <%= csrf_meta_tags %>
  </head>
  <body>

  <%= yield %>
  
  <%= javascript_include_tag "application" %>
  </body>
</html>
```
(Note that JavaScript include has been moved to the end. It took me ages to find that bug!)

Open the file `views/home/index.html.erb` and copy the contents of the SPA `<body>` element. Do not include the `<script src="..."></script>` but ensure that the Backbone templates `<script type="text/template ...></script>` are included. We will arrange for the Rails assets pipeline to load the JavaScript files later.

To avoid a clash between underscore templates and rails Erb templates, both of which use `<% %>` tags, we should do a global search and replace to replace `<%` by `<%%`. This will ensure that the template
tags meant for Backbone, will not be interpreted by rails.

At this point, you should see the same HTML for the Todos app, even though the CSS and other assets are not yet installed. Check in the new changes to git.

    $ git status
    $ git add .
    $ git commit -m "Add HTML for Todos SPA code as Rails views."

## 6. Add the CSS assets

Copy the `base.css` and `bg.png` assets from the `todomvc` repo to the rails repo. The CSS file goes in `app/assets/stylesheets`. The image goes into `app/assets/stylesheets`. On my system I used these commands:

    $ cp ../todomvc/assets/base.css app/assets/stylesheets
    $ cp ../todomvc/assets/*.png app/assets/images

Check the result by refreshing the page in the browser.

That's the easy bit!

    $ git add .
    $ git commit -m "Add CSS and image assets"

## 7. Add the library JavaScript files.

The Rails convention is to put JavaScript library files into `vendor/assets/javascripts`, so we'll do that here. The files we need to copy from `todomvc-backbone` are in the components folder. 

    $ cp -r ../todomvc-backbone/components/* vendor/assets/javascripts

Rails already has jQuery installed, so we can remove that from the 'vendor/assets/javascript' folder

    $ rm -rf vendor/assets/javascripts/jquery

We then need to add the new libraries and the configuration file to the Rails JavaScript assets manifest that is stored in `app/assets/javascripts/application.js`. Edit that file so that the manifest looks like:

```javascript
//= require jquery
//= require jquery_ujs
//= require underscore/underscore
//= require backbone/backbone
//= require backbone.localStorage/backbone.localStorage
//= require_tree .
```



Once again, check this change into version control:

    $ git add .
    $ git commit -m "Add vendor/assets/javascripts needed for backbone"

## 8. Add the application JavaScripts

In the `todomvc-backbone` application, the actual application JavaScript files are stored in the `js` folder, arranged as `models`, `views`, `collections` and 'routers'. We can use the same structure inside rails.

    $ cp -r ../todomvc-backbone/js/* app/assets/javascripts

Add these new assets to the mainfest file:

```javascript
//= require jquery
//= require underscore/underscore
//= require backbone/backbone
//= require backbone.localStorage/backbone.localStorage
//= require models/todo
//= require collections/todos
//= require views/todos
//= require views/app
//= require routers/router
//= require app.js
//= require application.js
```

At this point, the Rails server is serving the TodoMVC app like a web server would!

Commit your changes.

    $ git status
    $ git add .
    $ git commit -m "TodoMVC served by Rails!"

## 10. The last step is to make rails serve the Todo list as a resource. 

We'll tackle that in class.
