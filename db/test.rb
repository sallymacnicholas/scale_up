require 'populator'
require 'faker'
require 'pry'
module Test
  class Seed
    def run
      create_known_users
      create_borrowers(5)
      create_lenders(10)
      create_categories
      create_loan_requests_for_each_borrower(20)
      create_orders
    end

    def lenders
      User.where(role: 0)
    end

    def borrowers
      User.where(role: 1)
    end

    def orders
      Order.all
    end

    def create_known_users
      User.create(name: "Jorge", email: "jorge@example.com", password: "password")
      User.create(name: "Rachel", email: "rachel@example.com", password: "password")
      User.create(name: "Josh", email: "josh@example.com", password: "password", role: 1)
    end

    def create_lenders(quantity)
      User.populate(quantity) do |user|
        user.name = Faker::Name.name
        user.email = Faker::Internet.email
        user.password_digest = "$2a$10$I3tkspOkQVkZrZHCLUInM.I/M1OvPRTH.2/YyPwb/MbfJ2mLbbUPG" 
        user.role = 0 
        puts "created lender #{user.name}"
      end
    end

    def create_borrowers(quantity)
      User.populate(quantity) do |user|
        user.name = Faker::Name.name
        user.email = Faker::Internet.email
        user.password_digest = "$2a$10$I3tkspOkQVkZrZHCLUInM.I/M1OvPRTH.2/YyPwb/MbfJ2mLbbUPG" 
        user.role = 1
        puts "created borrower #{user.name}"
      end
    end

    def create_categories
      ["agriculture", "community", "education", "pizza", "food", 
        "teaching", "school", "turing", "category", "hey",
        "one", "two", "three", "four", "five", "six", "seven"].each do |cat|
        Category.create(title: cat, description: cat + " stuff")
      end
    end

    def create_loan_requests_for_each_borrower(quantity)
      b = borrowers
      LoanRequest.populate(quantity) do |lr|
        lr.title = Faker::Commerce.product_name
        lr.description = Faker::Company.catch_phrase
        lr.amount = 200
        lr.status = [0, 1].sample
        lr.requested_by_date = Faker::Time.between(7.days.ago, 3.days.ago)
        lr.repayment_begin_date = Faker::Time.between(3.days.ago, Time.now)
        lr.repayment_rate = 1
        lr.contributed = 0
        lr.repayed = 0
        lr.user_id = b.all.sample.id
        LoanRequestsCategory.populate(2) do |lrcat|
          lrcat.loan_request_id = lr.id
          lrcat.category_id = Category.all.sample.id
        end
      end
    end

    def create_orders
      loan_requests = LoanRequest.take(50000)
      possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
      lenders = User.where(role: 0)
      loan_requests.each do |request|
        lender = lenders.sample
        order = Order.create(cart_items:
                             { "#{request.id}" => possible_donations.sample },
                             user_id: lender.id)
        order.update_contributed(lender)
        puts "Created Order for Request #{request.title} by Lender #{lender.name}"
      end
    end
  end
end