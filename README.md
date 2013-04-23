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
    <%= javascript_include_tag "application" %>
    <%= csrf_meta_tags %>
  </head>
  <body>

  <%= yield %>

  </body>
</html>
```

Open the file `views/home/index.html.erb` and copy the contents of the SPA `<body>` element. Do not include the `<script src="..."></script>` but ensure that the Backbone templates `<script type="text/template ...></script>` are included. We will arrange for the Rails assets pipeline to load the JavaScript files later.

To avoid a clash between underscore templates and rails Erb templates, both of which use `<% %>` tags, we should do a global serach and replace to replace `<%` by `[%` and `%>` by `%]`.

    $ mv app/views/home/index.html.erb app/views/home/index.html

To tell Backbone about this change, add the following to the file `app/assets/javascripts/home.js.coffee`:

```javascript
_.templateSettings = {
    interpolate: /\[\[\=(.+?)\]\]/g,
    evaluate: /\[\[(.+?)\]\]/g
};
```

Rename the file `home.js.coffee` as `home.js`.

    $ git mv app/assets/javascripts/home.js.coffee app/assets/javascripts/home.js

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