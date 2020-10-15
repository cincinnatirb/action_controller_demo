# ActionController Demo
In this demo we will:
* Review a bit about the "M" and "V" parts of MVC
* Learn how to debug our code with Pry
* Learn about the essential parts of a Rails controller including:
    * Actions/Methods
    * Parameters including Strong Parameters
    * Filters
    * Flash (with Cookies & Sessions)

**NOTE:** You will eventually be able to watch a presentation of this material.

## 1. Prerequisites
* Ubuntu 20 LTS: https://www.youtube.com/watch?v=I8WhikkiiSI
* Ruby, Node and Yarn: https://www.youtube.com/watch?v=C_xhTo9bw0s
* Microsoft Visual Studio Code: https://www.youtube.com/watch?v=rizfyb1-u6Q

## 2. Starting from rails new
Let's create our Rails application and open the code in the Visual Source Code
IDE.

```sh
rails new action_controller_demo
code action_controller_demo
```
Let's open the integrated terminal using Ctrl-\` (backtick) and notice that this
places the prompt in the `action_controller_demo` directory. So we can just
commit source code as follows:
```sh
git add .
git commit -m'rails new action_controller_demo'
```

## 3. Generating a User
Let's re-use the command we used last month to generate our `User` scaffold
first:
```sh
rails generate scaffold user username:string first_name:string last_name:string bio:text bicycles:integer gpa:float birth_date:date account_expiration:datetime earthling:boolean
```
Then we'll set our root route by making the following change to
`config/routes.rb`
```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'users#index' # ADD THIS LINE!
  resources :users
end
```
Finally, we'll migrate the database and push (commit) our code.
```sh
rails db:migrate
git add .
git commit -m'Generate a User scaffold, set the root route and migrate the database'
```

## 4. Actions/Methods
Let's look at the routes Rails provides via the `resources :users` line of
`config/routes.rb` by running the following command:
```sh
rails routes -c UsersController
```
You should see the following output:
```
   Prefix Verb   URI Pattern               Controller#Action
     root GET    /                         users#index
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
     user GET    /users/:id(.:format)      users#show
          PATCH  /users/:id(.:format)      users#update
          PUT    /users/:id(.:format)      users#update
          DELETE /users/:id(.:format)      users#destroy
```
Notice that the `UsersController` defines a method for each action in the right
most column of the output above **EXCEPT** the `DELETE` verb maps to the `destroy`
controller method. This is because `ActiveRecord` `destroy` runs callbacks and its
`delete` method does not. Since the desired effect of the controller method is to run
the callbacks the `ActionController` method shares the same name.
```ruby
# app/controllers/users_copntroller.rb
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:username, :first_name, :last_name, :bio, :bicycles, :gpa, :birth_date, :account_expiration, :earthling)
    end
end
```
Also of note is that the last five routes listed in the
`rails routes -c UsersController` output above begin with `/users/:id`. The
`:id` represents the `id` routing parameter that `ActionController` parses from
the requested URL and makes available via the `params` hash to the `set_user`
method (and all methods defined in the controller) which in turn fetches the
associated `User` from the database. Wel'll learn more about parameters shortly.

## 5. Debugging with Pry
Few things go as initially planned and any application of significant size will
exhibit "bugging" behavior from time to time. [Pry](https://github.com/pry/pry)
is a handy tool for debugging a running Rails app. Let's install the gem by
adding these lines before the `:development` group in the `Gemfile`
```ruby
# Gemfile
group :development, :test do
  gem 'pry'
end
```
Now install the gem with:
```sh
bundle install
```
We'll see Pry in action in the next section but for now let's commit the change:
```sh
git add .
git commit -m'Add Pry gem'
```

## 6. Parameters & Strong Parameters
Let's put Pry to work to see what parameters are passed to a Rails controller
method. Go ahead and start the Rails server (you should know how to by now) and
add the `binding.pry` line inside the `set_user` method in the UsersController.
```ruby
# app/controllers/users_controller.rb
def set_user
  binding.pry
  @user = User.find(params[:id]) # <<<--- params[:id] is a routing parameter.
end
```
Now visit the new user URL: http://localhost:3000/users/new and create a user.
Notice that the browser hangs when you submit the form. Now look at the terminal
instance where you started the Rails server. You should see output that looks
pretty close to this:
```
   66: def set_user
=> 67:   binding.pry
   68:   @user = User.find(params[:id])
   69: end

[1] pry(#<UsersController>)>
```
Enter the word `params` at the prompt and notice the output:
```
[1] pry(#<UsersController>)> params
=> <ActionController::Parameters {"controller"=>"users", "action"=>"show", "id"=>"1"} permitted: false>
```
Pry has opened a Ruby [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)
inside the running Rails application! If we're concerned about a line of code we
can drop `binding.pry` on the line before the bothersome code and then run it to
see what the line actually does. Let's try it. Enter `User.find(params[:id])`
and you'll see output that looks similar to this:
```
[2] pry(#<UsersController>)> User.find(params[:id])
  User Load (0.6ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
  ↳ (pry):2
=> #<User:0x00007fe4c4632238
 id: 1,
 username: "agilous",
 first_name: "Bill",
 last_name: "Barnett",
 bio: "Swell guy.",
 bicycles: 2,
 gpa: 3.4,
 birth_date: Mon, 08 Jun 2015,
 account_expiration: Thu, 14 Oct 2021 03:25:00 UTC +00:00,
 earthling: true,
 created_at: Wed, 14 Oct 2020 03:26:16 UTC +00:00,
 updated_at: Wed, 14 Oct 2020 03:26:16 UTC +00:00>
```
Notice that the attributes match the form data of the user you just created.

Finally, let's add a query parameter to the `User` show route and examine the
`params` hash via `Pry`: http://localhost:3000/users/new?admin=true
```
   66: def set_user
=> 67:   binding.pry
   68:   @user = User.find(params[:id])
   69: end

[1] pry(#<UsersController>)> params
=> <ActionController::Parameters {"admin"=>"true", "controller"=>"users", "action"=>"show", "id"=>"1"} permitted: false>
```
Note the `admin` query parameter has been added to the `params` hash. Also note
`permitted: false` after the parameter hash. More on that in the next section.

## 7. Strong Parameters
Let's move our `Pry` call to the `update` method on the line before the call to
`@user.update(user_params)` in the `UsersController`. Then we'll edit a `User`
and examine the output in the `Pry` REPL when we save the changes.
```
   42: def update
   43:   respond_to do |format|
=> 44:     binding.pry
   45:     if @user.update(user_params)
   46:       format.html { redirect_to @user, notice: 'User was successfully updated.' }
   47:       format.json { render :show, status: :ok, location: @user }
   48:     else
   49:       format.html { render :edit }
   50:       format.json { render json: @user.errors, status: :unprocessable_entity }
   51:     end
   52:   end
   53: end

[1] pry(#<UsersController>)> user_params
=> <ActionController::Parameters {"username"=>"agilous", "first_name"=>"Bill", "last_name"=>"Barnett", "bio"=>"Swell guy.", "bicycles"=>"2", "gpa"=>"3.4", "birth_date(1i)"=>"2015", "birth_date(2i)"=>"6", "birth_date(3i)"=>"8", "account_expiration(1i)"=>"2021", "account_expiration(2i)"=>"10", "account_expiration(3i)"=>"14", "account_expiration(4i)"=>"03", "account_expiration(5i)"=>"25", "earthling"=>"1"} permitted: true>
```
Notice here the `permitted: true` after the parameter hash at the end of the
output above. The `update` method uses Rails' Strong Parameters feature to
approve the parameters sent in from the browser for mass assignment (setting
multiple attributes at one time) via the `@user.update(user_params)` method call
which in turm calls the `user_params` private method. Let's take a look at it.
```ruby
# app/controllers/users_controller.rb
def user_params
  params.require(:user).permit(:username, :first_name, :last_name, :bio, :bicycles, :gpa, :birth_date, :account_expiration, :earthling)
end
```
Here ActionController requires that the browser submits request parameters
that contains a `user` key that is permitted to contain values for `username`,
`first_name`, `last_name`, `bio`, `bicycles`, `gpa`, `birth_date`,
`account_expiration` and `earthling`.

Let's try to sneak in that `admin=true` parameter by modifying the form. We'll
add a hidden input in the `User` form between the `earthling` input and the
form submit button like so:
```html
# app/views/users/_form.html.erb
<div class="field">
  <%= form.label :earthling %>
  <%= form.check_box :earthling %>
</div>

<input type="hidden" name="user[admin]" value=true>

<div class="actions">
  <%= form.submit %>
</div>
```
Now let's update a `User` again and take a look at the `params` hash and
`user_params` private method call.
```
[1] pry(#<UsersController>)> params
=> <ActionController::Parameters {"utf8"=>"✓", "_method"=>"patch", "authenticity_token"=>"QnRynC50CfLRbc0zkZfK6rS9n13Ftht5kdWIiHWnkYOdiQ83Kb3pn/wEaeUeaKSFLAiG3dd/wp/6s/OFcC3fNg==", "user"=>{"username"=>"agilous", "first_name"=>"Bill", "last_name"=>"Barnett", "bio"=>"Swell guy.", "bicycles"=>"2", "gpa"=>"3.4", "birth_date(1i)"=>"2015", "birth_date(2i)"=>"6", "birth_date(3i)"=>"8", "account_expiration(1i)"=>"2021", "account_expiration(2i)"=>"10", "account_expiration(3i)"=>"14", "account_expiration(4i)"=>"03", "account_expiration(5i)"=>"25", "earthling"=>"1", "admin"=>"true"}, "commit"=>"Update User", "controller"=>"users", "action"=>"update", "id"=>"1"} permitted: false>
[2] pry(#<UsersController>)> user_params
Unpermitted parameter: :admin
=> <ActionController::Parameters {"username"=>"agilous", "first_name"=>"Bill", "last_name"=>"Barnett", "bio"=>"Swell guy.", "bicycles"=>"2", "gpa"=>"3.4", "birth_date(1i)"=>"2015", "birth_date(2i)"=>"6", "birth_date(3i)"=>"8", "account_expiration(1i)"=>"2021", "account_expiration(2i)"=>"10", "account_expiration(3i)"=>"14", "account_expiration(4i)"=>"03", "account_expiration(5i)"=>"25", "earthling"=>"1"} permitted: true>
```
Notice that since the `admin` attribute is not present in the permitted
parameters in the `user_params` method definition ActionController has scrubbed
it from the results.

Finally, let's not forget to remove the `binding.pry` call from the `update`
method definition in the `UsersController` and the hidden input from the `User`
form.

## 8. Filters
The last remaining bit of Rails generated code in the `UsersController` that we
haven't yet discussed is the `before_action :set_user, only: [:show, :edit, :update, :destroy]`
line as the very first line within the controller. As the Rails guides will tell
you, "filters are methods that are run 'before, 'after' or 'around' a controller
action."

This line runs the `set_user` private method before the `show`, `edit`, `update`
and `delete` methods are run because each of those methods load the associated
`User` from the database by means of the `id` sent into the method by
ActionController as a request parameter. (See the last five auto-generated
routes in Section 4 above.)

## Further Viewing & Reading:
* Tim's MVC presentation at the July 2020 Cincinnati Ruby Brigade meeting: https://www.youtube.com/watch?v=XRwGB0TpB1g
* The ActionController Rails guide: https://guides.rubyonrails.org/action_controller_overview.html
