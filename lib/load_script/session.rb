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
    rescue Capybara::Poltergeist::TimeoutError
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
       :sign_up_as_borrower, :browse_categories, :browse_category_pages,
       :borrower_creates_loan_request, :lender_creates_loan]
    end

    def log_in(email="demo+horace@jumpstartlab.com", pw="password")
      log_out
      session.visit host
      session.click_on("Login")
      session.fill_in("session[email]", with: email)
      session.fill_in("session[password]", with: pw)
      session.click_link_or_button("Log In")
    end

    def browse_loan_requests
      puts "browse loan request"
      log_out
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
      puts "browse loan request"
    end

    def borrower_creates_loan_request
      puts "borrower creates loan request"
      sign_up_as_borrower
      session.click_on "Create Loan Request"
      session.within("#loanRequestModal") do
        session.fill_in("loan_request[title]", with: Faker::Commerce.product_name)
        session.fill_in("loan_request[description]", with: Faker::Company.catch_phrase)
        session.fill_in("loan_request[requested_by_date]", with: Faker::Time.between(7.days.ago, 3.days.ago))
        session.fill_in("loan_request[repayment_begin_date]", with:
          Faker::Time.between(3.days.ago, Time.now))
        session.select("Weekly", from: "loan_request[repayment_rate]")
        session.select("Agriculture", from: "loan_request[category]")
        session.fill_in("loan_request[amount]", with: "200")
      end
    end

    def lender_creates_loan
      puts "lender lends"
      sign_up_as_lender
      session.visit host
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
      session.click_on("Contribute $25")
      session.click_on("Basket")
      session.click_on("Transfer Funds")
    end

    def browse_categories
      log_in
      session.visit "#{host}/browse"
      session.find("#dropdownMenu1").click
      session.within("#categories") do
        session.all("a").sample.click
      end
      session.all(".lr-about").sample.click
    end

    def browse_category_pages
      log_in
      session.visit "#{host}/browse"
      session.find("#dropdownMenu1").click
      session.within("#categories") do
        session.all("a").sample.click
      end
      session.all(".pagination a").sample.click
    end

    def browse_pages_loan_requests
      log_in
      session.visit "#{host}/browse"
      session.all(".pagination a").sample.click
      session.all(".pagination a").sample.click
      session.all(".pagination a").sample.click
      session.all(".pagination a").sample.click
    end

    def individual_loan_request
      puts "individual loan request"
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
    end

    def log_out
      session.visit host
      if session.has_content?("Log out")
        session.find("#logout").click
      end
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def sign_up_as_lender(name = new_user_name)
      log_out
      session.visit "#{host}/browse"
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
      session.fill_in("user_name", with: name)
      session.fill_in("user_email", with: new_user_email(name))
      session.fill_in("user_password", with: "password")
      session.fill_in("user_password_confirmation", with: "password")
      session.click_link_or_button "Create Account"
      end
    end

    def sign_up_as_borrower(name = new_user_name)
      log_out
      session.visit "#{host}/browse"
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click
      session.within("#borrowerSignUpModal") do
      session.fill_in("user_name", with: name)
      session.fill_in("user_email", with: new_user_email(name))
      session.fill_in("user_password", with: "password")
      session.fill_in("user_password_confirmation", with: "password")
      session.click_link_or_button "Create Account"
      end
    end

    def categories
      ["Agriculture", "Education", "Community"]
    end

  end
end
