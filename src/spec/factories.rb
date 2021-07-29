FactoryGirl.define do
  factory :user do
    sequence(:name)   { |n| "Person #{n}"}
    sequence(:email)  { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
    
    factory :activated_user do
      activated true

      factory :admin do
        admin true
      end

    end
  end

  factory :wrong_user do
    sequence(:name)   { |n| "Person #{n}"}
    email "wrong@example.com"
    # sequence(:email)  { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
    
    activated true

  end

end