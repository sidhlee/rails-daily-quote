# Rails Daily Quote

A simple project to learn ruby and rails.

## MVP

- I can add quote (text, author, tags and topic) via admin.
- I can edit and delete a quote via admin.
- The app runs cronjob at 5 am EST every morning to send me an email with 3 random quotes from the database.
- The app is deployed via render.com
- The app is connected to the domain, leehayoun.com

## Steps (Copilot)

This guide assumes you have a basic Rails project setup and are familiar with Ruby on Rails development practices.

1. **Setting Up the Author, Quote, and Tag Models**
    First, generate the `Author` model with fields for the author's name and image URL. Each author can have many quotes.

      ```txt
      rails generate model Author name:string image_url:string
      rails db:migrate
      ```

    Next, create the `Quote` model to store quotes. This model will include field for text, and it will reference the `Author` model to establish a one-to-many relationship.

      ```txt
      rails generate model Quote text:text author:references
      rails db:migrate
      ```

    Finally, generate the `Tag` model for managing tags. Since a quote can have many tags and a tag can belong to many quotes, you'll also need to create a join table to establish a many-to-many relationship between `Quote` and `Tag`.

      ```txt
      rails generate model Tag name:string
      rails db:migrate
      rails generate migration CreateJoinTableQuoteTag quote:references tag:references
      rails db:migrate
      ```

    The above code raises the following error:

      ```txt
      == 20240627215053 CreateJoinTableQuoteTag: migrating ==========================
      -- create_join_table(:quotes, :tags)
      rails aborted!
      StandardError: An error has occurred, this and all later migrations canceled:

      you can't define an already defined column 'quote_id'.
      /Users/hayounlee/Projects/rails-daily-quote/db/migrate/20240627215053_create_join_table_quote_tag.rb:4:in `block in change'
      /Users/hayounlee/Projects/rails-daily-quote/db/migrate/20240627215053_create_join_table_quote_tag.rb:3:in `change'

      Caused by:
      ArgumentError: you can't define an already defined column 'quote_id'.
      /Users/hayounlee/Projects/rails-daily-quote/db/migrate/20240627215053_create_join_table_quote_tag.rb:4:in `block in change'
      /Users/hayounlee/Projects/rails-daily-quote/db/migrate/20240627215053_create_join_table_quote_tag.rb:3:in `change'
      Tasks: TOP => db:migrate
      (See full trace by running task with --trace)
      ```

    You can resolve this by removing lines that defines references explicitly from the migration file.

      ```ruby
      class CreateJoinTableQuoteTag < ActiveRecord::Migration[7.0]
        def change
          create_join_table :quotes, :tags do |t|
            # This was generated but causes ArgumentError: you can't define an already defined column 'quote_id'.
            # and you can't define an already defined column 'quote_id'.
            # t.references :quote, null: false, foreign_key: true
            # t.references :tag, null: false, foreign_key: true
            t.index :quote_id
            t.index :tag_id
          end
        end
      end
      ```

    Next steps involve setting up the model associations correctly:

    - In `quote.rb`:

    ```ruby
    class Quote < ApplicationRecord
      belongs_to :author
      has_and_belongs_to_many :tags
    end
    ```

    - In `tag.rb`:

    ```ruby
    class Tag < ApplicationRecord
      has_and_belongs_to_many :quotes
    end
    ```

    This setup assumes you do not need to store additional information in the join table or work with the join table as its own entity. If later you find that you need to add more fields to the join table (e.g., timestamps, counters, or any other attributes that describe the relationship further), you would then need to migrate to a has_many :through relationship, which involves creating a model for the join table and adjusting your associations.

    ```ruby
    class Quote < ApplicationRecord
      belongs_to :author
      has_many :quote_tags
      has_many :tags, through: :quote_tags
    end

    class Tag < ApplicationRecord
      has_many :quote_tags
      has_many :quotes, through: :quote_tags
    end

    class QuoteTag < ApplicationRecord
      belongs_to :quote
      belongs_to :tag
    end
    ```

2. **Setting Up Admin Interface**
For adding, editing, and deleting quotes via an admin interface, you can use a gem like ActiveAdmin or RailsAdmin. Here's how to set up ActiveAdmin as an example:

    ```txt
    # Add to your Gemfile
    gem 'activeadmin'
    gem 'devise' # authentication lib
    gem 'sassc-rails' # SASS compiler

    # Then run bundle install
    bundle install

    # Install ActiveAdmin
    rails generate active_admin:install
    rails db:migrate
    # Runs the code found in the db/seeds.rb to create admin user
    rails db:seed
    rails server
    ```

    To add, edit, and delete quotes on the admin page using ActiveAdmin in your Rails application, follow these steps:

    1. **Register the Quote Model with ActiveAdmin** Generate an ActiveAdmin resource for the `Quote` model to manage it through the admin interface.

        ```txt
        rails generate active_admin:resource Quote
        ```

    2. **Customize the Quote Admin Resource** Edit the file app/admin/quotes.rb to customize the admin interface for Quote. Here's an example setup:

        ```ruby
        ActiveAdmin.register Quote do
          permit_params :text, :author_id, tag_ids: []

          index do
            selectable_column
            id_column
            column :text
            column :author
            column :tags do |quote|
              quote.tags.map(&:name).join(", ")
            end
            actions
          end

          filter :text
          filter :author
          filter :tags

          form do |f|
            f.inputs do
              f.input :text
              f.input :author
              f.input :tags, as: :check_boxes
            end
            f.actions
          end

          show do
            attributes_table do
              row :text
              row :author
              row :tags do |quote|
                quote.tags.map(&:name).join(", ")
              end
            end
          end
        end
        ```

       This setup allows you to:
       - **List Quotes**: Display quotes with their ID, text, author, and tags in the index page.
       - **Filter Quotes**: Filter quotes by text, author, or tags.
       - **Add/Edit** Quotes: Create or edit quotes with text, select an author from a dropdown, and associate tags using checkboxes.
       - **Delete Quotes**: Remove quotes from the database.

    3. Generate ActiveAdmin resources for `Author` and `Tag` models:

        ```txt
          rails generate active_admin:resource Author
          rails generate active_admin:resource Tag
        ```

        Running these commands will create two new files in `app/admin` directory:
        - `app/admin/authors.rb`
        - `app/admin/tags.rb`

    4. **Start Your Rails Server** Run `rails server` and navigate to `/admin` on your browser. Log in with your admin user credentials. You should now be able to add, edit, and delete quotes through the ActiveAdmin interface. </br></br>

3. **Setting Up Cron Job for Daily Emails**
To send an email with 3 random quotes from the database every morning at 5 am EST, you can use the whenever gem to manage cron jobs and Action Mailer for sending emails.

    - Action Mailer Setup: Follow the Rails guide to set up Action Mailer with your email provider.

    - Whenever Gem Setup:

    ```txt
    # Add to your Gemfile
    gem 'whenever', require: false

    # Then run bundle install
    bundle install

    # Generate the schedule file
    wheneverize .

    # Edit config/schedule.rb to add your task
    every 1.day, at: '5:00 am' do
      runner "QuoteMailer.daily_email.deliver_now"
    end

    # Update crontab
    whenever --update-crontab
    ```

    - QuoteMailer Setup:

    ```ruby
    # app/mailers/quote_mailer.rb
    class QuoteMailer < ApplicationMailer
      default from: 'your_email@example.com'

      def daily_email
        @quotes = Quote.order("RANDOM()").limit(3)
        mail(to: 'your_email@example.com', subject: 'Daily Quotes')
      end
    end
    ```

4. **Deployment via Render.com**

    - Sign up or log in to Render.com.
    - Click on "New +", then select "Web Service".
    - Connect your GitHub or GitLab repository containing your Rails project.
    - Follow the prompts to configure your build & deploy settings. Render will automatically detect it's a Rails project.
    - Set the environment variables as needed (e.g., database URL, email credentials).
    - Click "Create Web Service". Render will deploy your app.

5. **Connecting to Domain**
    After deployment, you can connect your app to a custom domain:

    On Render.com, go to your service's "Settings" tab.
    Scroll down to "Custom Domains" and click "Add a Custom Domain".
    Enter your domain (e.g., leehayoun.com) and follow the instructions to update your DNS settings with your domain registrar.
6. **Final Steps**
    Test your application thoroughly to ensure everything works as expected.
    Make sure your admin interface is secure.
    Monitor your application's performance and adjust resources on Render.com as necessary.
    This guide covers the basics to get you started. Each step may require additional configuration based on your specific requirements and the tools/services you choose to use.

## Decrypting credential with master.key file

In Rails 5.1 and later versions, the secrets.yml file was replaced by encrypted credentials for managing secrets. Instead of secrets.yml, you should look for `config/credentials.yml.enc` and `config/master.key`. The `credentials.yml.enc` file contains encrypted secrets that can be edited with the Rails command `rails credentials:edit`. The master.key file is used to decrypt `credentials.yml.enc` and should not be committed to your version control system (it's included in the `.gitignore` file by default).

## Moving to Superbase

### Step 1: Add pg Gem

Ensure the pg gem is in your Gemfile since Supabase is PostgreSQL compatible.

```ruby
gem 'pg'
```

Run `bundle install` to install the gem.

### Step 2: Update `database.yml`

Modify your `config/database.yml` to use PostgreSQL settings that match your Supabase database credentials. You can find these credentials in your Supabase project settings under the "Database" section.

```yml
default: &default
  adapter: postgresql
  encoding: unicode
  # For Rails 6.1 and up, `prepared_statements: true` might need to be set to false
  # prepared_statements: false
  # <%= %> is ERB (Embedded Ruby) templates. { 5 } provides default value
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: <%= ENV['SUPABASE_HOST'] %>
  user: <%= ENV['SUPABASE_USER'] %>
  password: <%= ENV['SUPABASE_PASSWORD'] %>
  port: <%= ENV['SUPABASE_PORT'] %>
  database: <%= ENV['SUPABASE_DB'] %>

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default
```

### Step 3: Set Environment Variables

Set the environment variables (`SUPABASE_HOST`, `SUPABASE_USER`, `SUPABASE_PASSWORD`, `SUPABASE_PORT`, `SUPABASE_DATABASE`) in your development and production environment. This can be done in a `.env` file for development (don't forget to add `.env` to your `.gitignore` file to avoid exposing your credentials).

For production, set these variables in your hosting environment's configuration section.

### Step 4: Migrate Database

Run your migrations to set up your database schema in Supabase:

```txt
rails db:create db:migrate
```

### Step 5: Test the Connection

Run your Rails server and perform some database operations to ensure everything is connected properly and working as expected.

### Additional Considerations

- **Security**: Ensure your Supabase database is secured and only accessible from your application's IP addresses or secure environments.
- **Environment Variables**: Never hard-code your database credentials in your application. Always use environment variables.
- **Supabase Features**: Supabase provides more than just a database. Explore other features like authentication, storage, and real-time subscriptions that you might want to integrate into your Rails application.
