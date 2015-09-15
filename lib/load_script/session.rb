require "logger"
require "pry"
require "capybara"
require 'capybara/poltergeist'
require "faker"
require "active_support"
require "active_support/core_ext"

module LoadScript
  class Session
    include Capybara::DSL
    attr_reader :host
    def initialize(host = nil)
      Capybara.default_driver = :poltergeist
      @host = host || "http://localhost:3000"
    end

    def logger
      @logger ||= Logger.new("./log/requests.log")
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      while true
        run_action(actions.sample)
      end
    end

    def run_action(name)
      benchmarked(name) do
        send(name)
      end
    rescue Capybara::Poltergeist::TimeoutError,
      Capybara::Poltergeist::StatusFailError
      logger.error("Timed out executing Action: #{name}. Will continue.")
    end

    def benchmarked(name)
      logger.info "Running action #{name}"
      start = Time.now
      val = yield
      logger.info "Completed #{name} in #{Time.now - start} seconds"
      val
    end

    def actions
    [:browse_loan_requests, :browse_pages_loan_requests, :sign_up_as_lender,
     :sign_up_as_borrower, :browse_categories, :browse_category_pages]
    end

    def log_in(email="demo+horace@jumpstartlab.com", pw="password")
      puts "log in"
      log_out
      session.visit host
      session.click_link("Log In")
      session.fill_in("email_address", with: email)
      session.fill_in("password", with: pw)
      session.click_link_or_button("Login")
    end

    def browse_loan_requests
      puts "browse loan request"
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
      puts "browse loan request"
    end

    def borrower_creates_loan_request
      puts "borrower creates loan request"
      sign_up_as_borrower
      session.click_on "Create Loan Request"
      session.within("#loanRequestModal") do
        session.fill_in("title", with: Faker::Commerce.product_name)
        session.fill_in("description", with: Faker::Company.catch_phrase)
        session.fill_in("image_url", with: DefaultImages.random)
      end
    end

    def browse_categories
      puts "browse categories"
      session.visit "#{host}/browse"
      session.find("#dropdownMenu1").click
      session.within("#categories") do
        session.all("a").sample.click
      end
      session.all(".lr-about").sample.click
      puts "browse categories"
    end

    def browse_category_pages
      puts "browse category pages"
      session.visit "#{host}/browse"
      session.find("#dropdownMenu1").click
      session.within("#categories") do
        session.all("a").sample.click
      end
      session.all(".pagination a").sample.click
    end
    
    def browse_pages_loan_requests
      puts "browse pages loans"
      session.visit "#{host}/browse"
      session.all(".pagination a").sample.click
      session.all(".pagination a").sample.click
      session.all(".pagination a").sample.click
      session.all(".pagination a").sample.click
      puts "browse page lr"
    end

    def log_out
      puts 'logout'
      session.visit host
      if session.has_content?("Log out")
        session.find("#logout").click
      end
      puts 'end of logout'
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def sign_up_as_lender(name = new_user_name)
      puts "sign up as lender"
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
      puts "sign up as lender"
    end

    def sign_up_as_borrower(name = new_user_name)
      puts "sign up as borrower"
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click
      session.within("#borrowerSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
      puts "sign up as borrower"
    end

    def categories
      ["Agriculture", "Education", "Community"]
    end
  end
end
