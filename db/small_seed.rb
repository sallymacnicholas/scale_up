require 'populator'
require 'faker'
module SmallSeed
  class Seed
    def run
      create_known_users
      create_borrowers(100)
      create_lenders(1000)
      create_categories
      create_loan_requests_for_each_borrower(100)
      create_orders(100)
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
      cats = Category.all
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
        lr.user_id = b.sample.id
        LoanRequestsCategory.populate(4) do |lrcat|
          lrcat.loan_request_id = lr.id
          lrcat.category_id = cats.sample.id
        end
      end
    end

    def create_orders(num)
      possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
      num.times do
          lender = lenders.sample
          lr = LoanRequest.all.sample
          order = Order.create(cart_items:
                               { "#{lr.id}" => possible_donations.sample },
                               user_id: lender.id)
          order.update_contributed(lender)
          puts "Created Order for Request #{lr.title} by Lender #{lender.name}"
      end
    end
  end
end
