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

    # Then run bundle install
    bundle install

    # Install ActiveAdmin
    rails generate active_admin:install
    rails db:migrate
    rails db:seed
    rails server
    ```

    Navigate to /admin and log in with the default username and password to start managing quotes.</br></br>

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
