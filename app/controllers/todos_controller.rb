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
