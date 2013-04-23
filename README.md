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