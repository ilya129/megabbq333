FactoryBot.define do
  factory :event do
    association :user
    title { 'Барбекю' }
    description { 'Гриль' }
    address { 'Москва, Красная площадь' }
    datetime { DateTime.parse('01.05.2019 09:00') }
  end
end
