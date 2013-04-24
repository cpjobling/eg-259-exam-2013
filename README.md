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

Use a generator to create a home controller with an index action. 

    $ rails generate controller home index --skip-javascripts

*Note* that the option 
`--skip-javascripts` prevents the
rails generator creating JavaScript files in support of the new controller. We will be writing those ourself.

Edit the file `config/routes.rb` to replace the line `get "home#index"` by `root to: "home#index"`.
Delete the file `public/index.html`.

    $ git rm public/index.html

In a new window, open the rails server

    $ rails server

Open a new window in your browser and navigate to <http://localhost:3000>. You should see the contents 
of the Erb template file `app/views/home.html.erb` rendered as the contents of the `views/layouts/application.html.erb` layout.

We will be replacing this with HTML from our original TodoMVC Backbone client shortly.

Before proceeding, check your changes into version control.
 
    $ git add .
    $ git commit -m "Add Home controller and remove default index.html."

## 5. Recreate the HTML for the Backbone SPA in Rails.

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
(Note that `javascript_include_tag` has been moved to the end. It took me ages to find a bug
that resulted from loading the JavaScript before the backbone templates in the HTML were loaded!)

Open the file `views/home/index.html.erb` and copy the contents of the SPA `<body>` element. Do not include the `<script src="..."></script>` but ensure that the Backbone templates `<script type="text/template ...></script>` *are* included. We will arrange for the Rails assets pipeline to load the JavaScript files later.

To avoid a clash between underscore templates and rails Erb templates, both of which use `<% %>` tags, we should do a global search and replace to replace `<%` by `<%%`. This will ensure that the template
tags meant for Backbone, will not be interpreted by rails, but passed on the browser as `<%`.

At this point, you should see the same HTML for the Todos app, even though the CSS and other assets are not yet installed. Check in the new changes to git.

    $ git status
    $ git add .
    $ git commit -m "Add HTML for Todos SPA code as Rails views."

## 6. Add the CSS assets

Copy the `base.css` and `bg.png` assets from the `todomvc` repo to the rails repo. The CSS file goes in `app/assets/stylesheets`. The image goes into `app/assets/images`. On my system I used these commands:

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

In the `todomvc-backbone` application, the actual application JavaScript files are stored in the `js` folder, arranged as `models`, `views`, `collections` and `routers`. We can use the same structure inside rails.

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

To make this simple, we'll uses the `rails scaffold` command to generate a new resource to represent the collection of todo items on the server, and to allow them to be persisted in the database.

    $ rails rails generate scaffold todo title completed:boolean order:integer --skip-javascripts

The main files that this command generates is the database "migration" file `db\migrations\`*timestamp*`_create_table_todos.rb`:

```ruby
class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string :title
      t.boolean :completed
      t.integer :order

      t.timestamps
    end
  end
end
```

A "model" file `app/models/todo.rb` that represents the database `todos` table as an *active record* object:

```ruby
class Todo < ActiveRecord::Base
  attr_accessible :completed, :order, :title
end
```

A resource entry in the application routes file `config/routes.rb`:

```ruby
TodosRails::Application.routes.draw do
  resources :todos # <= generated by scaffold generator
   :
  root to: "home#index"
   :
end
```

A controller that has code to generate both JSON and HTML from the seven "restful" actions that Rails
resources support. We will be changing this shortly, so I won't bother showing you the code here. But you may wish to have a look in `app/controllers/todos_controller.rb` because you may be asked about it in the exam.

The scaffolding function also adds views, Erb HTML templates that contain code for displaying a list of todos, showing one tod item, and creating and editing a todo item. As we already have a user interface to handle all of these fundamental operations in the Backbone SPA client we won't need to use the Rails HTML view templates here. Have a look at them for the purposes of learning rails, before you delete them:

    $ rm -rf app/views/todos

Now, run the `rake db:migrate` command to set up the database:

    $ rake db:migrate

Finally, replace the code in `app/controllers/todos_controller.rb` by the following:

```ruby
class TodosController < ApplicationController

 respond_to :json
  
  def index
    respond_with Todo.all
  end
  
  def show
    respond_with Todo.find(params[:id])
  end
  
  def create
    respond_with Todo.create(pick(params, :title, :order, :completed))
  end
  
  def update
    respond_with Todo.update(params[:id], pick(params, :title, :order, :completed))
  end
  
  def destroy
    respond_with Todo.destroy(params[:id])
  end

private

  # See http://www.quora.com/Backbone-js-1/How-well-does-Backbone-js-work-with-Ruby-on-Rails
  # for explanation
  def pick(hash, *keys)
    filtered = {}
    hash.each do |key, value| 
      filtered[key.to_sym] = value if keys.include?(key.to_sym) 
    end
    filtered
  end

end
```

You will want to study this code as explaining it may well form part of an exam question.

Finally, because it is conventional to serve JSON from a special URL that is separate from the normal HTML application, we change the route definition in `config/routes.rb` to:

```ruby
TodosRails::Application.routes.draw do
  scope 'api' do
    resources :todos # <= generated by scaffold generator
  end
   :
  root to: "home#index"
   :
end
```
There should now be a URL that responds with and accepts JSON for the following actions:

    GET /api/todos.json      # index
    GET /api/todos/1.json    # show
    POST /api/todos.json     # create
    PUT /api/todos/1.json    # update
    DELETE /api/todos/1.json # delete

Start the server:

    rails server

and navigate to <http://localhost:3000/api/todos.json>. The Rails server should return `[]`

Add the following to the `db/seeds.rb` file.

```ruby
[1, 2, 3].each do |task_number|
  Todos.create(title: "Task Number: #{task_number}")
end

t = Todos.last
t.completed = true
t.save
```

then run

    $ rake db:seed

Refresh the browser, it should now return something like:

```
[{"completed":true,"created_at":"2013-04-24T08:42:41Z","id":3,"order":null,"title":"Todo 
#3","updated_at":"2013-04-24T11:14:31Z"},{"completed":true,"created_at":"2013-04-
24T08:44:58Z","id":4,"order":null,"title":"Todo #4","updated_at":"2013-04-24T14:05:15Z"},{
"completed":false,"created_at":"2013-04-24T09:09:38Z","id":6,"order":null,"title":"Todo 
#6","updated_at":"2013-04-24T11:14:31Z"},{"completed":false,"created_at":"2013-04-
24T09:13:21Z","id":7,"order":null,"title":"Todo #7","updated_at":"2013-04-24T11:14:31Z"},{
"completed":false,"created_at":"2013-04-24T09:22:33Z","id":8,"order":null,"title":"Todo
#8","updated_at":"2013-04-24T11:14:31Z"},{"completed":true,"created_at":"2013-04-
24T10:08:43Z","id":9,"order":1,"title":"Todo #9","updated_at":"2013-04-24T11:14:31Z"},{
"completed":false,"created_at":"2013-04-24T10:47:20Z","id":11,"order":3,"title":"Todo
 #11","updated_at":"2013-04-24T11:14:31Z"},{"completed":false,"created_at":"2013-04-
 24T11:06:33Z","id":12,"order":null,"title":"Todo #12","updated_at":"2013-04-24T11:14:31Z"}
 ,{"completed":false,"created_at":"2013-04-
 24T11:07:40Z","id":13,"order":null,"title":"Todo #13","updated_at":"2013-04-24T11:14:31Z"}]
```

Notice that one of these items is marked completed!

Time to check into git!

    $ git add .
    $ git commit -am "Added todos resource and JSON api."